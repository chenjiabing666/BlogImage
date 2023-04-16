**大家好，我是不才陈某~**

大家在使用IDEA开发的时候有没有注意到过一个提示，在字段上使用Spring的依赖注入注解`@Autowired`后会出现如下警告

> Field injection is not recommended (字段注入是不被推荐的)

但是使用`@Resource`却不会出现此提示

网上文章大部分都是介绍两者的区别，没有提到为什么，今天来总结一下

## Spring常见的DI方式

- **构造器注入**：利用构造方法的参数注入依赖
- **Setter注入**：调用Setter的方法注入依赖
- **字段注入**：在字段上使用`@Autowired/Resource`注解

### **@Autowired VS @Resource**

事实上，他们的基本功能都是通过注解实现**依赖注入**，只不过`@Autowired`是`Spring`定义的，而`@Resource`是`JSR-250`定义的。大致功能基本相同，但是还有一些细节不同：

- **依赖识别方式**：`@Autowired`默认是**byType**可以使用`@Qualifier`指定Name，`@Resource`**默认ByName**如果**找不到则ByType**
- **适用对象**：`@Autowired`可以对**构造器、方法、参数、字段**使用，`@Resource`只能对**方法、字段**使用
- **提供方**：`@Autowired`是**Spring**提供的，`@Resource`是**JSR-250**提供的

## 各种DI方式的优缺点

参考Spring官方文档，建议了如下的使用场景：

- **构造器注入**：**强依赖性**（即必须使用此依赖），**不变性**（各依赖不会经常变动）
- **Setter注入**：**可选**（没有此依赖也可以工作），**可变**（依赖会经常变动）
- **Field注入**：大多数情况下尽量**少使用**字段注入，一定要使用的话， **@Resource相对@Autowired**对IoC容器的**耦合更低**

## Field注入的缺点

- **不能像构造器那样注入不可变的对象**
- **依赖对外部不可见**，外界可以看到构造器和setter，但无法看到私有字段，自然无法了解所需依赖
- 会导致**组件与IoC容器紧耦合**（这是最重要的原因，离开了IoC容器去使用组件，在注入依赖时就会十分困难）
- 导致**单元测试也必须使用IoC容器**，原因同上
- **依赖过多时不够明显**，比如我需要10个依赖，用构造器注入就会显得庞大，这时候应该考虑一下此组件是不是**违反了单一职责原则**

### **为什么IDEA只对@Autowired警告**

Field注入虽然有很多缺点，但它的好处也不可忽略：那就是**太方便了**。使用构造器或者setter注入需要写更多业务无关的代码，十分麻烦，而字段注入大幅简化了它们。并且绝大多数情况下业务代码和框架就是强绑定的，完全松耦合只是一件理想上的事，牺牲了敏捷度去过度追求松耦合反而得不偿失。

> 那么问题来了，为什么IDEA只对@Autowired警告，却对@Resource视而不见呢？

**个人认为**，就像我们前面提到过的：**@Autowired**是**Spring**提供的，它是**特定IoC提供的特定注解**，这就导致了应用与框架的**强绑定**，一旦换用了其他的IoC框架，是**不能够支持注入**的。

而 **@Resource**是**JSR-250**提供的，它是**Java标准**，我们使用的IoC容器应当去兼容它，这样即使更换容器，也可以正常工作。

---

**微信8.0将好友放开到了一万，小伙伴可以加我大号了，先到先得，再满就真没了**
![](https://www.java-family.cn/BlogImage/20220828212533.png)

## 推荐阅读（求关注，别白嫖！）

1. [Netty 如何做到单机百万并发？](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247518108&idx=1&sn=006365f9f0a4ec117cfd49c16fb42e4c&chksm=fcf75851cb80d147f5d85ea33be318158c247b45381061cea47d04170cfb7309b8ff331b6559&token=1204159206&lang=zh_CN#rd)
2. [接口流量突增，如何做好性能优化？](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247518033&idx=1&sn=73ce40caad5faaa2f4bbfe6589f4324e&chksm=fcf7589ccb80d18a48f6dd993a894c575deb927258da10c98edcf51dc55da821d07854284ead&token=1204159206&lang=zh_CN#rd)
3. [实战干货！Spring Cloud Gateway 整合 OAuth2.0 实现分布式统一认证授权！](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247503249&idx=1&sn=b33ae3ff70a08b17ee0779d6ccb30b53&chksm=fcf7125ccb809b4aa4985da09e620e06c606754e6a72681c93dcc88bdc9aa7ba0cb64f52dbc3&scene=21&cur_album_id=2042874937312346114#wechat_redirect)
4. [从实现原理来讲，Nacos 为什么这么强？](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247514933&idx=1&sn=374da0ea32321baf6938ff2e611d8fce&chksm=fcf764f8cb80edee2a0c493f58570b1502fb093ccd38fd498de1f6c1213e24e0355d8bcd713f&scene=21&cur_album_id=2042874937312346114#wechat_redirect)
5. [阿里限流神器Sentinel夺命连环 17 问？](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247498039&idx=1&sn=3a3caee655ff015b46249bd51aa4dc79&chksm=fcf726facb80afecea4d48faf94a9940b80ba21b325510cf4be6f7c7bce2f3c73266857f65d1&scene=21&cur_album_id=2042874937312346114#wechat_redirect)
6. [openFeign夺命连环9问，这谁受得了？](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247496653&idx=1&sn=7185077b3bdc1d094aef645d677ec472&chksm=fcf72c00cb80a516a8d1bc3b89400e202f2cbc1fd465e6c51e84a9a3543ec1c8bcfe8edeaec2&scene=21&cur_album_id=2042874937312346114#wechat_redirect)
7. [Spring Cloud Gateway夺命连环10问？](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247499894&idx=1&sn=f1606e4c00fd15292269afe052f5bca2&chksm=fcf71fbbcb8096ad349e6da50b0b9141964c2084d0a38eba977fe8baa3fbe8af3b20c7591110&scene=21&cur_album_id=2042874937312346114#wechat_redirect)



**如果你喜欢这篇文章，请帮忙点赞转发支持我，感谢～**