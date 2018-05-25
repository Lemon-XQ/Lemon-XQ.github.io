---
title: 实现在Java中执行python代码或py脚本（可传参数）
date: 2017-11-17 17:25:18
categories:
- Java
tags:
- Java
- Python
- Tomcat
- 服务端编程
---
## 写在前面
　　最近用**Java**写服务端程序时，遇到这样一个需求：需要把**用python写的机器学习算法**部署到服务器上，然后Java执行**py脚本**，并且取得算法执行的结果。在网上找了很久，有些跑不通，有些是基于windows的，我的服务器是**linux**的，遇到了不少坑= =好不容易解决了，记录一下。

**注：Web服务器：Tomcat　服务器OS：CentOS 7　开发工具：Eclipse**
<!--more-->

## 直接嵌入python代码(使用PythonInterpreter)
- **适用情形：**要嵌入的python代码不长
- **步骤：**
	- 下载**Jython**，导入jython.jar到项目lib中
	- 引用org.python包
	- 测试代码如下：
{% codeblock lang:java %}
import javax.script.*;    
import org.python.util.PythonInterpreter;  
import java.io.*;  
import static java.lang.System.*;  
public class Test  
{  
 public static void main(String args[])  
 {      
  PythonInterpreter interpreter = new PythonInterpreter();  
  interpreter.exec("print "TEST";");  
 }
} 
{% endcodeblock %}

## 执行python脚本(使用PythonInterpreter)
- **适用情形：**python代码为py文件形式
- **步骤：**
	- 下载Jython，导入jython.jar到项目lib中
	- 引用org.python包
	- 测试代码如下：
{% codeblock lang:java %}
import javax.script.*;    
import org.python.util.PythonInterpreter;  
import java.io.*;  
import static java.lang.System.*;  
public class Test  
{  
 public static void main(String args[])  
 {      
  PythonInterpreter interpreter = new PythonInterpreter();  
  InputStream filepy = new FileInputStream("D:\\demo.py");   
  interpreter.execfile(filepy);   
  filepy.close();  
 }  
}  
{% endcodeblock %}

## 执行python脚本(使用Runtime.getRuntime()）
- **适用情形：**
	- python脚本中**import了外来模块**；
	- 需要**传入数据**给python脚本
	- **PS:**上面两种不知道为啥老是会报错= =所以最后我用的是这种……
- **测试代码：**
{% codeblock lang:java %}
// 定义传入参数
int age;
// 接收python脚本的输出结果
int result;
// 若Python脚本在windows主机中
String cmdStr_windows = "python D:\\demo.py"+ " " + age;
// 若Python脚本在Linux主机中
String cmdStr_linux = "python /home/pythonCode/demo.py"+ " " + age);
// 定义缓冲区、正常结果输出流、错误信息输出流
byte[] buffer = new byte[1024];  
ByteArrayOutputStream outStream = new ByteArrayOutputStream();  
ByteArrayOutputStream outerrStream = new ByteArrayOutputStream();   

try {
	proc = Runtime.getRuntime().exec(cmdStr_linux);
	InputStream errStream = proc.getErrorStream();
	InputStream stream = proc.getInputStream();
	
	// 流读取与写入
	int len = -1;  
	while ((len = errStream.read(buffer)) != -1) {  
	    outerrStream.write(buffer, 0, len);  
	}  
	while ((len = stream.read(buffer)) != -1) {  
	    outStream.write(buffer, 0, len);  
	}  
	proc.waitFor();// 等待命令执行完成
	
	// 打印流信息
	System.out.println(outStream.toString());
	System.out.println(outerrStream.toString());
	
	// 将接收的输出结果转换为目标类型
	res = Integer.parseInt(outStream.toString());
} catch (Exception e) {
	e.printStackTrace();
}
{% endcodeblock %}
- demo.py脚本如下：
{% codeblock lang:python %}
import sys
age = sys.argv[1]
res = 1111
print res
{% endcodeblock %}

- **注：**
	- 若python脚本在Linux主机中，注意文件路径要为**绝对路径**，而且**不能用~代替家目录！！！**必须写成/XX/XXX的形式
	-  若要传递多个参数，需要以**空格**间隔
	- 接收python脚本执行结果可用**java的InputStream**截获控制台输出