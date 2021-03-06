---
title: ulua热更新小试
date: 2017-05-01 22:50:09
tags:
	- Unity
	- Lua
	- 热更新
categories:
	- Unity
---
<blockquote class="blockquote-center">传说中的热更新在Unity中是怎样实现的:)</blockquote>
## 写在前面
　　热更新技术在游戏行业可以说是大名鼎鼎了，虽然苹果前段时间禁止了JSPatch等热更新技术，但目前来看，苹果并没有禁止游戏引擎的热更新技术。某种程度上说明了热更新在游戏中的重要性。而ulua作为一款优秀的unity3d热更新插件，完美解决了Unity游戏热更新的问题。 
<!--more-->
## 什么是热更新
　　热更新一般用于网络游戏中。其指的是在不重新下载客户端的情况下，对游戏的内容进行更新（包括资源更新或逻辑更新等）。知乎上对热更新有一个很形象的比喻：假设你的卡车开到了150KM/H，然后有个轮胎爆了。司机说，你就直接换吧，我不停车。你小心点换。热更新机制大概就是这个意思。
## 什么是Lua
　　Lua是一款**轻巧**的脚本语言，由**标准C**编写而成，代码简洁优美，几乎在所有操作系统和平台上都可以编译，运行。在目前所有脚本引擎中，Lua的**速度是最快**的。这一切都决定了Lua是作为**嵌入式脚本**的最佳选择。（嗯这段其实是百度的orz...）

　　Lua代码都是运行时才编译的，不运行的时候就如同一张图片、一段音频一样，都是文件；所以更新逻辑只需要更新脚本，不需要再编译，因而Lua能轻松实现“热更新”。Ulua是一款非常实用的unity插件，它能让unity支持Lua语言，而且运行效率还不错。
## 使用ulua进行热更新
### 1.安装ulua插件 及 Lua编写工具LuaStudio

- ulua下载地址：http://ulua.org/
- LuaStudio下载地址：https://pan.baidu.com/s/1hsabx0w 密码: kqvp


### 2.新建Unity工程，将ulua导入工程中
### 3.ulua中的使用流程
- 实例化LuaState对象（new LuaState()）,一个LuaState对象代表一个Lua解释器
- 加载Lua代码（LuaState.DoString(string)），string为Lua代码字符串或Lua脚本文件名称**（推荐使用后者）**
- 调用Lua代码中的方法（GetFunction string）,LuaFunction.callFunction(string)
- **注：**由于Unity不支持扩展名为lua的文件，所以可将Lua脚本扩展名定为txt（纯文本文件）,并用unity的**TextAsset**列表负责记录所有脚本文件。建议列表中给每个脚本搭配一个string类型的ID，这样凭此ID即可加载正确的lua脚本；另外在LuaState类中新增一个String类型的public成员，赋值为该ID。这样一旦某个Lua脚本在运行时报错，可根据输出的ID值判断是哪个Lua脚本有错误。


### 4.ulua框架在Unity中的使用（SimpleFramework_UGUI解读）
- **框架启动**
	- GlobalGenerator:初始化游戏环境,包括添加AppView,启动**pureMVC**框架，添加各种Manager
	- GameManager中对资源进行更新处理
- **资源初始化过程 **OnResourceInited
	- 加载网络、游戏管理器的Lua脚本
	- 调用GameManager.lua里的LuaScriptPanel方法（CallMethod通过LuaScriptMgr.cs的CallLuaFunction()将控制权移交给GameManager.lua）
	- 创建Lua面板（Message、Prompt）
	- 调用方法OnInitOK表示初始化成功
-  ulua框架的执行顺序：
	- 每个UI Panel对应**View**下的lua代码，用来获取一些需要交互的属性
	- 每个UIprefab通过**Controller**进行控制，包括其实例化以及组件的一些行为，比如OnCreate事件


