**大家好，我是不才陈某~**

是的，今早一到公司就收到了机器人的告警，就是上文中的自动对账功能，从异常日志来看是数据库连接已关闭，然后我在解决这个问题的过程中发现了几个问题，不急，听我一一道来
![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f6c3219b14ed4779a624035f259efbdb~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.image)

## 异常被try后没有继续抛出，导致继续执行后续操作

我们看到前文示例代码会发现我们在 try 之后只是 rollback 了，对于异常也只是打印一下并没有继续抛出。
![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f12df08cbb1f41848c665002e5066bc1~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.image)



那么就会导致一种情况：假设你在 Service 层中调用多个调用数据库的修改方法，那么第一个操作失败后异常没有抛出，Service 层不知道，就会继续向后面执行，修复很简单，只需要将异常抛出即可：

```java
// 案例1：参考MybatisPlus的com.baomidou.mybatisplus.extension.toolkit.SqlHelper##executeBatch()实现
batchSqlSession.rollback();
Throwable unwrapped = ExceptionUtil.unwrapThrowable(e);
if (unwrapped instanceof RuntimeException) {
    MyBatisExceptionTranslator myBatisExceptionTranslator
            = new MyBatisExceptionTranslator(sqlSessionFactory.getConfiguration().getEnvironment().getDataSource(), true);
    throw Objects.requireNonNull(myBatisExceptionTranslator.translateExceptionIfPossible((RuntimeException) unwrapped));
}
throw new CommonException(unwrapped);

// 案例2：简单来说，只要能把异常抛出去即可，并不定需要像上面这么复杂
batchSqlSession.rollback();
throw new CustomException(e);
```

## 大事务/长事务导致 connection closed

### 代码场景

我们来看一段业务功能的伪代码，大致如下：

```java
@Transactional(rollbackFor = Exception.class)
@Override
public Integer billCheck() {
    // 获取对应的策略
    策略 = getStrategy();
    // 前置参数校验
    if (必要参数是否存在){
        return false;
    }
    try {
        // 解析文件
        文件里的数据集合 = 策略.parseFile(file);
        // 将文件里的数据插入数据库表
        影响的行数 = 策略.handleFileData(文件里的数据);
        if (影响的行数 > 0) {
            // 将文件里的数据和本地的数据进行对比操作
            对比后的数据 = 策略.doBillCheck(参数);
            // 将对比的结果分开插入到数据库中
            batchUtils.batchUpdateOrInsert(成功的数据,
                    某Mapper.class,
                    (billErr, mapper) -> mapper.insert(data));
            batchUtils.batchUpdateOrInsert(失败的数据,
                    某Mapper.class,
                    (billErr, mapper) -> mapper.insert(data));
            batchUtils.batchUpdateOrInsert(需要更新的数据,
                    某Mapper.class,
                    (billErr, mapper) -> mapper.update(data));
        }
        // 发送企业微信机器人通知
        策略.sendRobotMessage();
        log.info("耗时：{}毫秒", 耗时);
    } catch (Exception e) {
        log.error("对账出错", e);
        throw new CommonException("对账出错");
    }
    return 影响的行数;
}
```

我们梳理一下，这是一个普通的模板方法 + 策略模式的应用，因为业务场景中不管是哪个通道的文件都会必经如下几个步骤，所以就将其抽象了。
我们可以发现这个方法里面做了很多数据库操作，并且使用了声明式事务注解，然后里面大致有如下几个步骤：

1. 解析文件
2. 将文件里的数据插入数据库表
3. 将文件里的数据和本地的数据进行对比操作
4. 将对比的结果分开插入到数据库中

然后我们再来看一段配置，它来自 **druid** 连接池框架，如下：

```yaml
spring:
  datasource:
    druid:
      remove-abandoned: true
      ## 单位：秒
      remove-abandoned-timeout: 60
      log-abandoned: true
```

以上三条属性一般是用来**防止连接泄露**的，说明如下：

