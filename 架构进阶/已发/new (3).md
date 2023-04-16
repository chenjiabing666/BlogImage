**大家好，我是不才陈某~**

最近看到一篇不错的文章，今天分享给大家！

前天，日常上线了个小迭代。内容是：将接口A切换成了接口B，需求很小，QA也没想着测，自测后走免测上线了。开发完成后，赶紧部署到测试环境验证了下，没啥问题，perfect！可以上线了。

我兴奋地在线上一通构建，程序很快上线了。没一会，发现系统疯狂报错。瞅着错误栈里调用的接口url我一看，惊讶地大喊：“**怎么线上请求到测试环境了！**”。赶紧回滚代码。所幸，系统在代码回退后报错停止了。但是光回退代码还不行呀，还得找出原因上线呀。我仔细端详我的代码，业务逻辑上无懈可击，只有调用下游方式的写法有些差异。

```java
@Value("${rpc.url}")
private String host;
.......
public Boolean customerAuth(Object... objects) {
    URIBuilder uriBuilder = new URIBuilder();
    uriBuilder.setHost(host);
	......
    String content;
    HttpGet httpget;
    URI uri = uriBuilder.build();
    httpget = new HttpGet(uri);
    LOGGER.info("request:\n {} {} \n", httpget.getMethod(), httpget.getURI());
    HttpResponse response = httpClient.execute(httpget);
    ......
    return hasAuth;
}
```

原本调用下游，我是采用 **@Value**的方式，将请求下游服务的url注入进来的。为了更优雅的实现功能（默默拿出了《**代码整洁之道**》），我改成了采用 **@FeignClient注解**的方式实现，同时将路径配置到了Apollo里面，从而减少代码量。

```java
@FeignClient(name = "Rpc", contextId = "Rpc", url = "${rpc.url}")
public interface Rpc {
   @GetMapping(value = "xxx/xxx/query")
   Result<List<Object>> getContractDiscounts(@RequestParam("number") String number);
}

```

紧接着又仔细检查了apollo里自己配置的url路径，确认是线上的无疑。那么此时我就更晕了，“**测试环境不是运行的好好的么，怎么一到生产就拉胯了呢？**”，直到我看到了applicaiton.yml里的配置:

```yml
rpc:
  url: http://xxx.test.com
```

![](D:\BlogImage\对象池\101.png)

显然，**Apollo里配置没生效吧，而application.yml内的配置生效了**。为了证实我的猜想，我将applicaiton.yml里的代码删掉了，然后重新启动了下服务，调用了下接口，结果报出了这个错误：

```java
Caused by: java.lang.IllegalArgumentException: Illegal character in authority at index 7: http://${rpc.url}
	at java.net.URI.create(URI.java:852)
	at feign.RequestTemplate.target(RequestTemplate.java:465)
	... 162 common frames omitted

```

果然我的猜测是没错的，为了优先解决问题，我在applicaiton-test.yml中配置了新的接口路径，重新上线后，系统没有报错，且正常运行起来了。尽管代码正常运行起来了，但是我的脑海不仅有了个疑问：**"为什么在切换写法前，Apollo配置能够正常覆盖，但是在切换了写法之后，就不行了呢？"**

## Spring配置机制简介

为了找到问题发生的原因，首先需要了解配置是如何在SpringBoot项目中生效的。查阅资料后，我知道了在SpringBoot中，存在一个名为**Application**的变量，其中保存着Spring中启动的所有信息。在这所有的变量中，配置信息主要同变量**Environment**相关，诸如**JVM参数、环境变量、Apollo配置**等配置用**PropertySource**封装后，存放在**Environment**里的。

除了存储配置以外，SpringBoot还设计了**propertyResolver**用于管控当前的配置信息，并负责对配置进行填充。

![](D:\BlogImage\对象池\102.png)

至于**PropertyResolver**和**PropertySource**的关系，形象点来说，**PropertyResolver**就是一位翻译官，他会根据现有的词典**PropertySource**对我们的语言${xxx.url}做翻译，并最终得到所配置的信息。倘若字典中没有对应的信息，那么很自然"翻译官"是无法做出翻译的。

