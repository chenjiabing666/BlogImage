**大家好，我是不才陈某~**

RocketMQ 是一款开源的分布式消息系统，基于高可用分布式集群技术，提供低延时、高可靠的消息发布与订阅服务。

这篇文章，笔者整理了 RocketMQ 源码中创建线程的几点技巧，希望大家读完之后，能够有所收获。

![](https://mmbiz.qpic.cn/mmbiz_png/V71JNV78n288fFby0V5G1kWCQxnAg3s3iceJSvicm3Rdq1YrgY3Sn0ML5IibsGwED56pLUIR9CHxHp5dGviamyGnug/640?wx_fmt=png)

## 1. 创建单线程

首先我们先温习下常用的创建单线程的两种方式：

- 实现 Runnable 接口
- 继承 Thread 类

**▍一、实现 Runnable 接口**

![](https://mmbiz.qpic.cn/mmbiz_png/V71JNV78n288fFby0V5G1kWCQxnAg3s3mQOdhgKgCtnTZx7ElAt3HOF2XocELoPnbbBmcbA32YyDor9IUHeiagw/640?wx_fmt=png)

图中，MyRunnable 类实现了 Runnable 接口的 run 方法，run 方法中定义具体的任务代码或处理逻辑，而Runnable 对象是作为线程构造函数的参数。

**▍二、 继承 Thread 类**

![](https://mmbiz.qpic.cn/mmbiz_png/V71JNV78n288fFby0V5G1kWCQxnAg3s3jLFPFn2vcicLKstb6ejUgeHdroQtu4Oysbq7wKrtOUkCbyaOdUx3J8g/640?wx_fmt=png)

线程实现类直接继承 Thread ，本质上也是实现 Runnable 接口的 run 方法。

## 2. 单线程抽象类

创建单线程的两种方式都很简单，但每次创建线程代码显得有点冗余，于是 RocketMQ 里实现了一个抽象类 ServiceThread 。

![](https://mmbiz.qpic.cn/mmbiz_png/V71JNV78n288fFby0V5G1kWCQxnAg3s30PjnWXTPmKSGYHubVNUicXibicg1JZCwrQCyiaHYgP9PllRJfckV0uhjJw/640?wx_fmt=png)抽象类 ServiceThread

我们可以看到抽象类中包含了如下核心方法：

1. 定义线程名；
2. 启动线程；
3. 关闭线程。

下图展示了 RocketMQ 众多的单线程实现类。

![](https://mmbiz.qpic.cn/mmbiz_jpg/V71JNV78n288fFby0V5G1kWCQxnAg3s3YaYJr0jcdDrOlQUMJGibOWVkmludVk9aI2cfnUMANUbQEHW7piajhyaw/640?wx_fmt=jpeg)

实现类的编程模版类似 ：

![](https://mmbiz.qpic.cn/mmbiz_png/V71JNV78n288fFby0V5G1kWCQxnAg3s3ibxSxxich7amLLyGLYibRPPVUT08E0L2H2qGhqA3osWbEpq5UmQt5P3eQ/640?wx_fmt=png)

我们仅仅需要继承抽象类，并实现 **getServiceName** 和 **run** 方法即可。启动的时候，调用 **start** 方法 ， 关闭的时候调用 **shutdown** 方法。

## 3. 线程池原理

线程池是一种基于池化思想管理线程的工具，线程池维护着多个线程，等待着监督管理者分配可并发执行的任务。这避免了在处理短时间任务时创建与销毁线程的代价。线程池不仅能够保证内核的充分利用，还能防止过分调度。

JDK中提供的 **ThreadPoolExecutor** 类，是我们最常使用的线程池类。

![](https://mmbiz.qpic.cn/mmbiz_png/V71JNV78n288fFby0V5G1kWCQxnAg3s3Yxl7tic9Tp0iaYlKWNnTcxISDYnDDL2EhvuX1hd2F3AZ5hTG9Fqm6hoQ/640?wx_fmt=png)ThreadPoolExecutor构造函数

| 参数名                   | 作用                                                         |
| :----------------------- | :----------------------------------------------------------- |
| corePoolSize             | 队列没满时，线程最大并发数                                   |
| maximumPoolSizes         | 队列满后线程能够达到的最大并发数                             |
| keepAliveTime            | 空闲线程过多久被回收的时间限制                               |
| unit                     | keepAliveTime 的时间单位                                     |
| workQueue                | 阻塞的队列类型                                               |
| threadPoolFactory        | 改变线程的名称、线程组、优先级、守护进程状态                 |
| RejectedExecutionHandler | 超出 maximumPoolSizes + workQueue 时，任务会交给RejectedExecutionHandler来处理 |

![](https://mmbiz.qpic.cn/mmbiz_png/V71JNV78n288fFby0V5G1kWCQxnAg3s3RhS9l2FzrXKAza84vlpdWnzyqzeI8ACft8sjpADuPjKhibEEictxGXJw/640?wx_fmt=png)

任务的调度通过执行 execute方法完成，方法的核心流程如下：

1. 如果 workerCount < corePoolSize，创建并启动一个线程来执行新提交的任务。
2. 如果 workerCount >= corePoolSize，且线程池内的阻塞队列未满，则将任务添加到该阻塞队列中。
3. 如果 workerCount >= corePoolSize && workerCount < maximumPoolSize，且线程池内的阻塞队列已满，则创建并启动一个线程来执行新提交的任务。
4. 如果 workerCount >= maximumPoolSize，并且线程池内的阻塞队列已满, 则根据拒绝策略来处理该任务, 默认的处理方式是直接抛异常。

![](https://mmbiz.qpic.cn/mmbiz_png/V71JNV78n288fFby0V5G1kWCQxnAg3s3qnAUqtDDgQ22gWC1ibRAjd6RlmuS19FweibYjkzAfibSVywGHLR84tGZQ/640?wx_fmt=png)

## 4. 线程池封装

在 RocketMQ 里 ，网络请求都会携带命令编码，每种命令映射对应的处理器，而处理器又会注册对应的线程池。

![](https://mmbiz.qpic.cn/mmbiz_png/V71JNV78n288fFby0V5G1kWCQxnAg3s3vDtwhY63Ap492iaEeI7ibh4MFM5ETUSCQxeiczOOjIHic5fBS3W33wEq0w/640?wx_fmt=png)

当服务端 Broker 接收到发送消息命令时，都会有单独的线程池 sendMessageExecutor 来处理这种命令请求。

![](https://mmbiz.qpic.cn/mmbiz_png/V71JNV78n288fFby0V5G1kWCQxnAg3s328eWj7sh55pgfd9zAYKAujeusSB4NicT0LhP2oiaZKsr18xTKlMKiaL1Q/640?wx_fmt=png)

基于 ThreadPoolExecutor 做了一个简单的封装 ，BrokerFixedThreadPoolExecutor 构造函数包含六个核心参数：

1. 核心线程数和最大线程数相同 ，数量是：cpu核数和4比较后的最小值；
2. 空闲线程的回收的时间限制，默认1分钟；
3. 发送消息队列，有界队列，默认10000；
4. 线程工厂 ThreadFactoryImpl ，定义了线程名前缀：SendMessageThread_ 。

RocketMQ 实现了一个简单的线程工厂：**ThreadFactoryImpl**，线程工厂可以定义线程名称，以及是否是守护线程 。

![](https://mmbiz.qpic.cn/mmbiz_png/V71JNV78n288fFby0V5G1kWCQxnAg3s3hQyG18OgwhQSj5eh1JnmicpIZGSTPqr5TjrD5L7jEB1QXqE4dzQLNag/640?wx_fmt=png)线程工厂

> 开源项目 Cobar ，Xmemcached，Metamorphosis 中都有类似线程工厂的实现 。

## 5. 线程名很重要

**线程名很重要，线程名很重要，线程名很重要** ，重要的事情说三遍。

我们看到 RocketMQ 中，无论是单线程抽象类还是多线程的封装都会配置线程名 ，因为通过线程名，非常容易定位问题，从而大大提升解决问题的效率。

定位的媒介常见有两种：**日志文件**和**堆栈记录**。

**▍一、日志文件**

经常处理业务问题的同学，一定都经常与日志打交道。

![](https://mmbiz.qpic.cn/mmbiz_png/V71JNV78n288fFby0V5G1kWCQxnAg3s3HUKJCOcHsKQNSDzFibIKfDUoibJdNVjXeOe4vpLjD9GibMPgh6icBZRsrA/640?wx_fmt=png)

- 查看 ERROR 日志，追溯到执行线程， 要是线程池隔离做的好，基本可以判断出哪种业务场景出了问题；
- 通过查看线程打印的日志，推断线程调度是否正常，比如有的定时任务线程打印了开始，没有打印结束，推论当前线程可能已经挂掉或者阻塞。

**▍二、堆栈记录**

jstack 是 java 虚拟机自带的一种堆栈跟踪工具 ，主要用来查看 Java 线程的调用堆栈，线程快照包含当前 java 虚拟机内每一条线程正在执行的方法堆栈的集合，可以用来分析线程问题。

```
jstack -l 进程pid
```

![](https://mmbiz.qpic.cn/mmbiz_png/V71JNV78n288fFby0V5G1kWCQxnAg3s3iayjHvq9HPYQibE3GYPicqGfnYRgWZCcRS2X8UibeDDmnaOhOnmzHdxQjw/640?wx_fmt=png)

笔者查看线程堆栈，一般关注如下几点：

1. 当前 jvm 进程中的线程数量和线程分类是否在预期的范围内；
2. 系统接口超时或者定时任务停止的异常场景下 ，分析堆栈中是否有锁未释放，或者线程一直等待网络通讯响应；
3. 分析 jvm 进程中哪个线程占用的 CPU 最高。

## 6. 总结

本文是RocketMQ 系列文章的开篇，和朋友们简单聊聊 RocketMQ 源码里创建线程的技巧。

1. 单线程抽象类 ServiceThread

   使用者只需要实现业务逻辑以及定义线程名即可 ，不需要写冗余的代码。

2. 线程池封装

   适当封装，定义线程工厂，并合理配置线程池参数。

3. 线程名很重要

   文件日志，堆栈记录配合线程名能大大提升解决问题的效率。

RocketMQ 的多线程编程技巧很多，比如线程通讯，并发控制，线程模型等等，后续的文章会一一为大家展现。

## 最后说一句（别白嫖，求关注）

陈某每一篇文章都是精心输出，如果这篇文章对你有所帮助，或者有所启发的话，帮忙**点赞**、**在看**、**转发**、**收藏**，你的支持就是我坚持下去的最大动力！

另外陈某的[知识星球](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247518914&idx=1&sn=b3fdfd78c32b15077ac67535ccc10a00&scene=21#wechat_redirect)开通了，公众号回复关键词：**知识星球** 获取限量**30元**优惠券加入只需**89**元，一顿饭钱，但是星球回馈的价值却是巨大，目前更新了**Spring全家桶实战系列**、**亿级数据分库分表实战**、**DDD微服务实战专栏**、**我要进大厂、Spring，Mybatis等框架源码、架构实战22讲**等....每增加一个专栏价格将上涨20元

![](https://mmbiz.qpic.cn/mmbiz_png/19cc2hfD2rBvqdy8J18dlib7KepGcvuW08g7COtYpQvVoZzRtQFLgaW1GxibV1vsWMQ27S4wsOlt1ySoh3uEAeIw/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

关注公众号：【码猿技术专栏】，公众号内有超赞的粉丝福利，回复：加群，可以加入技术讨论群，和大家一起讨论技术，吹牛逼！