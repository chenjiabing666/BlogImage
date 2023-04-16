**大家好，我是不才陈某~**

优秀且经验丰富的 Java 开发人员的特点之一是对 API 的广泛了解，包括 JDK 和第三方库。如何使用现有的 API 进行开发，而不是为常见的东西编写新的代码。是提升开发效率必选之路。

一般来说，我会为日常项目提供有用的库，包括 Log4j 等日志库、Jackson 等 JSON 解析库以及 JUnit 和 Mockito 等单元测试 API。如果您需要在项目中使用它们，则可以在项目的类路径中包含这些库的 JAR 以开始使用它们，也可以使用Maven进行依赖管理。

**对 Java 程序员有用的开源库**

下面是收集的一些有用的第三方库，Java 开发人员可以在他们的应用程序中使用它们来完成很多有用的任务。为了使用这些库，Java 开发人员应该熟悉这一点，这就是本文的重点。如果您有一个想法，那么您可以研究该库并使用它。

## **1. 日志库**

日志库非常常见，因为您在每个项目中都需要它们。它们对于服务器端应用程序来说是最重要的，因为日志只放置在您可以看到应用程序正在发生什么的地方。尽管 JDK 附带了自己的日志库，但仍有更好的替代方案可用，例如 Log4j、SLF4j 和 LogBack。

Java 开发人员应该熟悉日志库的优缺点，并知道为什么使用 SLF4j 比普通的 Log4j 更好。

## **2. JSON解析库**

在当今的 Web 服务和物联网世界中，JSON 已成为将信息从客户端传输到服务器的首选协议。它们已取代 XML，成为以独立于平台的方式传输信息的首选方式。

不幸的是，JDK 没有JSON 库。但是，有许多优秀的第三方库可以让您解析和创建 JSON 消息，例如 Jackson 和 Gson。

Java Web 开发人员应该至少熟悉这些库中的一个。

## **3. 单元测试库**

单元测试是将普通开发人员与优秀开发人员区分开来的最重要的事情。程序员经常得到不编写单元测试的借口，但避免单元测试的最常见借口是缺乏流行单元测试库的经验和知识，包括 JUnit、Mockito 和 PowerMock。