![](D:\BlogImage\对象池\103.png)

因此，不难分析问题的原因应该是**切换写法后，配置发生了加载顺序上的变化，使得配置解析先于apollo里配置加载，从而出现解析失败的情况**。

## 配置加载顺序梳理

认识到问题原因可能是由于配置加载顺序导致的，我们需要**对Apollo、@Value、@FeignClient三者的配置加载顺序**进行了解。

### Apollo加载顺序梳理

首先我们来了解Apollo的配置加载顺序，结合Apollo的文档中的内容，不难得到apollo配置的加载顺序会有三种情况：

| apollo.bootstrap.enabled | apollo.bootstrap.eagerLoad.enabled | 对应SpringBoot的运行阶段 |
| ------------------------ | ---------------------------------- | ------------------------ |
| **True**                 | **True**                           | ***prepareEnvironment*** |
| **True**                 | **False**                          | ***prepareContext***     |
| **False**                | **False**                          | ***refreshContext***     |

​	这里简单介绍下这三种情况对应的Springboot运行阶段分别负责的功能是：

1. ***prepareEnvironment***，是最早加载配置的地方，**bootstrap.yml配置**、**系统启动参数中的环境变量**都会在这个阶段被加载。
2. ***prepareContext***，主要对上下文做初始化，如**设置bean名字命名器、设置加载.class文件加载器**等。
3. ***refreshContext***，该阶段主要负责对bean容器进行加载，括扫**描文件得到BeanDefinition和BeanFactory工厂、Bean工厂生产Bean对象、对Bean对象再进行属性注入**等工作。

​	这三个阶段在现有SpringBoot启动过程中顺序如下所示：

![](D:\BlogImage\对象池\104.png)

#### prepareEnviroment

在*preparenEnvironment*阶段，Spring会发出异步消息**ApplicationEnvironmentPreparedEvent**，同时名为**ConfigFileApplicationListener**对象会监听该消息，并对实现了`EnvironmentPostProcessor`接口的对象进行调用。

![](D:\BlogImage\对象池\105.png)

在Apollo源码中，**ApolloApplicationContextInitializer**类也实现了`EnvironmentPostProcessor`的接口。其实现方法中进行apollo配置的加载。

![](D:\BlogImage\对象池\106.png)

#### prepareContext

在*prepareContext*的阶段，主要依赖于方法*applyInitializers*。该方法会对所有实现了`ApplicationContextInitializer`接口的对象进行调用。在Apollo中，**ApolloApplicationContextInitializer**类也实现了该接口，并在方法中进行配置加载。

![](D:\BlogImage\对象池\107.png)

#### refreshContext

*refreshContext*为Apollo的默认加载阶段。在*refreshContext*中，会调用*invokeBeanFactoryPostProcessors*方法对实现了`BeanFactoryPostProcessor`接口的对象进行调用。在apollo源码中，对象**PropertySourcesProcessor**就实现了该接口。且该对象在*postProcessBeanFactory*方法中，进行了对配置信息的加载。

![](D:\BlogImage\对象池\108.png)



#### 小结

由此梳理下来，Apollo三个阶段的加载顺序及配置控制逻辑，如下图所示：

![](D:\BlogImage\对象池\109.png)

## @Value 加载顺序梳理

了解了apollo的加载顺序后。我们要了解下@Value的加载顺序，@Value的实现思想很纯粹，**当你的Bean对象创建好后，我再把属性通过getter、setter方法注入进去**，就实现注入的功能。

因此@Value的实现主要在Bean生成后。在*refreshContext*阶段，会调用*finishBeanFactoryInitialization*方法对所有单例bean对象做初始化逻辑。其中在**AbstractAutowireCapableBeanFactory**会有一个方法*populateBean*，其会对bean属性做填充。同上述类似，这里也会对所有继承了`BeanPostProcessor`接口的对象进行调用。其中包含一个特殊的对象**AutowiredAnnotationBeanPostProcessor**

![](D:\BlogImage\对象池\110.png)

**AutowiredAnnotationBeanPostProcessor**会将用@Value注解修饰的对象扫描出来，并从配置中找到对应的配置信息，注入到对象中。结合上述apollo配置加载顺序图，我们可以得到@Value和Apollo的配置优先级大概如下所示：

