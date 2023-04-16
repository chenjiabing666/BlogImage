**大家好，我是不才陈某~**

saas 服务未来会面临数据安全、合规等问题。公司的业务需要沉淀一套私有化部署能力，帮助业务提升行业竞争力。

为了完善平台系统能力、我们需要沉淀一套数据体系帮助运营分析活动效果、提升运营能力。

然而在实际的开发过程中，如果直接部署一套大数据体系，对于使用者来说将是一笔比较大的服务器开销。为此我们选用折中方案完善数据分析能力。

## Elasticsearch vs ClickHouse



ClickHouse 是一款高性能列式分布式数据库管理系统，我们对 ClickHouse 进行了测试，发现有下列优势：

**ClickHouse 写入吞吐量大**

单服务器日志写入量在 50MB 到 200MB/s，每秒写入超过 60w 记录数，是 ES 的 5 倍以上。

在 ES 中比较常见的写 Rejected 导致数据丢失、写入延迟等问题，在 ClickHouse 中不容易发生。

**查询速度快**

官方宣称数据在 pagecache 中，单服务器查询速率大约在 2-30GB/s；没在 pagecache 的情况下，查询速度取决于磁盘的读取速率和数据的压缩率。经测试 ClickHouse 的查询速度比 ES 快 5-30 倍以上。

**ClickHouse 比 ES 服务器成本更低**

一方面 ClickHouse 的数据压缩比比 ES 高，相同数据占用的磁盘空间只有 ES 的 1/3 到 1/30，节省了磁盘空间的同时，也能有效的减少磁盘 IO，这也是ClickHouse查询效率更高的原因之一。