## 热更新案例：UI面板更新
### 创建开发UI界面
- 设计UI Panel
![](http://okwl1c157.bkt.clouddn.com/panelDemo)
- 将UI panel做成prefab,进行**打包**（注意**后缀一定为.assetbundle**）
- 将UI panel所用到的所有UI资源进行打包（图片、字体等），最好分类打包
- 点击**Game-Build XXX Resources**(XXX 代表想要发布到的平台)
- 创建**Global Generator**（空Object上挂Global Generator脚本）
- 重写Logic文件夹中的**GameManager.lua**脚本
{% codeblock lang:lua %}
require "Common/define" --引入AppConst,NetManager的定义
require "Controller/BottomCtrl" --以下引入对各子面板的控制器
require "Controller/SettingsCtrl"
require "Controller/DialogCtrl"

GameManager = {}

function GameManager.LuaScriptPanel()
	return 'Bottom','Settings','Dialog'; --Prefab中除掉“Panel”后的名字
end

function GameManager.OnInitOK()
	--加载网络
	AppConst.SocketPort = 2012; --设置套接字端口号
    AppConst.SocketAddress = "127.0.0.1"; --设置套接字IP地址，这里默认从主机下载资源
    NetManager:SendConnect(); --建立连接
	
	BottomCtrl.Awake();
	SettingsCtrl.Awake();
	DialogCtrl.Awake();
end
{% endcodeblock %}
- View文件夹下**创建子面板的lua脚本**（以BottomPanel.lua为例，其他同理）
{% codeblock lang:lua  %}
BottomPanel = {}

local this = BottomPanel
local gameObject
local transform

function BottomPanel.Awake(obj)
	--对局部变量进行赋值
	gameObject = obj;
	transform = gameObject.transform
	
	this.InitPanel();--初始化面板
end

function BottomPanel.InitPanel()
	--给面板中的三个Button赋值
	this.buttonSettings = transform:FindChild("ButtonSetting").gameObject;
	this.buttonPeople = transform:FindChild("ButtonPeople").gameObject;
	this.buttonDialog = transform:FindChild("ButtonDialog").gameObject;
end
{% endcodeblock %}
- **[可选]**给SettingPanel下的BG添加动画：由小变大动画、隐藏动画、激活动画
- 重写SettingPanel.lua脚本获取UI中的组件
{% codeblock lang:lua %}
SettingsPanel = {}

local this = SettingsPanel
local transform
local gameObject

function SettingsPanel.Awake(obj)
	gameObject = obj;
	transform = gameObject.transform;
	
    this.InitPanel();
end

function SettingsPanel.InitPanel()
	--获取动画组件及按钮组件
	this.anim = transform:FindChild("Bg"):GetComponent("Animator");
	this.buttonClose = transform:FindChild("Bg/ButtonClose").gameObject;
end
{% endcodeblock %}
- 开发Controller控制层下的Lua代码，控制UI控件的产生和事件的监听（以BottomCtrl.lua为例）
{% codeblock lang:lua %}
require "Common/define"

BottomCtrl = {}

local this = BottomCtrl
local gameObject
local transform
local lua

function BottomCtrl.New()
	return this;
end

function BottomCtrl.Awake()
	--调用panel的创建方法创建相应面板，注意面板命名为XXPanel
	PanelManager:CreatePanel("Bottom",this.OnCreate)
end

function BottomCtrl.OnCreate(obj)
	gameObject = obj;
	transform = obj.transform
	
	lua = gameObject:GetComponent("LuaBehaviour");
	--注册按钮，绑定事件
	lua:AddClick(BottomPanel.buttonDialog,this.OnButtonDialogClick);
	lua:AddClick(BottomPanel.buttonPeople,this.OnButtonPeopleClick);
	lua:AddClick(BottomPanel.buttonSettings,this.OnButtonSettingsClick);
end

function BottomCtrl.OnButtonDialogClick()
	DialogCtrl.Show();
end

function BottomCtrl.OnButtonPeopleClick()
	
end

function BottomCtrl.OnButtonSettingsClick()
	SettingsCtrl.Show();
end
{% endcodeblock %}
- 发布到手机上，启动Server
	- Switch Platform - Android
	- Lua-Clear Wrap Files
	- Lua-Gen Wrap Files
	- Game-Build Android Resources
	- 修改AppConst.cs里的UpdateMode=true,DebugMode=false,WebUrl=局域网地址（有服务器的话就是服务器地址,这里假设用uLua自带服务器运行）
	- 打开Server.sln-HttpServer.cs，修改host,重新生成工程
	- 运行ulua文件夹下Server/Server/bin/Debug/SuperSocket.SocketService.exe（以管理员权限运行），选择r运行服务器
- 进行Lua代码的更新
	- Build & run,手机连电脑，将程序发布到手机
	- 更改Lua代码
	- 重新Build Android Resources
	- 手机重新启动该程序
	- 解包完成！更新完成！
- 进行UI资源的更新
	- 创建Dialog Panel,打包，新建Panel,Ctrl脚本文件
	- 重新Build Android Resources
	- 手机重新启动软件
**注意：**如果电脑防火墙没关，手机是没有权限访问电脑的，就会更新失败。。。


## Unity3D中的热更新
Unity3D的热更新会涉及3个目录。


- **游戏资源目录：**里面包含Unity3D工程中StreamingAssets文件夹下的文件。安装游戏之后，这些文件将会被一字不差地复制到目标机器上的特定文件夹里，不同平台的文件夹不同，如下所示

	* Mac OS或Windows：Application.dataPath "/StreamingAssets";
	* IOS： Application.dataPath "/Raw";
	* Android：jar:file://" Application.dataPath "!/assets/"; 


- **数据目录：**由于“游戏资源目录”在Android和IOS上是只读的，不能把网上的下载的资源放到里面，所以需要建立一个“数据目录”，该目录可读可写。第一次开启游戏后，程序将“游戏资源目录”的内容复制到“数据目录中”（这个步骤只会执行一次，下次再打开游戏就不复制了）。游戏过程中的资源加载，都是从“数据目录”中获取、解包。不同平台下，“数据目录”的地址也不同，LuaFramework的定义如下：

	* Android或IOS：Application.persistentDataPath "/LuaFramework"
	* Mac OS或Windows：c:/LuaFramework/
	* 调试模式下：Application.dataPath "/StreamingAssets/" 

　　**注：**”LuaFramework”和”StreamingAssets”由配置决定，这里取默认值


- **网络资源地址：**存放游戏资源的网址，游戏开启后，程序会从网络资源地址下载一些更新的文件到数据目录。

这些目录包含着不同版本的资源文件，以及用于版本控制的**files.txt。**Files.txt里面存放着资源文件的名称和md5码。程序会**先下载“网络资源地址”上的files.txt**，然后与“数据目录”中文件的**md5码**做比较，更新有变化的文件。



## 常见问题 && 注意事项
1. 运行 LuaStudio 时，请使用Administrator管理员权限！
2. Lua需要统一的UTF-8编码，有时候Lua脚本无故编译出错请检查编码问题！
3. 若运行到真机，记得一定要设置Const.DebugMode=false
4. 【该点摘录自云风博客】**更新时要保护后内存中的非代码数据。**这个时候，**对 local 变量的使用务必小心**。因为 local 变量总会被作为 upvalue 绑定在 closure 里。我们的代码经常会依赖这些 local 变量。在更新后，许多保存数据用的 local 变量会生成新的一份。这很可能丢失重要数据。而因为这个问题回避使用 local 也是不合适的。要知道 local 和 global 变量的性能可不只差上一点半点。
我采用的方法是，**把数据记录在专用的全局表下，并用 local 去引用它。初始化这些数据的时候，首先应该检查他们是否被初始化过了。这样来保证数据不被更新过程重置**
