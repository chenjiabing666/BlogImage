**大家好，我是不才陈某~**

过去，我们运维着“能做一切”的大型单体应用程序。这是一种将产品推向市场的很好的方式，因为刚开始我们也只需要让我们的第一个应用上线。

而且我们总是可以回头再来改进它的。部署一个大应用总是比构建和部署多个小块要容易。

**集中式：**

![](https://www.java-family.cn/BlogImage/20220906161904.png)

**集群：**

![](https://www.java-family.cn/BlogImage/20220906161911.png)

**分布式：**

![](https://www.java-family.cn/BlogImage/20220906161918.png)

分布式和集中式会配合使用。

我们在搭建网站的时候，为了及时响应用户的请求，尤其是高并发请求的时候，我们需要搭建分布式集群来处理请求。

我们一个服务器的处理能力是有限的。如果用我们一台设备当作服务器，那么当并发量比较大的时候，同一时间达到上百的访问量。那服务器就宕机了。然后只能重启服务器，当出现高并发访问的时候，就又会宕机。

所以我们需要更多的服务器来并行工作，处理用户的请求。那么问题来了，我们服务器运行的时候，怎么分发大量的请求给不同的服务器呢？

一般会采用(1apache+nTomcat)或者服务器模式来分发并处理请求。或者采用nginx分发请求。

微服务是运行在自己的进程中的可独立部署的服务套件。他们通常使用 HTTP 资源进行通信，每个服务通常负责整个应用中的某一个单一的领域。

在流行的电子商务目录例子中，你可以有一个商品条目服务，一个审核服务和一个评价服务，每个都只专注一个领域。

用这种方法让多语言服务（使用不同语言编写的服务）也成为可能，这样我们就可以让 Java/C++ 服务执行更多的计算密集型工作，让 Rails / Node.js 服务更多来支持前端应用等等。推荐公号：码猿技术专栏，回复关键词：1111 获取阿里内部java调优手册

微服务会成为大规模分布式应用的主流架构。任何复杂的工程问题都会归结为devide and conquer（分而治之），意思就是就是把一个复杂的问题分成两个或更多的相同或相似的子问题，再把子问题分成更小的子问题……

直到最后子问题可以简单的直接求解，原问题的解即子问题的解的合并。微服务本质是对服务的拆分，与工程领域惯用的“分而治之”的思路是一致的。

## **Spring Cloud 与 K8S 对比**

两个平台 Spring Cloud 和 Kubernetes 非常不同并且它们之间没有直接的相同特征。

![](https://www.java-family.cn/BlogImage/20220906161929.png)

两种架构处理了不同范围的MSA障碍，并且它们从根本上用了不同的方法。Spring Cloud方法是试图解决在JVM中每个MSA挑战，然而Kubernetes方法是试图让问题消失，为开发者在平台层解决。

Spring Cloud在JVM中非常强大，Kubernetes管理那些JVM很强大。同样的，它就像一个自然发展，结合两种工具并且从两个项目中最好的部分受益。

可以看到，里面差不多一半关注点是和运维相关的。这么看来，似乎拿spring cloud和kubernetes比较有点不公平，spring cloud只是一个开发框架，对于应用如何部署和调度是无能为力的，而kubernetes是一个运维平台。

也许用spring cloud+cloud foundry去和kubernetes比较才更加合理，但需要注意的是，即使加入了cloud foundry的paas能力，spring cloud仍然是“侵入式”的且语言相关，而kubernetes是“非侵入式”的且语言无关。



## **Spring Cloud vs Istio**

![](https://www.java-family.cn/BlogImage/20220906161938.png)

这里面哪些内容是我们可以拿掉或者说基于 Service Mesh（以 Istio 为例）能力去做的？

分析下来，可以替换的组件包括网关（gateway 或者 Zuul，由Ingress gateway 或者 egress 替换），熔断器（hystrix，由SideCar替换），注册中心（Eureka及Eureka client，由Polit，SideCar 替换），负责均衡（Ribbon，由SideCar 替换），链路跟踪及其客户端（Pinpoint 及 Pinpoint client，由 SideCar 及Mixer替换）。推荐公号：码猿技术专栏，回复关键词：1111 获取阿里内部java调优手册

这是我们在 Spring Cloud 解析中需要完成的目标：即确定需要删除或者替换的支撑模块。

![](https://www.java-family.cn/BlogImage/20220906161945.png)

可以说，springcloud关注的功能是kubernetes的一个子集。

可以看出，两边的解决方案都是比较完整的。kubernetes这边，在Istio还没出来以前，其实只能提供最基础的服务注册、服务发现能力（service只是一个4层的转发代理），istio出来以后，具有了相对完整的微服务能力。

而spring cloud这边，除了发布、调度、自愈这些运维平台的功能，其他的功能也支持的比较全面。相对而言，云厂商会更喜欢kubernetes的方案，原因就是三个字：非侵入。

平台能力与应用层的解耦，使得云厂商可以非常方便的升级、维护基础设施而不需要去关心应用的情况，这也是我比较看好service mesh这类技术前景的原因。



## Spring Boot + K8S

如果不用 Spring Cloud，那就是使用 Spring Boot + K8S。推荐：[SpringBoot实战教程](https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzU3MDAzNDg1MA==&action=getalbum&album_id=1532834475389288449#wechat_redirect)

![](https://www.java-family.cn/BlogImage/20220906161955.png)

这里就需要介绍一个项目，Spring Cloud Kubernetes，作用是把kubernetes中的服务模型映射到Spring Cloud的服务模型中，以使用Spring Cloud的那些原生sdk在kubernetes中实现服务治理。

具体来说，就是把k8s中的services对应到Spring Cloud中的services，k8s中的endpoints对应到Spring Cloud的instances。这样通过标准的Spring Cloud api就可以对接k8的服务治理体系。

老实说，个人认为这个项目的意义并不是很大，毕竟都上k8了，k8本身已经有了比较完善的微服务能力（有注册中心、配置中心、负载均衡能力），应用之间直接可以互相调用，应用完全无感知，你再通过sdk去调用，有点多此一举的感觉。

而且现在强调的是语言非侵入，Spring Cloud一个很大的限制是只支持java语言（甚至比较老的j2ee应用都不支持，只支持Spring Boot应用）。所以我个人感觉，这个项目，在具体业务服务层面，使用的范围非常有限。

借助于Spring Cloud Kubernetes项目，zuul可以以一种无侵入的方式提供api网关的能力，应用完全不需要做任何改造，并且网关是可插拔的，将来可以用其他网关产品灵活替换，整体耦合程度非常低。

得益于k8的service能力，zuul甚至支持异构应用的接入，这是Spring Cloud体系所不具备的。

而本身基于java开发，使得java程序员可以方便的基于zuul开发各种功能复杂的filter，而不需要去学习go或者openresty这样不太熟悉的语言。

## **Service Mesh的价值**

无论是单体应用，还是分布式应用，都可以建立在Service Mesh上，mesh上的sidecar支撑了所有的上层应用，业务开发者无须关心底层构成，可以用Java，也可以用Go等语言完成自己的业务开发。

当微服务架构体系越来越复杂的时候，需要将“业务服务”和“基础设施”解耦，将一个微服务进程一分为二：

![](https://www.java-family.cn/BlogImage/20220906162003.png)

为什么代理会叫sidecar proxy？

![](https://www.java-family.cn/BlogImage/20220906162012.png)

看了上图就容易懂了，biz和proxy相生相伴，就像摩托车(motor)与旁边的车厢(sidecar)。

未来，sidecar和proxy就指微服务进程解耦成两个进程之后，提供基础能力的那个代理进程。

Istio的理论概念是Service Mesh（服务网络），我们不必纠结于概念实际也是微服务的一种落地形式有点类似上面的SideCar模式。

它的主要思想是关注点分离，即不像SpringCloud一样交给研发来做，也不集成到k8s中产生职责混乱，Istio是通过为服务配 Agent代理来提供服务发现、负截均衡、限流、链路跟踪、鉴权等微服务治理手段。

Istio开始就是与k8s结合设计的，Istio结合k8s可以牛逼的落地微服务架构。

istio 超越 spring cloud和dubbo 等传统开发框架之处, 就在于不仅仅带来了远超这些框架所能提供的功能, 而且也不需要应用程序为此做大量的改动，开发人员也不必为上面的功能实现进行大量的知识储备。

但结论是不是 spring cloud 能做到的，k8s + istio 也能做到？甚至更好？

---

**微信8.0将好友放开到了一万，小伙伴可以加我大号了，先到先得，再满就真没了**
![](https://www.java-family.cn/BlogImage/20220828212533.png)

## 推荐阅读（求关注，别白嫖！）

1. [微服务最重要的10个设计模式](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247517905&idx=1&sn=3d33a3fa39e9fa8276f83c6783f5a6d6&chksm=fcf7591ccb80d00a37f65928c2c2c636b3e7aa3d295cc1df00926633029221384ba7396dc92d&token=123612753&lang=zh_CN#rd)
2. [如何用 ELK 搭建 TB 级的日志监控系统？](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247517680&idx=1&sn=57ce7829078aad1dd748244a47039612&chksm=fcf75a3dcb80d32ba66b8fd562c45df1d3fb395c0875030aecbfd5471ff2583cadcac6952295&token=154658036&lang=zh_CN#rd)
3. [实战干货！Spring Cloud Gateway 整合 OAuth2.0 实现分布式统一认证授权！](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247503249&idx=1&sn=b33ae3ff70a08b17ee0779d6ccb30b53&chksm=fcf7125ccb809b4aa4985da09e620e06c606754e6a72681c93dcc88bdc9aa7ba0cb64f52dbc3&scene=21&cur_album_id=2042874937312346114#wechat_redirect)
4. [从实现原理来讲，Nacos 为什么这么强？](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247514933&idx=1&sn=374da0ea32321baf6938ff2e611d8fce&chksm=fcf764f8cb80edee2a0c493f58570b1502fb093ccd38fd498de1f6c1213e24e0355d8bcd713f&scene=21&cur_album_id=2042874937312346114#wechat_redirect)
5. [阿里限流神器Sentinel夺命连环 17 问？](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247498039&idx=1&sn=3a3caee655ff015b46249bd51aa4dc79&chksm=fcf726facb80afecea4d48faf94a9940b80ba21b325510cf4be6f7c7bce2f3c73266857f65d1&scene=21&cur_album_id=2042874937312346114#wechat_redirect)
6. [openFeign夺命连环9问，这谁受得了？](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247496653&idx=1&sn=7185077b3bdc1d094aef645d677ec472&chksm=fcf72c00cb80a516a8d1bc3b89400e202f2cbc1fd465e6c51e84a9a3543ec1c8bcfe8edeaec2&scene=21&cur_album_id=2042874937312346114#wechat_redirect)
7. [Spring Cloud Gateway夺命连环10问？](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247499894&idx=1&sn=f1606e4c00fd15292269afe052f5bca2&chksm=fcf71fbbcb8096ad349e6da50b0b9141964c2084d0a38eba977fe8baa3fbe8af3b20c7591110&scene=21&cur_album_id=2042874937312346114#wechat_redirect)