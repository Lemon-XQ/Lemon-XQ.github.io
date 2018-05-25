---
title: Cent OS下网络配置的详细步骤及一些坑
date: 2017-03-04 20:16:03
categories: 
- Linux
tags:
- Linux
- Cent-OS
- Virtual Box
- eth0
- 网络
---
## 写在前面
　　本步骤基于**cent os 6.5**，使用的虚拟机是**Virtual Box**。最终可实现主机与虚拟机互ping通，虚拟机与外网互ping通。当然，如果是cent os 7.0以上或者虚拟机是VM ware的，可能会有些差异。
<!--more-->
## 虚拟机网络配置
1. 打开主机“网络连接”，可以看到有一块虚拟网卡（VirtualBox Host-Only Network）,双击查看**详细信息**
![](http://okwl1c157.bkt.clouddn.com/virtualbox%20hostonly%20network.png)
![](http://okwl1c157.bkt.clouddn.com/detail.png)
**PS: 虚拟网卡不一定只有一块，具体可在虚拟机全局设定中进行设置，这里我选择了第二块虚拟网卡作为cent os的物理网卡。**

2. 记下详细信息中**网卡的IP地址**（**192.168.137.1**）
3. 在**“网络连接”**中右键选择你当前上网所用的网卡（这里我用的是无线网卡），打开属性，在**“共享”**一栏选择刚才的那块虚拟网卡。
![](http://okwl1c157.bkt.clouddn.com/share.png)
**PS：这一步非常重要！！！目的是建立虚拟网卡与主机物理网卡的联系，从而达到共享网络的效果（个人理解类似于桥接）**

4. 打开VirtualBox的**全局设定**，进行如下设置：
![](http://okwl1c157.bkt.clouddn.com/setting-1.png)
![](http://okwl1c157.bkt.clouddn.com/setting-2.png)
5. 打开cent os虚拟机的设置，进行如下配置：
![](http://okwl1c157.bkt.clouddn.com/network.png)
**PS：这里我使用的是Host-Only，实际上使用桥接也可以，使用桥接的话直接桥接到主机物理网卡，无须设置共享**
## Cent OS中网络配置
1. 配置**ip地址**</br>使用命令 **vi /etc/sysconfig/network-scripts/ifcfg-eth0** 修改文件内容如下：
![](http://okwl1c157.bkt.clouddn.com/eth0setting.png)
2. 配置**网关**</br>使用命令 **vi /etc/sysconfig/network** 修改文件内容如下：
![](http://okwl1c157.bkt.clouddn.com/gateway.png)
3. 配置**DNS服务**</br>使用命令 **vi /etc/resolv.conf** 修改文件内容如下：
![](http://okwl1c157.bkt.clouddn.com/dns.png)
4. 重启网络服务（**service network restart**）


## 一些注意事项

1. 以上步骤理论上可实现虚拟机与主机、虚拟机与外网互ping通，如果只有虚拟机ping不通主机，那么应该是主机的**防火墙**没有关闭，主机ping不通虚拟机也可能是这个原因。
2. 如果更换网络或者对该虚拟机进行了迁移导致执行ifconfig命令后**找不到eth0网卡**，则只需执行以下几步：
	- 执行 **ifconfig -a** 命令查看虚拟机网卡（一般是**eth1**）地址(即**HWaddr**)
	- 执行 **vi /etc/sysconfig/network-scripts/ifcfg-eth0** 修改**HWaddr**值为虚拟机网卡地址
	- 执行 **rm －rf /etc/udev/rules.d/70-persistent-net.rules** 删除70-persistent-net.rules文件
	- 重启系统 **reboot -h now**

