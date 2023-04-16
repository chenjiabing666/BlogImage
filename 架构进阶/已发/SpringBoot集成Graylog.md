**大家好，我是不才陈某~**

在微服务架构中，一个服务通常都会有多个实例，而这些服务实例可能会被部署到不同的机器或虚拟容器上。此时对于日志数据的查看和分析就会变得困难起来，因为这些服务的日志数据都散落在各自实例所在的机器或容器上。例如，我现在要在订单服务里查找一个订单id为1的日志，而订单服务有10个实例并且部署在10台不同的机器上，那么我就得一台台的去找这个日志数据。所以这时候我们就需要有一个可以实现日志聚合的工具，将所有实例的日志数据都聚合在一个地方，那么我们就不需要到每个实例去找日志了，而本文将使用的日志聚合工具为Graylog

## 部署Graylog

老样子，直接上docker-compose，如果一直跟着我的步伐，应该对着不陌生了。 docker-compose.yml 的内容其实我也是抄官网的，这里还是贴下吧（就不用你们翻了）

```yaml
version: '3'
services:
    mongo:
      image: mongo:4.2
      networks:
        - graylog
    elasticsearch:
      image: docker.elastic.co/elasticsearch/elasticsearch-oss:7.10.2
      environment:
        - http.host=0.0.0.0
        - transport.host=localhost
        - network.host=0.0.0.0
        - "ES_JAVA_OPTS=-Dlog4j2.formatMsgNoLookups=true -Xms512m -Xmx512m"
      ulimits:
        memlock:
          soft: -1
          hard: -1
      deploy:
        resources:
          limits:
            memory: 1g
      networks:
        - graylog
    graylog:
      image: graylog/graylog:4.2
      environment:
        - GRAYLOG_PASSWORD_SECRET=somepasswordpepper
        - GRAYLOG_ROOT_PASSWORD_SHA2=8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918
        - GRAYLOG_HTTP_EXTERNAL_URI=http://ip:9009/ # 这里注意要改ip
      entrypoint: /usr/bin/tini -- wait-for-it elasticsearch:9200 --  /docker-entrypoint.sh
      networks:
        - graylog
      restart: always
      depends_on:
        - mongo
        - elasticsearch
      ports:
        - 9009:9000
        - 1514:1514
        - 1514:1514/udp
        - 12201:12201
        - 12201:12201/udp
networks:
    graylog:
      driver: bridg
```

这个文件里唯一需要改动的就是 ip （本来的端口是 9000 的，我由于已经占用了 9000 端口了，所以我这里把端口改成了 9009 ，你们可以随意）

嗯，写完 docker-compose.yml 文件，直接 docker-compose up -d 它就启动起来咯。

启动以后，我们就可以通过 ip:port 访问对应的Graylog后台地址了，默认的账号和密码是 admin/admin

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/27700a2d2ddc4511817207eb92868a7d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

随后，我们配置下 inputs 的配置，找到 GELF UDP ，然后点击 Launch new input ，只需要填写 Title 字段，保存就完事了（其他不用动）。

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/26a3dfdc94f64bae91dfc1de0e1c6683~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)



## Spring Boot 集成GrayLog

首先创建一个SpringBoot项目，SpringBoot默认自带的日志框架是Logback，我们可以到 Graylog组件市场查找Logback相应的组件。

添加依赖如下：

```xml
<dependency>
  <groupId>de.siegmar</groupId>
  <artifactId>logback-gelf</artifactId>
  <version>3.0.0</version>
</dependency>
```

接着在项目的resources目录下，新建一个`logback.xml`文件，编辑文件内容如下：

```xml
<appender name="GELF" class="de.siegmar.logbackgelf.GelfUdpAppender">
  <!-- Graylog服务的地址 -->
  <graylogHost>ip</graylogHost>
  <!-- UDP Input端口 -->
  <graylogPort>12201</graylogPort>
  <!-- 最大GELF数据块大小（单位：字节），508为建议最小值，最大值为65467 -->
  <maxChunkSize>508</maxChunkSize>
  <!-- 是否使用压缩 -->
  <useCompression>true</useCompression>
  <encoder class="de.siegmar.logbackgelf.GelfEncoder">
    <!-- 是否发送原生的日志信息 -->
    <includeRawMessage>false</includeRawMessage>
    <includeMarker>true</includeMarker>
    <includeMdcData>true</includeMdcData>
    <includeCallerData>false</includeCallerData>
    <includeRootCauseData>false</includeRootCauseData>
    <!-- 是否发送日志级别的名称，否则默认以数字代表日志级别 -->
    <includeLevelName>true</includeLevelName>
    <shortPatternLayout class="ch.qos.logback.classic.PatternLayout">
      <pattern>%m%nopex</pattern>
    </shortPatternLayout>
    <fullPatternLayout class="ch.qos.logback.classic.PatternLayout">
      <pattern>%d - [%thread] %-5level %logger{35} - %msg%n</pattern>
    </fullPatternLayout>

    <!-- 配置应用名称（服务名称），通过staticField标签可以自定义一些固定的日志字段 -->
    <staticField>app_name:austin</staticField>
  </encoder>
</appender>
```

