**大家好，我是不才陈某~**

在软件项目中做数据库设计用的是 `PowerDesigner` ，因为在之前认知各种产品中，没有任何一个软件工具可以替代它，谁让它的功能太强大。

前几天在论坛上看到一个朋友推荐一款 `PDMan` , 这是一款国内开源的数据库模型建模工具，`PowerDesigner` 中最常用功能在  `PDMan` 均已经实现，但  `PDMan` 的可视化界面很爽朗简洁，上手快，在官网介绍上看到它还提供了 `Windows`、`Mac`、`Linux` 三个平台版本。

这里我将体验向大家分享下。

![官网介绍](https://www.java-family.cn/BlogImage/20230120005433.png)



## 下载

我们直接在官网中[下载 PDMan-win64_x.x.x.exe，选择自己的操作系统对应的版本。

> 官网地址：http://www.pdman.cn

![下载网页](https://www.java-family.cn/BlogImage/20230120005444.png)

安装文件比较简单，这里不多介绍啦。

安装后打开 `PDMan` ，它默认提供一个案例，就是左下角这个 `学生信息管理系统`。

![](https://www.java-family.cn/BlogImage/20230120005455.png)

## 功能菜单

`PDMan` 使用的 `JSON` 文件，这里我连接本地 `MySQL`。

![创建项目1](https://www.java-family.cn/BlogImage/20230120005505.png)



![创建项目2](https://www.java-family.cn/BlogImage/20230120005515.png)



![创建项目3](https://www.java-family.cn/BlogImage/20230120005527.png)



选择一个文件路径，点击右下角 `create`。

## 开始

### 设置

这块主要是全局个性化配置，这里默认有的列是 创建时间 `create_time`、更新时间 `update_time`、删除标记 `delete_flag`、乐观锁 `revision` ，配置后以后每创建一张表都会默认带上以上的字段。

![](https://www.java-family.cn/BlogImage/20230120005547.png)

###  数据库连接

![创建数据库连接](https://www.java-family.cn/BlogImage/20230120005558.png)



![添加](https://www.java-family.cn/BlogImage/20230120005608.png)



选择需要连接的数据库类型

![db type](https://www.java-family.cn/BlogImage/20230120005619.png)



选择本地的一个数据库驱动，填写数据库地址、数据库端口、数据库名以及密码

![](https://www.java-family.cn/BlogImage/20230120005631.png)



点击 `测试`

![测试](https://www.java-family.cn/BlogImage/20230120005655.png)

确定提交后，这个连接就创建好

## 模型

### 数据库逆向解析

点击下一步生成。

![](https://www.java-family.cn/BlogImage/20230120005709.png)



![](https://www.java-family.cn/BlogImage/20230120005720.png)



勾选需要逆向的表。

![](https://www.java-family.cn/BlogImage/20230120005729.png)



在数据表中我们可以看到逆向解析的表结构，坐标的这些表可以往右侧的网格处拖拽。

![](https://www.java-family.cn/BlogImage/20230120005740.png)

### 导出文档

文档可以导出 `HTML`、 `WORD`、`MARKDOWN` 三种格式，文档内容包括各个表的字段属性，数据表间的关系图。

![](https://www.java-family.cn/BlogImage/20230120010005.png)



我用 `HTML` 导出做演示。

![](https://www.java-family.cn/BlogImage/20230120010015.png)

### 导出DDL脚本

![](https://www.java-family.cn/BlogImage/20230120010027.png)

### 导出JSON

![](https://www.java-family.cn/BlogImage/20230120010037.png)

## 模型版本

![](https://www.java-family.cn/BlogImage/20230120010047.png)



这个功能和 `Git` 相似，每次所修改的版本，以及对任意版本间的修改进行比对。