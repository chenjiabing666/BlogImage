**大家好，我是不才陈某~**

这篇文章分享一下Spring Boot 升级到2.7的踩坑总结，还是挺全面的，希望对大家有所帮助~

## 说明

2.7.2为2.x的最后一个稳定版本。

3开始最低要求 Java 17，所以暂时不到3.x。

以下的处理方法主要针对我们的项目，可能并不通用。



## 1、hibernate-validator包下的类报错

Springboot从2.3以后，spring-boot-starter-web中不再引入hibernate-validator，需要手动引入。

在父pom中引入，已经加入software-center-modules模块中，子模块不需要加：

```xml
<dependency>
    <groupId>org.hibernate.validator</groupId>
    <artifactId>hibernate-validator</artifactId>
    <version>6.0.18.Final</version>
    <scope>compile</scope>
</dependency>
```

## 2、ErrorController无getErrorPath方法

去掉该方法

## 3、logback和log4j冲突

```java
org.apache.logging.log4j.LoggingException: log4j-slf4j-impl cannot be present with log4j-to-slf4j
    at org.apache.logging.slf4j.Log4jLoggerFactory.validateContext(Log4jLoggerFactory.java:60)
    at org.apache.logging.slf4j.Log4jLoggerFactory.newLogger(Log4jLoggerFactory.java:44)
    at org.apache.logging.slf4j.Log4jLoggerFactory.newLogger(Log4jLoggerFactory.java:33)
    at org.apache.logging.log4j.spi.AbstractLoggerAdapter.getLogger(AbstractLoggerAdapter.java:53)
    at org.apache.logging.slf4j.Log4jLoggerFactory.getLogger(Log4jLoggerFactory.java:33)
    at org.slf4j.LoggerFactory.getLogger(LoggerFactory.java:363)
    at org.slf4j.LoggerFactory.getLogger(LoggerFactory.java:388)
    at com.ld.CreditTaskManageApplication.<clinit>(CreditTaskManageApplication.java:40)
    ... 34 more
```

排除掉springboot的logging

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-batch</artifactId>
    <exclusions>
        <!-- spring boot 默认的日志框架是Logback,所以在引用log4j之前，需要先排除该包的依赖，再引入log4j2的依赖 -->
        <exclusion>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-logging</artifactId>
        </exclusion>
    </exclusions>
</dependency>
```

## 4、循环依赖：The dependencies of some of the beans in the application context form a cycle

```java
[credit-task-manage]2022-08-04 13:54:43.411 [WARN]:Exception encountered during context initialization - cancelling refresh attempt: org.springframework.context.ApplicationContextException: Unable to start web server; nested exception is org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'webMainConfig': Unsatisfied dependency expressed through field 'handlerAdapter'; nested exception is org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'org.springframework.boot.autoconfigure.web.servlet.WebMvcAutoConfiguration$EnableWebMvcConfiguration': Unsatisfied dependency expressed through method 'setConfigurers' parameter 0; nested exception is org.springframework.beans.factory.BeanCurrentlyInCreationException: Error creating bean with name 'webMainConfig': Requested bean is currently in creation: Is there an unresolvable circular reference?   org.springframework.context.support.AbstractApplicationContext.refresh(AbstractApplicationContext.java:591) 


The dependencies of some of the beans in the application context form a cycle:

┌─────┐
|  webMainConfig (field private org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter com.ld.common.config.WebMainConfig.handlerAdapter)
↑     ↓
|  org.springframework.boot.autoconfigure.web.servlet.WebMvcAutoConfiguration$EnableWebMvcConfiguration
└─────┘


Action:

Relying upon circular references is discouraged and they are prohibited by default. Update your application to remove the dependency cycle between beans. As a last resort, it may be possible to break the cycle automatically by setting spring.main.allow-circular-references to true.
   org.springframework.boot.diagnostics.LoggingFailureAnalysisReporter.report(LoggingFailureAnalysisReporter.java:40) 
