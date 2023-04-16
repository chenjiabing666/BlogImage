![这样Debug，排查问题效率大大提升...](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a47061a3ce8847c5a1d975d9e45db24d~tplv-k3u1fbpfcp-zoom-crop-mark:3024:3024:3024:1702.awebp?)

Debug是开发人员必备的基础技能，伴随着开发生涯，只要需要写代码，就一定有debug的诉求... 因为大部分开发同学都是用Debug来确认程序是不是预期进行(单元测试也可以)。

Debug一个非常常见的我们以为自己已经熟练掌握的技能，有点像说话一样，每个人都可以把话说出来，但不是每个人都能表达出影响力...

大家都会Debug，不过有些Debug的方式可能确实会效率更高一些，还是直接进入主题吧；

## 开始Debug

相信大家都知道如何开始Debug： 1、在Idea的某个程序文件的目标行旁边，点击一下，设置个小红点。 即断点 ![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/836086d9d9944518b80066c935496558~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

2、使用Debug按钮运行程序，如果程序可以走到断点这里，就开始进入Debug模式。 ![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/04141b8110cf4709946a63db9288a6a8~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

3、基本操作就是：

- step in 进入方法内部
- step over 直接执行到下一行
- step out 跳出当前的方法

重复1,2,3步骤，刚开始调试的时候主要就是这几个步骤；

下面分享一下一些稍微隐藏一点的调试方法。

## 断点相关经验

### 只有满足某些条件才会进入断点

如果说Debug的位置是网关入口，那么流量会很大，各种类型的请求都会走到这个断点里面，如果不能按照条件进入断点，会非常影响我们的效率。

因为进入断点的请求，都不是我们想要的；这个时候可以对断点设置条件，当前请求中必须有满足什么条件才会进入Debug模式。

1、点击程序的目标行旁边，生成一个小红点； 2、右键小红点，可以在condition那里设置程序中的条件； ![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ee7c2418700e42798793195000601ab2~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

举个例子，如下当用Debug运行的时候，是不会走到断点的。 ![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e6170e38862a4859a70a03321bc3f1d6~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

而且在设置完成断点条件后，断点旁边会多出一个？和普通的断点不同。 ![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/493ab6845afa436a9e53059016b008bb~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

### Debug断点只生效一次，同时不阻塞系统

如果说Debug某个正在运行的系统，默认情况下会挂起所有的后续请求，很多人都以为系统死机了... 其实最后发现是你在调试。

有什么办法，可以在调试的时候不阻塞剩余的请求吗？
1、默认只断点一次； 2、断点的时候不挂起整个系统；

如下，通过断点管理器器，进入进来，或者右键断点，然后点击more可以进入进来 设置挂起选项，只挂起当前正在调试的线程，然后再下面勾选一旦命中移除断点。

![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e151df36cdd14f6b895933c503d7e484~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3356bd221a114e7e99e0c9fe0ae3d3ae~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

### 静态断点，只是想看程序会不会运行到这里来(类似于动态日志)

想确定请求能不能走到某个位置，但是又不想进入debug模式，感觉太重了，能不能如果经过这一行就直接打个日志呢？

这对于有时候程序的一些方法没有打日志，但是又想确认是不是能执行到这里有帮助。

在断点配置里面勾选，命中后打日志，也可以自己加一些其他的输出：

- 不要挂起程序
- 命中处打日志

![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/79f538551ed64e7bac2b7c0f313aecc5~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2bf1649ee77944f8afacd8bb5c68f923~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

### 分组管理断点(系统不同链路的断点)

系统常用的链路主要就几条，而常调试问题的地方也只有几处，可以把这几处位置的断点管理起来，在遇到问题的时候直接把断点分组管理拿出来就可以了。

![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/358d460bd8674e33a2de82be52fe9564~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

### 远程服务器Debug

这里主要是一个配置问题，和本地Debug区别不大，学会配置就好了。 启动程序的时候：

> java -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=0.0.0.0:5005 -jar 待发布的程序jar包名称.jar

在Idea里面： ![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f61d674de8a84aafa3d0f3118a5fa1fd~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

## 调试相关经验

程序已经进入断点了，这个时候要查问题了，有一些需要了解的吗。

### 快速执行到某个位置

有时候我们的断点没有设置在某个位置，但是也不想设置在哪个位置； 在Debug的时候想让程序直接运行到那个位置，怎么处理？

第一种方式： 鼠标移动到对应的行数，然后按下run to cursor按钮 ![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/dae8736dbd5c4ebcb00575a6c6f84346~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

第二种方式：直接点击文件旁边的数字即可，运行到对应的行哪里 ![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/29a9a2d6f19446b687b8df4e307fe756~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

### 回退重新开始执行

在一些复杂的链路中，方法调用很长，手一抖结果代码又运行了几行，这个时候想去重新开始执行这个断点怎么办？

常规操作是再模拟发出个请求，重新进入断点； 但其实Idea已经提供了对应的方式，直接撤回当前的帧即可，断点会重新进入方法开始执行。

**在Frame的位置点击撤回按钮，就会重新进入这个方法开始运行**

![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c0f85c0dabb843f482114f720d3ff69f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

### 中断后续执行链路

如果说debug到一半发现可能会往数据库写入脏数据，想直接停止当前的调试，怎么做？

同样在帧的位置，右键，可以提前返回不继续运行，这个提前返回是针对当前的方法的，也可以直接抛出异常； ![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7be28509b6eb4cb7b6381584c4cf71af~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

### 调试Strem流

Java8之后的labmda表达式里面一般流程会多一点，也不是很好调试，Idea也有对应的工具，可以直接查看Strem流中的数据，在Debug Window下发，如果识别到labmda表达式后会展示出来。

![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a269608beba04a7a91a283ce55572ce2~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d903bd292a754a908401b097f91bc12d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

### 断点的时候运行一些额外代码

在Debug模式下，Idea提供了一个类似于解释器的工具，可以输入一些额外的程序在运行，哪怕和本次debug无关；

当然有个店是这个表达式执行只会返回最后y一行语句的结果。

![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d8554feb3fe14934947835d45d10e34f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c41cc3698a194534ac004e26c5c41537~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

## 总结

1. debug代码是一个常用而且很常见的技能，但是不是每个人都能很有效率的debug代码...
2. 有一些idea隐藏的debug方式，虽然一些人不关注，但是有用并且能极大提升效率
3. 文章主要介绍一些一些在实际项目中相对有用的可以提升debug能力的一些经验。最后如果说实在是有问题，但是又没办法进入调试模式，可以考虑arthas的trace和watch。