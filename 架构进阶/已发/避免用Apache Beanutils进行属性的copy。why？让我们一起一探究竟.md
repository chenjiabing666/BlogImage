**大家好，我是不才陈某~**

今天，通过代码实例、源码解读、四大工具类横向对比的方式，和大家一起聊一聊`对象赋值`的问题。

在实际的项目开发中，对象间赋值普遍存在，随着双十一、秒杀等电商过程愈加复杂，数据量也在不断攀升，效率问题，浮出水面。

 问：如果是你来写对象间赋值的代码，你会怎么做？

答：想都不用想，直接代码走起来，get、set即可。

问：下图这样？

![img](https://mmbiz.qpic.cn/mmbiz_png/c5hh5ZpXfqtIP8GQwqic0ORAPcoxIvVVnth3uZjiawhPf8FeLyl7Szj9E5Luj7XE4TXbaakq9NAG4JWWyOP4xIpA/640?wx_fmt=png)

答：对啊，你怎么能把我的代码放到网上？

问：没，我只是举个例子

答：这涉及到商业机密，是很严重的问题

问：我发现你挺能扯皮啊，直接回答问题行吗？

 答：OK，OK，我也觉得这样写很low，上次这么写之后，差点挨打

1. 对象太多，ctrl c + strl v，键盘差点没敲坏；
2. 而且很容易出错，一不留神，属性没对应上，赋错值了；
3. 代码看起来很傻缺，一个类好几千行，全是get、set复制，还起个了自以为很优雅的名字transfer；
4. 如果属性名不能见名知意，还得加上每个属性的含义注释（基本这种赋值操作，都是要加的，注释很重要，注释很重要，注释很重要）；
5. 代码维护起来很麻烦；
6. 如果对象过多，会产生类爆炸问题，如果属性过多，会严重违背阿里巴巴代码规约（一个方法的实际代码最多20行）；

问：行了，行了，说说，怎么解决吧。

答：很简单啊，可以通过工具类Beanutils直接赋值啊

 问：我听说工具类最近很卷，你用的哪个啊？

答：就`Apache`自带的那个啊，贼简单。我手写一个，给你欣赏一下。

![img](https://mmbiz.qpic.cn/mmbiz_jpg/c5hh5ZpXfqtIP8GQwqic0ORAPcoxIvVVn8MJ3Yria4jv7Y8gpicGZ3fK10ldltbleDqaCttszgiaSyBkia45oXeHPZQ/640?wx_fmt=jpeg)

问：你这代码报错啊，避免用Apache Beanutils进行属性的copy。

答：没报错，只是严重警告而已，`代码能跑就行，有问题再优化呗`

 问：你这什么态度？人事在哪划拉的人，为啥会出现严重警告？

答：拿多少钱，干多少活，我又不是XXX，应该是性能问题吧

问：具体什么原因导致的呢？

答：3000块钱还得手撕一下 `apache copyProperties` 的源代码呗？

通过单例模式调用`copyProperties`，但是，每一个方法对应一个`BeanUtilsBean.getInstance()`实例，每一个类实例对应一个实例，这不算一个真正的单例模式。

```java
public static void copyProperties(Object dest, Object orig) throws IllegalAccessException, InvocationTargetException {
 BeanUtilsBean.getInstance().copyProperties(dest, orig);
}
```

 性能瓶颈 --> 日志太多也是病

通过源码可以看到，每一个`copyProperties`都要进行多次类型检查，还要打印日志。

```java
public void copyProperties(Object dest, Object orig) throws IllegalAccessException, InvocationTargetException {
    // 类型检查
    if (dest == null) {
        throw new IllegalArgumentException("No destination bean specified");
    } else if (orig == null) {
        throw new IllegalArgumentException("No origin bean specified");
    } else {
        // 打印日志
        if (this.log.isDebugEnabled()) {
            this.log.debug("BeanUtils.copyProperties(" + dest + ", " + orig + ")");
        }

        int var5;
        int var6;
        String name;
        Object value;
        // 类型检查
        // DanyBean 提供了可以动态修改实现他的类的属性名称、属性值、属性类型的功能
        if (orig instanceof DynaBean) {
            // 获取源对象所有属性
            DynaProperty[] origDescriptors = ((DynaBean)orig).getDynaClass().getDynaProperties();
            DynaProperty[] var4 = origDescriptors;
            var5 = origDescriptors.length;

            for(var6 = 0; var6 < var5; ++var6) {
                DynaProperty origDescriptor = var4[var6];
                // 获取源对象属性名
                name = origDescriptor.getName();
                // 判断源对象是否可读、判断目标对象是否可写
                if (this.getPropertyUtils().isReadable(orig, name) && this.getPropertyUtils().isWriteable(dest, name)) {
                    // 获取对应的值
                    value = ((DynaBean)orig).get(name);
                    // 每个属性都调用一次copyProperty
                    this.copyProperty(dest, name, value);
                }
            }
        } else if (orig instanceof Map) {
            ...
        } else {
            ...
        }

    }
}
```

 通过 jvisualvm.exe 检测代码性能

再通过`jvisualvm.exe`检测一下运行情况，果然，`logging.log4j`赫然在列，稳居耗时Top1。

![img](https://mmbiz.qpic.cn/mmbiz_jpg/c5hh5ZpXfqtIP8GQwqic0ORAPcoxIvVVn1NoRdEQhbgwKQBa7JKdryiagkib3oG7GMzSK9dNHCMTwWbjCj683j2NA/640?wx_fmt=jpeg)

 问：还有其它好的方式吗？性能好一点的

 答：当然有，据我了解有 4 种工具类，实际上，可能会有更多，话不多说，先简单介绍一下。

1. org.apache.commons.beanutils.BeanUtils;
2. org.apache.commons.beanutils.PropertyUtils;
3. org.springframework.cglib.beans.BeanCopier;
4. org.springframework.beans.BeanUtils；

 问：那你怎么不用？

 答：OK，我来演示一下

```java
public class Test {

    private static void apacheBeanUtilsCopyTest(User source, User target, int sum) {
        for (int i = 0; i < sum; i++) {
            org.apache.commons.beanutils.BeanUtils.copyProperties(source, target);
        }
    }

    private static void commonsPropertyCopyTest(User source, User target, int sum) {
        for (int i = 0; i < sum; i++) {
            org.apache.commons.beanutils.PropertyUtils.copyProperties(target, source);
        }
    }

    static BeanCopier copier = BeanCopier.create(User.class, User.class, false);
    private static void cglibBeanCopyTest(User source, User target, int sum) {
        for (int i = 0; i < sum; i++) {
            org.springframework.cglib.beans.BeanCopier.copier.copy(source, target, null);
        }
    }

    private static void springBeanCopy(User source, User target, int sum) {
        for (int i = 0; i < sum; i++) {
            org.springframework.beans.BeanUtils.copyProperties(source, target);
        }
    }
}
```

 "四大金刚" 性能统计

| 方法                    | 1000    | 10000   | 100000   | 1000000   |
| :---------------------- | :------ | :------ | :------- | :-------- |
| apache BeanUtils        | 906毫秒 | 807毫秒 | 1892毫秒 | 11049毫秒 |
| apache PropertyUtils    | 17毫秒  | 96毫秒  | 648毫秒  | 5896毫秒  |
| spring cglib BeanCopier | 0毫秒   | 1毫秒   | 3毫秒    | 10毫秒    |
| spring copyProperties   | 87毫秒  | 90毫秒  | 123毫秒  | 482毫秒   |

不测不知道，一测吓一跳，差的还真的多。

`spring cglib BeanCopier`性能最好，`apache BeanUtils`性能最差。

性能走势 --> `spring cglib BeanCopier` 优于 `spring copyProperties` 优于 `apache PropertyUtils` 优于 `apache BeanUtils`

避免用Apache Beanutils进行属性的copy的问题 上面分析完了，下面再看看其它的方法做了哪些优化。

## Apache PropertyUtils 源码分析

从源码可以清晰的看到，类型检查变成了非空校验，去掉了每一次copy的日志记录，性能肯定更好了。

1. 类型检查变成了非空校验
2. 去掉了每一次copy的日志记录
3. 实际赋值的地方由copyProperty变成了DanyBean  + setSimpleProperty；

DanyBean 提供了可以动态修改实现他的类的属性名称、属性值、属性类型的功能。

```java
public void copyProperties(Object dest, Object orig) {
    // 判断数据源和目标对象不是null
    if (dest == null) {
        throw new IllegalArgumentException("No destination bean specified");
    } else if (orig == null) {
        throw new IllegalArgumentException("No origin bean specified");
    } else {
        // 删除了org.apache.commons.beanutils.BeanUtils.copyProperties中最为耗时的log日志记录
        int var5;
        int var6;
        String name;
        Object value;
        // 类型检查
        if (orig instanceof DynaBean) {
            // 获取源对象所有属性
            DynaProperty[] origDescriptors = ((DynaBean)orig).getDynaClass().getDynaProperties();
            DynaProperty[] var4 = origDescriptors;
            var5 = origDescriptors.length;

            for(var6 = 0; var6 < var5; ++var6) {
                DynaProperty origDescriptor = var4[var6];
                // 获取源对象属性名
                name = origDescriptor.getName();
                // 判断源对象是否可读、判断目标对象是否可写
                if (this.isReadable(orig, name) && this.isWriteable(dest, name)) {
                    // 获取对应的值
                    value = ((DynaBean)orig).get(name);
                    // 相对于org.apache.commons.beanutils.BeanUtils.copyProperties此处有优化
                    // DanyBean 提供了可以动态修改实现他的类的属性名称、属性值、属性类型的功能
                    if (dest instanceof DynaBean) {
                        ((DynaBean)dest).set(name, value);
                    } else {
                        // 每个属性都调用一次copyProperty
                        this.setSimpleProperty(dest, name, value);
                    }
                }
            }
        } else if (orig instanceof Map) {
            ...
        } else {
            ...
        }

    }
}
```

 通过 jvisualvm.exe 检测代码性能

再通过jvisualvm.exe检测一下运行情况，果然，`logging.log4j`没有了，其他的基本不变。

![img](https://mmbiz.qpic.cn/mmbiz_jpg/c5hh5ZpXfqtIP8GQwqic0ORAPcoxIvVVnGOibRdUrFQHfkPhRED694icHice0UAFiae9GEtbZwhpaRUdwrYykUGicVBA/640?wx_fmt=jpeg)

## Spring copyProperties 源码分析

1. 判断数据源和目标对象的非空判断改为了断言；
2. 每次copy没有日志记录；
3. 没有`if (orig instanceof DynaBean) {`这个类型检查；
4. 增加了放开权限的步骤；

```java
private static void copyProperties(Object source, Object target, @Nullable Class<?> editable,
                                   @Nullable String... ignoreProperties) {

    // 判断数据源和目标对象不是null
    Assert.notNull(source, "Source must not be null");
    Assert.notNull(target, "Target must not be null");

    /**
     * 若target设置了泛型，则默认使用泛型
     * 若是 editable 是 null，则此处忽略
     * 一般情况下editable都默认为null
     */
    Class<?> actualEditable = target.getClass();
    if (editable != null) {
        if (!editable.isInstance(target)) {
            throw new IllegalArgumentException("Target class [" + target.getClass().getName() +
                    "] not assignable to Editable class [" + editable.getName() + "]");
        }
        actualEditable = editable;
    }

    // 获取target中全部的属性描述
    PropertyDescriptor[] targetPds = getPropertyDescriptors(actualEditable);
    // 需要忽略的属性
    List<String> ignoreList = (ignoreProperties != null ? Arrays.asList(ignoreProperties) : null);

    for (PropertyDescriptor targetPd : targetPds) {
        Method writeMethod = targetPd.getWriteMethod();
        // 目标对象存在写入方法、属性不被忽略
        if (writeMethod != null && (ignoreList == null || !ignoreList.contains(targetPd.getName()))) {
            PropertyDescriptor sourcePd = getPropertyDescriptor(source.getClass(), targetPd.getName());
            if (sourcePd != null) {
                Method readMethod = sourcePd.getReadMethod();
                /**
                 * 源对象存在读取方法、数据是可复制的
                 * writeMethod.getParameterTypes()[0]：获取 writeMethod 的第一个入参类型
                 * readMethod.getReturnType()：获取 readMethod 的返回值类型
                 * 判断返回值类型和入参类型是否存在继承关系，只有是继承关系或相等的情况下，才会进行注入
                 */
                if (readMethod != null &&
                        ClassUtils.isAssignable(writeMethod.getParameterTypes()[0], readMethod.getReturnType())) {
                    // 放开读取方法的权限
                    if (!Modifier.isPublic(readMethod.getDeclaringClass().getModifiers())) {
                        readMethod.setAccessible(true);
                    }
                    // 通过反射获取值
                    Object value = readMethod.invoke(source);
                    // 放开写入方法的权限
                    if (!Modifier.isPublic(writeMethod.getDeclaringClass().getModifiers())) {
                        writeMethod.setAccessible(true);
                    }
                    // 通过反射写入值
                    writeMethod.invoke(target, value);
                }
            }
        }
    }
}
```

## 总结

阿里的友情提示，避免用`Apache Beanutils`进行对象的`copy`，还是很有道理的。

`Apache Beanutils` 的性能问题出现在类型校验和每一次copy的日志记录；

 Apache PropertyUtils 进行了如下优化：

1. 类型检查变成了非空校验
2. 去掉了每一次copy的日志记录
3. 实际赋值的地方由copyProperty变成了DanyBean  + setSimpleProperty；

 Spring copyProperties 进行了如下优化：

1. 判断数据源和目标对象的非空判断改为了断言；
2. 每次copy没有日志记录；
3. 没有`if (orig instanceof DynaBean) {`这个类型检查；
4. 增加了放开权限的步骤；

## 最后说一句（别白嫖，求关注）

陈某每一篇文章都是精心输出，如果这篇文章对你有所帮助，或者有所启发的话，帮忙**点赞**、**在看**、**转发**、**收藏**，你的支持就是我坚持下去的最大动力！

另外陈某的[知识星球](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247518914&idx=1&sn=b3fdfd78c32b15077ac67535ccc10a00&scene=21#wechat_redirect)开通了，公众号回复关键词：**知识星球** 获取限量**30元**优惠券加入只需**89**元，一顿饭钱，但是星球回馈的价值却是巨大，目前更新了**Spring全家桶实战系列**、**亿级数据分库分表实战**、**DDD微服务实战专栏**、**我要进大厂、Spring，Mybatis等框架源码、架构实战22讲**等....每增加一个专栏价格将上涨20元

![](https://mmbiz.qpic.cn/mmbiz_png/19cc2hfD2rBvqdy8J18dlib7KepGcvuW08g7COtYpQvVoZzRtQFLgaW1GxibV1vsWMQ27S4wsOlt1ySoh3uEAeIw/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

关注公众号：【码猿技术专栏】，公众号内有超赞的粉丝福利，回复：加群，可以加入技术讨论群，和大家一起讨论技术，吹牛逼！