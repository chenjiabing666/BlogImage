**大家好，我是不才陈某~**

Sa-Token-Quick-Login 可以为一个系统快速的、零代码 注入一个登录页面

试想一下，假如我们开发了一个非常简单的小系统，比如说：服务器性能监控页面， 我们将它部署在服务器上，通过访问这个页面，我们可以随时了解服务器性能信息，非常方便

然而，这个页面方便我们的同时，也方便了一些不法的攻击者，由于这个页面毫无防护的暴露在公网中，任何一台安装了浏览器的电脑都可以随时访问它！

为此，我们必须给这个系统加上一个登录认证，只有知晓了后台密码的人员才可以进行访问

细细想来，完成这个功能你需要：

- 编写前端登录页面，手写各种表单样式
- 寻找合适的ajax类库，jQuery？Axios？还是直接前后台不分离？
- 寻找合适的模板引擎，比如jsp、Thymeleaf、FreeMarker、Velocity……选哪个呢？
- 处理后台各种拦截认证逻辑，前后台接口对接
- 你可能还会遇到令人头痛欲裂的模板引擎中ContextPath处理
- ……

你马上就会发现，写个监控页你一下午就可以搞定，然而这个登录页你却可能需要花上两三天的时间，这是一笔非常不划算的时间浪费

那么现在你可能就会有个疑问，难道就没有什么方法给我的小项目快速增加一个登录功能吗？

Sa-Token-Quick-Login便是为了解决这个问题！官方文档地址：

> - https://sa-token.cc/doc.html#/plugin/quick-login

## SpringBoot 整合

**1、引入 maven 依赖**

```xml
<!-- web支持 -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>
<!-- Sa-Token-Quick-Login 插件 -->
<dependency>
    <groupId>cn.dev33</groupId>
    <artifactId>sa-token-quick-login</artifactId>
    <version>1.29.0</version>
</dependency>
```

**2、配置参数**

```yaml
server:
  port: 8080

# Sa-Token-Quick-Login 配置
sa:
  # 登录账号
  name: admin
  # 登录密码
  pwd: 123456
  # 是否自动随机生成账号密码 (此项为true时, name与pwd失效)
  auto: false
  # 是否开启全局认证(关闭后将不再强行拦截)
  auth: true
  # 登录页标题
  title: Asurplus 登录
  # 是否显示底部版权信息
  copr: true
  # 指定拦截路径
  include: /**
  # 指定排除路径
  exclude: /test
```

## 测试

**1、编写一个 controller**

```java
@RestController
public class TestController {

    /**
     * 不需要认证
     *
     * @return
     */
    @GetMapping("test")
    public String test() {
        return "test";
    }

    /**
     * 需要认证
     *
     * @return
     */
    @GetMapping("test1")
    public String test1() {
        return "test1";
    }
}
```

**2、访问 http://localhost:8080/test**

![](https://www.java-family.cn/BlogImage/20230109230325.png)

返回正常

**3、访问 http://localhost:8080/test1**

![](https://www.java-family.cn/BlogImage/20230109230330.png)

由于没有登录，被拦截了，到了登录页面

**4、输入我们配置的用户密码：admin、123456**

![](https://www.java-family.cn/BlogImage/20230109230333.png)

登录过后，正常返回了响应数据

