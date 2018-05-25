---
title: Windows下迁移指定MySQL数据库至Linux
date: 2017-11-14 11:13:50
categories: 
- MySQL
tags:
- Linux
- CentOS7
- MySQL
---
## 写在前面
　　最近有个项目，需要把部署在Windows下的mysql数据库迁移到linux服务器中，且只迁移该项目的数据库。记录一下步骤。

**注：**本步骤基于**cent os 7**，使用的远程ssh工具为**XShell5**,数据库管理工具为**Navicat for MySQL**。迁移之前请确保两台主机已安装配置好MySQL数据库。
<!--more-->

## 使用sql脚本文件迁移
### Windows（迁出数据库主机）
1. 打开Navicat，在项目所在数据库处，**右键->转储SQL文件** 
![](http://okwl1c157.bkt.clouddn.com/sql_transfer1.png)
2. 导出sql文件成功
![](http://okwl1c157.bkt.clouddn.com/sql_transfer2.png)

### Linux（迁入数据库主机）
1. 打开XShell， **ssh**连接Linux主机（CentOS7）
2. 将windows下导出的sql文件上传至Linux主机中，这里以**XShell**提供的**ZMODEM**文件传输工具为例。
	- `yum install lrzsz` 下载远程上传下载工具
	- `cd 指定文件夹`
	- `rz`上传导出的sql文件（若**上传失败**请使用`rz -E`命令）
3.	执行sql脚本文件
	- `mysql -u root -p` 输入密码后进入mysql命令行
	- `create database 项目数据库名;`
	- `use 项目数据库名;`
	- `source 路径/XXX.sql`
	- 执行成功，`show tables;`可以看到已经导入的表


## 使用mysqldump命令迁移
### Windows（迁出数据库主机）
1. 打开cmd，执行mysqldump命令导出dump文件
	- `mysqldump -u root -p test > test.dump` 
	- 回车后输入密码
2. 导出dump文件成功(包括建表及插入语句等)

### Linux（迁入数据库主机）
1. 打开XShell， **ssh**连接Linux主机（CentOS7）
2. 将windows下导出的dump文件上传至Linux主机中，步骤同上
3. 从备份的dump文件恢复数据库
	- `mysql test < test.dump`