在这个配置信息里，唯一要改的也只是 **ip** 的地址，到这里接入就完毕了，我们再打开控制台，就能看到日志的信息啦。

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3f6c238e99ff4cea86cc0dbf89b80969~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

配置完成后启动项目，启动完成后正常情况下可以在Graylog的Search界面中查看日志信息：

![](https://s2.51cto.com/images/blog/201904/19/86f143a8cf547f066c3e40f9e927c60e.png?x-oss-process=image/watermark,size_16,text_QDUxQ1RP5Y2a5a6i,color_FFFFFF,t_30,g_se,x_10,y_10,shadow_20,type_ZmFuZ3poZW5naGVpdGk=/format,webp/resize,m_fixed,w_750)

点击一条日志信息会展开详细的字段：

![](https://s2.51cto.com/images/blog/201904/19/adb77ed14e80aa3addd002ed6b6eecac.png?x-oss-process=image/watermark,size_16,text_QDUxQ1RP5Y2a5a6i,color_FFFFFF,t_30,g_se,x_10,y_10,shadow_20,type_ZmFuZ3poZW5naGVpdGk=/format,webp/resize,m_fixed,w_750)

以上是最简单的日志配置，如果希望对更多配置项进行自定义的话，可以参考该组件的GitHub文档，上面有具体的配置项说明

现在我们已经成功将项目的日志数据发送到了Graylog服务，如果我们想在Graylog上检索日志也很简单，只需要使用一些简单的语法即可，例如我要查询包含Mapping的日志信息：

![](https://s2.51cto.com/images/blog/201904/19/91cbbe42ae8e5d80592d91edaa949ff1.png?x-oss-process=image/watermark,size_16,text_QDUxQ1RP5Y2a5a6i,color_FFFFFF,t_30,g_se,x_10,y_10,shadow_20,type_ZmFuZ3poZW5naGVpdGk=/format,webp/resize,m_fixed,w_750)

还可以使用一些条件表达式，例如我要查询message字段包含http，并且日志级别为INFO的日志信息：

![](https://s2.51cto.com/images/blog/201904/19/b150f42671aca37a793b88f485b45d53.png?x-oss-process=image/watermark,size_16,text_QDUxQ1RP5Y2a5a6i,color_FFFFFF,t_30,g_se,x_10,y_10,shadow_20,type_ZmFuZ3poZW5naGVpdGk=/format,webp/resize,m_fixed,w_750)

常用的日志搜索语法如下：

- 模糊查询：直接输入要查询的内容，例如：orderid
- 精确查询：要查询的内容加上引号，例如："orderid: 11"
- 指定字段查询： message:http 或 message:"http"
- 多字段查询：message:(base-service base-web)
- 多条件查询：message:http AND level_name:ERROR OR source:192.168.0.4

## 最后说一句（别白嫖，求关注）

陈某每一篇文章都是精心输出，已经写了**3个专栏**，整理成**PDF**，获取方式如下：

1. [《Spring Cloud 进阶》](https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzU3MDAzNDg1MA==&action=getalbum&album_id=2042874937312346114#wechat_redirect)PDF：关注公众号：【**码猿技术专栏**】回复关键词 **Spring Cloud 进阶** 获取！
2. [《Spring Boot 进阶》](https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzU3MDAzNDg1MA==&action=getalbum&album_id=1532834475389288449#wechat_redirect)PDF：关注公众号：【**码猿技术专栏**】回复关键词 **Spring Boot进阶** 获取！
3. [《Mybatis 进阶》](https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzU3MDAzNDg1MA==&action=getalbum&album_id=1500819225232343046#wechat_redirect)PDF：关注公众号：【**码猿技术专栏**】回复关键词 **Mybatis 进阶** 获取！

如果这篇文章对你有所帮助，或者有所启发的话，帮忙**点赞**、**在看**、**转发**、**收藏**，你的支持就是我坚持下去的最大动力！