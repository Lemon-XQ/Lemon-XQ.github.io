---
title: Hexo之使用CodingPages实现全站Https
date: 2017-11-20 00:26:04
categories:
- Hexo
tags:
- Hexo
- Https
- SSL
- Coding
---

<blockquote class="blockquote-center">拒绝让自己的网站成为不安全的网站：）</blockquote>
## 写在前面
　　之前博客单线部署在Github Pages的时候，用的是cloudflare提供的SSL证书。但是cloudflare只能绑定一个CNAME记录（而且好像只能绑github.io？），所以后面双线部署（GitHub Pages+Coding Pages）后，cloudflare就不能用了。不过好在Coding Pages提供了通过Let's Encrypt申请SSL证书进而开启全站HTTPs的方法。下面记录一下步骤~
<!--more-->

## 步骤
1. 首先确保你的博客已经部署在Coding Pages上并且已经添加CNAME记录，不懂的先参照[我的另一篇博客中关于域名绑定的部分](https://lemonxq.cn/2017/03/24/Hexo%E9%9D%99%E6%80%81%E5%8D%9A%E5%AE%A2%E6%90%AD%E5%BB%BA+%E4%B8%AA%E4%BA%BA%E5%AE%9A%E5%88%B6/) 
2. 申请SSL证书
**【注意：如果是Github+Coding双线部署，申请SSL证书前需要先将解析到github.io的CNAME记录暂停！！！不然Let's Encrypt主机在验证域名所有权时会定位到Github Pages的主机上导致SSL证书申请失败】**
![](http://okwl1c157.bkt.clouddn.com/ssl.png)
3. 等待10分钟左右申请成功
4. 强制开启Https
![](http://okwl1c157.bkt.clouddn.com/https.png)

## 后续
开启强制HTTPS访问后，网站内引用资源的URL必须以https:// 开头，避免引用资源加载失败。例如Css文件、JavaScript文件、Image文件。