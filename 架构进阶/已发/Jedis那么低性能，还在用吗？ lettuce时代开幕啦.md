**大家好，我是不才陈某~**

在与 [知识星球](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247518914&idx=1&sn=b3fdfd78c32b15077ac67535ccc10a00&scene=21#wechat_redirect) 的球友交流中，最近有很多小伙伴在面大厂， 经常遇到下面的问题：**3大redis客户端：Jedis、Redisson、Lettuce ，如何选型？**

今天就来深入聊聊这个问题

## Redis 的3大 Java 客户端组件

Redis 官方推荐的 Java 客户端有Jedis、lettuce 和 Redisson。

### **客户端组件1：Jedis**

Jedis 是老牌的 Redis 的 Java 实现客户端，提供了比较全面的 Redis 命令的支持、

Jedis 在线网址：http://tool.oschina.net/uploads/apidocs/redis/clients/jedis/Jedis.html

优点：

- 支持全面的 Redis 操作特性（可以理解为API比较全面）。

缺点：

- 使用阻塞的 I/O，且其方法调用都是同步的，程序流需要等到 sockets 处理完 I/O 才能执行，不支持异步；
- Jedis 客户端实例不是线程安全的，所以需要通过连接池来使用 Jedis。

### **客户端组件2：Redisson**

Redisson 是一个在 Redis 的基础上实现的 Java 驻内存数据网格（In-Memory Data Grid）。

Redisson 提供了使用Redis 的最简单和最便捷的方法。

它不仅提供了一系列的分布式的 Java 常用对象，还提供了许多分布式服务。

其中包括：

BitSet, Set, Multimap, SortedSet, Map, List, Queue, BlockingQueue, Deque, BlockingDeque, Semaphore, Lock, AtomicLong, CountDownLatch, Publish / Subscribe, Bloom filter, Remote service, Spring cache, Executor service, Live Object service, Scheduler service)

Redisson 的宗旨是促进使用者对Redis的关注分离（Separation of Concern），从而让使用者能够将精力更集中地放在处理业务逻辑上。

redisson 官网地址：https://redisson.org/

redisson git项目地址：https://github.com/redisson/redisson

优点：

- 使用者对 Redis 的关注分离，可以类比 Spring 框架，这些框架搭建了应用程序的基础框架和功能，提升开发效率，让开发者有更多的时间来关注业务逻辑；
- 提供很多分布式相关操作服务，例如，分布式锁，分布式集合，可通过Redis支持延迟队列等。
- Redisson基于Netty框架的事件驱动的通信层，其方法调用是异步的。
- Redisson的API是线程安全的，所以可以操作单个Redisson连接来完成各种操作

缺点：

- Redisson 对字符串的操作支持比较差。

### **客户端组件3：lettuce**

lettuce （[ˈletɪs]），是一种可扩展的线程安全的 Redis 客户端，支持异步模式。

如果避免阻塞和事务操作，如BLPOP和MULTI/EXEC，多个线程就可以共享一个连接。

lettuce 底层基于 Netty，支持高级的 Redis 特性，比如哨兵，集群，管道，自动重新连接和Redis数据模型。

lettuce能够支持redis4，需要java8及以上。

lettuce是基于netty实现的与redis进行同步和异步的通信。

lettuce 官网地址：https://lettuce.io/

lettuce git项目地址：https://github.com/lettuce-io/lettuce-core

优点：

- 支持同步异步通信模式；
- Lettuce 的 API 是线程安全的，如果不是执行阻塞和事务操作，如BLPOP和MULTI/EXEC，多个线程就可以共享一个连接。

## lettuce、jedis、Redisson 三者比较

jedis使直接连接redis server,如果在多线程环境下是非线程安全的，这个时候只有使用连接池，为每个jedis实例增加物理连接；

lettuce的连接是基于Netty的，连接实例（StatefulRedisConnection）可以在多个线程间并发访问，StatefulRedisConnection是线程安全的，所以一个连接实例可以满足多线程环境下的并发访问，当然这也是可伸缩的设计，一个连接实例不够的情况也可以按需增加连接实例。

Jedis 和 lettuce 是比较纯粹的 Redis 客户端，几乎没提供什么高级功能。

Jedis 的性能比较差，所以如果你不需要使用 Redis 的高级功能的话，优先推荐使用 lettuce。

Redisson实现了分布式和可扩展的Java数据结构，和Jedis相比，功能较为简单，不支持字符串操作，不支持排序、事务、管道、分区等Redis特性。

Redisson的宗旨是促进使用者对Redis的关注分离，从而让使用者能够将精力更集中地放在处理业务逻辑上。

如果需要分布式锁，分布式集合等分布式的高级特性，添加Redisson结合使用，因为Redisson本身对字符串的操作支持很差。

