**大家好，我是不才陈某~**

今天介绍一下使用RabbitMQ的延迟插件方便实现延迟消息的方案。

RabbitMQ 是一个由 Erlang 语言开发的 **AMQP**(高级消息队列协议) 的开源实现。

RabbitMQ 是**轻量级且易于部署**的，能支持多种消息协议。

RabbitMQ 可以部署在分布式和联合配置中，以满足**高规模、高可用性**的需求。

具体特点包括：

- **可靠性**（Reliability）：RabbitMQ 使用一些机制来保证可靠性，如持久化、传输确认、发布 确认。
- **灵活的路由**（Flexible Routing）：在消息进入队列之前，通过 Exchange 来路由消息的。对 于典型的路由功能，RabbitMQ 已经提供了一些内置的 Exchange 来实现。针对更复杂的路由功能，可以将多个 Exchange 绑定在一起，也通过插件机制实现自己的 Exchange 。
- **消息集群**（Clustering）：多个 RabbitMQ 服务器可以组成一个集群，形成一个逻辑 Broker。
- **高可用**（Highly Available Queues）：队列可以在集群中的机器上进行镜像，使得在部分节 点出问题的情况下队列仍然可用。
- **多种协议**（Multi-protocol）：RabbitMQ 支持多种消息队列协议，比如 STOMP、MQTT等等。
- **多语言客户端**（Many Clients）：RabbitMQ 几乎支持所有常用语言，比如 Java、.NET、 Ruby 等等。
- **管理界面**（Management UI）:RabbitMQ 提供了一个易用的用户界面，使得用户可以监控 和管理消息 Broker 的许多方面。
- **跟踪机制**（Tracing）:如果消息异常，RabbitMQ 提供了消息跟踪机制，使用者可以找出发生 了什么。
- **插件机制**（Plugin System）:RabbitMQ 提供了许多插件，来从多方面进行扩展，也可以编 写自己的插件。

## RabbitMQ的消息模型