```

WebMainConfig类中 去掉报错的方法和属性handlerAdapter，修改写法

```java
@Bean
public ConversionService getConversionService(DateConverter dateConverter) {
    ConversionServiceFactoryBean factoryBean = new ConversionServiceFactoryBean();
    Set<Converter<String, Date>> converters = new HashSet<>();
    converters.add(dateConverter);
    factoryBean.setConverters(converters);
    return factoryBean.getObject();
}
```

日期转换器，依赖hutool的日期工具类处理，如不满足再自行扩展

```java
import java.util.Date;

import org.springframework.context.annotation.Configuration;
import org.springframework.core.convert.converter.Converter;

import cn.hutool.core.date.DateUtil;

/**
 * @Description 表单形式的全局时间类型转换器
 */
@Configuration
public class DateConverter implements Converter<String, Date> {

    // 可以根据前端传递的时间格式自动匹配格式化
    @Override
    public Date convert(String source) {
        return DateUtil.parse(source);

    }

}
```

代码中应该尽量避免循环依赖的情况，如果出现了，加@Lazy注解，懒加载。

代码中不鼓励依赖循环引用，默认情况下禁止使用循环引用。如果能消除bean之间的依赖循环最好消除，如果实在改动太大，还有一种不推荐的处理方法，设置 `spring.main.allow-circular-references=true`

## 5、swagger错误：Failed to start bean 'documentationPluginsBootstrapper'

```scss
Application run failed   org.springframework.boot.SpringApplication.reportFailure(SpringApplication.java:824) 
org.springframework.context.ApplicationContextException: Failed to start bean 'documentationPluginsBootstrapper'; nested exception is java.lang.NullPointerException
    at org.springframework.context.support.DefaultLifecycleProcessor.doStart(DefaultLifecycleProcessor.java:181) ~[spring-context-5.3.22.jar:5.3.22]
复制代码
```

启动报了“Failed to start bean 'documentationPluginsBootstrapper'”，再往下面看到“springfox.documentation.spring.web.plugins.WebMvcRequestHandlerProvider”就可以断定是跟Swagger相关的问题。

查资料发现是新版本Spring Boot将Spring MVC默认路径匹配策略由AntPathMatcher更改为PathPatternParser，因此我们可以通过配置让其仍使用AntPathMatcher即可。

解决方案： 在application.properties里配置：

```properties
# 路径匹配策略使用旧版本的
spring.mvc.pathmatch.matching-strategy= ANT_PATH_MATCHER
```

顺便升级swagger到swagger3，已经加到base公共包里了

5.1、修改后路径需要修改，默认首页由swagger-ui.html变成了

```shell
/swagger-ui/index.html
```

5.2、如果还想使用扩展的2个ui的版本也需要跟着升级

```xml
<swagger-ui-layer.version>1.1.3</swagger-ui-layer.version>
<swagger-bootstrap-ui.version>1.9.6</swagger-bootstrap-ui.version>
```

我这里直接删除了那2个ui使用了swagger-bootstrap-ui的升级版：knife4j。base模块中已经引入

```xml
<knife4j.version>3.0.3</knife4j.version>
……
<dependency>
    <groupId>com.github.xiaoymin</groupId>
    <artifactId>knife4j-spring-boot-starter</artifactId>
    <version>${knife4j.version}</version>
