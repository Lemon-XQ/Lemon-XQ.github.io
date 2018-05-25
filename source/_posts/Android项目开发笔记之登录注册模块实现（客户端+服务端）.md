---
title: Android项目开发笔记之登录注册模块实现（客户端+服务端）
date: 2018-03-11 00:24:31
categories:
- Android
tags:
- 登录注册
- 服务端
- 客户端
---
## 写在前面
　　断断续续开发了几个月的App终于告一段落，虽然它可能还很不完美，不过作为上手Android的第一个完整项目，确实从中学到了蛮多，所以开个系列记录一下~本篇先从基本上每个App都会有的**登录注册**讲起，包含自动登录、记住密码功能的实现=w=
<!--more-->
## 实现：登录功能
### 思路
　　整个登录功能的逻辑为：用户提交账号、密码->判断账号密码是否为空->选项处理（自动登录及记住密码）->向服务端LoginServlet提交账号密码->服务端查询数据库判断账号是否存在->服务端查询数据库判断账号密码是否匹配->返回resCode（登录成功/失败）
### 客户端
**注： 客户端使用Litepal进行数据库的管理，关于Litepal的配置自行百度=。=**

1. 在LogInActivity启动时要先判断用户上次是否有勾选了自动登录或记住密码，这个是通过SharedPreferences实现的，代码如下：

{% codeblock lang:java %}
@Override
protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_login);

    initComponents();
    setListeners();

    // 自动填充
    SharedPreferencesUtil spu = new SharedPreferencesUtil(this);
    Boolean isRemember = (Boolean) spu.getParam("isRememberPwd",false);
    Boolean isAutoLogin = (Boolean) spu.getParam("isAutoLogin",false);
    // SharedPreference获取用户账号密码，存在则填充
    String account = (String) spu.getParam("account","");
    String pwd = (String)spu.getParam("pwd","");
    if(!account.equals("") && !pwd.equals("")){
        if(isRemember){
            accountText.setText(account);
            passwordText.setText(pwd);
            isRememberPwd.setChecked(true);
        }
        if(isAutoLogin)
            Login();
    }
}
{% endcodeblock %}

2.判断账号密码是否合理，这里设置为只有手机/邮箱才能登录

{% codeblock lang:java %}
private String checkDataValid(String account,String pwd){
    if(TextUtils.isEmpty(account) | TextUtils.isEmpty(pwd))
        return "账号或密码不能为空";
    if(account.length() != 11 && !account.contains("@"))
        return "用户名不是有效的手机或邮箱";
    return "";
}
{% endcodeblock %}

3.记录自动登录及记住密码选项，同时将最近登录的账号密码写入SharedPreferences中
{% codeblock lang:java %}
void OptionHandle(String account,String pwd){
    SharedPreferences.Editor editor = getSharedPreferences("UserData",MODE_PRIVATE).edit();
    SharedPreferencesUtil spu = new SharedPreferencesUtil(this);
    if(isRememberPwd.isChecked()){
        editor.putBoolean("isRememberPwd",true);
        // 保存账号密码
        spu.setParam("account",account);
        spu.setParam("pwd",pwd);
    }else{
        editor.putBoolean("isRememberPwd",false);
    }
    if(isAutoLogin.isChecked()){
        editor.putBoolean("isAutoLogin",true);
    }else{
        editor.putBoolean("isAutoLogin",false);
    }
    editor.apply();
}
{% endcodeblock %}

4.向服务端发起POST请求，这里将账号密码封装为JSON字符串后再提交，JSON的好处大家都懂得~
{% codeblock lang:java %}
// 登录请求
public void LoginPost(String account, String password, final Handler mHandler){
    final CommonRequest request = new CommonRequest();
    // 填充参数
    request.addRequestParam("account",account);
    request.addRequestParam("pwd",password);

    infoPost(Consts.URL_Login, request.getJsonStr());
    // 隔一段时间（2.5s）后再发送信息给LogInActivity，因为网络请求是耗时操作
    mHandler.postDelayed(new Runnable() {
        @Override
        public void run() {
            Message message = new Message();
            message.what = 1;
            mHandler.sendMessage(message);
        }
    }, 2500);
}
// 通用的POST信息方法
private void infoPost(String url, String json){
    HttpUtil.sendPost(url,json,new okhttp3.Callback() {
        @Override
        public void onResponse(Call call, Response response) throws IOException {
            CommonResponse res = new CommonResponse(response.body().string());
            resCode = res.getResCode();
            resMsg = res.getResMsg();
            property = res.getPropertyMap();
            dataList = res.getDataList();
        }
        @Override
        public void onFailure(Call call, IOException e) {
            e.printStackTrace();
            showResponse("Network ERROR");
        }
    });
}
{% endcodeblock %}

