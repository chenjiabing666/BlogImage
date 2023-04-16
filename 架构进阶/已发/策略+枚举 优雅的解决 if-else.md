**大家好，我是不才陈某~**

想起刚开始接触JAVA面向对象编程时，若遇到大量流程判断语句，几乎满屏都是if-else语句，多得让自己都忘了哪里是头，哪里是尾，但是，纵然满屏是if-else，但彼时也没有觉得多别扭。等到编程能力渐渐提升之后，再回过头去看曾经写过的满屏if-else时，脑海里只有一个画面，全都是翔.....

**可能初学者都会忽略掉一点，其实if-else是一种面向过程的实现。**

那么，如何避免在面向对象编程里大量使用if-else呢？

网络上有很多解决思路，有工厂模式、策略模式、甚至是规则引擎（这个太重了吧）......

这些，都有一个共同的缺点，使用起来还是过于繁重了。虽说避免出现过多的if-else，但是，却会增加很多额外的类，我总觉得，很不实用，只能当做某种模式的学习即可。

可以替换大量的if-else语句，且具备较好的可读性与扩展性，同时能显得轻量化，我比较推荐使用**策略枚举**来消除if-else。

如何使用呢，下面先从一个业务案例开始说起

假如有这样一个需求，需实现一周七天内分别知道要做事情的备忘功能，这里面就会涉及到一个流程判断，你可能会立马想到用if-else，那么，可能是会这样实现——

```java
 1 //if-else形式判断
 2 public String getToDo(String day){
 3     if("Monday".equals(day)){
          ......省略复杂语句
 4         return "今天上英语课";
 5     }else if("Tuesday".equals(day)){
          .....省略复杂语句
          return "今天上语文课";
 7     }else if("Wednesday".equals(day)){
         ......省略复杂语句
 8         return "今天上数学课";
 9     }else if("Thursday".equals(day)){
         ......省略复杂语句
10         return "今天上音乐课";
11     }else if("sunday".equals(day)){
         ......省略复杂语句
12         return "今天上编程课";
13     }else{
14         此处省略10086行......
15     }
16 }
```

这种代码，在业务逻辑里，少量还好，若是几百个判断呢，可能整块业务逻辑里都是满屏if-else,既不优雅也显得很少冗余。

这时，就可以考虑使用策略枚举形式来替换这堆面向过程的if-else实现了。

首先，先定义一个getToDo()调用方法，假如传进的是“星期一”，即参数"Monday"。

```java
//策略枚举判断
public String getToDo(String day){
    CheckDay checkDay=new CheckDay();
    return checkDay.day(DayEnum.valueOf(day));
}
```

在getToDo()方法里，通过DayEnum.valueOf("Monday")可获取到一个DayEnum枚举元素，这里得到的是Monday。

接下来，执行checkDay.day(DayEnum.valueOf("Monday"))，会进入到day（）方法中，这里，**通过dayEnum.toDo()做了一个策略匹配时**。注意一点，DayEnum.valueOf("Monday")得到的是枚举中的Monday，这样，实质上就是执行了Monday.toDo()，也就是说，会执行Monday里的toDo()——

```typescript
public class CheckDay {
    public String day( DayEnum dayEnum) {
        return dayEnum.toDo();
    }
}
复制代码
```

上面的执行过程为什么会是这样子呢？只有进入到DayEnum枚举当中，才知道是怎么回事了——(话外音：我第一次接触策略模式时，猛地一惊，原来枚举还可以这样玩)

```java
public enum DayEnum {
    Monday {
        @Override
        public String toDo() {
            ......省略复杂语句
            return "今天上英语课";
        }
    },
    Tuesday {
        @Override
        public String toDo() {
            ......省略复杂语句
            return "今天上语文课";
        }
    },
    Wednesday {
        @Override
        public String toDo() {
            ......省略复杂语句
            return "今天上数学课";
        }
    },
    Thursday {
        @Override
        public String toDo() {
            ......省略复杂语句
            return "今天上音乐课";
        }
    };
    public abstract String toDo();
}
```

在DayEnum枚举属性当中，定义了一个实现了toDo()抽象方法——

```java
 public abstract String toDo();
```

在每个枚举元素当中，都重写了该toDo()抽象方法。这样，当传参`DayEnum.valueOf("Monday")`流转到`dayEnum.toDo()`时，实质上是去DayEnum枚举里找到对应Monday定义的枚举元素，然后执行其内部重写的`toDo()`方法。

用if-esle形式表示，就类似"Monday".equals(day)匹配为true时，可得到其内部东西。

总结一下，策略枚举就是枚举当中使用了策略模式，所谓的策略模式，即给你一把钥匙，按照某种约定的方式，可以立马被指引找到可以打开的门。