</dependency>
```

5.3、swagger的配置类，注解@EnableSwagger2去掉，名字改为更通用的SwaggerConfig

```java
@Configuration
//@EnableSwagger2
@Slf4j
public class SwaggerConfig {

}
```

5.4、删除项目中自定义的pringfox.documentation.spring.web.readers包

5.5、去掉自定义的页面，如果想修改找到新的jar包复制出页面进行调整，否则可能看到的页面里没有内容

```bash
src/main/resources/META-INF/resources/doc.html
```

5.6 调整过滤器路径配置

```bash
#============================ 安全访问配置（SecurityFilter）========================
# 需要过滤的urlPatterns，多个用^分隔，没有或为空则不限制
security.access.urlPatterns = /doc.html^/docs.html^/swagger-ui.html^/swagger-ui/index.html^/v2/api-docs^/swagger-resources
```

## 6、跳转登录页出错

如果出现跳转时出错：

```java
Cannot forward to error page for request [/a/] as the response has already been committed. As a result, the response may have the wrong status code. If your application is running on WebSphere Application Server you may be able to resolve this problem by setting com.ibm.ws.webcontainer.invokeFlushAfterService to false   org.springframework.boot.web.servlet.support.ErrorPageFilter.handleCommittedResponse(ErrorPageFilter.java:219) 
```

解决方案同5

## 7、日期转换出错

升级后发现java中是Date类型，数据库中datetime类型（Timestamp类型没有问题）的数据不是转换为Timestamp，而是直接转为LocalDateTime类型了，解决办法：com.ld.shieldsb.dao.MyBeanProcessor修改type2Bean方法，增加LocalDateTime和LocalDate的处理

```java
if (value != null && fieldType.equals(Date.class)) {
    if (value.getClass().equals(String.class)) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        try {
            field.set(model, sdf.parse((String) value));
        } catch (ParseException e) {
            log.error("日期字段读取失败," + fieldType + ",error:" + e.getMessage());
        }
    } else if (value.getClass().equals(LocalDateTime.class)) {
        field.set(model, DateTimeUtil.localDateTime2Date((LocalDateTime) value));
    } else if (value.getClass().equals(LocalDate.class)) {
        field.set(model, DateTimeUtil.localDate2Date((LocalDate) value));
    } else {
        field.set(model, value);
    }
} 
```

我们使用的是mysql查看依赖jar包看到mysql-connector-java的版本从8.0.19变成了8.0.29

原因找到com.mysql.cj.jdbc.result.ResultSetImpl类的getObject(int columnIndex)方法可以看到Datetime类型的确实换了类型

```java
case DATETIME:
    return getTimestamp(columnIndex);
// 改为了
case DATETIME:
    return getLocalDateTime(columnIndex);
```

## 8、flyway：org.flywaydb.core.api.FlywayException: Unsupported Database: MySQL 5.7

```java
Application run failed   org.springframework.boot.SpringApplication.reportFailure(SpringApplication.java:824) 
org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'flywayInitializer' defined in class path resource [org/springframework/boot/autoconfigure/flyway/FlywayAutoConfiguration$FlywayConfiguration.class]: Invocation of init method failed; nested exception is org.flywaydb.core.api.FlywayException: Unsupported Database: MySQL 5.7
    at org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory.initializeBean(AbstractAutowireCapableBeanFactory.java:1804) ~[spring-beans-5.3.22.jar:5.3.22]
        ……
    at org.apache.catalina.startup.Bootstrap.start(Bootstrap.java:343) [bootstrap.jar:9.0.31]
    at org.apache.catalina.startup.Bootstrap.main(Bootstrap.java:474) [bootstrap.jar:9.0.31]
Caused by: org.flywaydb.core.api.FlywayException: Unsupported Database: MySQL 5.7
    at org.flywaydb.core.internal.database.DatabaseTypeRegister.getDatabaseTypeForConnection(DatabaseTypeRegister.java:106) ~[flyway-core-8.5.13.jar:?]
        ……org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory.initializeBean(AbstractAutowireCapableBeanFactory.java:1800) ~[spring-beans-5.3.22.jar:5.3.22]
    ... 49 more
```

flyway对数据库版本有要求，例如flyway-core的当前版本V8.4.3，不能使用 MySQL 5.7， 当flyway-core 降低到V7.15.0后 问题解决，所以匹配flyway-core和数据库版本后问题即可解决。

```xml
<properties>
……
    <flyway.version>7.15.0</flyway.version>
</properties>
……
        <!-- 添加 flyway 的依赖,flyway需要区分版本，不同版本对不同数据库版本支持不同 -->
        <dependency>
            <groupId>org.flywaydb</groupId>
            <artifactId>flyway-core</artifactId>
            <version>${flyway.version}</version>
        </dependency>
