

**大家好，我是不才陈某~**

今天分享几个非常实用的IDEA重构技巧，能够快速提升开发效率

## 1、提取方法

提取想要的代码，按快捷键`Ctrl+Alt+M`，就会弹出框，写出方法名称即可提取一个方法

![](https://www.java-family.cn/BlogImage/20230211165927.png)

![](https://www.java-family.cn/BlogImage/20230211165930.png)

## 2、合并方法

反向操作，选中方法后，把方法代码直接并入主方法里面

![](https://www.java-family.cn/BlogImage/20230211165934.png)


## 3、方法重命名

`Ctrl+Shift+Alt+T`，或者`Shift+F6`

![](https://www.java-family.cn/BlogImage/20230211165938.png)

![](https://www.java-family.cn/BlogImage/20230211165941.png)

## 4、函数参数位置更改与重命名

![](https://www.java-family.cn/BlogImage/20230211165943.png)

![](https://www.java-family.cn/BlogImage/20230211165946.png)

## 5、 重构变量

- `Ctrl+Alt+C` 快速提取常量（Constant）
- `Ctrl+Alt+V`快速提取变量（Variable）
- `Ctrl+Alt+F`快速提取成员变量（Filed Variable）
- `Ctrl+Shift+f6` 重构变量的类型

点击变量，直接使用快捷键

![](https://www.java-family.cn/BlogImage/20230211165948.png)

![](https://www.java-family.cn/BlogImage/20230211165951.png)

## 6、提取方法到父类

![](https://www.java-family.cn/BlogImage/20230211165954.png)![](https://www.java-family.cn/BlogImage/20230211170014.png)

![](https://www.java-family.cn/BlogImage/20230211170039.png)



## 7、内敛方法/参数

停放鼠标位置右键 —> Refactor —> Inline ；快捷键 Alt + Shift + i

![](https://www.java-family.cn/BlogImage/20230211170048.png)

结果：

![](https://www.java-family.cn/BlogImage/20230211170056.png)

## 8、将方法/参数下层到子类

选中方法/参数 右键—> Refactor —> Pull Members Download

![](https://www.java-family.cn/BlogImage/20230211170103.png)

结果：

![](https://www.java-family.cn/BlogImage/20230211170110.png)

## 9、添加循环、if、try catch等

快捷键：ctrl+alt+t 

![](https://www.java-family.cn/BlogImage/20230211170117.png)

## 10、终极重构技巧

右键 —> Refactor —> Generify，设置如下

![](https://www.java-family.cn/BlogImage/20230211170124.png)

接下来就可以使用快捷键了

选中，快捷键 Alt+Ctrl+Shift+T，则可以显示所有重构技巧了

![](https://www.java-family.cn/BlogImage/20230211170133.png)

 ## 最后说一句（别白嫖，求关注）

陈某每一篇文章都是精心输出，如果这篇文章对你有所帮助，或者有所启发的话，帮忙**点赞**、**在看**、**转发**、**收藏**，你的支持就是我坚持下去的最大动力！

另外陈某的[知识星球](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247518914&idx=1&sn=b3fdfd78c32b15077ac67535ccc10a00&scene=21#wechat_redirect)开通了，公众号回复关键词：**知识星球** 获取限量**30元**优惠券加入只需**89**元，一顿饭钱，但是星球回馈的价值却是巨大，目前更新了**Spring全家桶实战系列**、**亿级数据分库分表实战**、**DDD微服务实战专栏**、**我要进大厂、Spring，Mybatis等框架源码、架构实战22讲**等....每增加一个专栏价格将上涨20元

![](https://mmbiz.qpic.cn/mmbiz_png/19cc2hfD2rBvqdy8J18dlib7KepGcvuW08g7COtYpQvVoZzRtQFLgaW1GxibV1vsWMQ27S4wsOlt1ySoh3uEAeIw/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

关注公众号：【码猿技术专栏】，公众号内有超赞的粉丝福利，回复：加群，可以加入技术讨论群，和大家一起讨论技术，吹牛逼！