- **removeAbandoned**：要求获取到连接后，如果空闲时间超过 `removeAbandonedTimeoutMillis` 秒后没有 close，druid 会强制回收，默认false；
- **logAbandoned**：如果回收了连接，是否要打印一条 log，默认 false；
- **removeAbandonedTimeoutMillis**：连接回收的超时时间，默认5分钟；

看到这里我想大部分同学可能已经知道是什么问题了，没错，**肯定是因为拿到了连接，但拿的时间超过了这个限制，导致 druid 直接强制回收了该连接**，但是知根知底方能百战百胜，这么好的机会怎么能不深入了解一下？

### 什么时候获取的连接？

是的，既然是连接超时被关闭，那我们肯定要先找到是什么时候拿到的连接，是方法中第一次操作数据库【将文件里的数据插入数据库表】的时候？那当然不是，我们知道 Mybatis 有一个 Executor_ _接口，感兴趣的可以自行了解，它定义了数据库操作的基本方法，它才是SQL语句幕后的执行者，我们直接来看获取连接的地方 `org.apache.ibatis.executor.BaseExecutor##getConnection`：

```java
protected Connection getConnection(Log statementLog) throws SQLException {
    Connection connection = transaction.getConnection();
    if (statementLog.isDebugEnabled()) {
        return ConnectionLogger.newInstance(connection, statementLog, queryStack);
    } else {
        return connection;
    }
  }
```

我们可以看出来，我们是通过 `Transaction` 去获取连接的，但如果我们是第一次操作的时候才去获取的连接，那怎么会连接超时呢？所以我初步推断是开启事务的时候可能就已经获取连接了，那我们来求证一下，来到 Spring 的事务管理器 **PlatformTransactionManager**，Mybatis 用的是它的实现类 **DataSourceTransactionManager**, 然后我们一路跟 `getTransaction` 方法来到 **AbstractPlatformTransactionManager##getTransaction**，再到 **DataSourceTransactionManager##doBegin**

```java
public final TransactionStatus getTransaction(@Nullable TransactionDefinition definition) throws TransactionException {
    // 省略无关代码 ...
    doBegin(transaction, definition);
    // 省略无关代码 ...
}

@Override
protected void doBegin(Object transaction, TransactionDefinition definition) {
    DataSourceTransactionObject txObject = (DataSourceTransactionObject) transaction;
    Connection con = null;

    try {
        // 如果数据源事务对象的ConnectionHolder为null或者是事务同步的  
        if (!txObject.hasConnectionHolder() ||
                txObject.getConnectionHolder().isSynchronizedWithTransaction()) {
            // 获取当前数据源的数据库连接  
            Connection newCon = obtainDataSource().getConnection();
            if (logger.isDebugEnabled()) {
                logger.debug("Acquired Connection [" + newCon + "] for JDBC transaction");
            }
            txObject.setConnectionHolder(new ConnectionHolder(newCon), true);
        }
}
```

就是这！它其实在进入方法的最开始，开启事务的时候就已经获取了连接，然后由于【解析文件】耗时过长，导致整个方法的执行时间超过了 60s 被强制回收连接，但你以为这就结束了？没错，当时出现这个问题的时候，我还手动触发了一次，结果第二次通过了，你说诡异不诡异？两次执行的时间都是 90s。

### druid removeAbandoned 背后的秘密

所以我们继续看一下 druid 是怎么强制回收连接的，Druid每隔 **timeBetweenEvictionRunsMillis**（默认1分钟）会调用DestroyTask，在这里会判断是否可以回收泄露的连接，就是因为它是1分钟执行一次，所以可能第二次正好它执行的时候还没超过 60s，所以这次简直就是玄学了啊。

```java
public class DestroyTask implements Runnable {
    public DestroyTask() {

    }

    @Override
    public void run() {
        shrink(true, keepAlive);
        // 判断removeAbandoned是否为true，默认是false
        if (isRemoveAbandoned()) {
            removeAbandoned();
        }
    }

}
```

然后我们看到 removeAbandoned 方法，这里面有一段代码如下：