……
```

## 9、Junit运行后没有反应

升级后默认使用junit5，而依赖的jar包中引入了junit4的jar包冲突了，去掉junit4的jar包即可。

注意使用junit5后包的名字发生了变化，下面箭头前后分别是junit4和junit5的

```java
org.junit.Test》org.junit.jupiter.api.Test
org.junit.runner.RunWith》org.junit.jupiter.api.extension.ExtendWith
//使用时
@RunWith(SpringRunner.class)》@ExtendWith(SpringExtension.class)
```

## 10、升级后json中Long类型字段精度丢失

出现如下情况，前面是真实值后面为json传递后的值

```java
344280995828072448》344280995828072450
344268472663932928》344268472663932900
343301120241696768》343301120241696800
```

原项目中是有Long转字符串的处理的。

问题原因：经查看，默认已经有多个消息转换器了。而 configureMessageConverters 方法中是一个 list 参数。直接向其中添加 HttpMessageConverter 后，默认是排在最后的。就造成了你自定义的消息转换器不生效。其实是被其他转换器接管了。

解决办法：加到第一个就行了。add(0, customConverter())

```java
    @Override
    public void configureMessageConverters(List<HttpMessageConverter<?>> converters) {
        FastJsonHttpMessageConverter fastConverter = new FastJsonHttpMessageConverter();
        ……
        // 支持text 转string
        converters.add(0, customJackson2HttpMessageConverter());
        converters.add(0, new StringHttpMessageConverter(StandardCharsets.UTF_8));
        converters.add(0, fastConverter);

    }
```

如果使用的是@bean注解，覆盖的fastjson则不需要改，如下：

```java
@Bean
    public HttpMessageConverters customConverters() {
        FastJsonHttpMessageConverter fastConverter = new FastJsonHttpMessageConverter();
        // 创建配置类
        FastJsonConfig fastJsonConfig = new FastJsonConfig();
        fastJsonConfig.setSerializerFeatures(SerializerFeature.WriteNullListAsEmpty, SerializerFeature.WriteMapNullValue,
                SerializerFeature.WriteNullStringAsEmpty);

        // 解决 Long 转json 精度丢失的问题
        SerializeConfig serializeConfig = SerializeConfig.globalInstance;
        serializeConfig.put(BigInteger.class, ToStringSerializer.instance);
        serializeConfig.put(Long.class, ToStringSerializer.instance);
        serializeConfig.put(Long.TYPE, ToStringSerializer.instance);
        fastJsonConfig.setSerializeConfig(serializeConfig);

        // 此处是全局处理方式
        fastJsonConfig.setDateFormat(DATE_FORMAT);
        fastJsonConfig.setCharset(StandardCharsets.UTF_8);
        fastConverter.setFastJsonConfig(fastJsonConfig);

        List<MediaType> supportedMediaTypes = new ArrayList<>();
        supportedMediaTypes.add(MediaType.APPLICATION_JSON);
        fastConverter.setSupportedMediaTypes(supportedMediaTypes);
        // 支持text 转string
        StringHttpMessageConverter stringHttpMessageConverter = new StringHttpMessageConverter();
        return new HttpMessageConverters(fastConverter, stringHttpMessageConverter);
    }
```

## 最后说一句（别白嫖，求关注）

陈某每一篇文章都是精心输出，已经写了**3个专栏**，整理成**PDF**，获取方式如下：

1. [《Spring Cloud 进阶》](https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzU3MDAzNDg1MA==&action=getalbum&album_id=2042874937312346114#wechat_redirect)PDF：关注公众号：【**码猿技术专栏**】回复关键词 **Spring Cloud 进阶** 获取！
2. [《Spring Boot 进阶》](https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzU3MDAzNDg1MA==&action=getalbum&album_id=1532834475389288449#wechat_redirect)PDF：关注公众号：【**码猿技术专栏**】回复关键词 **Spring Boot进阶** 获取！
3. [《Mybatis 进阶》](https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzU3MDAzNDg1MA==&action=getalbum&album_id=1500819225232343046#wechat_redirect)PDF：关注公众号：【**码猿技术专栏**】回复关键词 **Mybatis 进阶** 获取！

如果这篇文章对你有所帮助，或者有所启发的话，帮忙**点赞**、**在看**、**转发**、**收藏**，你的支持就是我坚持下去的最大动力！