例如，我给你的钥匙叫“Monday”，那么，就可以通过约定方式dayEnum.toDo()，立马找到枚举里的Monday大门，然后进到门里，去做想做的事toDo()，其中，每扇门后的房间都有不同的功能，但它们都有一个相同抽象功能——toDo()，即各房间共同地方都是可以用来做一些事情的功能，但具体可以什么事情，就各有不同了。

在本文的案例里，每扇大门里的**toDo()，根据不同策略模式可得到不同字符串返回，例如，"今天上英语课"、"今天上语文课"，等等。** 



可见，把流程判断抽取到策略枚举当中，还可以把一堆判断解耦出来，避免在业务代码逻辑里呈现一大片密密麻麻冗余的if-else。

这里，会出现一种情况，即，假如有多个重复共同样功能的判断话，例如，在if-else里，是这样

```java
public String getToDoByIfElse(String day){
    if("Monday".equals(day)||"Tuesday".equals(day)||"Wednesday".equals(day)){
        ......省略复杂语句
        return "今天上英语课";
    }else if("Thursday".equals(day)){
        ......
    }
}
```

那么，在策略枚举下应该如何使用从而避免代码冗余呢？

可以参考一下以下思路，设置一个内部策略枚举，将有相同功能的外部引用指向同一个内部枚举元素，这样即可实现调用重复功能了——

```java
public enum DayEnum {
    //指向内部枚举的同一个属性即可执行相同重复功能
    Monday("星期一", Type.ENGLISH),
    Tuesday("星期二", Type.ENGLISH),
    Wednesday("星期三", Type.ENGLISH),
    
    Thursday("星期四", Type.CHINESE);
    private final Type type;
    private final String day;
    DayEnum(String day, Type type) {
        this.day = day;
        this.type = type;
    }
    String toDo() {
        return type.toDo();
    }
    /**
     * 内部策略枚举
     */
    private enum Type {
        ENGLISH {
            @Override
            public String toDo() {
                ......省略复杂语句
                return "今天上英语课";
            }
        },
        CHINESE {
            @Override
            public String toDo() {
                ......省略复杂语句
                return "今天上语文课";
            }
        };
        public abstract String toDo();
    }
}
```

若要扩展其判断流程，只需要直接在枚举增加一个属性和内部toDo（实现），就可以增加新的判断流程了，而外部，仍旧用同一个入口dayEnum.toDo()即可。



**可能，会有这样一个疑问：为什么在枚举里定义一个抽象方法，会在各个枚举元素里实现呢？**

 

**这功能就类似子类继承父类的做法了**。DayEnum类似一个父类，DayEnum枚举里的元素就相当是其子类。当父类里定义了抽象方法toDo（），其继承的子类就会默认实现toDo()方法，这样，就会出现枚举里可以这样的写法：

```java
 private enum Type {
        ENGLISH {
            @Override
            public String toDo() {
                return "今天上英语课";
            }
        }；
        public abstract String toDo();
    }
```

我很喜欢在**大批量if-else**里使用策略枚举来消除替换，总而言之，使用策略枚举可以很灵活处理各种复杂判断，且可读性与扩展性都比较好，它更像是函数式编程，即传进一个参数，就可以得到对应模式下返回的数值。

**若Java里业务逻辑中大批量使用if-else，则是面向过程了，因为业务逻辑里的if-else是从上往下一个if接一个if判断下去的，在各个if上打个断点，debug下去，就明白它其实是面向过程的。**

由此可知，若项目里有大量的if-else话，着实是一件很影响性能的事情，虽然这点性能可忽略不计，但有更好的取代方案，不是更好吗？

## 最后说一句（别白嫖，求关注）

陈某每一篇文章都是精心输出，已经写了**3个专栏**，整理成**PDF**，获取方式如下：

1. [《Spring Cloud 进阶》](https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzU3MDAzNDg1MA==&action=getalbum&album_id=2042874937312346114#wechat_redirect)PDF：关注公众号：【**码猿技术专栏**】回复关键词 **Spring Cloud 进阶** 获取！
2. [《Spring Boot 进阶》](https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzU3MDAzNDg1MA==&action=getalbum&album_id=1532834475389288449#wechat_redirect)PDF：关注公众号：【**码猿技术专栏**】回复关键词 **Spring Boot进阶** 获取！
3. [《Mybatis 进阶》](https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzU3MDAzNDg1MA==&action=getalbum&album_id=1500819225232343046#wechat_redirect)PDF：关注公众号：【**码猿技术专栏**】回复关键词 **Mybatis 进阶** 获取！

如果这篇文章对你有所帮助，或者有所启发的话，帮忙**点赞**、**在看**、**转发**、**收藏**，你的支持就是我坚持下去的最大动力！