```java
for (; iter.hasNext();) {
    DruidPooledConnection pooledConnection = iter.next();

    // 判断该连接是否还在运行，只回收不运行的连接
    // Druid会在连接执行query,update的时候设置为正在运行，
    // 并在回收后设置为不运行
    if (pooledConnection.isRunning()) {
        continue;
    }

    long timeMillis = (currrentNanos - pooledConnection.getConnectedTimeNano()) / (1000 * 1000);

    //判断连接借出去的时间大小
    if (timeMillis >= removeAbandonedTimeoutMillis) {
        iter.remove();
        pooledConnection.setTraceEnable(false);
        abandonedList.add(pooledConnection);
    }
}

//判断是否要记录连接回收日志，这个很重要，可以及时发现项目中是否有连接泄露
if (isLogAbandoned()) {
    StringBuilder buf = new StringBuilder();
    buf.append("abandon connection, owner thread: ");
    buf.append(pooledConnection.getOwnerThread().getName());
    buf.append(", connected at : ");
    buf.append(pooledConnection.getConnectedTimeMillis());
    buf.append(", open stackTrace\n");
}
```

是的，如果你的连接被强制回收了的话，你只需要将 `LogAbandoned` 设置为 true，就可以通过日志看到相关信息了

### 解决方案

到这，问题就基本都发现了，那么我最后是怎么解决的呢？原本我是想的把不需要事务的动作抽离出来新建一个方法，后面我发现这样子好像模板方法并不好使了，我就采用了**编程式事务**，感兴趣的可以自己在了解一下，最后伪代码如下：

```java
@Autowired
private TransactionTemplate transactionTemplate;

@Transactional(rollbackFor = Exception.class)
@Override
public Integer billCheck() {
    // 获取对应的策略
    策略 = getStrategy();
    // 前置参数校验
    if (必要参数是否存在){
        return false;
    }
    try {
        // 解析文件
        文件里的数据集合 = 策略.parseFile(file);
        // 编程式事务
        影响的行数 = transactionTemplate.execute(transactionStatus -> {
            // 将文件里的数据插入数据库表
            return 策略.handleFileData(文件里的数据);
        });
        if (影响的行数 > 0) {
            // 将文件里的数据和本地的数据进行对比操作
            对比后的数据 = 策略.doBillCheck(参数);
            // 编程式事务
            transactionTemplate.execute(transactionStatus -> {
                // 将对比的结果分开插入到数据库中
                batchUtils.batchUpdateOrInsert(成功的数据,
                        某Mapper.class,
                        (billErr, mapper) -> mapper.insert(data));
                batchUtils.batchUpdateOrInsert(失败的数据,
                        某Mapper.class,
                        (billErr, mapper) -> mapper.insert(data));
                batchUtils.batchUpdateOrInsert(需要更新的数据,
                        某Mapper.class,
                        (billErr, mapper) -> mapper.update(data));
                return Boolean.TRUE;
            });
        }
        // 发送企业微信机器人通知
        策略.sendRobotMessage();
        log.info("耗时：{}毫秒", 耗时);
    } catch (Exception e) {
        log.error("对账出错", e);
        throw new CommonException("对账出错");
    }
    return 影响的行数;
}
```

这样子，我们将解析文件和对比数据（只是查询）这种耗时操作放在了事务外，并且将原本一个事务里的操作拆成了两个小事务，这样子基本就避免了大事务的问题了，完结撒花~

## 大事务/长事务可能造成的影响

- 并发情况下，数据库连接池容易被撑爆
- 锁定太多的数据，造成大量的阻塞和锁超时
- 执行时间长，容易造成主从延迟
- 回滚所需要的时间比较长
- undo log膨胀

所以在业务涉及中，你一定要对大事务特别对待，比如业务设计时，把大事务拆成小事务。

## 总结

**声明式事务有一个局限，那就是他的最小粒度要作用在方法上**！所以大家在用的时候要格外格外注意大事务的问题，尽量避免在事务中做一些无关数据库的操作，比如RPC远程调用、文件解析等，都是血泪的教训啊！！
