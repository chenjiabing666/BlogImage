

**大家好，我是不才陈某~**

TiDB 是一个分布式 NewSQL 数据库。它支持水平弹性扩展、ACID 事务、标准 SQL、MySQL 语法和 MySQL 协议，具有数据强一致的高可用特性，是一个不仅适合 OLTP 场景还适合 OLAP 场景的混合数据库。

TiDB是 PingCAP公司自主设计、研发的开源分布式关系型数据库，是一款同时支持在线事务处理与在线分析处理 (Hybrid Transactional and Analytical Processing, HTAP）的融合型分布式数据库产品，具备水平扩容或者缩容、金融级高可用、实时 HTAP、云原生的分布式数据库、兼容 MySQL 5.7 协议和 MySQL 生态等重要特性。目标是为用户提供一站式 OLTP (Online Transactional Processing)、OLAP (Online Analytical Processing)、HTAP 解决方案。TiDB 适合高可用、强一致要求较高、数据规模较大等各种应用场景。

## 什么是NewSQL

数据库发展至今已经有3代了：

1. SQL，传统关系型数据库，例如 MySQL
2. noSQL，例如 MongoDB,Redis
3. newSQL

## 传统SQL的问题

互联网在本世纪初开始迅速发展，互联网应用的用户规模、数据量都越来越大，并且要求7X24小时在线。

传统关系型数据库在这种环境下成为了瓶颈，通常有2种解决方法：

### 升级服务器硬件

虽然提升了性能，但总有天花板。

### 数据分片

> 使用分布式集群结构

对单点数据库进行数据分片，存放到由廉价机器组成的分布式的集群里，可扩展性更好了，但也带来了新的麻烦。

以前在一个库里的数据，现在跨了多个库，应用系统不能自己去多个库中操作，需要使用数据库分片中间件。

分片中间件做简单的数据操作时还好，但涉及到跨库join、跨库事务时就很头疼了，很多人干脆自己在业务层处理，复杂度较高。

## NoSQL 的问题

后来 noSQL 出现了，放弃了传统SQL的强事务保证和关系模型，重点放在数据库的高可用性和可扩展性。

### 优点

- 高可用性和可扩展性，自动分区，轻松扩展
- 不保证强一致性，性能大幅提升
- 没有关系模型的限制，极其灵活

### 缺点

- 不保证强一致性，对于普通应用没问题，但还是有不少像金融一样的企业级应用有强一致性的需求。
- 不支持 SQL 语句，兼容性是个大问题，不同的 NoSQL 数据库都有自己的 api 操作数据，比较复杂。

## NewSQL 特性

NewSQL 提供了与 noSQL 相同的可扩展性，而且仍基于关系模型，还保留了极其成熟的 SQL 作为查询语言，保证了ACID事务特性。

简单来讲，NewSQL 就是在传统关系型数据库上集成了 NoSQL 强大的可扩展性。

传统的SQL架构设计基因中是没有分布式的，而 NewSQL 生于云时代，天生就是分布式架构。

## NewSQL 的主要特性

- SQL 支持，支持复杂查询和大数据分析。
- 支持 ACID 事务，支持隔离级别。
- 弹性伸缩，扩容缩容对于业务层完全透明。
- 高可用，自动容灾。

## 三种SQL的对比

![](https://baiyp.ren/images/tidb/tidb02.png)

## TiDB怎么来的

著名的开源分布式缓存服务 Codis 的作者，PingCAP联合创始人& CTO ，资深 infrastructure 工程师的黄东旭，擅长分布式存储系统的设计与实现，开源狂热分子的技术大神级别人物。即使在互联网如此繁荣的今天，在数据库这片边界模糊且不确定地带，他还在努力寻找确定性的实践方向。

直到 2012 年底，他看到 Google 发布的两篇论文，如同棱镜般，折射出他自己内心微烁的光彩。这两篇论文描述了 Google 内部使用的一个海量关系型数据库 F1/Spanner ，解决了关系型数据库、弹性扩展以及全球分布的问题，并在生产中大规模使用。“如果这个能实现，对数据存储领域来说将是颠覆性的”，黄东旭为完美方案的出现而兴奋， PingCAP 的 TiDB 在此基础上诞生了。

## TiDB社区版和企业版

> TiDB分为社区版以及企业版，企业版收费提供服务以及安全性的支持

![](https://baiyp.ren/images/tidb/tidb03.png)

## TIDB核心特性

### 水平弹性扩展

> 通过简单地增加新节点即可实现 TiDB 的水平扩展，按需扩展吞吐或存储，轻松应对高并发、海量数据场景

得益于 TiDB 存储计算分离的架构的设计，可按需对计算、存储分别进行在线扩容或者缩容，扩容或者缩容过程中对应用运维人员透明。

### 分布式事务支持

TiDB 100% 支持标准的 ACID 事务

### 金融级高可用

> 相比于传统主从 (M-S) 复制方案，基于 Raft 的多数派选举协议可以提供金融级的 100% 数据强一致性保证，且在不丢失大多数副本的前提下，可以实现故障的自动恢复 (auto-failover)，无需人工介入

数据采用多副本存储，数据副本通过 Multi-Raft 协议同步事务日志，多数派写入成功事务才能提交，确保数据强一致性且少数副本发生故障时不影响数据的可用性。可按需配置副本地理位置、副本数量等策略满足不同容灾级别的要求。

### 实时 HTAP

> TiDB 作为典型的 OLTP 行存数据库，同时兼具强大的 OLAP 性能，配合 TiSpark，可提供一站式 HTAP 解决方案，一份存储同时处理 OLTP & OLAP 无需传统繁琐的 ETL 过程

提供行存储引擎 TiKV、列存储引擎 TiFlash 两款存储引擎，TiFlash 通过 Multi-Raft Learner 协议实时从 TiKV 复制数据，确保行存储引擎 TiKV 和列存储引擎 TiFlash 之间的数据强一致。TiKV、TiFlash 可按需部署在不同的机器，解决 HTAP 资源隔离的问题。

### 云原生的分布式数据库

TiDB 是为云而设计的数据库，同 Kubernetes 深度耦合，支持公有云、私有云和混合云，使部署、配置和维护变得十分简单。TiDB 的设计目标是 100% 的 OLTP 场景和 80% 的 OLAP 场景，更复杂的 OLAP 分析可以通过 TiSpark 项目来完成。 TiDB 对业务没有任何侵入性，能优雅的替换传统的数据库中间件、数据库分库分表等 Sharding 方案。同时它也让开发运维人员不用关注数据库 Scale 的细节问题，专注于业务开发，极大的提升研发的生产力

### 高度兼容 MySQL

兼容 MySQL 5.7 协议、MySQL 常用的功能、MySQL 生态，应用无需或者修改少量代码即可从 MySQL 迁移到 TiDB。

提供丰富的数据迁移工具帮助应用便捷完成数据迁移，大多数情况下，无需修改代码即可从 MySQL 轻松迁移至 TiDB，分库分表后的 MySQL 集群亦可通过 TiDB 工具进行实时迁移。

## OLTP&OLAP(自学)

### OLTP(联机事务处理)

OLTP(Online Transactional Processing) 即联机事务处理，OLTP 是传统的关系型数据库的主要应用，主要是基本的、日常的事务处理，记录即时的增、删、改、查，比如在银行存取一笔款，就是一个事务交易

联机事务处理是事务性非常高的系统，一般都是高可用的在线系统，以小的事务以及小的查询为主，评估其系统的时候，一般看其每秒执行的Transaction以及Execute SQL的数量。在这样的系统中，单个数据库每秒处理的Transaction往往超过几百个，或者是几千个，Select 语句的执行量每秒几千甚至几万个。典型的OLTP系统有电子商务系统、银行、证券等，如美国eBay的业务数据库，就是很典型的OLTP数据库。

### OLAP(联机分析处理)

OLAP(Online Analytical Processing) 即联机分析处理，是数据仓库的核心部心，支持复杂的分析操作，侧重决策支持，并且提供直观易懂的查询结果。典型的应用就是复杂的动态报表系统

在这样的系统中，语句的执行量不是考核标准，因为一条语句的执行时间可能会非常长，读取的数据也非常多。所以，在这样的系统中，考核的标准往往是磁盘子系统的吞吐量（带宽），如能达到多少MB/s的流量。

### 特性对比

OLTP和OLAP的特性对比

| —                  | OLTP                                                         | OLAP                                                         |
| ------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 实时性             | OLTP 实时性要求高，OLTP 数据库旨在使事务应用程序仅写入所需的数据，以便尽快处理单个事务 | OLAP 的实时性要求不是很高，很多应用顶多是每天更新一下数据    |
| 数据量             | OLTP 数据量不是很大，一般只读 / 写数十条记录，处理简单的事务 | OLAP 数据量大，因为 OLAP 支持的是动态查询，所以用户也许要通过将很多数据的统计后才能得到想要知道的信息，例如时间序列分析等等，所以处理的数据量很大 |
| 用户和系统的面向性 | OLTP 是面向顾客的，用于事务和查询处理                        | OLAP 是面向市场的，用于数据分析                              |
| 数据库设计         | OLTP 采用实体 - 联系 ER 模型和面向应用的数据库设计           | OLAP 采用星型或雪花模型和面向主题的数据库设计                |

### 设计角度区别

| —        | OLTP                               | OLAP                               |
| -------- | ---------------------------------- | ---------------------------------- |
| 用户     | 操作人员，低层管理人员             | 决策人员，高级管理人员             |
| 功能     | 日常操作处理                       | 分析决策                           |
| 主要工作 | 增、删、改                         | 查询                               |
| DB 设计  | 面向应用                           | 面向主题                           |
| 数据     | 当前的，最新的细节，二维的，分立的 | 历史的，聚集的，多维集成的，统一的 |
| 存取     | 读/写数十条记录                    | 读上百万条记录                     |
| 工作单位 | 简单的事务                         | 复杂的查询                         |
| 用户数   | 上千个                             | 上百个                             |
| DB 大小  | 100MB-GB                           | 100GB-TB                           |

## TiDB 整体架构

## TiDB的优势

与传统的单机数据库相比，TiDB 具有以下优势：

- 纯分布式架构，拥有良好的扩展性，支持弹性的扩缩容
- 支持 SQL，对外暴露 MySQL 的网络协议，并兼容大多数 MySQL 的语法，在大多数场景下可以直接替换 MySQL
- 默认支持高可用，在少数副本失效的情况下，数据库本身能够自动进行数据修复和故障转移，对业务透明
- 支持 ACID 事务，对于一些有强一致需求的场景友好，例如：银行转账
- 具有丰富的工具链生态，覆盖数据迁移、同步、备份等多种场景

## TiDB的组件

要深入了解 TiDB 的水平扩展和高可用特点，首先需要了解 TiDB 的整体架构。TiDB 集群主要包括三个核心组件：TiDB Server，PD Server 和 TiKV Server，此外，还有用于解决用户复杂 OLAP 需求的 TiSpark 组件。

在内核设计上，TiDB 分布式数据库将整体架构拆分成了多个模块，各模块之间互相通信，组成完整的 TiDB 系统。对应的架构图如下：

![architecture](https://baiyp.ren/images/tidb/tidb04.png)

### TiDB Server

TiDB Server 负责接收 SQL 请求，处理 SQL 相关的逻辑，并通过 PD 找到存储计算所需数据的 TiKV 地址，与 TiKV 交互获取数据，最终返回结果。TiDB Server 是无状态的，其本身并不存储数据，只负责计算，可以无限水平扩展，可以通过负载均衡组件（如 LVS、HAProxy 或 F5）对外提供统一的接入地址。

### PD (Placement Driver) Server

Placement Driver (简称 PD) 是整个集群的管理模块，其主要工作有三个：

- 一是存储集群的元信息（某个 Key 存储在哪个 TiKV 节点）；
- 二是对 TiKV 集群进行调度和负载均衡（如数据的迁移、Raft group leader 的迁移等）；
- 三是分配全局唯一且递增的事务 ID。

PD 通过 Raft 协议保证数据的安全性。Raft 的 leader server 负责处理所有操作，其余的 PD server 仅用于保证高可用。建议部署奇数个 PD 节点

### TiKV Server

TiKV Server 负责存储数据，从外部看 TiKV 是一个分布式的提供事务的 Key-Value 存储引擎。存储数据的基本单位是 Region，每个 Region 负责存储一个 Key Range（从 StartKey 到 EndKey 的左闭右开区间）的数据，每个 TiKV 节点会负责多个 Region。TiKV 使用 Raft 协议做复制，保持数据的一致性和容灾。副本以 Region 为单位进行管理，不同节点上的多个 Region 构成一个 Raft Group，互为副本。数据在多个 TiKV 之间的负载均衡由 PD 调度，这里也是以 Region 为单位进行调度。

### TiSpark

TiSpark 作为 TiDB 中解决用户复杂 OLAP 需求的主要组件，将 Spark SQL 直接运行在 TiDB 存储层上，同时融合 TiKV 分布式集群的优势，并融入大数据社区生态。至此，TiDB 可以通过一套系统，同时支持 OLTP 与 OLAP，免除用户数据同步的烦恼。

### TiFlash

TiFlash 是一类特殊的存储节点。和普通 TiKV 节点不一样的是，在 TiFlash 内部，数据是以列式的形式进行存储，主要的功能是为分析型的场景加速。

## TiKV整体架构

与传统的整节点备份方式不同的，TiKV是将数据按照 key 的范围划分成大致相等的切片（下文统称为 Region），每一个切片会有多个副本（通常是 3 个），其中一个副本是 Leader，提供读写服务。TiKV 通过 PD 对这些 Region 以及副本进行调度，以保证数据和读写负载都均匀地分散在各个 TiKV 上，这样的设计保证了整个集群资源的充分利用并且可以随着机器数量的增加水平扩展。

![](https://baiyp.ren/images/tidb/tidb05.png)

### Region分裂与合并

当某个 Region 的大小超过一定限制（默认是 144MB）后，TiKV 会将它分裂为两个或者更多个 Region，以保证各个 Region 的大小是大致接近的，这样更有利于 PD 进行调度决策。同样，当某个 Region 因为大量的删除请求导致 Region 的大小变得更小时，TiKV 会将比较小的两个相邻 Region 合并为一个。

### Region调度

Region 与副本之间通过 Raft 协议来维持数据一致性，任何写请求都只能在 Leader 上写入，并且需要写入多数副本后（默认配置为 3 副本，即所有请求必须至少写入两个副本成功）才会返回客户端写入成功。

当 PD 需要把某个 Region 的一个副本从一个 TiKV 节点调度到另一个上面时，PD 会先为这个 Raft Group 在目标节点上增加一个 Learner 副本（复制 Leader 的数据）。当这个 Learner 副本的进度大致追上 Leader 副本时，Leader 会将它变更为 Follower，之后再移除操作节点的 Follower 副本，这样就完成了 Region 副本的一次调度。

Leader 副本的调度原理也类似，不过需要在目标节点的 Learner 副本变为 Follower 副本后，再执行一次 Leader Transfer，让该 Follower 主动发起一次选举成为新 Leader，之后新 Leader 负责删除旧 Leader 这个副本。

### 分布式事务

TiKV 支持分布式事务，用户（或者 TiDB）可以一次性写入多个 key-value 而不必关心这些 key-value 是否处于同一个数据切片 (Region) 上，TiKV 通过两阶段提交保证了这些读写请求的 ACID 约束。

## 高可用架构

高可用是 TiDB 的另一大特点，TiDB/TiKV/PD 这三个组件都能容忍部分实例失效，不影响整个集群的可用性。下面分别说明这三个组件的可用性、单个实例失效后的后果以及如何恢复。

### TiDB高可用

TiDB 是无状态的，推荐至少部署两个实例，前端通过负载均衡组件对外提供服务。当单个实例失效时，会影响正在这个实例上进行的 Session，从应用的角度看，会出现单次请求失败的情况，重新连接后即可继续获得服务。单个实例失效后，可以重启这个实例或者部署一个新的实例。

### PD高可用

PD 是一个集群，通过 Raft 协议保持数据的一致性，单个实例失效时，如果这个实例不是 Raft 的 leader，那么服务完全不受影响；如果这个实例是 Raft 的 leader，会重新选出新的 Raft leader，自动恢复服务。PD 在选举的过程中无法对外提供服务，这个时间大约是3秒钟。推荐至少部署三个 PD 实例，单个实例失效后，重启这个实例或者添加新的实例。

### TiKV高可用

TiKV 是一个集群，通过 Raft 协议保持数据的一致性（副本数量可配置，默认保存三副本），并通过 PD 做负载均衡调度。单个节点失效时，会影响这个节点上存储的所有 Region。对于 Region 中的 Leader 结点，会中断服务，等待重新选举；对于 Region 中的 Follower 节点，不会影响服务。当某个 TiKV 节点失效，并且在一段时间内（默认 10 分钟）无法恢复，PD 会将其上的数据迁移到其他的 TiKV 节点上。

## 应用场景

### MySQL分片与合并

![](https://baiyp.ren/images/tidb/tidb06.png)

TiDB 应用的第一类场景是 MySQL 的分片与合并。对于已经在用 MySQL 的业务，分库、分表、分片、中间件是常用手段，随着分片的增多，跨分片查询是一大难题。TiDB 在业务层兼容 MySQL 的访问协议，PingCAP 做了一个数据同步的工具——Syncer，它可以把黄东旭 TiDB 作为一个 MySQL Slave，将 TiDB 作为现有数据库的从库接在主 MySQL 库的后方，在这一层将数据打通，可以直接进行复杂的跨库、跨表、跨业务的实时 SQL 查询。黄东旭提到，“过去的数据库都是一主多从，有了 TiDB 以后，可以反过来做到多主一从。”

### 直接替换MySQL

![](https://baiyp.ren/images/tidb/tidb07.png)

第二类场景是用 TiDB 直接去替换 MySQL。如果你的IT架构在搭建之初并未考虑分库分表的问题，全部用了 MySQL，随着业务的快速增长，海量高并发的 OLTP 场景越来越多，如何解决架构上的弊端呢?

在一个 TiDB 的数据库上，所有业务场景不需要做分库分表，所有的分布式工作都由数据库层完成。TiDB 兼容 MySQL 协议，所以可以直接替换 MySQL，而且基本做到了开箱即用，完全不用担心传统分库分表方案带来繁重的工作负担和复杂的维护成本，友好的用户界面让常规的技术人员可以高效地进行维护和管理。另外，TiDB 具有 NoSQL 类似的扩容能力，在数据量和访问流量持续增长的情况下能够通过水平扩容提高系统的业务支撑能力，并且响应延迟稳定。

### 数据仓库

![](https://baiyp.ren/images/tidb/tidb08.png)



TiDB 本身是一个分布式系统，第三种使用场景是将 TiDB 当作数据仓库使用。TPC-H 是数据分析领域的一个测试集，TiDB 2.0 在 OLAP 场景下的性能有了大幅提升，原来只能在数据仓库里面跑的一些复杂的 Query，在 TiDB 2.0 里面跑，时间基本都能控制在 10 秒以内。当然，因为 OLAP 的范畴非常大，TiDB 的 SQL 也有搞不定的情况，为此 PingCAP 开源了 TiSpark，TiSpark 是一个 Spark 插件，用户可以直接用 Spark SQL 实时地在 TiKV 上做大数据分析。

### 作为其他系统的模块

![](https://baiyp.ren/images/tidb/tidb09.png)

TiDB 是一个传统的存储跟计算分离的项目，其底层的 Key-Value 层，可以单独作为一个 HBase 的 Replacement 来用，它同时支持跨行事务。TiDB 对外提供两个 API 接口，一个是 ACID Transaction 的 API，用于支持跨行事务；另一个是 Raw API，它可以做单行的事务，换来的是整个性能的提升，但不提供跨行事务的 ACID 支持。用户可以根据自身的需求在两个 API 之间自行选择。例如有一些用户直接在 TiKV 之上实现了 Redis 协议，将 TiKV 替换一些大容量，对延迟要求不高的 Redis 场景。

## 应用案例

![](https://baiyp.ren/images/tidb/tidb10.png)

## TiDB与MySQL兼容性对比

- TiDB**支持MySQL**传输协议及其绝大多数的语法。这意味着您现有的MySQL连接器和客户端都可以继续使用。 大多数情况下您现有的应用都可以迁移至 TiDB，无需任何代码修改。
- 当前TiDB服务器官方支持的版本为**MySQL 5.7**。大部分MySQL运维工具（如PHPMyAdmin, Navicat, MySQL Workbench等），以及备份恢复工具（如 mysqldump, Mydumper/myloader）等都可以直接使用。
- 不过一些特性由于在分布式环境下没法很好的实现，目前暂时不支持或者是表现与MySQL有差异
- **一些MySQL语法在TiDB中可以解析通过，但是不会做任何后续的处理**，例如Create Table语句中Engine，是解析并忽略。

## TiDB不支持的MySql特性

- 存储过程与函数
- 触发器
- 事件
- 自定义函数
- 外键约束
- 临时表
- 全文/空间函数与索引
- 非 `ascii`/`latin1`/`binary`/`utf8`/`utf8mb4` 的字符集
- SYS schema
- MySQL 追踪优化器
- XML 函数
- X-Protocol
- Savepoints
- 列级权限
- `XA` 语法（TiDB 内部使用两阶段提交，但并没有通过 SQL 接口公开）
- `CREATE TABLE tblName AS SELECT stmt` 语法
- `CHECK TABLE` 语法
- `CHECKSUM TABLE` 语法
- `GET_LOCK` 和 `RELEASE_LOCK` 函数

## 自增ID

TiDB 的自增列仅保证唯一，也能保证在单个 TiDB server 中自增，但不保证多个 TiDB server 中自增，不保证自动分配的值的连续性，建议不要将缺省值和自定义值混用，若混用可能会收 `Duplicated Error` 的错误信息。

TiDB 可通过 `tidb_allow_remove_auto_inc` 系统变量开启或者关闭允许移除列的 `AUTO_INCREMENT` 属性。删除列属性的语法是：`alter table modify` 或 `alter table change`。

TiDB 不支持添加列的 `AUTO_INCREMENT` 属性，移除该属性后不可恢复。

## SELECT 的限制

- 不支持 `SELECT ... INTO @变量` 语法。
- 不支持 `SELECT ... GROUP BY ... WITH ROLLUP` 语法。
- TiDB 中的 `SELECT .. GROUP BY expr` 的返回结果与 MySQL 5.7 并不一致。MySQL 5.7 的结果等价于 `GROUP BY expr ORDER BY expr`。而 TiDB 中该语法所返回的结果并不承诺任何顺序，与 MySQL 8.0 的行为一致。

## 视图

目前TiDB**不支持**对视图进行UPDATE、INSERT、DELETE等**写入操作**。

## 默认设置差异

### 字符集

- TiDB 默认：`utf8mb4`。
- MySQL 5.7 默认：`latin1`。
- MySQL 8.0 默认：`utf8mb4`。

### 排序规则

- TiDB 中 `utf8mb4` 字符集默认：`utf8mb4_bin`。
- MySQL 5.7 中 `utf8mb4` 字符集默认：`utf8mb4_general_ci`。
- MySQL 8.0 中 `utf8mb4` 字符集默认：`utf8mb4_0900_ai_ci`。

### 大小写敏感

> 关于`lower_case_table_names`的配置

- TiDB 默认：`2`，且仅支持设置该值为 `2`。
- MySQL 默认如下：
  - Linux 系统中该值为 `0`
  - Windows 系统中该值为 `1`
  - macOS 系统中该值为 `2`

### 参数解释

- lower_case_table_names=0 表名存储为给定的大小和比较是区分大小写的
- lower_case_table_names = 1 表名存储在磁盘是小写的，但是比较的时候是不区分大小写
- lower_case_table_names=2 表名存储为给定的大小写但是比较的时候是小写的

### timestamp类型字段更新

> 默认情况下，timestamp类型字段所在数据行被更新时，该字段会自动更新为当前时间，而参数explicit_defaults_for_timestamp控制这一种行为。

- TiDB 默认：`ON`，且仅支持设置该值为 `ON`。
- MySQL 5.7 默认：`OFF`。
- MySQL 8.0 默认：`ON`。

### 参数解释

- explicit_defaults_for_timestamp=off，数据行更新时，timestamp类型字段更新为当前时间
- explicit_defaults_for_timestamp=on，数据行更新时，timestamp类型字段不更新为当前时间。

### 外键支持

- TiDB 默认：`OFF`，且仅支持设置该值为 `OFF`。
- MySQL 5.7 默认：`ON`。
