**大家好，我是不才陈某~**

JVM调优的最难的地方就是分析GC日志，今天这篇文章介绍一款非常好用的GC日志可视化工具

## JVM调优实践

### JVM实践调优主要步骤

默认的策略是最普用，但不是最佳的。

**第一步**：监控分析GC日志

**第二步**：判断JVM问题：

- 如果各项参数设置合理，系统没有超时日志出现，GC频率不高，GC耗时不高，那么没有必要进行GC优化;如果GC时间超过1-3秒，或者频繁GC，则必须优化。

**第三步**：确定调优目标

**第四步**：调整参数
- 调优一般是从满足程序的内存使用需求开始，之后是时间延迟要求，最后才是吞吐量要求，要基于这个步骤来不断优化，每一个步骤都是进行下一步的基础，不可逆行之。

**第五步**：对比调优前后差距

**第六步**：重复：1 、 2 、 3 、 4 、 5 步骤

- 找到最佳JVM参数设置

**第七步**：应用JVM到应用服务器：

- 找到最合适的参数，将这些参数应用到所有服务器，并进行后续跟踪。

以上，就是我们进行jvm调优得一些步骤了。

那我们就从第一步开始喽！！！^_^

## 分析GC日志

### 初始参数设置

**机器环境：**

| 指标         | 参数               |
| :----------- | :----------------- |
| 机器         | CPU 12核，内存16GB |
| 集群规模     | 单机               |
| seqb_web版本 | 1.0                |
| 数据库       | 4核 16G            |

Jvm调优典型参数设置;

1. **-Xms堆内存的最小值：**

2. 默认情况下，当堆中可用内存小于40%时，堆内存会开始增加，一直增加到-Xmx的大小。

3. **-Xmx堆内存的最大值：** 默认值是总内存/64（且小于1G）

4. 默认情况下，当堆中可用内存大于70%时，堆内存会开始减少，一直减小到-Xms的大小；

5. **-Xmn新生代内存的最大值：**
- 包括Eden区和两个Survivor区的总和
- 配置写法如：-Xmn1024k，-Xmn1024m，-Xmn1g

7. **-Xss每个线程的栈内存：**

- 默认1M，一般来说是不需要改。线程栈越小意味着可以创建的线程数越多

整个堆的大小 = 年轻代大小 + 年老代大小，堆的大小不包含元空间大小，如果增大了年轻代，年老代相应就会减小，官方默认的配置为年老代大小/年轻代大小=2/1左右；

建议在开发测试环境可以用Xms和Xmx分别设置最小值最大值，但是在线上生产环境，**Xms和Xmx设置的值必须一样，防止抖动；**

> 这里比较重要喔，一般我们都是将Xms和Xmx的值设置为一样的！！！