![](https://www.java-family.cn/BlogImage/20230102193806.png)



另一方面 ClickHouse 比 ES 占用更少的内存，消耗更少的 CPU 资源。我们预估用 ClickHouse 处理日志可以将服务器成本降低一半。

![](https://www.java-family.cn/BlogImage/20230102193809.png)



## 成本分析

在没有任何折扣的情况下，基于 aliyun 分析。



![](https://www.java-family.cn/BlogImage/20230102193812.png)



## 环境部署



**1、zookeeper 集群部署**



![](https://www.java-family.cn/BlogImage/20230102193815.png)



```shell
yum install java-1.8.0-openjdk-devel.x86_64
/etc/profile 配置环境变量
更新系统时间
yum install  ntpdate
ntpdate asia.pool.ntp.org

mkdir zookeeper
mkdir ./zookeeper/data
mkdir ./zookeeper/logs
wget  --no-check-certificate https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/zookeeper-3.7.1/apache-zookeeper-3.7.1-bin.tar.gz
tar -zvxf apache-zookeeper-3.7.1-bin.tar.gz -C /usr/zookeeper

export ZOOKEEPER_HOME=/usr/zookeeper/apache-zookeeper-3.7.1-bin
export PATH=$ZOOKEEPER_HOME/bin:$PATH

进入ZooKeeper配置目录
cd $ZOOKEEPER_HOME/conf

新建配置文件
vi zoo.cfg

tickTime=2000
initLimit=10
syncLimit=5
dataDir=/usr/zookeeper/data
dataLogDir=/usr/zookeeper/logs
clientPort=2181
server.1=zk1:2888:3888
server.2=zk2:2888:3888
server.3=zk3:2888:3888

在每台服务器上执行，给zookeeper创建myid
echo "1" > /usr/zookeeper/data/myid
echo "2" > /usr/zookeeper/data/myid
echo "3" > /usr/zookeeper/data/myid

进入ZooKeeper bin目录
cd $ZOOKEEPER_HOME/bin
sh zkServer.sh start
```



**2、Kafka 集群部署**



```shell
mkdir -p /usr/kafka
chmod 777 -R /usr/kafka
wget  --no-check-certificate https://mirrors.tuna.tsinghua.edu.cn/apache/kafka/3.2.0/kafka_2.12-3.2.0.tgz
tar -zvxf kafka_2.12-3.2.0.tgz -C /usr/kafka

不同的broker Id 设置不一样，比如 1,2,3
broker.id=1
listeners=PLAINTEXT://ip:9092
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
log.dir=/usr/kafka/logs
num.partitions=5
num.recovery.threads.per.data.dir=3
offsets.topic.replication.factor=2
transaction.state.log.replication.factor=3
transaction.state.log.min.isr=3
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
zookeeper.connect=zk1:2181,zk2:2181,zk3:2181
zookeeper.connection.timeout.ms=30000
group.initial.rebalance.delay.ms=0

后台常驻进程启动kafka
nohup /usr/kafka/kafka_2.12-3.2.0/bin/kafka-server-start.sh /usr/kafka/kafka_2.12-3.2.0/config/server.properties   >/usr/kafka/logs/kafka.log >&1 &

/usr/kafka/kafka_2.12-3.2.0/bin/kafka-server-stop.sh

$KAFKA_HOME/bin/kafka-topics.sh --list --bootstrap-server  ip:9092

$KAFKA_HOME/bin/kafka-console-consumer.sh --bootstrap-server ip:9092 --topic test --from-beginning

$KAFKA_HOME/bin/kafka-topics.sh  --create --bootstrap-server  ip:9092  --replication-factor 2 --partitions 3 --topic xxx_data
```



**3、FileBeat 部署**



```shell
sudo rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
Create a file with a .repo extension (for example, elastic.repo) in your /etc/yum.repos.d/ directory and add the following lines:
在/etc/yum.repos.d/ 目录下创建elastic.repo

[elastic-8.x]
name=Elastic repository for 8.x packages
baseurl=https://artifacts.elastic.co/packages/8.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md

yum install filebeat
systemctl enable filebeat
chkconfig --add filebeat
```



FileBeat 配置文件说明，坑点 1（需设置 keys_under_root: true）。如果不设置kafka 的消息字段如下：



![](https://www.java-family.cn/BlogImage/20230102193821.png)





```shell
文件目录：/etc/filebeat/filebeat.yml

filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /root/logs/xxx/inner/*.log
  json:  
如果不设置该索性，所有的数据都存储在message里面，这样设置以后数据会平铺。
       keys_under_root: true 
output.kafka:
  hosts: ["kafka1:9092", "kafka2:9092", "kafka3:9092"]
  topic: 'xxx_data_clickhouse'
  partition.round_robin:
            reachable_only: false
            required_acks: 1
            compression: gzip
processors: 
剔除filebeat 无效的字段数据
    - drop_fields:  
        fields: ["input", "agent", "ecs", "log", "metadata", "timestamp"]
        ignore_missing: false

nohup ./filebeat -e -c /etc/filebeat/filebeat.yml > /user/filebeat/filebeat.log & 
输出到filebeat.log文件中，方便排查
```



**4、clickhouse 部署**



![](https://www.java-family.cn/BlogImage/20230102193828.png)



```shell
检查当前CPU是否支持SSE 4.2，如果不支持，需要通过源代码编译构建
grep -q sse4_2 /proc/cpuinfo && echo "SSE 4.2 supported" || echo "SSE 4.2 not supported"
返回 "SSE 4.2 supported" 表示支持，返回 "SSE 4.2 not supported" 表示不支持

创建数据保存目录，将它创建到大容量磁盘挂载的路径
mkdir -p /data/clickhouse
修改/etc/hosts文件，添加clickhouse节点
举例：
10.190.85.92 bigdata-clickhouse-01
10.190.85.93 bigdata-clickhouse-02

服务器性能参数设置：
cpu频率调节，将CPU频率固定工作在其支持的最高运行频率上，而不动态调节，性能最好
echo 'performance' | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

内存调节，不要禁用 overcommit
echo 0 | tee /proc/sys/vm/overcommit_memory

始终禁用透明大页(transparent huge pages)。它会干扰内存分配器，从而导致显着的性能下降
echo 'never' | tee /sys/kernel/mm/transparent_hugepage/enabled

首先，需要添加官方存储库：
yum install yum-utils
rpm --import <https://repo.clickhouse.tech/CLICKHOUSE-KEY.GPG>
yum-config-manager --add-repo <https://repo.clickhouse.tech/rpm/stable/x86_64>
查看clickhouse可安装的版本：
yum list | grep clickhouse
运行安装命令：
yum -y install clickhouse-server clickhouse-client

修改/etc/clickhouse-server/config.xml配置文件，修改日志级别为information，默认是trace
<level>information</level>
执行日志所在目录：

正常日志
/var/log/clickhouse-server/clickhouse-server.log
异常错误日志
/var/log/clickhouse-server/clickhouse-server.err.log

查看安装的clickhouse版本：
clickhouse-server --version
clickhouse-client --password

sudo clickhouse stop
sudo clickhouse tart
sudo clickhouse start
```



![](https://www.java-family.cn/BlogImage/20230102193831.png)



clickhouse 部署过程中遇到的一些问题如下：

**1）clickhouse 创建 kafka 引擎表**

```shell
CREATE TABLE default.kafka_clickhouse_inner_log ON CLUSTER clickhouse_cluster (
    log_uuid   String ,
    date_partition   UInt32 ,
    event_name   String ,
    activity_name   String ,
    activity_type   String ,
    activity_id   UInt16 
) ENGINE = Kafka SETTINGS
    kafka_broker_list = 'kafka1:9092,kafka2:9092,kafka3:9092',
    kafka_topic_list = 'data_clickhouse',
    kafka_group_name = 'clickhouse_xxx',
    kafka_format = 'JSONEachRow',
    kafka_row_delimiter = '\n',
    kafka_num_consumers = 1;
```

**问题 1：clikhouse 客户端无法查询 kafka 引擎表**

```java
Direct select is not allowed. To enable use setting stream_like_engine_allow_direct_select.(QUERY_NOT_ALLOWED) (version 22.5.2.53 (official build))
```

![](https://www.java-family.cn/BlogImage/20230102193835.png)



**解决方案：**



```shell
需要在clickhouse client 创建加上 --stream_like_engine_allow_direct_select 1

clickhouse-client --stream_like_engine_allow_direct_select 1 --password xxxxx
```



![](https://www.java-family.cn/BlogImage/20230102193839.png)



**2）clickhouse 创建本地节点表**

**问题 2：无法开启本地表 macro**



```java
Code: 62. DB::Exception: There was an error on [10.74.244.57:9000]: Code: 62. DB::Exception: No macro 'shard' in config while processing substitutions in '/clickhouse/tables/default/bi_inner_log_local/{shard}' at '50' or macro is not supported here. (SYNTAX_ERROR) (version 22.5.2.53 (official build)). (SYNTAX_ERROR) (version 22.5.2.53 (official build))
```

```shell
创建本地表（使用复制去重表引擎）
create table default.bi_inner_log_local ON CLUSTER clickhouse_cluster (
    log_uuid   String ,
    date_partition   UInt32 ,
    event_name   String ,
    activity_name   String ,
    credits_bring   Int16 ,
    activity_type   String ,
    activity_id   UInt16 
) ENGINE = ReplicatedReplacingMergeTree('/clickhouse/tables/default/bi_inner_log_local/{shard}','{replica}')
  PARTITION BY date_partition
  ORDER BY (event_name,date_partition,log_uuid)
   SETTINGS index_granularity = 8192;
```



**解决方案：**在不同的 clickhouse 节点上配置不同的 shard，每一个节点的 shard 名称不能一致



```xml
<macros>
    <shard>01</shard>
    <replica>example01-01-1</replica>
</macros>
```



![](https://www.java-family.cn/BlogImage/20230102193843.png)



![](https://www.java-family.cn/BlogImage/20230102193845.png)



**问题 3：clickhouse 中节点数据已经存在**

```java
Code: 253. DB::Exception: There was an error on : Code: 253. DB::Exception: Replica /clickhouse/tables/default/bi_inner_log_local/01/replicas/example01-01-1 already exists. (REPLICA_IS_ALREADY_EXIST) (version 22.5.2.53 (official build)). (REPLICA_IS_ALREADY_EXIST) (version 22.5.2.53 (official build))
```

**解决方案：进入 zookeeper 客户端删除相关节点，然后再重新创建 ReplicatedReplacingMergeTree 表。这样可以保障每一个 clickhouse 节点都会去消费 kafka partition 的数据。**



**3）clickhouse 创建集群表**

创建分布式表（根据 log_uuid 对数据进行分发，相同的 log_uuid 会发送到同一个 shard 分片上，用于后续合并时的数据去重）：

```sql
CREATE TABLE default.bi_inner_log_all ON CLUSTER clickhouse_cluster AS default.bi_inner_log_local
ENGINE = Distributed(clickhouse_cluster, default, bi_inner_log_local, xxHash32(log_uuid));
```

**问题 4：分布式集群表无法查询**

```java
Code: 516. DB::Exception: Received from 10.74.244.57:9000. DB::Exception: default: Authentication failed: password is incorrect or there is no user with such name. (AUTHENTICATION_FAILED) (version 22.5.2.53 (official build))
```

**解决方案：**



```xml
 <!--分布式表配置-->
 <remote_servers>
       <clickhouse_cluster> <!--集群名称, 可以自定义, 后面在新建库、表的时候需要用到集群名称-->
     <shard>
    <!--内部复制(默认false), 开启后, 在分布式表引擎下, 数据写入时-->
                        <!--每个分片只会去寻找一个节点写, 并不是每个都写-->
                        <internal_replication>true</internal_replication>
                        <replica>
                            <host>ip1</host>
                            <port>9000</port>
                                    <user>default</user>
                                    <password>xxxx</password>
                        </replica>
                    </shard>
                    <shard>
                        <internal_replication>true</internal_replication>
                        <replica>
                            <host>ip2</host>
                            <port>9000</port>
                                    <user>default</user>
                                    <password>xxxx</password>
                        </replica>
                    </shard>
                </clickhouse_cluster>
</remote_servers>
```



**4）clickhouse 创建物化视图**

创建物化视图，把 Kafka 消费表消费的数据同步到 ClickHouse 分布式表。

```sql
CREATE MATERIALIZED VIEW default.view_bi_inner_log ON CLUSTER clickhouse_cluster TO default.bi_inner_log_all AS 
SELECT 
    log_uuid ,
date_partition ,
event_name ,
activity_name ,
credits_bring ,
activity_type ,
activity_id 
FROM default.kafka_clickhouse_inner_log;
```



功夫不负有心人，解决完以上所有的问题。数据流转通了！本文所有组件都是比较新的版本，所以过程中问题的解决基本都是官方文档或操作手册一步一步的解决。

![](https://www.java-family.cn/BlogImage/20230102193850.png)



总结一句话：遇到问题去官方文档或--help 去尝试解决，慢慢的你就会升华。