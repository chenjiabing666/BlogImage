**大家好，我是不才陈某~**

Spring Framework 6.0 发布了首个 RC 版本。

![](https://mmbiz.qpic.cn/mmbiz_png/dkwuWwLoRK8yypAQriaO4ZG8qhavP3X7sF2gmgpaMLs0wquxPDmN7SRkukHM8iaq9vqxkkC4Qv55Dv47frOJEQ3w/640?wx_fmt=png)

发布公告写道，Spring Framework 6.0 作为重大更新，目前 RC1 要求**使用 Java 17 或更高版本**，并且已迁移到 Jakarta EE 9+（在 `jakarta` 命名空间中取代了以前基于 `javax` 的 EE API），以及对其他基础设施的修改。

基于这些变化，Spring Framework 6.0 支持最新 Web 容器，如 Tomcat 10 / Jetty 11，以及最新的持久性框架 Hibernate ORM 6.1。这些特性仅可用于 Servlet API 和 JPA 的 jakarta 命名空间变体。

此版本的一项重要变化是完成对 Spring 应用上下文的 **AOT 转换**和相应的 AOT 处理支持的基础。该变化有助于优化部署安排，从微调的 JVM 部署到对 GraalVM 原生镜像的 “一等公民” 支持。

值得一提的是，开发者可通过此版本在基于 Spring 的应用中体验 “虚拟线程”（JDK 19 中的预览版 “Project Loom”），现在提供了自定义选项来插入基于虚拟线程的 `Executor` 实现，目标是在 Project Loom 正式可用时提供 “一等公民” 的配置选项。

除了上述的变化，Spring Framework 6.0 还包含许多其他改进和特性，例如：

- 提供基于 `@HttpExchange` 服务接口的 HTTP 接口客户端
- 对 RFC 7807 问题详细信息的支持
- Spring HTTP 客户端提供基于 Micrometer 的可观察性
- ……

此外，团队称将在下周发布 Spring Boot 3.0 首个 RC 版本，以及 Spring Framework 6.0 的第二个 RC，然后在 11 月正式 GA。

发布公告：https://spring.io/blog/2022/10/12/spring-framework-6-0-goes-rc1

下载地址：https://github.com/spring-projects/spring-framework/releases/tag/v6.0.0-RC1

新特性介绍：https://github.com/spring-projects/spring-framework/wiki/What%27s-New-in-Spring-Framework-6.x/



来源：出品 | OSC开源社区（ID：oschina2013)

---
欢迎加入陈某的知识星球，一起学习打卡，交流技术。加入方式，扫描下方二维码：

![](https://www.java-family.cn/BlogImage/20221013191230.png)

已在知识星球中更新如下几个专栏，详情[戳链接了解](](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247518914&idx=1&sn=b3fdfd78c32b15077ac67535ccc10a00&chksm=fcf7550fcb80dc1945cfd871ad5c939dcd3e66b3013b91590edbf523fbf016b61f2a93fe20a0&token=1892293211&lang=zh_CN#rd))：

1. **《我要进大厂》**：汇总了大厂面试考点系列、系统架构设计、实战总结调优....
2. **《亿级数据分库分表实战》**：**文章+视频**的形式分享亿级数据的分库分表实战
3. **《精尽Spring Cloud Alibaba系列》**：Spring Cloud Alibaba各个中间件的使用以及源码深究，完整的案例源码分享，涉及Spring Cloud 的各个组件源码介绍
4. **《精尽Spring Boot 系列》**：整理了Spring Boot 入门到源码级别的文章
5. **《精尽Spring系列》**：迭代了47+篇文章，入门到源码级别的介绍，完整的案例源码
5. **《DDD实战系列》**：从DDD入门到实战进阶
6. Java后端相关技术的源码讲解、全栈学习路线图

## 最后说一句（别白嫖，求关注）

陈某每一篇文章都是精心输出，已经写了**3个专栏**，整理成**PDF**，获取方式如下：

1. [《Spring Cloud 进阶》](https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzU3MDAzNDg1MA==&action=getalbum&album_id=2042874937312346114#wechat_redirect)PDF：关注公众号：【**码猿技术专栏**】回复关键词 **Spring Cloud 进阶** 获取！
2. [《Spring Boot 进阶》](https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzU3MDAzNDg1MA==&action=getalbum&album_id=1532834475389288449#wechat_redirect)PDF：关注公众号：【**码猿技术专栏**】回复关键词 **Spring Boot进阶** 获取！
3. [《Mybatis 进阶》](https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzU3MDAzNDg1MA==&action=getalbum&album_id=1500819225232343046#wechat_redirect)PDF：关注公众号：【**码猿技术专栏**】回复关键词 **Mybatis 进阶** 获取！

如果这篇文章对你有所帮助，或者有所启发的话，帮忙**点赞**、**在看**、**转发**、**收藏**，你的支持就是我坚持下去的最大动力！