**大家好，我是不才陈某~**

说起虚拟机工具大家最熟悉的自然是 VMware，功能很多很强大，最让我认可的地方就是可以非常方便的修改虚拟机的配置，让虚拟机达到自己想要的性能～～

可是 VMware 好用是真的好用，但就是要付费呀！还不便宜，每次续费的时候我多多少少都有点心疼～～

## Multipass

最近有读者给我推荐了一款虚拟机工具：Multipass，非常轻量级的虚拟机命令管理工具。运行环境支持 Linux、Windows 和 macOS。

![](https://mmbiz.qpic.cn/mmbiz_png/Z4N0CzO8W9A1E1mm1jkXbaYsZwLDu2WibAmiavK2Rsdxgy3amicXl3FgSoFCF3nQbY2HHoWiaXDw6w3icDibmwhibj9ng/640?wx_fmt=png)

## 开始使用

首先我们需要在官网下载并且安装 Multipass ，选择自己对应的操作系统，我选择的是 Windows 。

![](https://www.java-family.cn/BlogImage/20230102141514.png)

安装之后，查看自己安装的版本

```shell
$ multipass version
```

## 创建Ubuntu虚拟机

首先查看可以下载使用的 Ubuntu 镜像，

```shell
$ multipass find
```

运行成功后，可以看到下面的这些镜像列表，包含各种版本的。

```shell
牛逼啊！接私活必备的 N 个开源项目！赶快收藏
Image                       Aliases           Version          Description                                              
snapcraft:core18                              20201111         Snapcraft builder for Core 18                            
snapcraft:core20                              20201111         Snapcraft builder for Core 20                            
core                        core16            20200818         Ubuntu Core 16                                           
core18                                        20200812         Ubuntu Core 18                                           
16.04                       xenial            20210128         Ubuntu 16.04 LTS                                         
18.04                       bionic            20210129         Ubuntu 18.04 LTS                                         
20.04                       focal,lts         20210223         Ubuntu 20.04 LTS                                         
20.10                       groovy            20210209         Ubuntu 20.10                                             
appliance:adguard-home                        20200812         Ubuntu AdGuard Home Appliance                            
appliance:mosquitto                           20200812         Ubuntu Mosquitto Appliance                               
appliance:nextcloud                           20200812         Ubuntu Nextcloud Appliance                               
appliance:openhab                             20200812         Ubuntu openHAB Home Appliance                            
appliance:plexmediaserver                     20200812         Ubuntu Plex Media Server Appliance
```

新建一个容器，

```shell
$ multipass launch --name dg
Launched: dg
```

然后下载最新版的 Ubuntu 镜像，之后我们就可以直接使用了。

```shell
$ multipass exec dg -- lsb_release -d
Description:    Ubuntu 18.04.4 LTS
```

## 操作虚拟机

**查看虚拟机列表**

虚拟机创建完成后，查看虚拟机列表。

```shell
Name                 State             IPv4             Image
dg                   Running           192.168.24.5     Ubuntu 18.04 LTS
```

现在有一台 Ubuntu 18.04 版本的虚拟机在运行，对应的 IP 地址是：192.168.24.5 。

**查看虚拟机信息**

通过命令你可以查看当前运行的虚拟机具体信息。

```shell
$ multipass info --all

Name:           dg
State:          Running
IPv4:           192.168.24.5
Release:        Ubuntu 18.04.4 LTS
Image hash:     fe3030933742 (Ubuntu 18.04 LTS)
Load:           0.00 0.00 0.00
Disk usage:     1.5G out of 4.7G
Memory usage:   112.1M out of 985.7M
```

**进入虚拟机**

使用下面的命令查看虚拟机的系统配置信息、内存、磁盘等的使用情况。

```shell
$ multipass shell dg
```

如果你不想进入系统内部，也可以通过上述提到的 multipass exce 命令，来操作 Ubuntu 系统。另外，搜索公众号Linux就该这样学后台回复“猴子”，获取一份惊喜礼包。

**暂停/重启虚拟机**

```shell
# 暂停
$ multipass stop dg
# 启动
$ multipass start dg
```

**删除/释放虚拟机**

使用 delete 命令 删除虚拟机之后，该虚拟机实际上还是存在了，想要彻底删除则需要释放虚拟机。

```shell
# 删除
$ multipass delete dg
# 释放
$ multipass purge dg
```

**配置自动化**

既要保持开发环境和线上环境一致，又要节省部署时间。我们可以使用 --cloud-init 对容器进行初始化配置:

```shell
$ multipass launch --name ubuntu --cloud-init config.yaml
```

config.yaml 是初始化配置文件，内容如下：

```shell
#cloud-config

runcmd:
 - curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
 - sudo apt-get install -y nodejs  
 - wget https://releases.leanapp.cn/leancloud/lean-cli/releases/download/v0.21.0/lean-cli-x64.deb  
 - sudo dpkg -i lean-cli-x64.deb
```

runcmd 可以指定容器首次启动时运行的命令

## 总结

经过一段时间的使用，我认为这款工具确实是不错的！比如说我要搞点 linux 的小试验，通过 Multipass 几分钟就能搭起系统来测试。要测试小型数据库集群，也可以通过 Multipass 在本地快速搭建虚拟机集群，很不错！

唯一美中不足的是 Multipass 只能使用 Ubuntu 镜像，因为这款工具是由 Ubuntu 背后的 Canonical 公司开发开源的。