![](https://www.java-family.cn/BlogImage/20230108171333.png)

![](https://www.java-family.cn/BlogImage/20230108171336.png)

## Why use rabbitMQ ？

下面，我以一个（花店）商家的角色来向大家形象地举例：

## 异步

之前顾客来店里下单，我会叫顾客等一下，同时叫店员准备订单，准备好送到顾客手上了顾客**才能离开**

现在顾客打电话给我:"我要买xxx，地址是：xxx，你帮我送一下"

我拿个小本子记下：顾客a，电话：xxx，地址：xxx

店员**有空**后就会准备订单并配送

## 解耦

以前有新订单时，我会亲自找**每一个店员**（负责准备花束的，负责记账的，负责送花的等），告诉他们有新订单了，有空了处理一下

如果有店员入职，我通知的时候会多**通知**一个人；离职时，少**通知**一个人（维护一个需要通知的人员列表）

现在，有新订单的时候，我只需要**记到小本子上**，店员有空了自己来看

## 削峰

去年七夕，很多电话打给我，我把每一个订单告诉店员，但是店员忙不过来，客户又一直打电话来催，最后店员累成狗直接罢工

今年七夕节我学乖了，电话打进来我会告诉顾客:"我知道了，**会尽快安排处理**"，然后记到小本子上就行，店员有空时**按顺序来处理订单**就好

*另外还有一种思路，引导客户不一定要在七夕才开始下单，可以**提前**先买（淘宝的双十一预售就是出于这样的削峰思路）*

以上是rabbitMQ解决的**核心**问题。

## How to use rabbitMQ ?

## 基操安装方式

### MAC端

```
brew install rabbitmq

```

### Windows端

1. 安装Erlang，下载地址：[erlang.org/download/ot…](https://link.juejin.cn?target=http%3A%2F%2Ferlang.org%2Fdownload%2Fotp_win64_21.3.exe)

![](https://www.java-family.cn/BlogImage/20230108171340.png)

1. 安装RabbitMQ，下载地址：[dl.bintray.com/rabbitmq/al…](https://link.juejin.cn?target=https%3A%2F%2Fdl.bintray.com%2Frabbitmq%2Fall%2Frabbitmq-server%2F3.7.14%2Frabbitmq-server-3.7.14.exe)

![](https://www.java-family.cn/BlogImage/20230108171345.png)

1. 安装完成后，进入RabbitMQ安装目录下的sbin目录

![](https://www.java-family.cn/BlogImage/20230108171349.png)

1. 在地址栏输入cmd并回车启动命令行，然后输入以下命令启动管理功能：

```bash
rabbitmq-plugins enable rabbitmq_management

```

![](https://www.java-family.cn/BlogImage/20230108171352.png)

1. 访问地址查看是否安装成功：[http://localhost:15672/](https://link.juejin.cn?target=http%3A%2F%2Flocalhost%3A15672%2F)

![](https://www.java-family.cn/BlogImage/20230108171355.png)

### CentOS端

安装erlang

```bash
# rabbitmq依赖erlang 需要自己去自行下载
cd /path/to/erlang-sound-code && ./configure --prefix=/usr/local/erlang
make && make install 

vim /etc/profile
# 添加
export PATH=$PATH:/usr/local/erlang/bin

source /etc/profile
# 输入erl，会出现版本信息，即安装成功


```

安装rabbitmq

```bash
 #下载 abbitmq_server-3.8.16 并移动到/usr/local/下
vim /etc/profile
 # 添加
export PATH=$PATH:/usr/local/rabbitmq_server-3.8.16/sbin
source /etc/profile

cd /usr/local/rabbitmq_server-3.8.16/sbin 
# 启动
./rabbitmq-server start

```

## 功能实现

> RabbitMQ实现延迟消息的方式有两种，一种是使用`死信队列`实现，另一种是使用`延迟插件`实现。
>
> 死信队列的实现网上较多，本文介绍更简单的，使用`延迟插件`实现（mac环境，java版本）。

## 另外的安装方式（建议使用这种）

首先准备需要用到的安装文件及插件(rabbitmq_delayed_message_exchange)，版本需要匹配，不匹配的版本可能装不上或导致兼容问题。

![](https://www.java-family.cn/BlogImage/20230108171359.png)

本人使用的erl_25.0和rabbitMQ-3.10.0（可以到官网下载或者私信作者获取）。使用这种方式安装的优点在于本地安装和服务器安装流程完全一致，不过服务器需要开放安全端口5672,15672视情况，一般建议测试环境开放，生产环境关闭。

安装erl和rabbitMQ，具体步骤略（这个应该没人不会吧，逃~）。

将插件文件复制到RabbitMQ安装目录的`plugins`目录下，执行以下命令后重启rabbitMQ：

```bash
rabbitmq-plugins enable rabbitmq_delayed_message_exchange
```

## 实现延迟消息

以一个实际业务场景举例：当客服状态为在线且3分钟未回复客户消息时，自动重启im会话机器人接管会话。这是一个常见的延迟消息使用场景。

首先在`pom.xml`文件中添加`AMQP`相关依赖

```xml
<!--消息队列相关依赖-->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-amqp</artifactId>
</dependency>
```

在`application.yml`添加RabbitMQ的相关配置

```yaml
spring:
  rabbitmq:
    host: localhost # rabbitmq的连接地址
    port: 5672 # rabbitmq的连接端口号
    virtual-host: /mall # rabbitmq的虚拟host
    username: im # rabbitmq的用户名
    password: xxxxxx # rabbitmq的密码
    publisher-confirms: true #如果对异步消息需要回调必须设置为true
```

接下来创建RabbitMQ的java配置，主要用于配置交换机、队列和绑定关系

```java
/**
 * 消息队列配置
 */
@Configuration
public class RabbitMqConfig {
    /**
     * 机器人消息重启插件消息队列所绑定的交换机
     */
    @Bean
    CustomExchange chatPluginDirect() {
        //创建一个自定义交换机，可以发送延迟消息
        Map<String, Object> args = new HashMap<>();
        args.put("x-delayed-type", "direct");
        return new CustomExchange(QueueEnum.QUEUE_RESET_MESSAGE_CANCEL.getExchange(), "x-delayed-message", true, false, args);
    }

    /**
     * 机器人消息重启插件队列
     */
    @Bean
    public Queue chatPluginQueue() {
        return new Queue(QueueEnum.QUEUE_RESET_MESSAGE_CANCEL.getName());
    }

    /**
     * 将机器人消息重启插件队列绑定到交换机
     */
    @Bean
    public Binding chatPluginBinding(CustomExchange chatPluginDirect, Queue chatPluginQueue) {
        return BindingBuilder
                .bind(chatPluginQueue)
                .to(chatPluginDirect)
                .with(QueueEnum.QUEUE_RESET_MESSAGE_CANCEL.getRouteKey())
                .noargs();
    }
}

```

创建一个消息的发出者,通过给消息设置`x-delay`头来设置消息从交换机发送到队列的延迟时间

```java
/**
 * 机器人重启队列发出者
 */
@Component
@Slf4j
public class ChatQueueSender {
    private static Logger LOGGER = LoggerFactory.getLogger(ChatQueueSender.class);
    @Autowired
    private AmqpTemplate amqpTemplate;

    public void sendMessageToChat(Long cmid, final long delayTimes) {
        //给延迟队列发送消息
        amqpTemplate.convertAndSend(QueueEnum.QUEUE_RESET_MESSAGE_CANCEL.getExchange(), QueueEnum.QUEUE_RESET_MESSAGE_CANCEL.getRouteKey(), cmid, new MessagePostProcessor() {
            @Override
            public Message postProcessMessage(Message message) throws AmqpException {
                //给消息设置延迟毫秒值
                message.getMessageProperties().setHeader("x-delay", delayTimes);
                return message;
            }
        });
    }
}

```

创建一个消息的接收者，用于处理延迟插件队列中的消息。

```java
/**
 * 机器人重启队列处理者
 */
@Component
@Slf4j
@RabbitListener(queues = "im.chat.cancel")
public class ChatQueueReceiver {
    @Autowired
    private ChatRestartRobotService chatRestartRobotService;

    @RabbitHandler
    public void handleOnChat(Long cmid) {
//        log.info("机器人会话重启");
        chatRestartRobotService.restartRobot(cmid);
    }
}

```

最后，在对应的地方调用即可：

![](https://www.java-family.cn/BlogImage/20230108171405.png)