![](D:\BlogImage\对象池\111.png)

可以看到，@Value的配置晚于apollo的配置，因此在切换写法前，apollo的配置可以被正常注入。

## @FeignClient 加载顺序梳理

了解完@Value的加载顺序后，我们还需要了解下@FeignClient的配置加载顺序。对于FeignClient来说，它通常采用接口做实现，因此需要根据@FeignClient生成新的Bean对象，并注册到容器中。因此，其配置的加载顺序在Bean对象生成之前。

类**ConfigurationClassPostProcessor**继承自接口`AutowiredAnnotationBeanPostProcessor`，其*postProcessBeanDefinitionRegistry*方法会对BeanDefinition做注入处理。（BeanDefinition，简写为BeanDef，是Bean容器未生成的形态，如果将Bean比作一辆汽车，那么BeanDefinition就是汽车的图纸。）

同时，类**ConfigurationClassBeanDefinitionReader**会调用*loadBeanDefinitionsFromRegistrars*方法，该方法会将实现了`ImportBeanDefinitionRegistrar`接口的对象逐一进行调用。这其中包含一个**FeignClientsRegistrar**对象，其实现的*registerFeignClients*方法会扫描所有被@FeignClient注解的对象。

![](D:\BlogImage\对象池\112.png)

 同时，对单个BeanDef对象，还会调用**FeignClientsRegistrar**下的*registerFeignClient*方法做处理，将我们其中的url、path等属性都用propertyResolver做翻译处理，倘若此时，配置中不存在相应的属性，就不会更新。**这就是造成本次问题的关键点。**

![](D:\BlogImage\对象池\113.png)

关注到加载顺序上，@FeignClient注解所依赖的接口为`BeanDefinitionRegistryPostProcessor`，而Apollo中默认加载的情况则依赖于`BeanFactoryPostProcessor`接口。两者几乎在同一处方法调用内，但`BeanDefinitionRegistryPostProcessor`接口执行稍微先于`BeanFactoryPostProcessor`。因此在加载顺序上，**@FeignClient会先于默认情况下的Apollo加载**。

![](D:\BlogImage\对象池\114.png)

至此也就不难理解为什么Apollo注解没法生效了。因为在@FeignClient注解的情况下，beanDef注入时，apollo的配置还没有加载，**PropertyResolver**找不到对应的配置，自然也就无法进行注入了。

## 总结

在了解了上述配置的作用机制后，我在原本代码中添加了apollo.bootstrap.enabled=true，将Apollo的配置加载提前到了FeignClient加载前，然后重新运行代码，项目果然如想象中的正常运转起来。

## 最后说一句（别白嫖，求关注）

陈某每一篇文章都是精心输出，如果这篇文章对你有所帮助，或者有所启发的话，帮忙**点赞**、**在看**、**转发**、**收藏**，你的支持就是我坚持下去的最大动力！

另外陈某的[知识星球](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247523057&idx=1&sn=32b42c6b0ac41b48785b7c0d24ce344a&chksm=fcf7453ccb80cc2a4a6cf38d5b9ab0354f09f270418bf4ff5eeb832b020aedabd561979b712d&token=1260267649&lang=zh_CN#rd)开通了，公众号回复关键词：**知识星球** 获取限量**30元**优惠券加入只需**89**元，一顿饭钱，但是星球回馈的价值却是巨大，目前更新了**Spring全家桶实战系列**、**亿级数据分库分表实战**、**DDD微服务实战专栏**、**我要进大厂、Spring，Mybatis等框架源码、架构实战22讲**等....每增加一个专栏价格将上涨20元

![](https://mmbiz.qpic.cn/mmbiz_png/19cc2hfD2rBvqdy8J18dlib7KepGcvuW08g7COtYpQvVoZzRtQFLgaW1GxibV1vsWMQ27S4wsOlt1ySoh3uEAeIw/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

关注公众号：【码猿技术专栏】，公众号内有超赞的粉丝福利，回复：加群，可以加入技术讨论群，和大家一起讨论技术，吹牛逼！

