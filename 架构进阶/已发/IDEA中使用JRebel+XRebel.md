**大家好，我是不才陈某~**

IDEA上原生是不支持热部署的，当我们修改代码和配置文件等大部分操作时，都需要重启服务器。

JRebel是一款JAVA虚拟机插件，它使得JAVA程序员能在不进行重部署的情况下，即时看到代码的改变对一个应用程序带来的影响。JRebel使你能即时分别看到代码、类和资源的变化，从而跳过了构建和部署的过程，可以省去大量的部署用的时间。

> 目前对于idea热部署最好的解决方案就是安装JRebel。

XRebel 是不间断运行在 web 应用的交互式分析器，当发现问题会在浏览器中显示警告信息。XRebel 会实时监测应用代码的性能指标和可能会发生的问题。

官方文档：

> - https://manuals.jrebel.com/jrebel/index.html

## 安装JRebel/XRebel

**1.通过IDEA插件仓库查询JRebel即可，这俩个插件是绑定在一起下载的，如图。**

![](D:\BlogImage\对象池\31.png)

**2.由于该插件为收费，我们需要对插件进行激活**

- 依次进入`help->Jrebel->Activation`
- 服务器地址：`https://jrebel.qekang.com/{GUID}`
- 生成GUID：在线GUID地址
- 将服务器地址与GUID拼接后填入`Team URL`
- 点击`CHANGE LICENSE`

到此，JRebel就激活完成了。

![](D:\BlogImage\对象池\32.png)

![](D:\BlogImage\对象池\33.png)

## 设置JRebel

**1.设置为离线工作模式，点击`WORK OFFLICE`**

![](D:\BlogImage\对象池\34.png)

也可更改JRebel的自动刷新间隔

**2.为IDEA设置自动编译（一般默认就是自动编译）**

![](D:\BlogImage\对象池\35.png)

在`advanced setting`勾选`Allow auto -make…`

![](D:\BlogImage\对象池\36.png)

## 对项目进行热部署

**1.打开下面的JRebel，选择需要进行热部署的服务**

![](D:\BlogImage\对象池\37.png)

**2.在SpringBoot项目中，选择更新类和资源**

![](D:\BlogImage\对象池\38.png)

**3.使用JRebel+XRebel(若仅需要热部署，可选择JRebel)启动项目，而不是原生启动**

![](D:\BlogImage\对象池\39.png)

**4.当本地有多个微服务时，在service中选择所有的微服务，并使用JRebel启动**

![](D:\BlogImage\对象池\40.png)

这样，当任何一个服务中的代码改变时，直接`Ctrl+Shift+F9`，JRebel将会监测到代码改变并且Reload，可以继续愉快地继续开发了，避免了重新启动服务器，等待几十秒的时间。

![](D:\BlogImage\对象池\41.png)

## 使用XRebel性能分析

**1.XRebel访问**

项目启动后访问地址为：服务器项目应用地址/xrebel

例如：http://localhost:8080/xrebel

**2.激活XRebel**

激活方式同JRebel

**3.功能**

![](https://img-blog.csdnimg.cn/8aa6bbfed18c4c88a80a80f10f36d262.png)

1. 能够捕捉到应用运行时发生的异常
2. 能够详细的观察某每一次的调用，而且能够非常详细的观察各个步骤的执行时间
3. 每个步骤还可以看到详细的源码执行流程
4. 在数据库操作上能够看到具体的耗时和格式化后的SQL语句
5. 可以查看详细的系统执行日志，可以下载到本地
6. 不仅支持单机模式下，还可以应用于微服务分布式

![](D:\BlogImage\对象池\42.png)

![](D:\BlogImage\对象池\43.png)

## 总结

以上就是JRebel+XRebel的介绍，学会了妈妈就再也不用担心我改bug不开心了！！！

## 最后说一句（别白嫖，求关注）

陈某每一篇文章都是精心输出，如果这篇文章对你有所帮助，或者有所启发的话，帮忙**点赞**、**在看**、**转发**、**收藏**，你的支持就是我坚持下去的最大动力！

另外陈某的[知识星球](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247523057&idx=1&sn=32b42c6b0ac41b48785b7c0d24ce344a&chksm=fcf7453ccb80cc2a4a6cf38d5b9ab0354f09f270418bf4ff5eeb832b020aedabd561979b712d&token=1260267649&lang=zh_CN#rd)开通了，公众号回复关键词：**知识星球** 获取限量**30元**优惠券加入只需**89**元，一顿饭钱，但是星球回馈的价值却是巨大，目前更新了**Spring全家桶实战系列**、**亿级数据分库分表实战**、**DDD微服务实战专栏**、**我要进大厂、Spring，Mybatis等框架源码、架构实战22讲**等....每增加一个专栏价格将上涨20元

![](https://mmbiz.qpic.cn/mmbiz_png/19cc2hfD2rBvqdy8J18dlib7KepGcvuW08g7COtYpQvVoZzRtQFLgaW1GxibV1vsWMQ27S4wsOlt1ySoh3uEAeIw/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

关注公众号：【码猿技术专栏】，公众号内有超赞的粉丝福利，回复：加群，可以加入技术讨论群，和大家一起讨论技术，吹牛逼！