![](https://www.java-family.cn/BlogImage/20230209201312.png)

## **4. 通用库**

Java 开发人员可以使用一些优秀的通用第三方库，例如 Apache Commons 和 Google Guava。我总是在我的项目中包含这些库，因为它们简化了很多任务。

重新发明轮子是没有意义的。我们应该更喜欢使用久经考验的库，而不是时不时地编写我们自己的例程。

![](https://www.java-family.cn/BlogImage/20230209201317.png)

Java 开发人员最好熟悉 Google Guava 和 Apache Commons 库。

## **5. HTTP 库**

我不喜欢 JDK 的一件事是它们缺乏对 HTTP 的支持。虽然您可以使用包中的类建立 HTTP 连接 java.net，但使用开源第三方库（如 Apache HttpClient 和 HttpCore）并不容易或无缝。

![](https://www.java-family.cn/BlogImage/20230209201322.png)

尽管 JDK 9 带来了对 HTTP 2.0 的支持以及对 HTTP 的更好支持，但我强烈建议所有 Java 开发人员熟悉流行的 HTTP 客户端库，包括 HttpClient 和 HttpCore。

## **6. XML 解析库**

有许多 XML 解析库，包括 Xerces、JAXB、JAXP、Dom4j 和 Xstream。Xerces2 是 Apache Xerces 系列中的下一代高性能、完全兼容的 XML 解析器。这个新版本的 Xerces 引入了 Xerces Native Interface (XNI)，这是一个用于构建解析器组件和配置的完整框架，它非常模块化且易于编程。

![](https://www.java-family.cn/BlogImage/20230209201327.png)

Apache Xerces2 解析器是 XNI 的参考实现，但其他解析器组件、配置和解析器可以使用 Xerces Native Interface 编写。Dom4j 是另一个用于 Java 应用程序的灵活 XML 框架。

## **7. Excel 阅读库**

信不信由你——所有现实世界的应用程序都必须以某种形式与 Microsoft Office 交互。许多应用程序需要提供在 Excel 中导出数据的功能，如果您必须从 Java 应用程序中执行相同操作，则需要 Apache POI API。

这是一个非常丰富的库，允许您 从 Java 程序读取和写入 XLS 文件。您可以查看该链接以获取在核心 Java 应用程序中读取 Excel 文件的工作示例。

## **8. 字节码库**

如果您正在编写生成代码或与字节码交互的框架或库，那么您需要一个字节码库。

它们允许您读取和修改应用程序生成的字节码。Java 世界中一些流行的字节码库是 javassist 和 Cglib Nodep。

![](https://www.java-family.cn/BlogImage/20230209201335.png)

Javassist（JAVA 编程助手）使 Java 字节码操作变得非常简单。它是一个用于在 Java 中编辑字节码的类库。ASM 是另一个有用的字节码编辑库。

## **9. 数据库连接池库**

如果您从 Java 应用程序与数据库进行交互，但不使用数据库连接池库，那么，您会丢失一些东西。

由于在运行时创建数据库连接需要时间并且使请求处理速度变慢，因此始终建议使用数据库连接库。一些流行的是 Commons Pool 和 DBCP。

在 Web 应用程序中，它的 Web 服务器通常提供这些功能，但在核心 Java 应用程序中，您需要将这些连接池库包含到您的类路径中才能使用数据库连接池。

## **10. 消息库**

与日志记录和数据库连接类似，消息传递也是许多实际 Java 应用程序的共同特征。

Java 提供 JMS 或 Java 消息传递服务，它不是 JDK 的一部分。对于此组件，您需要包含一个单独的 jms.jar

![](https://www.java-family.cn/BlogImage/20230209201339.png)

同样，如果您使用第三方消息传递协议，例如 Tibco RV，那么您需要 tibrv.jar 在应用程序类路径中使用第三方 JAR 。

## **11. PDF 库**

与 Microsoft Excel 类似，PDF 库是另一种普遍存在的格式。如果您需要在应用程序中支持 PDF 功能，例如 在 PDF 文件中导出数据，您可以使用 iText 和 Apache FOP 库。



两者都提供有用的 PDF 相关功能，但 iText 更丰富更好。

![](https://www.java-family.cn/BlogImage/20230209201343.png)

## **12. 日期和时间库**

在 Java 8 之前，JDK 的数据和时间库有很多缺陷，因为它们不是线程安全的、不可变的和容易出错的。许多 Java 开发人员依靠 JodaTime 来实现他们的日期和时间要求。

从 JDK 8 开始，没有理由使用 Joda，因为您可以在 JDK 8 的新日期和时间 API中获得所有这些功能，但是如果您使用的是较旧的 Java 版本，那么 JodaTime 是一个值得学习的库。

![](https://www.java-family.cn/BlogImage/20230209201350.png)

## **13. 集合库**

尽管 JDK 拥有丰富的集合库，但也有一些第三方库提供了更多选项，例如 Apache Commons 集合、Goldman Sachs 集合、Google 集合和 Trove。

Trove 库特别有用，因为它为 Java 提供了高速的常规和原始集合。

![](https://www.java-family.cn/BlogImage/20230209201354.png)

FastUtil 是另一个类似的 API。它通过提供特定类型的映射、集合、列表和优先级队列来扩展 Java 集合框架，这些映射、集合、列表和优先级队列具有较小的内存占用、快速访问和插入；它还提供大（64 位）数组、集合和列表，以及用于二进制和文本文件的快速、实用的 I/O 类。

## **14. 电子邮件 API**

javax.mail 和 Apache Commons Email 都提供了用于从 Java 发送电子邮件的 API 。它建立在 JavaMail API 之上，旨在简化它。

![](https://www.java-family.cn/BlogImage/20230209201359.png)

## **15. HTML 解析库**

与JSON和XML类似，HMTL 是我们许多人必须处理的另一种常见格式。值得庆幸的是，我们有 JSoup，它极大地简化了在 Java 应用程序中使用 HTML。

您可以使用JSoup不仅解析 HTML，还可以创建 HTML 文档

![](https://www.java-family.cn/BlogImage/20230209201402.png)

它提供了一个非常方便的 API 用于提取和操作数据，使用最好的DOM、CSS 和类似 jquery 的方法。JSoup 实现了 WHATWG HTML5 规范并将HTML解析为与现代浏览器相同的 DOM。

## **16.密码库**

Apache Commons Codec 包包含各种格式的简单编码器和解码器，例如Base64和 Hexadecimal。

除了这些广泛使用的编码器和解码器之外，编解码器包还维护了一组语音编码实用程序。

![](https://www.java-family.cn/BlogImage/20230209201407.png)

## **17. 嵌入式 SQL 数据库库**

我真的很喜欢像 H2 这样的内存数据库，你可以将它嵌入到你的 Java 应用程序中。它们非常适合测试您的 SQL 脚本和运行需要数据库的单元测试。但是，H2 不是唯一的 DB，您还可以选择 Apache Derby 和 HSQL。

![](https://www.java-family.cn/BlogImage/20230209201410.png)

## **18. JDBC 故障排除库**

有一些很好的 JDBC 扩展库可以让调试更容易，比如 P6spy。

这是一个库，可以无缝拦截和记录数据库数据，而无需更改应用程序的代码。您可以使用它们来记录 SQL 查询及其时间。

例如，如果您在代码中使用PreparedStatment和CallableStatement，这些库可以记录带有参数的准确调用以及执行所需的时间。

![](https://www.java-family.cn/BlogImage/20230209201420.png)

## **19. 序列化库**

Google 协议缓冲区是一种以高效且可扩展的格式对结构化数据进行编码的方法。它是Java 序列化的更丰富和更好的替代方案。我强烈建议有经验的 Java 开发人员学习 Google Protobuf。

![](https://www.java-family.cn/BlogImage/20230209201424.png)

## **20. 网络库**

一些有用的网络库是 Netty 和 Apache MINA。如果您正在编写需要执行低级网络任务的应用程序，请考虑使用这些库。

![](https://www.java-family.cn/BlogImage/20230209201427.png)

以上就是今天小编分享给大家的一些工作中常用的库，了解并熟练的运用他们，不仅可以大大提高你的开发效率，也可以学习优秀代码的设计，提高自己的编码能力。

## 最后说一句（别白嫖，求关注）

陈某每一篇文章都是精心输出，如果这篇文章对你有所帮助，或者有所启发的话，帮忙**点赞**、**在看**、**转发**、**收藏**，你的支持就是我坚持下去的最大动力！

另外陈某的[知识星球](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247518914&idx=1&sn=b3fdfd78c32b15077ac67535ccc10a00&scene=21#wechat_redirect)开通了，公众号回复关键词：**知识星球** 获取限量**30元**优惠券加入只需**89**元，一顿饭钱，但是星球回馈的价值却是巨大，目前更新了**Spring全家桶实战系列**、**亿级数据分库分表实战**、**DDD微服务实战专栏**、**我要进大厂、Spring，Mybatis等框架源码、架构实战22讲**等....每增加一个专栏价格将上涨20元

![](https://mmbiz.qpic.cn/mmbiz_png/19cc2hfD2rBvqdy8J18dlib7KepGcvuW08g7COtYpQvVoZzRtQFLgaW1GxibV1vsWMQ27S4wsOlt1ySoh3uEAeIw/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

关注公众号：【码猿技术专栏】，公众号内有超赞的粉丝福利，回复：加群，可以加入技术讨论群，和大家一起讨论技术，吹牛逼！