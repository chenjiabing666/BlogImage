**大家好，我是不才陈某~**

在前面的文章中介绍过一款数据库变更管理的工具Flyway，有需要了解的请看：[Spring Boot 集成 Flyway，数据库也能做版本控制](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247515703&idx=1&sn=c7fbc34807df6dfade2e554cf4c6fe9e&chksm=fcf761facb80e8ec4858512e301325a1897b7648f0e8822f862f608d066e803074a50b7bd60e&token=216746963&lang=zh_CN#rd)

今天给大家介绍另外一款比较不错的数据库变更管理工具：**Liquibase** 

本文将带着大家实操一个 SpringBoot 结合 Liquibase 的项目，看看如何新增数据表、修改表字段、初始化数据等功能，顺带使用一下 Liquibase 模版生成器插件。

本项目包含两个小项目，一个是 liquibase 模版生成器插件，项目名叫做 liquibase-changelog-generate，另一个项目是 liquibase 应用，叫做 springboot-liquibase。

## Liquibase模版生成器插件

创建一个 maven 项目 liquibase-changelog-generate，本项目具备生成 xml 和 yaml 两种格式的 changelog，个人觉得 yaml 格式的 changelog 可读性更高。

1、导入依赖

```xml
<dependencies>
  <!-- https://mvnrepository.com/artifact/org.apache.maven/maven-plugin-api -->
  <dependency>
    <groupId>org.apache.maven</groupId>
    <artifactId>maven-plugin-api</artifactId>
    <version>3.8.6</version>
  </dependency>
  <dependency>
    <groupId>org.apache.maven.plugin-tools</groupId>
    <artifactId>maven-plugin-annotations</artifactId>
    <version>3.6.4</version>
    <scope>provided</scope>
  </dependency>
  <dependency>
    <groupId>cn.hutool</groupId>
    <artifactId>hutool-all</artifactId>
    <version>5.8.5</version>
  </dependency>

</dependencies>

<build>
  <plugins>
    <plugin>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-plugin-plugin</artifactId>
      <version>3.6.4</version>
      <!-- 插件执行命令前缀 -->
      <configuration>
        <goalPrefix>hresh</goalPrefix>
        <skipErrorNoDescriptorsFound>true</skipErrorNoDescriptorsFound>
      </configuration>
    </plugin>
    <plugin>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-maven-plugin</artifactId>
      <version>2.6.3</version>
    </plugin>
    <!-- 编码和编译和JDK版本 -->
    <plugin>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-compiler-plugin</artifactId>
      <configuration>
        <source>1.8</source>
        <target>1.8</target>
      </configuration>
    </plugin>
  </plugins>
</build>

```

2、定义一个接口，提前准备好公用代码，主要是判断 changelog id 是否有非法字符，并且生成 changelog name。

```java
public interface LiquibaseChangeLog {

  default String getChangeLogFileName(String sourceFolderPath) {
    System.out.println("> Please enter the id of this change:");
    Scanner scanner = new Scanner(System.in);
    String changeId = scanner.nextLine();
    if (StrUtil.isBlank(changeId)) {
      return null;
    }

    String changeIdPattern = "^[a-z][a-z0-9_]*$";
    Pattern pattern = Pattern.compile(changeIdPattern);
    Matcher matcher = pattern.matcher(changeId);
    if (!matcher.find()) {
      System.out.println("Change id should match " + changeIdPattern);
      return null;
    }

    if (isExistedChangeId(changeId, sourceFolderPath)) {
      System.out.println("Duplicate change id :" + changeId);
      return null;
    }

    Date now = new Date();
    String timestamp = DateUtil.format(now, "yyyyMMdd_HHmmss_SSS");
    return timestamp + "__" + changeId;
  }

  default boolean isExistedChangeId(String changeId, String sourceFolderPath) {
    File file = new File(sourceFolderPath);
    File[] files = file.listFiles();
    if (null == files) {
      return false;
    }

    for (File f : files) {
      if (f.isFile()) {
        if (f.getName().contains(changeId)) {
          return true;
        }
      }
    }
    return false;
  }
}

```

3、每个 changelog 文件中的 changeSet 都有一个 author 属性，用来标注是谁创建的 changelog，目前我的做法是执行终端命令来获取 git 的 userName，如果有更好的实现，望不吝赐教。

```java
public class GitUtil {

  public static String getGitUserName() {
    try {
      String cmd = "git config user.name";
      Process p = Runtime.getRuntime().exec(cmd);
      InputStream is = p.getInputStream();
      BufferedReader reader = new BufferedReader(new InputStreamReader(is));
      String line = reader.readLine();
      p.waitFor();
      is.close();
      reader.close();
      p.destroy();
      return line;
    } catch (IOException | InterruptedException e) {
      e.printStackTrace();
    }
    return "hresh";
  }
}

```

4、生成 xml 格式的 changelog

```java
@Mojo(name = "generateModelChangeXml", defaultPhase = LifecyclePhase.PACKAGE)
public class LiquibaseChangeLogXml extends AbstractMojo implements LiquibaseChangeLog {

  // 配置的是本maven插件的配置，在pom使用configration标签进行配置 property就是名字，
  // 在配置里面的标签名字。在调用该插件的时候会看到
  @Parameter(property = "sourceFolderPath")
  private String sourceFolderPath;

  @Override
  public void execute() throws MojoExecutionException, MojoFailureException {
    System.out.println("Create a new empty model changelog in liquibase yaml file.");
    String userName = GitUtil.getGitUserName();

    String changeLogFileName = getChangeLogFileName(sourceFolderPath);
    if (StrUtil.isNotBlank(changeLogFileName)) {
      generateXmlChangeLog(changeLogFileName, userName);
    }
  }

  private void generateXmlChangeLog(String changeLogFileName, String userName) {
    String changeLogFileFullName = changeLogFileName + ".xml";
    File file = new File(sourceFolderPath, changeLogFileFullName);
    String content = "<?xml version=\"1.1\" encoding=\"UTF-8\" standalone=\"no\"?>\n"
        + "<databaseChangeLog xmlns=\"http://www.liquibase.org/xml/ns/dbchangelog\"\n"
        + "  xmlns:ext=\"http://www.liquibase.org/xml/ns/dbchangelog-ext\"\n"
        + "  xmlns:pro=\"http://www.liquibase.org/xml/ns/pro\"\n"
        + "  xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\n"
        + "  xsi:schemaLocation=\"http://www.liquibase.org/xml/ns/dbchangelog-ext http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-ext.xsd http://www.liquibase.org/xml/ns/pro http://www.liquibase.org/xml/ns/pro/liquibase-pro-latest.xsd http://www.liquibase.org/xml/ns/dbchangelog http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-latest.xsd\">\n"
        + "  <changeSet author=\" " + userName + "\" id=\"" + changeLogFileName + "\">\n"
        + "  </changeSet>\n"
        + "</databaseChangeLog>";
    try {
      FileWriter fw = new FileWriter(file.getAbsoluteFile());
      BufferedWriter bw = new BufferedWriter(fw);
      bw.write(content);
      bw.close();
      fw.close();
    } catch (IOException e) {
      e.printStackTrace();
    }
  }

}

```

5、生成 yaml 格式的 changelog

```java
@Mojo(name = "generateModelChangeYaml", defaultPhase = LifecyclePhase.PACKAGE)
public class LiquibaseChangeLogYaml extends AbstractMojo implements LiquibaseChangeLog {

  // 配置的是本maven插件的配置，在pom使用configration标签进行配置 property就是名字，
  // 在配置里面的标签名字。在调用该插件的时候会看到
  @Parameter(property = "sourceFolderPath")
  private String sourceFolderPath;

  @Override
  public void execute() throws MojoExecutionException, MojoFailureException {
    System.out.println("Create a new empty model changelog in liquibase yaml file.");
    String userName = GitUtil.getGitUserName();

    String changeLogFileName = getChangeLogFileName(sourceFolderPath);
    if (StrUtil.isNotBlank(changeLogFileName)) {
      generateYamlChangeLog(changeLogFileName, userName);
    }
  }

  private void generateYamlChangeLog(String changeLogFileName, String userName) {
    String changeLogFileFullName = changeLogFileName + ".yml";
    File file = new File(sourceFolderPath, changeLogFileFullName);
    String content = "databaseChangeLog:\n"
        + "  - changeSet:\n"
        + "      id: " + changeLogFileName + "\n"
        + "      author: " + userName + "\n"
        + "      changes:";
    try {
      FileWriter fw = new FileWriter(file.getAbsoluteFile());
      BufferedWriter bw = new BufferedWriter(fw);
      bw.write(content);
      bw.close();
      fw.close();
    } catch (IOException e) {
      e.printStackTrace();
    }
  }

}

```

6、执行 mvn install 命令，然后会在 maven 的 repository 文件中生成对应的 jar 包。

项目整体结构如下图所示：

![liquibase 模版生成器项目结构](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/125dd8ef34b442668c97c3ef24c97a02~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

因为个人感觉 yaml 文件看起来比较简洁，所以虽然插件提供了两种格式，但后续我选择 yaml 文件。

## Liquibase项目

本项目只是演示如何通过 Liquibase 新增数据表、修改表字段、初始化数据等功能，并不涉及具体的业务功能，所以代码部分会比较少。

1、引入依赖

```xml
<parent>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-parent</artifactId>
  <version>2.6.3</version>
  <relativePath/>
</parent>

<properties>
  <java.version>1.8</java.version>
  <mysql.version>8.0.19</mysql.version>
  <org.projectlombok.version>1.18.20</org.projectlombok.version>
  <druid.version>1.1.18</druid.version>
  <liquibase.version>4.16.1</liquibase.version>
</properties>

<dependencies>
  <!-- 实现对 Spring MVC 的自动化配置 -->
  <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
  </dependency>

  <dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <version>${mysql.version}</version>
    <scope>runtime</scope>
  </dependency>
  <dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>druid-spring-boot-starter</artifactId>
    <version>${druid.version}</version>
  </dependency>
  <dependency>
    <groupId>org.liquibase</groupId>
    <artifactId>liquibase-core</artifactId>
    <version>4.16.1</version>
  </dependency>
  <dependency>
    <groupId>com.baomidou</groupId>
    <artifactId>mybatis-plus-boot-starter</artifactId>
    <version>3.5.1</version>
  </dependency>
  <dependency>
    <groupId>com.baomidou</groupId>
    <artifactId>mybatis-plus</artifactId>
    <version>3.5.1</version>
  </dependency>

</dependencies>

<build>
  <plugins>
    <plugin>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-maven-plugin</artifactId>
    </plugin>
    <plugin>
      <groupId>org.liquibase</groupId>
      <artifactId>liquibase-maven-plugin</artifactId>
      <version>4.16.1</version>
      <configuration>
        <!--properties文件路径，该文件记录了数据库连接信息等-->
        <propertyFile>src/main/resources/application.yml</propertyFile>
        <propertyFileWillOverride>true</propertyFileWillOverride>
      </configuration>
    </plugin>
    <plugin>
      <groupId>com.msdn.hresh</groupId>
      <artifactId>liquibase-changelog-generate</artifactId>
      <version>1.0-SNAPSHOT</version>
      <configuration>
        <sourceFolderPath>src/main/resources/liquibase/changelogs/
        </sourceFolderPath><!-- 当前应用根目录 -->
      </configuration>
    </plugin>
  </plugins>
</build>

```

2、application.yml 配置如下：

```yaml
server:
  port: 8088

spring:
  application:
    name: springboot-liquibase
  datasource:
    type: com.alibaba.druid.pool.DruidDataSource
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://localhost:3306/mysql_db?serverTimezone=Hongkong&characterEncoding=utf-8&useSSL=false
    username: root
    password: root
  liquibase:
    enabled: true
    change-log: classpath:liquibase/master.xml
    # 记录版本日志表
    database-change-log-table: databasechangelog
    # 记录版本改变lock表
    database-change-log-lock-table: databasechangeloglock

mybatis:
  mapper-locations: classpath:mapper/*Mapper.xml
  configuration:
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl
    lazy-loading-enabled: true

changeLogFile: src/main/resources/liquibase/master.xml
#输出文件路径配置
#outputChangeLogFile: src/main/resources/liquibase/out/out.xml

```

3、resources 目录下创建 Liquibase 相关文件，主要是 master.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<databaseChangeLog xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-3.8.xsd">

  <!--  定义公共参数，供数据库中使用-->
  <property name="id" value="int(11)" dbms="mysql"/>
  <property name="time" value="timestamp" dbms="mysql"/>

  <includeAll path="liquibase/changelogs"/>

</databaseChangeLog>

```

还需要创建 liquibase/changelogs 目录。

4、创建一个启动类，准备启动项目

```java
@SpringBootApplication
public class LiquibaseApplication {

  public static void main(String[] args) {
    SpringApplication.run(LiquibaseApplication.class, args);
  }
}

```

接下来我们就进行测试使用 Liquibase 来进行数据库变更控制。

### 创建表

准备通过 Liquibase 来创建数据表，首先点击下面这个命令：

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d4d6c89cb51647e3a6c63cc18eccea55~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

然后在控制台输入 create_table_admin，回车，我们可以看到对应的文件如下：

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7b58f155c500470a97b0289bceb47daf~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

我们填充上述文件，将建表字段加进去。

```yaml
databaseChangeLog:
  - changeSet:
      id: 20221124_161016_997__create_table_admin
      author: hresh
      changes:
        - createTable:
            tableName: admin
            columns:
              - column:
                  name: id
                  type: ${id}
                  autoIncrement: true
                  constraints:
                    primaryKey: true
                    nullable: false
              - column:
                  name: name
                  type: varchar(50)
              - column:
                  name: password
                  type: varchar(100)
              - column:
                  name: create_time
                  type: ${time}

```

关于 Liquibase yaml SQL 格式推荐去[官网](https://link.juejin.cn?target=https%3A%2F%2Fdocs.liquibase.com%2Fconcepts%2Fchangelogs%2Fyaml-format.html)查询。

启动项目后，先来查看控制台输出：

![liquibase执行日志](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/95248bc040ab44dda3a3153b24155399~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

接着去数据库中看 databasechangelog 表记录

![databasechangelog 表记录](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/01164afb6aef4371a7c346bb640665d2~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

以及 admin 表结构

![admin表字段](https://www.hreshhao.com/wp-content/uploads/2022/11/image-20221124163400245.png)

### 新增表字段

使用我们的模版生成器插件，输入 add_column_address_in_admin，回车得到一个模版文件，比如说我们在 admin 表中新增 address 字段。

```yaml
databaseChangeLog:
  - changeSet:
      id: 20221124_163754_923__add_column_address_in_admin
      author: hresh
      changes:
        - addColumn:
            tableName: admin
            columns:
              - column:
                  name: address
                  type: varchar(100)

```

再次重启项目，这里我就不贴控制台输出日志了，直接去数据库中看 admin 表的变化。

![admin表字段](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8682b2e3cda141daaa2b98311e313ac5~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

### 创建索引

输入 create_index_in_admin，回车得到模版文件，然后填充内容：

```yaml
databaseChangeLog:
  - changeSet:
      id: 20221124_164641_992__create_index_in_admin
      author: hresh
      changes:
        - createIndex:
            tableName: admin
            indexName: idx_name
            columns:
              - column:
                  name: name

```

查看 admin 表变化：

![admin表字段](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/598d156aafdc4e2188ebdcee54b13153~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

如果要修改索引，一般都是先删再增，删除索引可以这样写：

```yaml
databaseChangeLog:
  - changeSet:
      id: 20221124_164641_992__create_index_in_admin
      author: hresh
      changes:
        - dropIndex:
            tableName: admin
            indexName: idx_name

```

### 初始化数据

输入 init_data_in_admin ，修改模版文件

```yaml
databaseChangeLog:
  - changeSet:
      id: 20221124_165413_348__init_data_in_admin
      author: hresh
      changes:
        - sql:
            dbms: mysql
            sql: "insert into admin(name,password) values('hresh','1234')"
            stripComments:  true

```

重启项目后，可以发现数据表中多了一条记录。

关于 Liquibase 还有很多操作没介绍，等大家实际应用时再去发掘了，这里就不一一介绍了。

Liquibase 好用是好用，那么有没有可视化的界面呢？答案当然是有的。

## plugin-生成数据库修改文档

双击liquibase plugin面板中的`liquibase:dbDoc`选项，会生成数据库修改文档，默认会生成到`target`目录中，如下图所示

![liquibase文档](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c3f33c1c75e1454caeebeb692b7b1f5f~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

访问`index.html`会展示如下页面，简直应有尽有

![liquibase可视化界面](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9d9c52822ef040ca9c322af5bf293e3c~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

关于 liquibase 的更多有意思的命令使用，可以花时间再去挖掘一下，这里就不过多介绍了。

## 问题

**控制台输出 liquibase.changelog Reading resource 读取了很多没必要的文件**

控制台截图如下所示：

![](https://www.hreshhao.com/wp-content/uploads/2022/11/image-20221124105341305.png)

我们查找一个 AbstractChangeLogHistoryService 文件所在位置，发现它是 liquibase-core 包下的文件，如下所示：

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a0898a7338884965bfa55f22a60861db~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

为什么会这样呢？首先来看下我们关于 liquibase 的配置，如下图所示：

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6441e8b0ab85477a898ef93f1bb3a620~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

其中 master.xml 文件内容如下：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<databaseChangeLog xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-3.8.xsd">

  <property name="id" value="int(11)" dbms="mysql"/>
  <property name="time" value="timestamp" dbms="mysql"/>

  <includeAll path="liquibase/changelog/"/>

</databaseChangeLog>

```

从上面可以看出，resource 目录下关于 liquibase 的文件夹和 liquibase-core 中的一样，难道是因为重名导致读取了那些文件，我们试着修改一下文件夹名称，将 changelog 改为 changelogs，顺便修改 master.xml。

再次重启项目，发现控制台就正常输出了。

简单去看了下 Liquibase 的执行流程，看看读取 changelog 时做了哪些事情，最终定位到 liquibase.integration.spring.SpringResourceAccessor 文件中的 list()方法，源码如下：

```java
public SortedSet<String> list(String relativeTo, String path, boolean recursive, boolean includeFiles, boolean includeDirectories) throws IOException {
  String searchPath = this.getCompletePath(relativeTo, path);
  if (recursive) {
    searchPath = searchPath + "/**";
  } else {
    searchPath = searchPath + "/*";
  }

  searchPath = this.finalizeSearchPath(searchPath);
  Resource[] resources = ResourcePatternUtils.getResourcePatternResolver(this.resourceLoader).getResources(searchPath);
  SortedSet<String> returnSet = new TreeSet();
  Resource[] var9 = resources;
  int var10 = resources.length;

  for(int var11 = 0; var11 < var10; ++var11) {
    Resource resource = var9[var11];
    boolean isFile = this.resourceIsFile(resource);
    if (isFile && includeFiles) {
      returnSet.add(this.getResourcePath(resource));
    }

    if (!isFile && includeDirectories) {
      returnSet.add(this.getResourcePath(resource));
    }
  }

  return returnSet;
}

```

其中 searchPath 变量值为 classpath*:/liquibase/changelog/**，然后通过 ResourcePatternUtils 读取文件时，就把 liquibase-core 包下同路径的文件都扫描出来了。如下图所示：

![](https://www.hreshhao.com/wp-content/uploads/2022/11/image-20221124113407281.png)

所以我们的应对措施暂时定为修改 changelog 目录名为 changelogs。

## 最后说一句（别白嫖，求关注）

陈某每一篇文章都是精心输出，如果这篇文章对你有所帮助，或者有所启发的话，帮忙**点赞**、**在看**、**转发**、**收藏**，你的支持就是我坚持下去的最大动力！

另外陈某的[知识星球](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247523057&idx=1&sn=32b42c6b0ac41b48785b7c0d24ce344a&chksm=fcf7453ccb80cc2a4a6cf38d5b9ab0354f09f270418bf4ff5eeb832b020aedabd561979b712d&token=1260267649&lang=zh_CN#rd)开通了，公众号回复关键词：**知识星球** 获取限量**30元**优惠券加入只需**89**元，一顿饭钱，但是星球回馈的价值却是巨大，目前更新了**Spring全家桶实战系列**、**亿级数据分库分表实战**、**DDD微服务实战专栏**、**我要进大厂、Spring，Mybatis等框架源码、架构实战22讲**等....每增加一个专栏价格将上涨20元

![](https://mmbiz.qpic.cn/mmbiz_png/19cc2hfD2rBvqdy8J18dlib7KepGcvuW08g7COtYpQvVoZzRtQFLgaW1GxibV1vsWMQ27S4wsOlt1ySoh3uEAeIw/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

关注公众号：【码猿技术专栏】，公众号内有超赞的粉丝福利，回复：加群，可以加入技术讨论群，和大家一起讨论技术，吹牛逼！