5.以上3步合起来即为Login方法，代码如下:
{% codeblock lang:java %}
/**
 *  POST方式Login
 */
private void Login() {
    // 前端参数校验，防SQL注入
    account = Util.StringHandle(accountText.getText().toString());
    password = Util.StringHandle(passwordText.getText().toString());

    // 检查数据格式是否正确
    String resMsg = checkDataValid(account,password);
    if(!resMsg.equals("")){
        showResponse(resMsg);
        return;
    }

    // 显示进度条
    progressDialog = new ProgressDialog(this);
    progressDialog.setMessage("登录中...");
    progressDialog.setCancelable(false);
    progressDialog.show();

    OptionHandle(account,password);// 处理自动登录及记住密码

    server.LoginPost(account,password,loginHandler);
}
{% endcodeblock %}

6.loginHandler根据得到的登录状态码进行相应处理：
{% codeblock lang:java %}
@SuppressLint("HandlerLeak")
Handler loginHandler = new Handler(){
    @Override
    public void handleMessage(Message msg) {
        switch (msg.what){
            case 1:
                String resCode = server.getResCode();
                String resMsg = server.getResMsg();
                // 登录成功
                if (resCode != null && resCode.equals(Consts.SUCCESSCODE_LOGIN)) {
                    // 查找本地数据库中是否已存在当前用户,不存在则新建用户并写入
                    User user = DataSupport.where("account=?",account).findFirst(User.class);
                    if(user == null){
                        user = new User();
                        user.setAccount(account);
                        user.setPassword(password);
                        user.setVisitor(false);
                        user.save();
                    }
                    UserManager.setCurrentUser(user);// 设置当前用户

                    autoStartActivity(MainActivity.class);
                }
                progressDialog.dismiss();// 隐藏进度条
                showResponse(resMsg);// Toast相应信息
                break;
        }
    }
};
{% endcodeblock %}

### 服务端
**注：服务端使用Java Servlet实现，这个网上也有很多资料，不多说**

1. 因为使用的是POST方式，所以以下步骤均在**Servlet的****doPost**中进行;
2. 获取客户端发来的请求，将request对象转化为字符串，进而恢复其JSON格式
{% codeblock lang:java %}
// request转字符串
BufferedReader read = request.getReader();
StringBuilder sb = new StringBuilder();
String line = null;
while ((line = read.readLine()) != null) {
    sb.append(line);
}
String req = sb.toString();
// 获取 客户端 发来的请求，恢复其Json格式——>需要客户端发请求时也封装成Json格式
JSONObject object = JSONObject.fromObject(req);
{% endcodeblock %}
3. 提取json中的requestCode和requestParam，requestCode可以用于区分同一类请求下的不同子请求，eg.获取数据库的不同信息
{% codeblock lang:java %}
// requestCode、requestParam要和客户端CommonRequest封装时候的名字一致  
String requestCode = object.getString("requestCode");  // 暂时不用
JSONObject requestParam = object.getJSONObject("requestParam"); 
{% endcodeblock %}
4. 提取账号密码
{% codeblock lang:java %}
// json中提取参数
String account = requestParam.getString("account");
String pwd = requestParam.getString("pwd");
{% endcodeblock %}

5. 定义查询语句、查询结果集、Response信息对象
{% codeblock lang:java %}
// 自定义的结果信息类  
CommonResponse res = new CommonResponse();  

// Sql查询语句
String sqlQueryExist = "select * from "+DBUtil.table_user_pwd+" where username=?;";

// 查询结果
ResultSet resultSet = null;
ArrayList<String> args = new ArrayList<String>();
{% endcodeblock %}

6. 核心逻辑：填充查询参数->执行查询语句->判断账号是否存在->若存在则查询密码是否匹配->否则返回错误信息
{% codeblock lang:java %}
try {
	args.add(account);
	resultSet = DBUtil.query(sqlQueryExist, args);				
	if(resultSet.next()){// 账号存在，查询密码是否正确
		if(resultSet.getString("pwd").equals(pwd)){// 密码正确
			res.setResult("100", "登录成功！");
		}else{// 密码错误
			res.setResult("201", "密码错误！");
		}				
	}else{// 账号不存在
		res.setResult("202", "账号不存在，请先注册！");
	}
} catch (Exception e) {
	res.setResult("300", "数据库查询错误");
	e.printStackTrace();
}
{% endcodeblock %}

7. 将结果封装为Json格式返回给客户端
{% codeblock lang:java %}
// 注意实际网络传输时还是传输json的字符串
String resStr = JSONObject.fromObject(res).toString();
response.getWriter().append(resStr).flush();
{% endcodeblock %}


