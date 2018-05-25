---
title: '[自制工具]实现自动推送Hexo博客文章至百度'
date: 2017-11-23 12:50:06
categories:
- Hexo
tags:
- Hexo
- SEO
- Python
---
## 写在前面
　　我们在博客发布文章时，总是希望百度能尽快收录我们的文章，但是如果傻傻等百度爬虫爬到我们这种小站点的文章……不知道要等到何年何月= =基于此，百度站长平台提供了**主动推送文章至百度的接口**。但是这个接口要求我们先把所有文章的URL一行一个写入urls.txt中。然而还是太麻烦了，每次写完文章还得再自己**手动更新urls.txt**。所以，我用python做了一个小工具，可以一键/一条命令**自动推送所有文章至百度**~适合我这种懒人使用2333
<!--more-->
## 工具介绍
### 原理
　　原理其实很简单粗暴——就是写个爬虫爬取你博客里的所有文章URL，然后逐行写入urls.txt，再使用百度站长平台提供的接口完成推送。恩，听上去就是这么简单……然而渣渣如我在制作过程中还是遇到了不少问题，略去不表= =
### 使用前提
- 确保电脑中已安装**python**;
- 确保已安装**pyyaml**模块，安装方法：`pip install pyyaml`
- Ubuntu用户请确保已安装**curl**命令，安装方法：`sudo apt install curl`
- 确保你的博客基于Hexo搭建且主题为**Next | Jacman | Yelee | Apollo**【暂时只测试了这几个主题，后续有需要的话再增加】;
- 有[百度站长平台](http://ziyuan.baidu.com/linksubmit/index)账号且已绑定你的博客站点，方法平台里写的很清楚了;

### 步骤
#### Windows：
- 直接在[我的项目主页](https://github.com/Lemon-XQ/Hexo-BaiduPushTool) **download zip** 或者** git bash**下执行`git clone https://github.com/Lemon-XQ/Hexo-BaiduPushTool.git`
- 打开**_urlconfig.yml**，填入你的**博客地址、使用主题、百度主动推送接口**，保存
- 双击**baidupush.bat**文件，等待推送完成

#### Linux：
- `git clone https://github.com/Lemon-XQ/Hexo-BaiduPushTool.git`
- `cd Hexo-BaiduPushTool`
- `vi _urlconfig.yml` 填写相应信息后保存退出
- `python BaiduPush.py` 等待推送完成

#### 效果预览
![](http://okwl1c157.bkt.clouddn.com/baidupush_linux.png)
#### 注意
填写配置文件时，请注意yaml语法！即**URL:**后需加一个空格！否则会报错
## 最后
　　源码见[github](https://github.com/Lemon-XQ/Hexo-BaiduPushTool)，如果有bug或者是建议麻烦跟我说一下啦~如果觉得还行的话给个star就更好啦（比心）~**最后,github求一波互粉呀（逃**