![比较重要喔](https://www.java-family.cn/BlogImage/20221211190613.jpg)

**JVM调优设置合大小堆内存空间，既不能太大，也不能太小。那么应该设置为多少呢？**

默认的配置是否存在性能瓶颈。如果想要确定JVM性能问题瓶颈，需要进一步分析**GC日志**

1. **-XX:+PrintGCDetails** 开启GC日志创建更详细的GC日志 ，默认情况下，GC日志是关闭的

2. **-XX:+PrintGCTimeStamps，-XX:+PrintGCDateStamps** 开启GC时间提示

   - 开启时间便于我们更精确地判断几次GC操作之间的时两个参数的区别

   - 时间戳是相对于 0 （依据JVM启动的时间）的值，而日期戳（date stamp）是实际的日期字符串
   - 由于日期戳需要进行格式化，所以它的效率可能会受轻微的影响，不过这种操作并不频繁，它造成的影响也很难被我们感知。

3. **-XX:+PrintHeapAtGC** 打印堆的GC日志

5. **-Xloggc:./logs/gc.log** 指定GC日志路径

这里，我们是在window下面进行测试，idea配置如下：

![idea配置](https://www.java-family.cn/BlogImage/20221211190623.jpg)

```shell
-XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -XX:+PrintHeapAtGC -Xloggc:E:/logs/gc-default.log
```

这样就会在e盘下logs文件夹下面，生成`gc-default.log`日志

![gc-default.log](https://www.java-family.cn/BlogImage/20221211190634.jpg)

### GC日志解读

**Young GC 日志含义**

```java
2022-08-05T13:45:23.336+0800: 4.866: [GC (Metadata GC Threshold) [PSYoungGen: 136353K->20975K(405504K)] 160049K->48437K(720384K), 0.0092260 secs] [Times: user=0.00 sys=0.02, real=0.02 secs] 
```

这里的内容，我们一个一个解析：

```java
2022-08-05T13:45:23.336+0800: 本次GC发生时间
4.866: 举例启动应用的时间
[GC【表示GC的类型，youngGC】 (Metadata GC Threshold) 元空间超阈值
[PSYoungGen: 136353K->20975K(405504K年轻代总空间)] 160049K->48437K(720384K)整堆), 0.0092260 secs本次垃圾回收耗时]
[Times: user=0.00本次GC消耗CPU的时间 sys=0.02系统暂停时间, real=0.02 secs实际应用暂停时间]
```

> 这里的解析，应该很详细了吧，还有谁看不懂的呢？

![有谁看不懂](https://www.java-family.cn/BlogImage/20221211190642.jpg)

**FullGC 日志含义**

```java
2022-08-05T20:24:47.815+0800: 6.955: [Full GC (Metadata GC Threshold) [PSYoungGen: 701K->0K(72704K)] [ParOldGen: 38678K->35960K(175104K)] 39380K->35960K(247808K), [Metaspace: 56706K->56706K(1099776K)], 0.1921975 secs] [Times: user=1.03 sys=0.00, real=0.19 secs] 
```

这里的内容，我们也是一个一个解析：

```java
2022-08-05T20:24:47.815+0800:
6.955: 刚启动服务就Full GC【整堆回收！！】

[Full GC (Metadata GC Threshold) Metaspace空间超限！
[PSYoungGen: 701K->0K(72704K)] 年轻代没有回收空间
[ParOldGen: 38678K->35960K(175104K)] 39380K->35960K(247808K), 老年代也没有到阈值，整堆更没有到阈值
[Metaspace: 56706K->56706K(1099776K)], 0.1921975 secs]
[Times: user=1.03本次GC消耗CPU的时间 sys=0.00系统暂停时间, real=0.19 secs实际应用暂停时间] 
```

看到这里，有些哥们就会说，这么看，也太恶心了吧，密密麻麻的日志，看着头疼！！！

那么接下来我们来学一个GC日志可视化工具

### GC日志可视化分析

分析GC日志，就必须让GC日志输出到一个文件中，然后使用GC日志分析工具（**gceasy.io**：`https://gceasy.io/`) 进行分析

![GC日志可视化分析](https://www.java-family.cn/BlogImage/20221211190702.jpg)

这里分析完之后，可以下载分析报告

![下载分析报告](https://www.java-family.cn/BlogImage/20221211190712.jpg)

### JVM内存占用情况

![JVM内存占用情况](https://www.java-family.cn/BlogImage/20221211190721.jpg)

| Generation【区域】               | Allocated【最大值】 | Peak【占用峰值】 |
| :------------------------------- | :------------------ | :--------------- |
| Young Generation【年轻代】       | 74.5 mb             | 74.47 mb         |
| Old Generation【老年轻代】       | 171 mb              | 95.62 mb         |
| Meta Space【元空间】             | 1.05 gb             | 55.38 mb         |
| Young + Old + Meta space【整体】 | 1.3 gb              | 212.64 mb        |

### 关键性能指标

![关键性能指标](https://www.java-family.cn/BlogImage/20221211190733.jpg)

1 、**吞吐量**：百分比越高表明GC开销越低。这个指标反映了JVM的吞吐量。

- `Throughput`：**97.043%**

2 、**GC 延迟**：**Latency**

- `Avg Pause GC Time`：**7.80 ms** 平均GC暂停时间
- `Max Pause GC Time`：**190 ms** 最大GC暂停时间

### GC 可视化交互聚合结果

![可视化交互聚合结果](https://www.java-family.cn/BlogImage/20221211190742.jpg)

由上图可以看到，发生了3次full gc

存在问题：一开始就发生了 3 次full gc , 很明显不太正常；

### GC 统计

![GC 统计](https://www.java-family.cn/BlogImage/20221211190752.jpg)

**GC Statistics**：GC统计

由上图可以得到，发生gc的总次数，young gc，full gc的统计，gc 暂停时间统计。

### GC原因

![GC原因](https://www.java-family.cn/BlogImage/20221211190801.jpg)

| 原因                  | 次数 | 平均时间 | 最大时间 | 总耗时 |
| :-------------------- | :--- | :------- | :------- | :----- |
| Metadata GC Threshold | 6    | 43.3 ms  | 190 ms   | 260 ms |
| Allocation Failure    | 53   | 3.77 ms  | 10.0 ms  | 200 ms |

这里对这些原因解析一下：

1. **Metadata GC Threshold**：元空间超阈值
2. **Allocation Failure** ：年轻代空间不足

这里补充一个原因，本案例还没出现的：

- **Ergonomics**：译文是“人体工程学”，GC中的Ergonomics含义是负责自动调解gc暂停时间和吞吐量之间平衡从而产生的GC。目的是使得虚拟机性能更好的一种做法。

由此可见，通过可视化的工具，可以快速的帮我们分析GC的日志。我们得善于利用工具。

因为gc的日志文件，内容太多，都是密密麻麻的数字，文本。看得实在是头疼。

有了**gc easy**可视化工具，而且还是在线的，十分的方便。**GC日志分析是免费的**

由于jvm调优实践的分析，篇幅比较长，所以今天就先到这里，剩下的留着下次分享了。