## 实现：注册功能
### 思路
　　注册功能逻辑为：用户提交账号、密码、确认密码->判断三者是否均不为空->判断两次输入的密码是否一致->判断用户名是否合理->提交账号密码至服务端->服务端查询账号是否已存在->若不存在则插入账号密码至user_pwd表中->向客户端返回信息
### 客户端
注释写的很清楚了，直接放源码~

{% codeblock lang:java %}
/**
 *  POST方式Register
 */
private void register() {
    // 创建请求体对象
    CommonRequest request = new CommonRequest();

    // 前端参数校验，防SQL注入
    String account = Util.StringHandle(accountText.getText().toString());
    String pwd = Util.StringHandle(pwdText.getText().toString());
    String pwd_confirm = Util.StringHandle(confirmPwdText.getText().toString());

    // 检查数据格式是否正确
    String resMsg = checkDataValid(account,pwd,pwd_confirm);
    if(!resMsg.equals("")){
        showResponse(resMsg);
        return;
    }

    // 填充参数
    request.addRequestParam("account",account);
    request.addRequestParam("pwd",pwd);

    // POST请求
    HttpUtil.sendPost(Consts.URL_Register, request.getJsonStr(), new okhttp3.Callback() {
        @Override
        public void onResponse(Call call, Response response) throws IOException {
            CommonResponse res = new CommonResponse(response.body().string());
            String resCode = res.getResCode();
            String resMsg = res.getResMsg();
            // 显示注册结果
            showResponse(resMsg);
            // 注册成功
            if (resCode.equals(Consts.SUCCESSCODE_REGISTER)) {
                finish();
            }
        }

        @Override
        public void onFailure(Call call, IOException e) {
            e.printStackTrace();
            showResponse("Network ERROR");
        }
    });
}
private String checkDataValid(String account,String pwd,String pwd_confirm){
    if(TextUtils.isEmpty(account) | TextUtils.isEmpty(pwd) | TextUtils.isEmpty(pwd_confirm))
        return "账号或密码不能为空";
    if(!pwd.equals(pwd_confirm))
        return "两次输入的密码需保持一致";
    if(account.length() != 11 && !account.contains("@"))
        return "用户名不是有效的手机号或邮箱";
    return "";
}
{% endcodeblock %}
### 服务端
1. 1-4步与登录功能里的一致，不再赘述
2. 核心逻辑：填充查询参数->查询账号是否存在->若不存在执行Insert操作，同时更新userInfo表->向客户端返回消息
{% codeblock lang:java %}
// 自定义的结果信息类  
CommonResponse res = new CommonResponse();  

// Sql语句
String sqlQueryExist = "select * from "+DBUtil.table_user_pwd+" where username=?;";
String sqlInsert = "insert into "+DBUtil.table_user_pwd+"(username,pwd)"+
		" values(?,?);";

// 查询结果
ResultSet resultSet = null;
ArrayList<String> args = new ArrayList<String>();

try {
	DBUtil.checkConnection();
	args.add(account);
	resultSet = DBUtil.query(sqlQueryExist, args);				
	if(resultSet.next()){// resSet不为空
		res.setResult("203", "账号已存在，请登录");
	}else{
		args.add(pwd);
		int rows = DBUtil.update(sqlInsert, args);// 返回插入后受影响的行数
		if(rows==1){// 插入userpwd表成功
			String sqlQueryId = "select userId from "+DBUtil.table_user_pwd+
					" where username=?;";
			args.clear();
			args.add(account);
			ResultSet resSet = DBUtil.query(sqlQueryId, args);
			if(resSet.next()){
				// 获取用户id,更新userInfo表
				String userId = resSet.getInt("userId")+"";
				String sqlInsertId = "insert into "+DBUtil.table_user_info+
						"(userId)"+" values(?);";
				args.clear();
				args.add(userId);
				rows = DBUtil.update(sqlInsertId, args);
				if(rows == 1 ){
					res.setResult("101", "注册成功");
				}
			}
		}else{
			res.setResult("204", "用户信息插入失败");
		}
	}
} catch (SQLException e) {
	res.setResult("300", "数据库查询错误");
	e.printStackTrace();
}        
// 将结果封装成Json格式准备返回给客户端，但实际网络传输时还是传输json的字符串
String resStr = JSONObject.fromObject(res).toString();
response.getWriter().append(resStr).flush();
{% endcodeblock %}

## 最后
　　登录注册模块到这里就完成啦！里面涉及到一些功能类和功能函数的封装，不难实现，源码放[Github](https://github.com/Lemon-XQ/PregnantMonitor)了，欢迎star~　　