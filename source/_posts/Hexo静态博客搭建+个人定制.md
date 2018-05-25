---
title: Hexo静态博客搭建+个人定制
date: 2017-03-24 23:34:45
tags: 
	  - Hexo
	  - 博客
	  - SEO 

categories: 
	  - Hexo
	 
---
<blockquote class="blockquote-center">打造高逼格的个人博客</blockquote>
## 写在前面
　　很早以前就想写这样一篇了，因为各种原因耽搁到现在（逃）...网上关于Hexo的教程其实已经有挺多了，但是很多都是一笔带过。这篇博客除了**Hexo**博客的搭建过程，还有一些我加进去的**个人定制**模块，以及**博客如何被搜索引擎（百度、谷歌）收录、如何进行SEO优化**等等，以及在这过程中遇到的数不胜数的坑。虽然时隔一个月，有些搭建过程遇到的问题记不太清了orz...但是有什么问题还是可以问我的，我尽量解答=3=最后！！！【**超长文预警**】！！！建议可以先看目录选择感兴趣的部分orz
<!--more-->
## Hexo简介
　　相信点进来看的都是对 Hexo 已经有了一定了解的吧~简而言之，Hexo 是一个基于 Node.js 的静态博客程序，可以方便的生成静态网页托管在github和Heroku上。其作者是来自台湾的[tommy351](https://github.com/hexojs/hexo)大神。Hexo 因其界面简洁、美观且对各类人群（不只是程序猿）友好而广受欢迎，声望不亚于大名鼎鼎的WordPress。这也是我放弃 WordPress 改投 Hexo 的原因=。=放一张 Hexo NexT 主题的照片（是不是很好看hhh）
![](http://okwl1c157.bkt.clouddn.com/next.png)
## 基础配置篇
【注：本文中使用的 Hexo 版本为**3.22**，部分配置与**2.x**可能有所出入】
### 1.安装 & 搭建
- 安装[Git](http://git-scm.com)：安装后，注册 Github 账号，配置 SSH（具体见下一步）,打开 Git Bash,**接下来的命令均在Git Bash中执行**
- 安装[Node.js](https://nodejs.org/en/)
- 安装 Hexo : `$npm install -g hexo`
- 安装依赖包： `$npm install`
- 新建博客文件夹：cd到该文件夹，执行`$hexo init`
- 新建Github仓库：仓库名**必须**为`你的Github名.github.io`，要不然就不能使用Github Pages服务了。。。

### 2.配置 SSH
　　关于什么是 SSH，请自行百度（我懒..）这里直接讲一下配置步骤。  

- 本地生成公钥私钥
　`$ssh-keygen -t rsa -C "你的邮件地址"`
- 添加公钥到 Github
	- 根据上一步的提示，找到公钥文件（默认为id_rsa.pub），用记事本打开，全选并复制。
	- 登录 Github，右上角 头像 -> Settings —> SSH keys —> Add SSH key。把公钥粘贴到key中，填好title并点击 Add key。
	- git bash中输入命令`$ssh -T git@github.com`，选yes，等待片刻可看到成功提示。

### 3. NexT主题下载
　　 NexT 主题是由 [iissnan](https://github.com/iissnan) 大神所制作的一款简洁美观不失逼格的主题。下载方法有以下两种：  
- 进入`博客根目录/themes/`, 执行`$git clone https://github.com/iissnan/hexo-theme-next.git`
- 直接进入上面的链接，在项目主页download zip文件，然后解压到`博客根目录/themes/` 文件夹

### 4. 发布
　　使用以下两条命令进行发布，发布成功后可在浏览器中使用`你的github名.github.io`进入你的博客~
```
$hexo clean
$hexo d -g
```

## Hexo日常使用篇
### 1.生成静态页面：
```
$hexo generate
```
### 2.本地预览： 
```
$hexo server//或 hexo s
//然后打开浏览器输入localhost:4000可以预览博客效果，用于调试
```
### 3. 新建文章
```
$hexo new post "title"
//新文章位置：/source/_posts
```
### 4. 新建页面
```
$hexo new page "title"
```
### 5. 部署并生成
```
$hexo d -g
```
### 6. 清除生成的文件和缓存
```
$hexo clean
```
## _config文件配置篇
### 1.整站配置  
直接贴一下我的配置文件吧【路径：**博客根目录/_config.yml**】  

【**友情提示：**不要用系统自带记事本打开，容易出现编码不一致问题，最好用 **Notepad++** 或 **Sublime Text** 之类的】   

{% codeblock lang:yaml %}
# Hexo Configuration
## Docs: https://hexo.io/docs/configuration.html
## Source: https://github.com/hexojs/hexo/

# Site
title: Lemon-XQ # 博客名
subtitle: Stay Hungry, Stay Foolish # 副标题
description: 银河街角，时光路口 # 站点描述
author: Lemon-XQ # 作者名
language: zh-Hans # 语言设置
timezone: Asia/Shanghai

# URL
## If your site is put in a subdirectory, set url as 'http://yoursite.com/child' and root as '/child/'
url: http://lemonxq.cn # 博客所要绑定的域名，没有则不填
root: /
permalink: :year/:month/:day/:title/
permalink_defaults:

# Directory
source_dir: source
public_dir: public
tag_dir: tags
archive_dir: archives
category_dir: categories
code_dir: downloads/code
i18n_dir: :lang
skip_render:

# Writing
new_post_name: :title.md # File name of new posts
default_layout: post
titlecase: false # Transform title into titlecase
external_link: true # Open external links in new tab
filename_case: 0
render_drafts: false
post_asset_folder: false
relative_link: false
future: true
highlight: # Hexo自带代码高亮插件
  enable: true
  line_number: true
  auto_detect: false
  tab_replace:

# Category & Tag
default_category: uncategorized
category_map:
tag_map:

# Date / Time format
## Hexo uses Moment.js to parse and display date
## You can customize the date format as defined in
## http://momentjs.com/docs/#/displaying/format/
date_format: YYYY-MM-DD
time_format: HH:mm:ss

# Pagination
## Set per_page to 0 to disable pagination
per_page: 10 # 每页显示文章数
pagination_dir: page

# Extensions # 以下为第三方插件设置
## Plugins: https://hexo.io/plugins/
## Themes: https://hexo.io/themes/
theme: next # 使用的主题，主题配置后面讲

search: # 本地搜索插件
  path: search.xml
  field: post
  format: html
  limit: 10000

feed: # RSS订阅插件
  type: atom
  path: atom.xml
  limit: 0

plugins:
baidusitemap: # 百度站点地图
  path: baidusitemap.xml

# Deployment # 非常重要的部署设置
## Docs: https://hexo.io/docs/deployment.html
deploy:
  type: git
  repository: # 可选择同时部署到 GitHub 和 coding 或者只部署到 Github
    github: git@github.com:你的GitHub名/你的GitHub名.github.io.git
    coding: git@git.coding.net:你的Coding名/你的Coding名.git
  branch: master 

{% endcodeblock %}


### 2.Next主题配置  
一样贴一下我的主题config文件吧，注意和上面的全局config文件区分。  
【路径：博客根目录/themes/next/_config.yml】

{% codeblock lang:yaml %}

# ---------------------------------------------------------------
# Site Information Settings
# ---------------------------------------------------------------

# Put your favicon.ico into `hexo-site/source/` directory.
favicon: /favicon.ico # 网站logo

# Set default keywords (Use a comma to separate)
keywords: "Lemon,xq,unity,Hexo" # 网站关键词，有利于SEO优化

# Set rss to false to disable feed link.
# Leave rss as empty to use site's feed link.
# Set rss to specific value if you have burned your feed already.
rss: /atom.xml

# Specify the date when the site was setup
since: 2017 # 建站年份

# icon between year and author @Footer
authoricon: heart

# Footer `powered-by` and `theme-info` copyright
copyright: true

# Canonical, set a canonical link tag in your hexo, you could use it for your SEO of blog.
# See: https://support.google.com/webmasters/answer/139066
# Tips: Before you open this tag, remeber set up your URL in hexo _config.yml ( ex. url: http://yourdomain.com )
canonical: true

# Change headers hierarchy on site-subtitle (will be main site description) and on all post/pages titles for better SEO-optimization.
seo: false

# ---------------------------------------------------------------
# Menu Settings
# ---------------------------------------------------------------

# When running the site in a subdirectory (e.g. domain.tld/blog), remove the leading slash (/archives -> archives)
menu: # 菜单栏设置
  home: /
  categories: /categories
  about: /about
  archives: /archives
  tags: /tags
  #sitemap: /sitemap.xml
  #commonweal: /404.html


# Enable/Disable menu icons.
# Icon Mapping:
#   Map a menu item to a specific FontAwesome icon name.
#   Key is the name of menu item and value is the name of FontAwsome icon. Key is case-senstive.
#   When an question mask icon presenting up means that the item has no mapping icon.
menu_icons: # 菜单项图标
  enable: true
  #KeyMapsToMenuItemKey: NameOfTheIconFromFontAwesome
  home: home
  about: user
  categories: th
  schedule: calendar
  tags: tags
  archives: archive
  sitemap: sitemap
  commonweal: heartbeat


# ---------------------------------------------------------------
# Scheme Settings
# ---------------------------------------------------------------

# Schemes # NexT 主题提供三种布局
#scheme: Muse
#scheme: Mist
scheme: Pisces


# ---------------------------------------------------------------
# Font Settings
# - Find fonts on Google Fonts (https://www.google.com/fonts)
# - All fonts set here will have the following styles:
#     light, light italic, normal, normal intalic, bold, bold italic
# - Be aware that setting too much fonts will cause site running slowly
# - Introduce in 5.0.1
# ---------------------------------------------------------------
font:
  enable: true

  # Uri of fonts host. E.g. //fonts.googleapis.com (Default)
  host:

  # Global font settings used on <body> element.
  global:
    # external: true will load this font family from host.
    external: true
    family: Lato

  # Font settings for Headlines (h1, h2, h3, h4, h5, h6)
  # Fallback to `global` font settings.
  headings:
    external: true
    family:

  # Font settings for posts
  # Fallback to `global` font settings.
  posts:
    external: true
    family:

  # Font settings for Logo
  # Fallback to `global` font settings.
  # The `size` option use `px` as unit
  logo:
    external: true
    family:
    size:

  # Font settings for <code> and code blocks.
  codes:
    external: true
    family:
    size:


# ---------------------------------------------------------------
# Sidebar Settings
# ---------------------------------------------------------------

#friend links
links_title: 友情链接

links:
  # 添加你的友情链接（eg. 慕课网: imooc.com）

# Social Links
# Key is the link label showing to end users.
# Value is the target link (E.g. GitHub: https://github.com/iissnan)
social: # 添加你的社交账号
  GitHub: https://github.com/Lemon-XQ


# Social Links Icons
# Icon Mapping:
#   Map a menu item to a specific FontAwesome icon name.
#   Key is the name of the item and value is the name of FontAwsome icon. Key is case-senstive.
#   When an globe mask icon presenting up means that the item has no mapping icon.
social_icons: 
  enable: true
  # Icon Mappings.
  # KeyMapsToSocalItemKey: NameOfTheIconFromFontAwesome
  GitHub: github
  Twitter: twitter
  Weibo: weibo


# Sidebar Avatar
# in theme directory(source/images): /images/avatar.jpg
# in site  directory(source/uploads): /uploads/avatar.jpg
avatar: /images/avatar.jpg # 自定义头像

# 是否为侧边栏文章的目录自动添加索引
# Table Of Contents in the Sidebar
toc:
  enable: true

  # Automatically add list number to toc.
  number: true


# Creative Commons 4.0 International License.
# http://creativecommons.org/
# Available: by | by-nc | by-nc-nd | by-nc-sa | by-nd | by-sa | zero
#creative_commons: by-nc-sa
#creative_commons:


sidebar: # 这个改了好像没什么用。。。
  # Sidebar Position, available value: left | right
  position: left
  #position: right

  # Sidebar Display, available value:
  #  - post    expand on posts automatically. Default.
  #  - always  expand for all pages automatically
  #  - hide    expand only when click on the sidebar toggle icon.
  #  - remove  Totally remove sidebar including sidebar toggler.
  display: post
  #display: always
  #display: hide
  #display: remove


# Blogrolls 
#links_title: Links
#links_layout: block
#links_layout: inline
#links:
  #Title: http://example.com/


# ---------------------------------------------------------------
# Post Settings
# ---------------------------------------------------------------

# Automatically scroll page to section which is under <!-- more --> mark.
# 开启后使用 <!-more--> 可以实现点击查看全文效果
scroll_to_more: true

# Automatically excerpt description in homepage as preamble text.
excerpt_description: true

# Automatically Excerpt. Not recommand.
# Please use <!-- more --> in the post to control excerpt accurately.
auto_excerpt:
  enable: true
  length: 150

# Post meta display settings
post_meta:
  item_text: true
  created_at: true
  updated_at: false
  categories: true

#开启微信赞赏
# Wechat Subscriber
wechat_subscriber:
  enabled: true
  qcode: http://okwl1c157.bkt.clouddn.com/wechat-qcode.jpg
  description: 坚持原创技术分享，您的支持将鼓励我继续创作！



# ---------------------------------------------------------------
# Misc Theme Settings # Misc布局设置
# ---------------------------------------------------------------

# Custom Logo.
# !!Only available for Default Scheme currently.
# Options:
#   enabled: [true/false] - Replace with specific image
#   image: url-of-image   - Images's url
custom_logo:
  enabled: false
  image: 


# Code Highlight theme
# Available value:
#    normal | night | night eighties | night blue | night bright
# https://github.com/chriskempson/tomorrow-theme
# 设置代码高亮主题
highlight_theme: night bright


# ---------------------------------------------------------------
# Third Party Services Settings
# ---------------------------------------------------------------

# MathJax Support
mathjax:
  enable: false
  per_page: false
  cdn: //cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML

# 自从Swiftype要收费后。。。你懂的
# Swiftype Search API Key
#swiftype_key:

# Baidu Analytics ID
#baidu_analytics:

# 多说 你的昵称
# Duoshuo ShortName
duoshuo_shortname: lemonxq

# Disqus
#disqus_shortname:

# Hypercomments
#hypercomments_id:

# Gentie productKey
#gentie_productKey:

# Support for youyan comments system.
# You can get your uid from http://www.uyan.cc
#youyan_uid: your uid

# Baidu Share
# Available value:
#    button | slide
# Warning: Baidu Share does not support https.
#baidushare:
##  type: button

# Share
#jiathis:
# Warning: JiaThis does not support https.
#add_this_id:

# Share
duoshuo_share: true

# Google Webmaster tools verification setting
# See: https://www.google.com/webmasters/
#google_site_verification:


# Google Analytics
#google_analytics:

# CNZZ count
cnzz_siteid: # CNZZ站长统计功能，开启服务后将siteid添加在此处

# Application Insights
# See https://azure.microsoft.com/en-us/services/application-insights/
# application_insights:

# Make duoshuo show UA
# user_id must NOT be null when admin_enable is true!
# you can visit http://dev.duoshuo.com get duoshuo user id.
# 多说评论功能
duoshuo_info:
  ua_enable: true 
  admin_enable: true
  user_id: # 管理员ID
  admin_nickname: 博主

duoshuo_hotartical: true # 多说 热评文章

# Facebook SDK Support.
# https://github.com/iissnan/hexo-theme-next/pull/410
facebook_sdk:
  enable: false
  app_id:       #<app_id>
  fb_admin:     #<user_id>
  like_button:  #true
  webmaster:    #true

# Facebook comments plugin
# This plugin depends on Facebook SDK.
# If facebook_sdk.enable is false, Facebook comments plugin is unavailable.
facebook_comments_plugin:
  enable: false
  num_of_posts: 10  # min posts num is 1
  width: 100%       # default width is 550px
  scheme: light     # default scheme is light (light or dark)


# Show number of visitors to each article.
# You can visit https://leancloud.cn get AppID and AppKey.
# 启动页面浏览量功能
leancloud_visitors:
  enable: true
  app_id: # leancloud 控制台后台获取
  app_key: # leancloud 控制台后台获取

# Show PV/UV of the website/page with busuanzi.
# Get more information on http://ibruce.info/2015/04/04/busuanzi/
# 不蒜子统计功能
busuanzi_count:
  # count values only if the other configs are false
  enable: true
  # custom uv span for the whole site
  site_uv: false
  site_uv_header: <i class="fa fa-user"></i>
  site_uv_footer:
  # custom pv span for the whole site
  site_pv: false
  site_pv_header: <i class="fa fa-eye"></i>
  site_pv_footer:
  # custom pv span for one page only
  page_pv: false
  page_pv_header: <i class="fa fa-file-o"></i>
  page_pv_footer:


# Tencent analytics ID
# tencent_analytics:


# Enable baidu push so that the blog will push the url to baidu automatically which is very helpful for SEO
# 百度推送
baidu_push: true

# Google Calendar
# Share your recent schedule to others via calendar page
#
# API Documentation:
# https://developers.google.com/google-apps/calendar/v3/reference/events/list
calendar:
  enable: false
  calendar_id: <required>
  api_key: <required>
  orderBy: startTime
  offsetMax: 24
  offsetMin: 4
  timeZone:
  showDeleted: false
  singleEvents: true
  maxResults: 250

# Algolia Search
algolia_search:
  enable: false
  hits:
    per_page: 10
  labels:
    input_placeholder: Search for Posts
    hits_empty: "We didn't find any results for the search: ${query}"
    hits_stats: "${hits} results found in ${time} ms"

{% endcodeblock %}


## 个人定制模块
### 更改代码块颜色及字体大小
1. 打开`\themes\next\source\css\ _variables\base.styl`文件
2. 修改`$code-background`和`$code-foreground`的值：
{% codeblock lang:yaml %}
// Code & Code Blocks
// 用``围出的代码块
// --------------------------------------------------
$code-font-family               = $font-family-monospace
$code-font-size                 = 15px # 代码字体大小
$code-background                = #自定义RGB值
$code-foreground                = #自定义RGB值
$code-border-radius             = 4px
{% endcodeblock %}

### 实现底栏半透明
1. 打开
`博客根目录/themes/next/source/css/_common/components/footer/footer,styl`文件
2. 在最开始的.footer中修改color值为#999
{% codeblock lang:yaml %}
.footer {
  font-size: 14px;
  color: #999;
  img { border: none; }
  +mobile(){
	font-size: 13px;
  }
}
{% endcodeblock %}

### 添加背景图片
1. 将背景图片命名为**background.jpg**并放入`博客根目录/source/images`文件夹中
2. 打开`博客根目录/themes/next/source/css/_custom/custom.styl`文件
3. 加入如下代码：

{% codeblock lang:Yaml %}
// Custom styles.
body { 
	background-image: url(/images/background.jpg);
	background-attachment: fixed;
	background-repeat: no-repeat;
}
{% endcodeblock %}

## 域名绑定
### 购买域名
　　一个高逼格的博客怎么能够少了域名呢=。=域名提供商有很多，像godaddy、万网等。如果是学生党的话推荐使用**腾讯云**“[1元云主机+域名](https://www.qcloud.com/act/campus)”计划。
### 绑定域名
这里以在腾讯云购买的域名为例。
1. 进入腾讯云后台域名管理，点击解析域名
2. 添加DNS记录：
![](http://okwl1c157.bkt.clouddn.com/dns2.png)
![](http://okwl1c157.bkt.clouddn.com/dns1.png)
【注：腾讯云中DNS记录生效需要十分钟，请耐心等待】
3. 在博客根目录里的source目录中新建CNAME文本文件（不带任何后缀！！！），然后用Notepad++编辑CNAME文件，写入你的域名，保存退出
4. 重新部署一下博客（hexo clean、hexo d -g）
5. 试试能不能通过域名访问到你的博客

## 百度 & 谷歌收录
检测站点是否已被百度 or 谷歌收录的方法： 在百度 or 谷歌搜索框中输入`site:你的站点`然后回车，如果有结果显示，说明已被收录。
### 百度收录
　　让百度收录我的博客真的是经历了很长的一段过程。。。关于提交sitemap、设置推送链接可以看一下[这篇文章](http://www.jianshu.com/p/8c0707ce5da4)。事实上按照该博客的做法后，我等了一个星期都没有收录成功（明明谷歌的都收录了orz）。后来，我发现了原因。那就是github禁止了百度爬虫，而我的站点又是托管在github上的，所以百度爬取不到我的网页，自然收录不了，以下是解决方案。
1. 将博客同时部署在github和**coding**上，coding的服务器在国内，访问速度快，而且最重要的是不禁百度爬虫
2. 打开根目录下_config.yml文件，修改最下面的deploy部分如下

{% codeblock %}
deploy:
  type: git
  repository:
    github: git@github.com:你的GitHub名/你的GitHub名.github.io.git
    coding: git@git.coding.net:你的Coding名/你的Coding名.git
  branch: master 
{% endcodeblock %}

3. coding上创建一个新项目，建议**命名为你的Github名**
4. 本地打开 id_rsa.pub 文件，复制其中全部内容，填写到SSH_RSA公钥key下的一栏，公钥名称可以随意起名字。完成后点击“添加”，然后输入密码或动态码即可添加完成。添加后，在git bash命令输入：`ssh -T git@git.coding.net`检测公钥是否添加成功
5. 在coding项目主页中点击**pages服务**，进行如下配置
![](http://okwl1c157.bkt.clouddn.com/pages.png)
6. 在DNS Pod中添加两条CNAME记录，如下
![](http://okwl1c157.bkt.clouddn.com/dns3.png)
![](http://okwl1c157.bkt.clouddn.com/dns4.png)
7. 重新部署博客，等待一两天后应该就可以在百度里搜索到你的博客啦（虽然目前为止，百度好像也就收录了我的站点首页= =）
8. 小tips：百度**主动推送**比自动推送等要快的多，因此每写完一篇博客后，建议自己主动推送给百度，方法百度站长平台里有写
9. 小tips之二：在百度站长平台**索引量**工具定制索引规则为：`你的站点/*`　可以加快百度爬虫爬取你的博客网站下的子网页并建立索引的速度。
### 谷歌收录
让谷歌收录就容易多了，只要提交站点地图然后验证域名所有权就行了，具体的上面那篇文章也很详细地介绍了，这里不再赘述。

## SEO优化
### 更改首页标题格式
打开\themes\next\layout\index.swig文件，找到这行代码：
```
{% block title %} {{ config.title }} {% endblock %}
```
把它改成：
```
{% block title %}
  {{ theme.keywords }} - {{ config.title }} - {{ theme.description }}
{% endblock %}
```
### 外链生成
　　这里推荐使用外链工具为你的站点批量生成外链。百度一下“超级外链SEO工具”，输入站点名，然后就让它自动为你生成外链吧~~新站的话建议每天刷两次。

## 参考资料
1. [Hexo3.1.1静态博客搭建指南](https://lovenight.github.io/2015/11/10/Hexo-3-1-1-%E9%9D%99%E6%80%81%E5%8D%9A%E5%AE%A2%E6%90%AD%E5%BB%BA%E6%8C%87%E5%8D%97/)

2. [NexT使用文档](http://theme-next.iissnan.com/)

3. [Hexo官方文档（中文版）](https://hexo.io/zh-cn/docs/)