Redisson 的优势是提供了很多开箱即用的 Redis 高级功能，如果你的应用中需要使用到 Redis 的高级功能，建议使用 Redisson。

具体 Redisson 的高级功能可以参考：https://redisson.org/

## 使用建议

建议：lettuce + Redisson

在spring boot2之后，redis连接默认就采用了lettuce。

就想 spring  的本地缓存，默认使用Caffeine一样，

这就一定程度说明了，**lettuce 比 Jedis在性能的更加优秀**。

## 生产问题

### 问题1 链接断裂怎么办？

**小伙伴问题1 链接断裂怎么办？**

具体问题：Jedis有心跳 能保持长连接，lettuce好像没有心跳。阿里ecs 搭的redis tcp长时间没有传输 就会断开 ，但是lettuce感知不到， 再执行redis请求就会提示链接不可用

具体来说，可以通过用netty的空闲检测机制来维持连接。

*注意：是空闲检测 不是心跳机制。*

**什么是心跳机制**

心跳是在TCP长连接中，客户端和服务端定时向对方发送数据包通知对方自己还在线，保证连接的有效性的一种机制。在服务器和客户端之间一定时间内没有数据交互时, 即处于 idle 状态时, 客户端或服务器会发送一个特殊的数据包给对方, 当接收方收到这个数据报文后, 也立即发送一个特殊的数据报文, 回应发送方, 此即一个 PING-PONG 交互.

自然地, 当某一端收到心跳消息后, 就知道了对方仍然在线, 这就确保 TCP 连接的有效性.

空闲检测 是心跳的基础机制。

**什么是空闲检测**

就是检测通道中的读写数据包，如果一段时间内，没有收到读写数据包，就会出发  IdleStateEvent 空闲状态事件。

所以，可以借助这个机制，主动关闭 空闲的、被异常断开的连接。

这就需要大家，熟悉Netty的开发和源码，关于Netty源码和开发的内容，请参见《java高并发核心编程卷1加强版》 ，很多小伙伴，就是通过此书掌握的。

最后，奉上问题解决的参考代码：

```java
import io.lettuce.core.resource.ClientResources;
import io.lettuce.core.resource.NettyCustomizer;
import io.netty.bootstrap.Bootstrap;
import io.netty.channel.Channel;
import io.netty.channel.ChannelDuplexHandler;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.timeout.IdleStateEvent;
import io.netty.handler.timeout.IdleStateHandler;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
 
@Configuration
public class ClientConfig {
 
    @Bean
    public ClientResources clientResources(){
 
        NettyCustomizer nettyCustomizer = new NettyCustomizer() {
 
            @Override
            public void afterChannelInitialized(Channel channel) {
                channel.pipeline().addLast(
                        //此处事件必须小于超时时间 
                        new IdleStateHandler(40, 0, 0));
                channel.pipeline().addLast(new ChannelDuplexHandler() {
                    @Override
                    public void userEventTriggered(ChannelHandlerContext ctx, Object evt) throws Exception {
                        if (evt instanceof IdleStateEvent) {
                            ctx.disconnect();
                        }
                    }
                });
            }
 
            @Override
            public void afterBootstrapInitialized(Bootstrap bootstrap) {
 
            }
 
        };
 //替换掉 NettyCustomizer 通道初始化处理器
        return ClientResources.builder().nettyCustomizer(nettyCustomizer ).build();
    }
}
```

## 写在最后

这个组件，是一个新的组件，性能比 jedis 高太多，很多小伙伴一样用起来了。

赶紧用起来，要不然，技术水平又落到上个时代去了。

## 最后说一句（别白嫖，求关注）

陈某每一篇文章都是精心输出，如果这篇文章对你有所帮助，或者有所启发的话，帮忙**点赞**、**在看**、**转发**、**收藏**，你的支持就是我坚持下去的最大动力！

另外陈某的[知识星球](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247518914&idx=1&sn=b3fdfd78c32b15077ac67535ccc10a00&scene=21#wechat_redirect)开通了，公众号回复关键词：**知识星球** 获取限量**30元**优惠券加入只需**89**元，一顿饭钱，但是星球回馈的价值却是巨大，目前更新了**Spring全家桶实战系列**、**亿级数据分库分表实战**、**DDD微服务实战专栏**、**我要进大厂、Spring，Mybatis等框架源码、架构实战22讲**等....每增加一个专栏价格将上涨20元

![](https://mmbiz.qpic.cn/mmbiz_png/19cc2hfD2rBvqdy8J18dlib7KepGcvuW08g7COtYpQvVoZzRtQFLgaW1GxibV1vsWMQ27S4wsOlt1ySoh3uEAeIw/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

关注公众号：【码猿技术专栏】，公众号内有超赞的粉丝福利，回复：加群，可以加入技术讨论群，和大家一起讨论技术，吹牛逼！
