

**大家好，我是不才陈某~**

MybatisX 是一款基于 IDEA 的快速开发插件，方便在使用mybatis以及mybatis-plus开始时简化繁琐的重复操作，提高开发速率。

![](C:\Users\18796\Desktop\文章\1.png)

## 使用MybatisX的好处

- 节省大量持久层代码开发时间
- 强大的功能为业务编写提供各类支持
- 配置简单，告别各类复杂的配置文件

## 如何使用MybatisX?

**1.创建一个简单的数据库**

![](https://mmbiz.qpic.cn/mmbiz_png/TNUwKhV0JpROick59wZhFYhPKO6xgzW8bRJErcCNZPr4icHLuRGLBiaEAP8wAzEyOThxF7FkT9zRYwBsFiaC0wKhog/640?wx_fmt=png)

**2.创建一个简单的Springboot工程**

![](https://mmbiz.qpic.cn/mmbiz_png/TNUwKhV0JpROick59wZhFYhPKO6xgzW8bamEaar1OWJY7XTMRniapp4trE71STrDb38ibw2mZnxGfnKyuib5656kEg/640?wx_fmt=png)

**3.在pom.xml文件中引入mybatis-plus依赖**

```xml
<!--mybatisPlus-->
<dependency>
    <groupId>com.baomidou</groupId>
    <artifactId>mybatis-plus-boot-starter</artifactId>
    <version>3.5.1</version>
</dependency>
```



**4.在File->Settings->Plugins下载MybatiX插件**

![](https://mmbiz.qpic.cn/mmbiz_png/TNUwKhV0JpROick59wZhFYhPKO6xgzW8bd0PibpwQVgquFXjUV8rHzCPiaibOF5Jve3kIRibJK9nrXaW1SicJbeU0Q0A/640?wx_fmt=png)

**5.两下SHIFT键搜索database进入数据库**

![](https://mmbiz.qpic.cn/mmbiz_png/TNUwKhV0JpROick59wZhFYhPKO6xgzW8bGcvNXS7Xzpian75Pe8pCht0WLYlFWTqQndGnrX8qfFWK8mNY1ceMrnA/640?wx_fmt=png)

**6.新建Mysql连接**

![](https://mmbiz.qpic.cn/mmbiz_png/TNUwKhV0JpROick59wZhFYhPKO6xgzW8bp1Nic60qflRrjhSKorjSYCD3ibpRKA7XEUQRBgDOicmwzagYakDGIXib6g/640?wx_fmt=png)

输入用户、密码及数据库名

![](https://mmbiz.qpic.cn/mmbiz_png/TNUwKhV0JpROick59wZhFYhPKO6xgzW8bzbAQfXU4m3CM9cdzz83d18QNlhYpMCphSx6wmeoLLmOaCxhVRr7zaw/640?wx_fmt=png)

当`Test Connection`时会提示这么一段话：这是时区未设置问题

![](https://mmbiz.qpic.cn/mmbiz_png/TNUwKhV0JpROick59wZhFYhPKO6xgzW8bqYxPicSVtXHQR0RcSXXzngAfbe4cOfVibDQvD9oVYwTCLvdol4MyofKA/640?wx_fmt=png)

根据提示来到Advanced，找到severTimezone，将其设置为GMT(`Greenwich Mean Time`格林尼治标准时间)

![](https://mmbiz.qpic.cn/mmbiz_png/TNUwKhV0JpROick59wZhFYhPKO6xgzW8b3ABgtZLQ61msFmL2rvMzzG7AhwSUCiae6f3Ust1doZzvnTD8zc18NtA/640?wx_fmt=png)

此时再测试连接会发现已经成功

![](https://mmbiz.qpic.cn/mmbiz_png/TNUwKhV0JpROick59wZhFYhPKO6xgzW8bgoWxCicTftUjX1fvVvrgN2PDeF8nElc4KnTooawiaIubAyRLTzhpwOgA/640?wx_fmt=png)

这时候我们就可以看见我们想要连接的数据库和其对应的表等信息了

![](https://mmbiz.qpic.cn/mmbiz_png/TNUwKhV0JpROick59wZhFYhPKO6xgzW8b1TWP42NiadKXiaNFjWH2NPaicVgYUoKw1m5cFupD0sbr1aL3pHtnHFKLQ/640?wx_fmt=png)

右键对应的表，我们可以看到MybatiX-Generator

![](https://mmbiz.qpic.cn/mmbiz_png/TNUwKhV0JpROick59wZhFYhPKO6xgzW8bCj8N9h4wm46ot1w2R4kIX2x5eiasXmG9qO6m7VJmMOhLwY4C00LGeMA/640?wx_fmt=png)

点击后我们会看到这样一个页面，我们可以在这个页面中设置需要消除的前后缀、文件存放目录等...

![](https://mmbiz.qpic.cn/mmbiz_png/TNUwKhV0JpROick59wZhFYhPKO6xgzW8bdm1cXHf9aB5tQtNrlKaXBwzYcCfibxViaecA5RndoaTo1UWVq5my6CPg/640?wx_fmt=png)

点击Next，在下面是一些配置，我们勾选Mybatis-Plus的最新版本Mybatix-Plus 3 和 简化开发的Lombok

![](https://mmbiz.qpic.cn/mmbiz_png/TNUwKhV0JpROick59wZhFYhPKO6xgzW8btSJCHEVdqOe1AH6ic60lReUEMia2RwTQXqqHsNsN1W5WJf0AaWz7Y6UQ/640?wx_fmt=png)

点击Finish，我们可以看到MybatisX为我们自动生成了该表对应的实体类、Mapper文件、Service和相对应的接口

![](https://mmbiz.qpic.cn/mmbiz_png/TNUwKhV0JpROick59wZhFYhPKO6xgzW8bQj509OdkTERCO8Y65MgF0dEIibNnWNibEMoOpSly2WawobEHAMOwy12w/640?wx_fmt=png)

在yaml中对数据库进行配置：

application.yaml

```yaml
spring:
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://localhost:3306/user?characterEncoding=utf-8&useSSL=false&serverTimezone=GMT
    username: root
    password: password
```

控制层编写方法，使用到Mybatis-Plus中的条件构造器：

```java
package com.example.mybatixtest.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.example.mybatixtest.pojo.User;
import com.example.mybatixtest.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TestController {

    @Autowired
    UserService userService;

    @GetMapping("/test")
    public User test(){
        QueryWrapper<User> userQueryWrapper = new QueryWrapper<>();
        userQueryWrapper.eq("user_id",1);
        User user = userService.getOne(userQueryWrapper);
        return user;
    }

}
```

访问成功

![](https://mmbiz.qpic.cn/mmbiz_png/TNUwKhV0JpROick59wZhFYhPKO6xgzW8bStlu1qB8tZx4cc8gLdVaPBvIC4wVWzAI8VOZic5OTgMmDNZByXhiaqhQ/640?wx_fmt=png)

至此，MybatiX整合springboot的简单配置结束！！

## 最后说一句（别白嫖，求关注）

陈某每一篇文章都是精心输出，如果这篇文章对你有所帮助，或者有所启发的话，帮忙**点赞**、**在看**、**转发**、**收藏**，你的支持就是我坚持下去的最大动力！

另外陈某的[知识星球](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247523057&idx=1&sn=32b42c6b0ac41b48785b7c0d24ce344a&chksm=fcf7453ccb80cc2a4a6cf38d5b9ab0354f09f270418bf4ff5eeb832b020aedabd561979b712d&token=1260267649&lang=zh_CN#rd)开通了，公众号回复关键词：**知识星球** 获取限量**30元**优惠券加入只需**89**元，一顿饭钱，但是星球回馈的价值却是巨大，目前更新了**Spring全家桶实战系列**、**亿级数据分库分表实战**、**DDD微服务实战专栏**、**我要进大厂、Spring，Mybatis等框架源码、架构实战22讲**等....每增加一个专栏价格将上涨20元

![](https://mmbiz.qpic.cn/mmbiz_png/19cc2hfD2rBvqdy8J18dlib7KepGcvuW08g7COtYpQvVoZzRtQFLgaW1GxibV1vsWMQ27S4wsOlt1ySoh3uEAeIw/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

关注公众号：【码猿技术专栏】，公众号内有超赞的粉丝福利，回复：加群，可以加入技术讨论群，和大家一起讨论技术，吹牛逼！