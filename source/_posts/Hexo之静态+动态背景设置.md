---
title: Hexo之静态+动态背景设置
date: 2017-11-20 00:27:39
categories:
- Hexo
tags:
- Hexo
- JavaScript
- CSS
---
## 写在前面
　　实现背景图更换及平铺，以及引入动态背景（可交互）
<!--more-->

## 静态background设置
1. 打开`博客根目录/themes/next/source/css/_custom/custom.styl`文件，编辑如下：
```
// Custom styles.
body { 
	background-image: url(/images/background.png);
	background-attachment: fixed; // 不随屏幕滚动而滚动
	background-repeat: repeat; // 如果背景图不够屏幕大小则重复铺，改为no-repeat则表示不重复铺
	background-size: contain; // 等比例铺满屏幕
}
```
2. 将背景图命名为**background.png**并放入`主题根目录/images`下

## 动态可交互背景（js引入）
1. 打开`博客根目录/themes/next/layout/_layout.swig`文件，在</body>之前添加代码如下：```
{% if theme.canvas_nest %}
<script type="text/javascript"
color="0,0,255" opacity='0.7' zIndex="-2" count="99" src="//cdn.bootcss.com/canvas-nest.js/1.0.0/canvas-nest.min.js"></script>
{% endif %}
```
> **属性说明：**
> - **color** ：线条颜色, 默认: '0,0,0'；三个数字分别为(R,G,B)
> - **opacity**: 线条透明度（0~1）, 默认: 0.5
> - **count**: 线条的总数量, 默认: 150
> - **zIndex**: 背景的z-index属性，css属性用于控制所在层的位置, 默认: -1

2.打开`博客根目录/themes/next/_config.yml`，找到字段**canvas_nest**，将其置为**true**【如果没有找到该字段，请自行添加】
3.hexo clean , hexo d -g可以看到效果~
