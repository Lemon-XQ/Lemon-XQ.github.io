---
title: Unity中脚本的生命周期详解
date: 2017-04-20 15:06:22
tags:
	- Unity
categories:
	- Unity
---
<blockquote class="blockquote-center">关于脚本的生命周期你都知道多少？</blockquote>
## 写在前面
　　在Unity项目中，经常会使用到Start、Update、Awake、OnEnable、LateUpdate、OnDisable、OnDestroy、OnGUI、FixedUpdate方法，然而，它们的生命周期你都清楚么？看上去好像无关紧要的东西往往会在不经意间给你挖了一个坑...曾经被坑过的我如是说：)
<!--more-->
## Unity脚本的生命周期
　　先上一张图:
![](http://okwl1c157.bkt.clouddn.com/Image.png)
　　接下来将逐个讲解...


### Awake
　　Awake在MonoBehavior创建后就**立刻**调用，此后每当脚本被加载时调用一次Awake,即使脚本没有被激活；在**脚本实例的整个生命周期**中，Awake函数**仅执行一次**；**值得注意的一点是，Awake函数的执行与否与脚本实例的状态（启用或禁用）并没有关系，而是与脚本实例所绑定的游戏对象的开关状态有关。**如果游戏对象（即gameObject）的初始状态为关闭状态，那么运行程序，Awake函数不会执行；如果游戏对象的初始状态为开启状态，那么Awake函数会执行；如果重新加载场景，那么场景内Awake函数的执行情况重新遵循上述两点。

### Start
　　Start()将在MonoBehavior创建后**在该帧Update()第一次执行前**被调用；只会在第一次调用Update之前调用一次；Start()函数**只在脚本实例被启用时**才会执行；Start函数**总是在Awake函数之后执行。**如果游戏对象开启了，对象上绑定的脚本实例被禁用了，那么Start函数不会执行。这是Start函数的特点，只有在脚本实例被启用且是**首次启用时**它才会执行。**如果是已经开启过的脚本实例被关闭后再次开启，那么Start函数不会再次执行。**

　　**注：一般开发中都是在Awake函数中获取游戏对象或者脚本实例的信息，然后在Start函数中进行一些获取之后的初始化设置。**

### Update && LateUpdate && FixedUpdate

　　当MonoBehaviour启用时,其Update 和 LateUpdate在每一帧被调用；Update每帧调用一次（每秒60帧不会卡），一般用于处理画面逻辑;

　　LateUpate一般用于刷新其他逻辑，注意LateUpdate是晚于所有Update执行的。一般类似相机跟随的代码会放到lateupdate里面去执行。举个栗子，一个宿舍4个人，每个人的起床在update中执行，出发在某个人中的lateupdate执行，这样就可以保证每个人都起床了才会出发

　　而FixedUpdate会**在每个固定的物理时间片**被调用一次.不会受到图像刷新帧速率的影响。这是放置游戏基本物理行为代码的地方。在Update之后调用。

### OnEnable && OnDisable && OnDestory 
　　OnEnable:在每次激活脚本时调用OnEnable;
　　OnDisable:取消激活状态后调用
　　OnDestroy：被销毁时调用一次

　**　注：Awake、OnEnable、Start,都是游戏开始运行前就调用的方法。**

　　GameObject的Activity为true，脚本的enable为true时，其先后顺序为：Awake、OnEnable、Start；
　　GameObject的Activity为true，脚本的enable为false时,只运行Awake；
　　GameObject的Activity为false时，以上都不调用，OnDisable()被调用；


### OnGUI
　　这个函数会每帧调用好几次（每个事件一次），GUI显示函数只能在OnGui中调用

### Reset
　　Reset是在用户点击检视面板的Reset按钮或者首次添加该组件时被调用.此函数只在编辑模式下被调用.Reset最常用于在检视面板中给定一个最常用的默认值.




