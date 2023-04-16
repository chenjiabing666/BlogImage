**大家好，我是不才陈某~**

Spring Boot 自定义线程池实现异步开发相信看过陈某的文章都了解，但是在实际开发中需要在父子线程之间传递一些数据，比如用户信息，链路信息等等

比如用户登录信息使用ThreadLocal存放保证线程隔离，代码如下：

```java
/**
 * @author 公众号：码猿技术专栏
 * @description 用户上下文信息
 */
public class OauthContext {
    private static  final  ThreadLocal<LoginVal> loginValThreadLocal=new ThreadLocal<>();

    public static  LoginVal get(){
        return loginValThreadLocal.get();
    }
    public static void set(LoginVal loginVal){
        loginValThreadLocal.set(loginVal);
    }
    public static void clear(){
        loginValThreadLocal.remove();
    }
}
```

那么子线程想要获取这个LoginVal如何做呢？

今天就来介绍几种优雅的方式实现Spring Boot 内部的父子线程的数据传递。

![](https://www.java-family.cn/BlogImage/20230103223443.png)



## 1. 手动设置

每执行一次异步线程都要分为两步：

1. 获取父线程的LoginVal
2. 将LoginVal设置到子线程，达到复用

代码如下：

```java
public void handlerAsync() {
        //1. 获取父线程的loginVal
        LoginVal loginVal = OauthContext.get();
        log.info("父线程的值：{}",OauthContext.get());
        CompletableFuture.runAsync(()->{
            //2. 设置子线程的值，复用
           OauthContext.set(loginVal);
           log.info("子线程的值：{}",OauthContext.get());
        });
    }
```

虽然能够实现目的，但是每次开异步线程都需要手动设置，重复代码太多，看了头疼，你认为优雅吗？

## 2. 线程池设置TaskDecorator

TaskDecorator是什么？官方api的大致意思：这是一个执行回调方法的装饰器，主要应用于传递上下文，或者提供任务的监控/统计信息。

知道有这么一个东西，如何去使用？

TaskDecorator是一个接口，首先需要去实现它，代码如下：

```java
/**
 * @author 公众号：码猿技术专栏
 * @description 上下文装饰器
 */
public class ContextTaskDecorator implements TaskDecorator {
    @Override
    public Runnable decorate(Runnable runnable) {
        //获取父线程的loginVal
        LoginVal loginVal = OauthContext.get();
        return () -> {
            try {
                // 将主线程的请求信息，设置到子线程中
                OauthContext.set(loginVal);
                // 执行子线程，这一步不要忘了
                runnable.run();
            } finally {
                // 线程结束，清空这些信息，否则可能造成内存泄漏
                OauthContext.clear();
            }
        };
    }
}
```

这里我只是设置了LoginVal，实际开发中其他的共享数据，比如`SecurityContext`，`RequestAttributes`....

`TaskDecorator`需要结合线程池使用，实际开发中异步线程建议使用线程池，只需要在对应的线程池配置一下，代码如下：

```java
@Bean("taskExecutor")
public ThreadPoolTaskExecutor taskExecutor() {
        ThreadPoolTaskExecutor poolTaskExecutor = new ThreadPoolTaskExecutor();
        poolTaskExecutor.setCorePoolSize(xx);
        poolTaskExecutor.setMaxPoolSize(xx);
        // 设置线程活跃时间（秒）
        poolTaskExecutor.setKeepAliveSeconds(xx);
        // 设置队列容量
        poolTaskExecutor.setQueueCapacity(xx);
        //设置TaskDecorator，用于解决父子线程间的数据复用
        poolTaskExecutor.setTaskDecorator(new ContextTaskDecorator());
        poolTaskExecutor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());
        // 等待所有任务结束后再关闭线程池
        poolTaskExecutor.setWaitForTasksToCompleteOnShutdown(true);
        return poolTaskExecutor;
    }
```

此时业务代码就不需要去设置子线程的值，直接使用即可，代码如下：

```java
public void handlerAsync() {
        log.info("父线程的用户信息：{}", OauthContext.get());
        //执行异步任务，需要指定的线程池
        CompletableFuture.runAsync(()-> log.info("子线程的用户信息：{}", OauthContext.get()),taskExecutor);
    }
```

来看一下结果，如下图：

![](https://www.java-family.cn/BlogImage/20230103150501.png)

这里使用的是`CompletableFuture`执行异步任务，使用`@Async`这个注解同样是可行的。

> **注意**：无论使用何种方式，都需要指定线程池



## 3. InheritableThreadLocal

这种方案不建议使用，InheritableThreadLocal虽然能够实现父子线程间的复用，但是在线程池中使用会存在复用的问题，具体的可以看陈某之前的文章：[微服务中使用阿里开源的TTL，优雅的实现身份信息的线程间复用](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247512365&idx=1&sn=f847a72fecda9852ad23879e78e07af2&chksm=fcf76ee0cb80e7f6df3c15868f89a7722db5152625b2e60c2ba78f4bc14112fbc45280e52fac&scene=178&cur_album_id=2042874937312346114#rd)

这种方案使用也是非常简单，直接用InheritableThreadLocal替换ThreadLocal即可，代码如下：

```java
/**
 * @author 公众号：码猿技术专栏
 * @description 用户上下文信息
 */
public class OauthContext {
    private static  final  InheritableThreadLocal<LoginVal> loginValThreadLocal=new InheritableThreadLocal<>();

    public static  LoginVal get(){
        return loginValThreadLocal.get();
    }
    public static void set(LoginVal loginVal){
        loginValThreadLocal.set(loginVal);
    }
    public static void clear(){
        loginValThreadLocal.remove();
    }
}
```



## 4. TransmittableThreadLocal

TransmittableThreadLocal是阿里开源的工具，弥补了InheritableThreadLocal的缺陷，在使用线程池等会池化复用线程的执行组件情况下，提供`ThreadLocal`值的传递功能，解决异步执行时上下文传递的问题。

使用起来也是非常简单，添加依赖如下：

```xml
<dependency>
	<groupId>com.alibaba</groupId>
	<artifactId>transmittable-thread-local</artifactId>
	<version>2.14.2</version>
</dependency>
```

OauthContext改造代码如下：

```java
/**
 * @author 公众号：码猿技术专栏
 * @description 用户上下文信息
 */
public class OauthContext {
    private static  final TransmittableThreadLocal<LoginVal> loginValThreadLocal=new TransmittableThreadLocal<>();

    public static  LoginVal get(){
        return loginValThreadLocal.get();
    }
    public static void set(LoginVal loginVal){
        loginValThreadLocal.set(loginVal);
    }
    public static void clear(){
        loginValThreadLocal.remove();
    }
}
```

关于TransmittableThreadLocal想深入了解其原理可以看陈某之前的文章：[微服务中使用阿里开源的TTL，优雅的实现身份信息的线程间复用](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247512365&idx=1&sn=f847a72fecda9852ad23879e78e07af2&chksm=fcf76ee0cb80e7f6df3c15868f89a7722db5152625b2e60c2ba78f4bc14112fbc45280e52fac&scene=178&cur_album_id=2042874937312346114#rd)，应用还是非常广泛的



## TransmittableThreadLocal原理

从定义来看，`TransimittableThreadLocal`继承于`InheritableThreadLocal`，并实现`TtlCopier`接口，它里面只有一个`copy`方法。所以主要是对`InheritableThreadLocal`的扩展。

```java
public class TransmittableThreadLocal<T> extends InheritableThreadLocal<T> implements TtlCopier<T> 
```

在`TransimittableThreadLocal`中添加`holder`属性。这个属性的作用就是被标记为具备线程传递资格的对象都会被添加到这个对象中。

**要标记一个类，比较容易想到的方式，就是给这个类新增一个`Type`字段，还有一个方法就是将具备这种类型的的对象都添加到一个静态全局集合中。之后使用时，这个集合里的所有值都具备这个标记。**

```java
// 1. holder本身是一个InheritableThreadLocal对象
// 2. 这个holder对象的value是WeakHashMap<TransmittableThreadLocal<Object>, ?>
//   2.1 WeekHashMap的value总是null,且不可能被使用。
//    2.2 WeekHasshMap支持value=null
private static InheritableThreadLocal<WeakHashMap<TransmittableThreadLocal<Object>, ?>> holder = new InheritableThreadLocal<WeakHashMap<TransmittableThreadLocal<Object>, ?>>() {
  @Override
  protected WeakHashMap<TransmittableThreadLocal<Object>, ?> initialValue() {
    return new WeakHashMap<TransmittableThreadLocal<Object>, Object>();
  }
 
  /**
   * 重写了childValue方法，实现上直接将父线程的属性作为子线程的本地变量对象。
   */
  @Override
  protected WeakHashMap<TransmittableThreadLocal<Object>, ?> childValue(WeakHashMap<TransmittableThreadLocal<Object>, ?> parentValue) {
    return new WeakHashMap<TransmittableThreadLocal<Object>, Object>(parentValue);
  }
};
```

应用代码是通过`TtlExecutors`工具类对线程池对象进行包装。工具类只是简单的判断，输入的线程池是否已经被包装过、非空校验等，然后返回包装类`ExecutorServiceTtlWrapper`。根据不同的线程池类型，有不同和的包装类。

```java
@Nullable
public static ExecutorService getTtlExecutorService(@Nullable ExecutorService executorService) {
  if (TtlAgent.isTtlAgentLoaded() || executorService == null || executorService instanceof TtlEnhanced) {
    return executorService;
  }
  return new ExecutorServiceTtlWrapper(executorService);
}
```

进入包装类`ExecutorServiceTtlWrapper`。可以注意到不论是通过`ExecutorServiceTtlWrapper#submit`方法或者是`ExecutorTtlWrapper#execute`方法，都会将线程对象包装成`TtlCallable`或者`TtlRunnable`，用于在真正执行`run`方法前做一些业务逻辑。

```java
/**
 * 在ExecutorServiceTtlWrapper实现submit方法
 */
@NonNull
@Override
public <T> Future<T> submit(@NonNull Callable<T> task) {
  return executorService.submit(TtlCallable.get(task));
}

/**
 * 在ExecutorTtlWrapper实现execute方法
 */
@Override
public void execute(@NonNull Runnable command) {
  executor.execute(TtlRunnable.get(command));
}
```

所以，重点的核心逻辑应该是在`TtlCallable#call()`或者`TtlRunnable#run()`中。以下以`TtlCallable`为例，`TtlRunnable`同理类似。在分析`call()`方法之前，先看一个类`Transmitter`

```java
public static class Transmitter {
  /**
    * 捕获当前线程中的是所有TransimittableThreadLocal和注册ThreadLocal的值。
    */
  @NonNull
  public static Object capture() {
    return new Snapshot(captureTtlValues(), captureThreadLocalValues());
  }
 
    /**
    * 捕获TransimittableThreadLocal的值,将holder中的所有值都添加到HashMap后返回。
    */
  private static HashMap<TransmittableThreadLocal<Object>, Object> captureTtlValues() {
    HashMap<TransmittableThreadLocal<Object>, Object> ttl2Value = 
      new HashMap<TransmittableThreadLocal<Object>, Object>();
    for (TransmittableThreadLocal<Object> threadLocal : holder.get().keySet()) {
      ttl2Value.put(threadLocal, threadLocal.copyValue());
    }
    return ttl2Value;
  }

  /**
    * 捕获注册的ThreadLocal的值,也就是原本线程中的ThreadLocal,可以注册到TTL中，在
    * 进行线程池本地变量传递时也会被传递。
    */
  private static HashMap<ThreadLocal<Object>, Object> captureThreadLocalValues() {
    final HashMap<ThreadLocal<Object>, Object> threadLocal2Value = 
      new HashMap<ThreadLocal<Object>, Object>();
    for(Map.Entry<ThreadLocal<Object>,TtlCopier<Object>>entry:threadLocalHolder.entrySet()){
      final ThreadLocal<Object> threadLocal = entry.getKey();
      final TtlCopier<Object> copier = entry.getValue();
      threadLocal2Value.put(threadLocal, copier.copy(threadLocal.get()));
    }
    return threadLocal2Value;
  }

  /**
    * 将捕获到的本地变量进行替换子线程的本地变量，并且返回子线程现有的本地变量副本backup。
    * 用于在执行run/call方法之后，将本地变量副本恢复。
    */
  @NonNull
  public static Object replay(@NonNull Object captured) {
    final Snapshot capturedSnapshot = (Snapshot) captured;
    return new Snapshot(replayTtlValues(capturedSnapshot.ttl2Value), 
                        replayThreadLocalValues(capturedSnapshot.threadLocal2Value));
  }
 
  /**
    * 替换TransmittableThreadLocal
    */
  @NonNull
  private static HashMap<TransmittableThreadLocal<Object>, Object> replayTtlValues(@NonNull HashMap<TransmittableThreadLocal<Object>, Object> captured) {
    // 创建副本backup
    HashMap<TransmittableThreadLocal<Object>, Object> backup = 
      new HashMap<TransmittableThreadLocal<Object>, Object>();

    for (final Iterator<TransmittableThreadLocal<Object>> iterator = holder.get().keySet().iterator(); iterator.hasNext(); ) {
      TransmittableThreadLocal<Object> threadLocal = iterator.next();
      // 对当前线程的本地变量进行副本拷贝
      backup.put(threadLocal, threadLocal.get());

      // 若出现调用线程中不存在某个线程变量，而线程池中线程有，则删除线程池中对应的本地变量
      if (!captured.containsKey(threadLocal)) {
        iterator.remove();
        threadLocal.superRemove();
      }
    }
    // 将捕获的TTL值打入线程池获取到的线程TTL中。
    setTtlValuesTo(captured);
    // 是一个扩展点，调用TTL的beforeExecute方法。默认实现为空
    doExecuteCallback(true);
    return backup;
  }

  private static HashMap<ThreadLocal<Object>, Object> replayThreadLocalValues(@NonNull HashMap<ThreadLocal<Object>, Object> captured) {
    final HashMap<ThreadLocal<Object>, Object> backup = 
      new HashMap<ThreadLocal<Object>, Object>();
    for (Map.Entry<ThreadLocal<Object>, Object> entry : captured.entrySet()) {
      final ThreadLocal<Object> threadLocal = entry.getKey();
      backup.put(threadLocal, threadLocal.get());
      final Object value = entry.getValue();
      if (value == threadLocalClearMark) threadLocal.remove();
      else threadLocal.set(value);
    }
    return backup;
  }

  /**
    * 清除单线线程的所有TTL和TL，并返回清除之气的backup
    */
  @NonNull
  public static Object clear() {
    final HashMap<TransmittableThreadLocal<Object>, Object> ttl2Value = 
      new HashMap<TransmittableThreadLocal<Object>, Object>();

    final HashMap<ThreadLocal<Object>, Object> threadLocal2Value = 
      new HashMap<ThreadLocal<Object>, Object>();
    for(Map.Entry<ThreadLocal<Object>,TtlCopier<Object>>entry:threadLocalHolder.entrySet()){
      final ThreadLocal<Object> threadLocal = entry.getKey();
      threadLocal2Value.put(threadLocal, threadLocalClearMark);
    }
    return replay(new Snapshot(ttl2Value, threadLocal2Value));
  }

  /**
    * 还原
    */
  public static void restore(@NonNull Object backup) {
    final Snapshot backupSnapshot = (Snapshot) backup;
    restoreTtlValues(backupSnapshot.ttl2Value);
    restoreThreadLocalValues(backupSnapshot.threadLocal2Value);
  }

  private static void restoreTtlValues(@NonNull HashMap<TransmittableThreadLocal<Object>, Object> backup) {
    // 扩展点，调用TTL的afterExecute
    doExecuteCallback(false);

    for (final Iterator<TransmittableThreadLocal<Object>> iterator = holder.get().keySet().iterator(); iterator.hasNext(); ) {
      TransmittableThreadLocal<Object> threadLocal = iterator.next();

      if (!backup.containsKey(threadLocal)) {
        iterator.remove();
        threadLocal.superRemove();
      }
    }

    // 将本地变量恢复成备份版本
    setTtlValuesTo(backup);
  }

  private static void setTtlValuesTo(@NonNull HashMap<TransmittableThreadLocal<Object>, Object> ttlValues) {
    for (Map.Entry<TransmittableThreadLocal<Object>, Object> entry : ttlValues.entrySet()) {
      TransmittableThreadLocal<Object> threadLocal = entry.getKey();
      threadLocal.set(entry.getValue());
    }
  }

  private static void restoreThreadLocalValues(@NonNull HashMap<ThreadLocal<Object>, Object> backup) {
    for (Map.Entry<ThreadLocal<Object>, Object> entry : backup.entrySet()) {
      final ThreadLocal<Object> threadLocal = entry.getKey();
      threadLocal.set(entry.getValue());
    }
  }

  /**
   * 快照类，保存TTL和TL
   */
  private static class Snapshot {
    final HashMap<TransmittableThreadLocal<Object>, Object> ttl2Value;
    final HashMap<ThreadLocal<Object>, Object> threadLocal2Value;

    private Snapshot(HashMap<TransmittableThreadLocal<Object>, Object> ttl2Value,
                     HashMap<ThreadLocal<Object>, Object> threadLocal2Value) {
      this.ttl2Value = ttl2Value;
      this.threadLocal2Value = threadLocal2Value;
    }
  }
```

进入`TtlCallable#call()`方法。

```java
@Override
public V call() throws Exception {
  Object captured = capturedRef.get();
  if (captured == null || releaseTtlValueReferenceAfterCall && 
      !capturedRef.compareAndSet(captured, null)) {
    throw new IllegalStateException("TTL value reference is released after call!");
  }
  // 调用replay方法将捕获到的当前线程的本地变量，传递给线程池线程的本地变量，
  // 并且获取到线程池线程覆盖之前的本地变量副本。
  Object backup = replay(captured);
  try {
    // 线程方法调用
    return callable.call();
  } finally {
    // 使用副本进行恢复。
    restore(backup);
  }
}
```

到这基本上线程池方式传递本地变量的核心代码已经大概看完了。总的来说在创建`TtlCallable`对象是，调用`capture()`方法捕获调用方的本地线程变量，在`call()`执行时，将捕获到的线程变量，替换到线程池所对应获取到的线程的本地变量中，并且在执行完成之后，将其本地变量恢复到调用之前。

## 总结

上述列举了4种方案，陈某这里推荐方案2和方案4，其中两种方案的缺点非常明显，实际开发中也是采用的方案2或者方案4

