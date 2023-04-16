**大家好，我是不才陈某~**

目前nacos越来越广泛，大多数的企业在使用微服务架构的时候，基本上都会选择nacos作为注册中心和配置中心。

那nacos其实也是阿里开源的一个项目，存在漏洞，至少难免的。

那我们今天就来分享一下nacos存在的漏洞问题，主要是一些安全漏洞的问题。

毕竟现在很多政务的项目，都会做等保测试这块。等保做得多了，漏洞也就多了。

这不，今天就又有一个漏洞了。那就开始修复喽！！！

![](https://www.java-family.cn/BlogImage/20221113202033.png)



## 1.nacos权限绕过漏洞

详情可查看nacos官网：https%3A%2F%2Fnacos.io%2Fzh-cn%2Fdocs%2Fauth.html

![](https://www.java-family.cn/BlogImage/20221113202037.png)

这个漏洞是在nacos已经开启账号密码访问的时候，当header添加了user-agent：Nacos-Server时，就会绕过权限访问，直接获取到nacos配置等信息。

nacos版本：`1.4.2`

详情如下：

**不加账号密码访问（403）**

![](https://www.java-family.cn/BlogImage/20221113202042.png)

**添加账号密码访问（正常）**

![](https://www.java-family.cn/BlogImage/20221113202046.png)

**不加账号密码访问，但添加header（正常）**

![](https://www.java-family.cn/BlogImage/20221113202050.png)

![](https://www.java-family.cn/BlogImage/20221113202218.png)

> 由此可见，header加上`user-agent:Nacos-Server`，确实能绕过nacos认证。

## 2.漏洞修复

升级到nacos目前最新版：`2.1.1`

下载地址：https%3A%2F%2Fnacos.io%2Fzh-cn%2Fdocs%2Fquick-start.html

![](https://www.java-family.cn/BlogImage/20221113202111.png)

![](https://www.java-family.cn/BlogImage/20221113202115.png)

下载地址：https%3A%2F%2Fgithub.com%2Falibaba%2Fnacos%2Freleases%2Fdownload%2F2.1.1%2Fnacos-server-2.1.1.zip

从`1.4.2`升级到`2.1.1`，nacos官网有详细的文档说明：https%3A%2F%2Fnacos.io%2Fzh-cn%2Fdocs%2F2.0.0-upgrading.html

对于我们现在的环境升级，这里记录下注意的事项：

### 2.1 nacos配置文件的修改

vi nacos/conf/application.properties

```properties
#122行
server.tomcat.basedir=file:.

#148行
nacos.core.auth.enable.userAgentAuthWhite=false
nacos.core.auth.server.identity.key=serverIdentity
nacos.core.auth.server.identity.value=security
```

> 这里要修改成这个，否则启动报错。

### 2.2 nacos数据库修改

```sql
/*config_info表增加字段*/
ALTER TABLE jxbp_nacos.config_info ADD COLUMN encrypted_data_key text NULL COMMENT '秘钥';

/*his_config_info表增加字段*/
ALTER TABLE jxbp_nacos.his_config_info ADD COLUMN encrypted_data_key text NULL COMMENT '秘钥';
```

### 2.3 nacos启动后测试

**不加账号密码访问，但添加header（403）**

![](https://www.java-family.cn/BlogImage/20221113202120.png)

![](https://www.java-family.cn/BlogImage/20221113202125.png)

> 由此可见，该漏洞已被修复

**加账号密码访问，不添加header（正常）**

![](https://www.java-family.cn/BlogImage/20221113202131.png)

> 经测试，正常了。

**注意：**

当然**不想升级的话**，也是可以的，直接在`1.4.2`的基础上对配置文件进行修改：

`vi nacos/conf/application.properties`

```properties
#148行
nacos.core.auth.enable.userAgentAuthWhite=false
nacos.core.auth.server.identity.key=serverIdentity
nacos.core.auth.server.identity.value=security
```

------

看到这里，是不是觉得自己折腾了大半天，最终解决的方式，还有更简单的方法。

## 最后说一句（别白嫖，求关注）

陈某每一篇文章都是精心输出，如果这篇文章对你有所帮助，或者有所启发的话，帮忙**点赞**、**在看**、**转发**、**收藏**，你的支持就是我坚持下去的最大动力！
