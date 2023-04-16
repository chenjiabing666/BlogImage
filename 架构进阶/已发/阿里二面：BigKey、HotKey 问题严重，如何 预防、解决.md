**大家好，我是不才陈某~**

BigKey、HotKey是 日常生产中经常会碰到由于redis集群的不当访问，造成的线上问题。

而且，这也是常见的面试题。

在咱们社群的面试交流中，有很多小伙伴在面试网易、滴滴、京东等大厂的二面、三面中遇到了这个问题。

**前段时间，有一个[知识星球](https://mp.weixin.qq.com/s/gTR6znZVC1WnperfCrhQVw)的小伙伴在面试阿里的时候，又遇到了此问题。**

所以，陈某在这里，结合行业生产案例，特意给大家，做一个彻底的、系统的梳理。

**大家按照这个思路去作答，一定能拿出一个令人 满意的答案， 喜提一个优质offer。**

## 问题的严重性

首先，要申明一下，问题的严重性。

BigKey（大key）和HotKey（热key）的问题是较常见。

这类问题不止会使服务的性能下降，还会影响用户正常使用功能，

甚至会造成大范围的服务故障，故障有时还会发生连环效应，导致更加严重的后果，发生系统的雪崩，**造成巨大的经济损失，巨大的品牌损伤**。

所以，在 Redis 运维过程中，由于 Bigkey 的存在，DBA 也一直和业务开发方强调 Bigkey 的规避方法以及危害。

**在开发的过程中，开发同学，也需要十分重视和预防这个问题。**

## 一、什么是BigKey、HotKey？

### **什么是BigKey**

俗称“大key”，是指redis在日常生产的过程中，某些key所占内存空间过大。

通俗来说，redis是key-value的存储方式，当一个key所对应的存储数值达到一定程度，就会出现大key的情况。

redis里有多种数据存储结构，如String、List、Hash等，每种存储结构都有能够承载的数据限值。当一个key包含的内容接近限制，或者高于平均值，大key就产生了。

在 Redis 中，一个字符串类型最大可以到 512MB，一个二级数据结构（比如 hash、list、set、zset 等）可以存储大约 40 亿个(2^32-1)个元素，

但实际上不会达到这么大的值，一般情况下如果达到下面的情况，就可以认为它是 Bigkey 了。

- 【字符串类型】：单个 string 类型的 value 值超过 1MB，就可以认为是 Bigkey。
- 【非字符串类型】：哈希、列表、集合、有序集合等， 它们的元素个数超过 2000 个，就可以认为是 Bigkey。

### 什么是HotKey

俗称“热key”，一个key对应在一个redis分片上，当短时间内大量的请求打到该分片上，key被频繁访问，该key就是热key。

当大量的请求，经过分发和计算，最终集中于同一个redis实例下的某个key时，该key由于被请求频率过高，而占用掉了大量资源。

而其他分片，由于key的不合理分配导致请求量较少。

整个redis集群呈现出了资源使用不均衡的现象。

**举个例子**：一线女明星官宣领证结婚，短时间内该女星微博账号被访问量激增（假设该账号内容被同步在缓存，账号id作为key），微博服务瘫痪（不具备任何实时参考性，仅作为虚拟的例子）。

在该场景下，上述key被大量访问，造成热key。

总之，在某个Key接收到的访问次数、显著高于其它Key时，我们可以将其称之为HotKey，

从访问量上来说，常见的HotKey如：

- 某Redis实例的每秒总访问量为10000，而其中一个Key的每秒访问量达到了7000（访问次数显著高于其它Key）
- 对一个拥有上千个成员且总大小为1MB的HASH Key每秒发送大量的HGETALL（带宽占用显著高于其它Key）
- 对一个拥有数万个成员的ZSET Key每秒发送大量的ZRANGE（CPU时间占用显著高于其它Key）



## 二、服务中的bigkey和hotkey

## 会导致什么问题

我们可以通过上述两种key的特性，来简单分析可能出现的几种问题。

### 第1：bigkey的问题

主要的问题是一个key所占空间太大，内存空间分配不均衡（小tips：redis是内存型key-value数据库）。那就可能引发以下问题：

**1.数据请求大量超时**：

redis是单线程的，当一个key数据响应的久一点，就会造成后续请求频繁超时。如果服务容灾措施考虑得不够，会引发更大的问题。

**2.侵占带宽网络拥堵**：

当一个key所占空间过大，多次请求就会占用较大的带宽，直接影响服务的正常运行。

**3.内存溢出或处理阻塞**：

当一个较大的key存在时，持续新增，key所占内存会越来越大，严重时会导致内存数据溢出；当key过期需要删除时，由于数据量过大，可能发生主库较响应时间过长，主从数据同步异常（删除掉的数据，从库还在使用）。

### 第2：hotkey的问题

**热key**，热key的问题是单点访问频率过高。那就可能引发以下问题：

**1.分片服务瘫痪**：

redis集群会分很多个分片，每个分片有其要处理的数据范围。当某一个分片被频繁请求，该分片服务就可能会瘫痪。

**2.Redis 分布式集群优势弱化**：

如果请求不够均衡，过于单点，那么redis分布式集群的优势也必然被弱化。

**3.可能造成资损**：

在极端场景下，容易发生边界数据处理不及时，在订单等场景下，可能造成资损。

**4.引发缓存击穿**：

我们都知道，当缓存请求不到，就会去请求数据库。如果请求过于集中，redis承载不了，就会有大量请求打到数据库。**此时，可能引发数据库服务瘫痪。进而引发系统雪崩**。

**5.cpu占用高，影响其他服务**：

单个分片cpu占用率过高，其他分片无法拥有cpu资源，从而被影响。

## 三、如何发现bigkey和hotkey

#### **1.业务分析结合技术方案：**

通常需要对业务场景做分析，结合技术方案去判断是否会出现大key、热key的问题。

比如说：

（1）购物车场景，当一个购物车的key设计，没有上限，没有其他随机值约束，仅使用了mid。这个时候就要注意，如果有个购物狂，一次加购5w件商品怎么办？

（2）活动资格列表场景，当一个活动的资格查询list被放入一个key，活动期间频繁的查询和操作。这个时候就要注意，list的数据量有多少？查询资格的操作是否集中？如果集中，qps是多少？

#### **2.借助redis命令来发现：**

Redis4.0 及以上版本提供了--Bigkeys, --hotkeys 命令，可以分析出实例中每种数据结构的 top 1 的 Bigkey，同时给出了每种数据类型的键值个数以及平均大小。

查看bigkey：redis-cli -a 登录密码 --bigkeys

查看hotkey：redis-cli -a 登录密码 --hotkeys

--bigkey 的使用示例

![](https://mmbiz.qpic.cn/mmbiz_png/xlgvgPaib7WMjluibkF7MjLJx4iarLf6SaDB6jvaSpYjaCbgHSzkOSdt9vRmXzj6kVpx7eQzY7cbC2o9E6ZibZy78A/640?wx_fmt=png)

#### **3.借助工具：**

(1)可使用redis可视化工具进行查看（例如：another redis desktop manager）

![](https://mmbiz.qpic.cn/mmbiz_png/xlgvgPaib7WMjluibkF7MjLJx4iarLf6SaDV5aMnIpqn3sPLqrOorJV4deK7UOxSF5gRtRAzWoMNj1D5oGaLXPUrQ/640?wx_fmt=png)

可视化的工具可以明确给出redis集群当下的信息，经过简要数据分析，便可观测异常。

(2)借助市面上的开源工具（本文暂不对此深入探讨）

redis-rdb-tools（附：https://github.com/sripathikrishnan/redis-rdb-tools）

（3）借助公司的自研工具

如果 vivo内部的 DaaS（数据即服务）平台。

#### 4.RDB 文件分析法

通过 RDB 文件，分析 big key

## 四、如何解决bigkey和hotkey问题

解决方案

### bigkey的解决方案

主要的方法：对 big key 进行拆分

对 big key 存储的数据 （big value）进行拆分，变成value1，value2… valueN,

如果big value 是个大json 通过 mset 的方式，将这个 key 的内容打散到各个实例中，减小big key 对数据量倾斜造成的影响。

如果big value 是个大list，可以拆成将list拆成。= list_1， list_2, list3, listN

其他数据类型同理

### hotkey的解决方案

主要的方法：使用本地缓存

在 client 端使用本地缓存，从而降低了redis集群对hot key的访问量，

但是本地缓存 ，带来两个问题：1、如果对可能成为 hot key 的 key 都进行本地缓存，那么本地缓存是否会过大，从而影响应用程序本身所需的缓存开销。

2、如何保证本地缓存和redis集群数据的有效期的一致性。

以上两个问题，具体看：[聊聊 Redis+Caffeine 两级缓存](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247511216&idx=1&sn=4f323dd6686f6d24869dde5bce474f19&chksm=fcf7737dcb80fa6bd0ca927b630be92e790293a636464387bf595bd973fb890166fbac4334d6&token=1688209513&lang=zh_CN#rd)

## 五、生产实例：

### 以下是vivo团队Bigkey问题的解决方案

*此生产实例，非常宝贵，是珍贵的一线工业级实操案例，来源于 vivo 互联网数据库团队- Du Ting*

*陈某仅仅是将其结构，做进一步的梳理，方便大家学习。*

### vivo 团队运维的Redis集群的介绍

全网 Redis 集群有 2200 个以上，实例数量达到 4.5 万以上，

进行一次全网 Bigkey 检查，估计需要以年为时间单位，非常耗时。

### Bigkey的来源

 Bigkey 一般都是由于程序设计不当、或者对于数据规模 预估 失策，比如以下的情况。

- 【统计】场景

  遇到一个统计类 key 记录访问用户的 IP，随着网站访问的用户越来越多，这个 key 的元素会越来越大，形成 Bigkey。

- 【缓存】场景

  CacheAside 模式，业务程序 将数据从数据库查询出来序列化放到 Redis 里，就会查询数据库并将查询到的数据追加到 Redis 缓存中，短时间内会缓存大量的数据到 Redis 的 key 中，形成 Bigkey。

- 【队列】场景

  把 Redis 当做队列使用场景，如果消费不及时，将导致队列越来越大，出现 Bigkey。



#### 问题1：内存空间不均匀

内存空间不均匀会不利于集群对内存的统一管理，有数据丢失风险。

下图中的三个节点是同属于一个集群，它们的 key 的数量比较接近，但内存容量相差比较多，存在 Bigkey 的实例占用的内存多了 4G 以上了。

![](https://mmbiz.qpic.cn/mmbiz_png/xlgvgPaib7WMjluibkF7MjLJx4iarLf6SaDf9JI2YhntwSx0XasPIibhdlkwNPxic4dbpCcEWLqYxH7Mof6MqGJRSnQ/640?wx_fmt=png)

可以使用 Daas 平台“工具集-操作项管理”，选择对应的 slave 实例执行分析，找出具体的 Bigkey。

#### 问题2：超时阻塞

Redis 是单线程工作的，通俗点讲就是同一时间只能处理一个 Redis 的访问命令，

操作 Bigkey 的命令通常比较耗时，这段时间 Redis 不能处理其他命令，其他命令只能阻塞等待，这样会造成客户端阻塞，导致客户端访问超时，更严重的会造成 master-slave 的故障切换。

当然，造成阻塞的操作不仅仅是业务程序的访问，还有 key 的自动过期的删除、del 删除命令，对于 Bigkey，这些操作也需要谨慎使用。

### 来一个生产上的超时阻塞案例

我们遇到一个这样超时阻塞的案例，业务方反映：程序访问 Redis 集群出现超时现象，hkeys 访问 Redis 的平均响应时间在 200 毫秒左右，最大响应时间达到了 500 毫秒以上，如下图。

![](https://mmbiz.qpic.cn/mmbiz_png/xlgvgPaib7WMjluibkF7MjLJx4iarLf6SaDdd2Uj1sawAJoLIQrzjQQ7ZgzIXfl2wjct3B6Yf0KpdzS2yHLCLwC3w/640?wx_fmt=png)

hkeys 是获取所有哈希表中的字段的命令，分析应该是集群中某些实例存在 hash 类型的 Bigkey，导致 hkeys 命令执行时间过长，发生了阻塞现象。

1.使用 Daas 平台“服务监控-数据库实例监控”，选择 master 节点，选择 Redis 响应时间监控指标“redis.instance.latency.max”，如下图所示，从监控图中我们可以看到

（1）正常情况下，该实例的响应时间在 0.1 毫秒左右。

（2）监控指标上面有很多突刺，该实例的响应时间到了 70 毫秒左右，最大到了 100 毫秒左右，这种情况就是该实例会有 100 毫秒都在处理 Bigkey 的访问命令，不能处理其他命令。

通过查看监控指标，验证了我们分析是正确的，是这些监控指标的突刺造成了 hkeys 命令的响应时间比较大，我们找到了具体的 master 实例，然后使用 master 实例的 slave 去分析下 Bigkey 情况。

![](https://mmbiz.qpic.cn/mmbiz_png/xlgvgPaib7WMjluibkF7MjLJx4iarLf6SaD877Mv7kz4icQrhnfEfREDOzAze5Sq7Juo9x6zIibwSZdYMq7qLHpA3LA/640?wx_fmt=png)

![](https://mmbiz.qpic.cn/mmbiz_png/xlgvgPaib7WMjluibkF7MjLJx4iarLf6SaDjrYZHCV5asg4UQmNjicvLF2lj30b7V2u3xfvZicq9GQ2V9qtvPKUlGfA/640?wx_fmt=png)

2.使用 Daas 平台“工具集-操作项管理”，选择 slave 实例执行分析，分析结果如下图，有一个 hash 类型 key 有 12102218 个 fields。

![](https://mmbiz.qpic.cn/mmbiz_png/xlgvgPaib7WMjluibkF7MjLJx4iarLf6SaDfknWk62Hib396xkJcrwESY64FyTNej7OkAGRPxicW3rERC4Ad60PR8sg/640?wx_fmt=png)

1. 和业务沟通，进行Bigkey 拆分

   这个 Bigkey 是连续存放了 30 天的业务数据了，建议根据二次 hash 方式拆分成多个 key，

   也可把 30 天的数据根据分钟级别拆分成多个 key，把每个 key 的元素数量控制在 5000 以内。

   优化后，监控指标的响应时间的突刺就会消失了。

#### 问题3：网络阻塞

Bigkey 的 value 比较大，也意味着每次获取要产生的网络流量较大，假设一个 Bigkey 为 10MB，客户端每秒访问量为 100，那么每秒产生 1000MB 的流量，对于普通的千兆网卡(按照字节算是 128MB/s)的服务器来说简直是灭顶之灾。

而且我们现在的 Redis 服务器是采用单机多实例的方式来部署 Redis 实例的，也就是说一个 Bigkey 可能会对同一个服务器上的其他 Redis 集群实例造成影响，影响到其他的业务。

#### 问题4：迁移困难

我们在运维中经常做的变更操作是水平扩容，就是增加 Redis 集群的节点数量来达到扩容的目的，这个水平扩容操作就会涉及到 key 的迁移，把原实例上的 key 迁移到新扩容的实例上。

当要对 key 进行迁移时，是通过 migrate 命令来完成的，migrate 实际上是通过 dump + restore + del 三个命令组合成原子命令完成，它在执行的时候会阻塞进行迁移的两个实例，直到以下任意结果发生才会释放：迁移成功，迁移失败，等待超时。

如果 key 的迁移过程中遇到 Bigkey，会长时间阻塞进行迁移的两个实例，可能造成客户端阻塞，导致客户端访问超时；也可能迁移时间太长，造成迁移超时导致迁移失败，水平扩容失败。

### 来一个生产上的迁移失败案例

我们也遇到过一些因为 Bigkey 扩容迁移失败的案例，如下图所示，

这是一个 Redis 集群水平扩容的工单，需要进行 key 的迁移，当工单执行到 60%的时候，迁移失败了。

如何解决呢？

大概的解决流程，如下：

1. 进入工单找到失败的实例，使用失败实例的 slave 节点，在 Daas 平台的“工具集-操作项管理”进行 Bigkey 分析。

![](https://mmbiz.qpic.cn/mmbiz_png/xlgvgPaib7WMjluibkF7MjLJx4iarLf6SaDehbw2Mu4PZic6Jcdrh2XHqCHBxeNqWAsyLGDVgkcib0Kic4dUGjgIzXEQ/640?wx_fmt=png)

1. 经过分析找出了 hash 类型的 Bigkey 有 8421874 个 fields，正是这个 Bigkey 导致迁移时间太长，超过了迁移时间限制，导致工单失败了。

![](https://mmbiz.qpic.cn/mmbiz_png/xlgvgPaib7WMjluibkF7MjLJx4iarLf6SaDjDwQnCSA7hEibGApJEud4pPicEUXcgMXY9fOa7H3RiciaFndh5czqqX0Bw/640?wx_fmt=png)

3.和业务沟通，这些 key 是记录用户访问系统的某个功能模块的 ip 地址的，访问该功能模块的所有 ip 都会记录到给 key 里面，随着时间的积累，这个 key 变的越来越大。同样是采用拆分的方式进行优化，可以考虑按照时间日期维度来拆分，就是一段时间段的访问 ip 记录到一个 key 中。

4.Bigkey 优化后，扩容的工单可以重试，完成集群扩容操作。

### 生产上如何进行Bigkey 的发现

- 首先需要重源头治理，防止 Bigkey 的产生；
- 其次是需要能够及时的发现，发现后及时处理。

分析 Bigkey 的方法不少，这里介绍两种比较常用的方法，也是 Daas 平台分析 Bigkey 使用的两种方式，分别是 Bigkeys 命令分析法、RDB 文件分析法。

#### 1.Bigkeys 命令分析

Redis4.0 及以上版本提供了--Bigkeys 命令，可以分析出实例中每种数据结构的 top 1 的 Bigkey，同时给出了每种数据类型的键值个数以及平均大小。

执行--Bigkeys 命令时候需要注意以下几点：

- 建议在 slave 节点执行，因为--Bigkeys 也是通过 scan 完成的，可能会对节点造成阻塞。
- 建议在节点本机执行，这样可以减少网络开销。
- 如果没有从节点，可以使用--i 参数，例如(--i 0.1 代表 100 毫秒执行一次)。
- --Bigkeys 只能计算每种数据结构的 top1，如果有些数据结构有比较多的 Bigkey，是查找不出来的。

Daas 平台集成了基于原生--Bigkeys 代码实现的查询 Bigkey 的方式，这个方式的缺点是只能计算每种数据结构的 top1，如果有些数据结构有比较多的 Bigkey，是查找不出来的。该方式相对比较安全，已经开放出来给业务开发同学使用。

#### 2. RDB 文件分析

借助开源的工具，比如 rdb-tools，分析 Redis 实例的 RDB 文件，找出其中的 Bigkey，这种方式需要生成 RDB 文件，需要注意以下几点：

- 建议在 slave 节点执行，因为生成 RDB 文件会影响节点性能。
- 需要生成 RDB 文件，会影响节点性能，虽然在 slave 节点执行，但是也是有可能造成主从中断，进而影响到 master 节点。

Daas 平台集成了基于 RDB 文件分析代码实现的查询 Bigkey 的方式，可以根据实际需求自定义填写 N，分析的 top N 个 Bigkey。该方式相对有一定风险，只有 DBA 有权限执行分析。

#### 3.Bigkey 巡检

通过巡检，可以暴露出隐患，提前解决，避免故障的发生，进行全网 Bigkey 的巡检，是避免 Bigkey 故障的比较好的方法。

由于全网 Redis 实例数量非常大，分析的速度比较慢，使用当前的分析方法很难完成。

为了解决这个问题，存储研发组分布式数据库同学计划开发一个高效的 RDB 解析工具，然后通过大规模解析 RDB 文件来分析 Bigkey，可以提高分析速度，实现 Bigkey 的巡检。

### 生产上 Bigkey 处理优化

#### 1. Bigkey 拆分

优化 Bigkey 的原则就是 string 减少字符串长度，list、hash、set、zset 等减少元素数量。当我们知道哪些 key 是 Bigkey 时，可以把单个 key 拆分成多个 key，比如以下拆分方式可以参考。

- big list：list1、list2、...listN
- big hash：可以做二次的 hash，例如 hash%100
- 按照日期拆分多个：key20220310、key20220311、key202203212

#### 2. Bigkey 分析工具优化

我们全网 Redis 集群有 2200 以上，实例数量达到 4.5 万以上，有的比较大的集群的实例数量达到了 1000 以上，前面提到的两种 Bigkey 分析工具还都是实例维度分析，对于实例数量比较大的集群，进行全集群分析也是比较耗时的，为了提高分析效率，从以下几个方面进行优化：

- 可以从集群维度选择全部 slave 进行分析。
- 同一个集群的相同服务器 slave 实例串行分析，不同服务器的 slave 实例并行分析，最大并发度默认 10，同时可以分析 10 个实例，并且可以自定义输入执行分析的并发度。
- 分析出符合 Bigkey 规定标准的所有 key 信息：大于 1MB 的 string 类型的所有 key，如果不存在就列出最大的 50 个 key；hash、list、set、zset 等类型元素个数大于 2000 的所有 key，如不存在就给出每种类型最大的 50 个 key。
- 增加暂停、重新开始、结束功能，暂停分析后可以重新开始。

### 水平扩容迁移优化

目前情况，我们有一些 Bigkey 的发现是被动的，一些是在水平扩容时候发现的，由于 Bigkey 的存在导致扩容失败了，严重的还触发了 master-slave 的故障切换，这个时候可能已经造成业务程序访问超时，导致了可用性下降。

我们分析了 Daas 平台的水平扩容时迁移 key 的过程及影响参数，内容如下：

（1）【cluster-node-timeout】：控制集群的节点切换参数，

master 堵塞超过 cluster-node-timeout/2 这个时间，就会主观判定该节点下线 pfail 状态，如果迁移 Bigkey 阻塞时间超过 cluster-node-timeout/2，就可能会导致 master-slave 发生切换。

（2）【migrate timeout】：控制迁移 io 的超时时间

超过这个时间迁移没有完成，迁移就会中断。

（3）【迁移重试周期】：迁移的重试周期是由水平扩容的节点数决定的，

比如一个集群扩容 10 个节点，迁移失败后的重试周期就是 10 次。

（4）【一个迁移重试周期内的重试次数】：在一个起迁移重试周期内，会有 3 次重试迁移，

每一次的 migrate timeout 的时间分别是 10 秒、20 秒、30 秒，每次重试之间无间隔。

比如一个集群扩容 10 个节点，迁移时候遇到一个 Bigkey，第一次迁移的 migrate timeout 是 10 秒，10 秒后没有完成迁移，就会设置 migrate timeout 为 20 秒重试，如果再次失败，会设置 migrate timeout 为 30 秒重试，

如果还是失败，程序会迁移其他新 9 个的节点，但是每次在迁移其他新的节点之前还会分别设置 migrate timeout 为 10 秒、20 秒、30 秒重试迁移那个迁移失败的 Bigkey。

这个重试过程，每个重试周期阻塞（10+20+30）秒，会重试 10 个周期，共阻塞 600 秒。其实后面的 9 个重试周期都是无用的，每次重试之间没有间隔，会连续阻塞了 Redis 实例。

（5）【迁移失败日志】：日志的缺失

迁移失败后，记录的日志没有包括迁移节点、solt、key 信息，不能根据日志立即定位到问题 key。

我们对这个迁移过程做了优化，具体如下：

（1）【cluster-node-timeout】：延长超时时间

默认是 60 秒，在迁移之前设置为 15 分钟，防止由于迁移 Bigkey 阻塞导致 master-slave 故障切换。

（2）【migrate timeout】：减少阻塞时间

为了最大限度减少实例阻塞时间，每次重试的超时时间都是 10 秒，3 次重试之间间隔 30 秒，这样最多只会连续阻塞 Redis 实例 10 秒。

（3）【重试次数】：去掉了其他节点迁移的重试

迁移失败后，只重试 3 次（重试是为了避免网络抖动等原因造成的迁移失败），每次重试间隔 30 秒，重试 3 次后都失败了，会暂停迁移，日志记录下 Bigkey，去掉了其他节点迁移的重试。

（4）【优化日志记录】：日志记录

迁移失败日志记录迁移节点、solt、key 信息，可以立即定位到问题节点及 key。

## 关于BigKey、Hotkey的总结

首先是需要从源头治理，防止 Bigkey 、Hotkey形成，加强对业务开发同学 bigkey 相关问题的宣导；

其次，提升及时发现的能力，实现 Bigkey 、Hotkey 及时探测能力。

## 参考资料：

Github：rdb-tools：https://github.com/sripathikrishnan/redis-rdb-tools

(1) redis命令：Redis 命令参考 — Redis 命令参考

(2) Github: https://github.com/sripathikrishnan/redis-rdb-tools

(3) another redis desktop manager下载地址AnotherRedisDesktopManager 发行版：https://gitee.com/qishibo/AnotherRedisDesktopManager/releases

## 最后说一句（别白嫖，求关注）

陈某每一篇文章都是精心输出，如果这篇文章对你有所帮助，或者有所启发的话，帮忙**点赞**、**在看**、**转发**、**收藏**，你的支持就是我坚持下去的最大动力！

另外陈某的[知识星球](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247518914&idx=1&sn=b3fdfd78c32b15077ac67535ccc10a00&scene=21#wechat_redirect)开通了，公众号回复关键词：**知识星球** 获取限量**30元**优惠券加入只需**89**元，一顿饭钱，但是星球回馈的价值却是巨大，目前更新了**Spring全家桶实战系列**、**亿级数据分库分表实战**、**DDD微服务实战专栏**、**我要进大厂、Spring，Mybatis等框架源码、架构实战22讲**等....每增加一个专栏价格将上涨20元

![](https://mmbiz.qpic.cn/mmbiz_png/19cc2hfD2rBvqdy8J18dlib7KepGcvuW08g7COtYpQvVoZzRtQFLgaW1GxibV1vsWMQ27S4wsOlt1ySoh3uEAeIw/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

关注公众号：【码猿技术专栏】，公众号内有超赞的粉丝福利，回复：加群，可以加入技术讨论群，和大家一起讨论技术，吹牛逼！