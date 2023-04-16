**大家好，我是不才陈某~**

SPI(Service Provider Interface)是JDK内置的一种服务提供发现机制，可以用来启用框架扩展和替换组件,主要用于框架中开发，例如Dubbo、Spring、Common-Logging，JDBC等采用采用SPI机制，针对同一接口采用不同的实现提供给不同的用户，从而提高了框架的扩展性。

之前也写过Java SPI的深入剖析：[聊聊 Java SPI 机制](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247511021&idx=1&sn=2a1b394387970210fe449193ca6535d7&chksm=fcf77420cb80fd367124c35cae6b0150cd2e75c9f26fee583f921f335168d659f971df0dec59&scene=178&cur_album_id=2110812371806912514#rd)

推荐Java工程师技术指南：https://github.com/chenjiabing666/JavaFamily

## Java SPI实现

Java内置的SPI通过java.util.ServiceLoader类解析classPath和jar包的META-INF/services/目录 下的以接口全限定名命名的文件，并加载该文件中指定的接口实现类，以此完成调用。

## 示例说明

### 创建动态接口

```java
public interface VedioSPI
{
    void call();
}

```

### 实现类1

```java
public class Mp3Vedio implements VedioSPI
{
    @Override
    public void call()
    {
        System.out.println("this is mp3 call");
    }

}

```

## 实现类2

```java
public class Mp4Vedio implements VedioSPI
{
    @Override
    public void call()
    {
       System.out.println("this is mp4 call");
    }

}

```

在项目的source目录下新建META-INF/services/目录下，创建com.skywares.fw.juc.spi.VedioSPI文件。

![](https://www.java-family.cn/BlogImage/20230129210115.png)

## 相关测试

```java
public class VedioSPITest
{
    public static void main(String[] args)
    {
        ServiceLoader<VedioSPI> serviceLoader =ServiceLoader.load(VedioSPI.class);
        
        serviceLoader.forEach(t->{
            t.call();
        });
    }
}

```

说明：Java实现spi是通过ServiceLoader来查找服务提供的工具类。

## 运行结果：

![](https://www.java-family.cn/BlogImage/20230129210119.png)

## 源码分析

上述只是通过简单的示例来实现下java的内置的SPI功能。其实现原理是ServiceLoader是Java内置的用于查找服务提供接口的工具类，通过调用load()方法实现对服务提供接口的查找，最后遍历来逐个访问服务提供接口的实现类。

![](https://www.java-family.cn/BlogImage/20230129210122.png)

从源码可以发现：

- ServiceLoader类本身实现了Iterable接口并实现了其中的iterator方法，iterator方法的实现中调用了LazyIterator这个内部类中的方法，迭代器创建实例。
- 所有服务提供接口的对应文件都是放置在META-INF/services/目录下，final类型决定了PREFIX目录不可变更。

虽然java提供的SPI机制的思想非常好，但是也存在相应的弊端。具体如下：

- Java内置的方法方式只能通过遍历来获取
- 服务提供接口必须放到META-INF/services/目录下。

针对java的spi存在的问题，Spring的SPI机制沿用的SPI的思想，但对其进行扩展和优化。

> 推荐Java工程师技术指南：https://github.com/chenjiabing666/JavaFamily

## Spring SPI

Spring SPI沿用了Java SPI的设计思想，Spring采用的是spring.factories方式实现SPI机制，可以在不修改Spring源码的前提下，提供Spring框架的扩展性。

## Spring 示例

### 定义接口

```java
public interface DataBaseSPI
{
   void getConnection();
}
```

### 相关实现

```java
##DB2实现
public class DB2DataBase implements DataBaseSPI
{
    @Override
    public void getConnection()
    {
        System.out.println("this database is db2");
    }

}

##Mysql实现
public class MysqlDataBase implements DataBaseSPI
{
    @Override
    public void getConnection()
    {
       System.out.println("this is mysql database");
    }

}

```

1、在项目的META-INF目录下，新增spring.factories文件

![](https://www.java-family.cn/BlogImage/20230129210128.png)

2、填写相关的接口信息，内容如下：

```properties
com.skywares.fw.juc.springspi.DataBaseSPI = com.skywares.fw.juc.springspi.DB2DataBase, com.skywares.fw.juc.springspi.MysqlDataBase
```

说明多个实现采用逗号分隔。

### 相关测试类

```java
public class SpringSPITest
{
    public static void main(String[] args)
    {
         List<DataBaseSPI> dataBaseSPIs =SpringFactoriesLoader.loadFactories(DataBaseSPI.class, 
                 Thread.currentThread().getContextClassLoader());
         
         for(DataBaseSPI datBaseSPI:dataBaseSPIs){
            datBaseSPI.getConnection();
         }
    }
}

```

### 输出结果

![](https://www.java-family.cn/BlogImage/20230129210132.png)

从示例中我们看出，Spring 采用spring.factories实现SPI与java实现SPI非常相似，但是spring的spi方式针对java的spi进行的相关优化具体内容如下：

- Java SPI是一个服务提供接口对应一个配置文件，配置文件中存放当前接口的所有实现类，多个服务提供接口对应多个配置文件，所有配置都在services目录下；
- Spring factories SPI是一个spring.factories配置文件存放多个接口及对应的实现类，以接口全限定名作为key，实现类作为value来配置，多个实现类用逗号隔开，仅spring.factories一个配置文件。

那么spring是如何通过加载spring.factories来实现SpI的呢?我们可以通过源码来进一步分析。

> 推荐Java工程师技术指南：https://github.com/chenjiabing666/JavaFamily

## 源码分析

![](https://www.java-family.cn/BlogImage/20230129210135.png)

说明:loadFactoryNames解析spring.factories文件中指定接口的实现类的全限定名，具体实现如下：

![](https://www.java-family.cn/BlogImage/20230129210138.png)

 

说明： 获取所有jar包中META-INF/spring.factories文件路径，以枚举值返回。 遍历spring.factories文件路径，逐个加载解析，整合factoryClass类型的实现类名称，获取到实现类的全类名称后进行类的实例话操作，其相关源码如下：

![](https://www.java-family.cn/BlogImage/20230129210141.png)

说明：实例化是通过反射来实现对应的初始化。

## 最后说一句（别白嫖，求关注）

陈某每一篇文章都是精心输出，如果这篇文章对你有所帮助，或者有所启发的话，帮忙**点赞**、**在看**、**转发**、**收藏**，你的支持就是我坚持下去的最大动力！

另外陈某的[知识星球](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247518914&idx=1&sn=b3fdfd78c32b15077ac67535ccc10a00&scene=21#wechat_redirect)开通了，公众号回复关键词：**知识星球** 获取限量**30元**优惠券加入，即将涨价，目前更新了**Spring全家桶实战系列**、**亿级数据分库分表实战**、**DDD微服务实战专栏**、**我要进大厂，架构实战22讲**等....每增加一个专栏价格将上涨20元

![](https://mmbiz.qpic.cn/mmbiz_png/19cc2hfD2rBvqdy8J18dlib7KepGcvuW08g7COtYpQvVoZzRtQFLgaW1GxibV1vsWMQ27S4wsOlt1ySoh3uEAeIw/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)