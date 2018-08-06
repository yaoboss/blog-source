---
title: 如何正确的kill一个java程序
date: 2016-07-24 22:45:22
tags:
- Java
- linux
category:
- Java
---
以前代码部署在线上的linux环境，每次都是直接kill -9 pid停止程序的进程。因为我们是使用的jetty 嵌入式模式，直接通过java程序启动的，又没有写相应的相应停止的代码，看了公司以前的用来启动和停止shell脚本的代码，也是直接在使用kill -9 pid这种方式。
<!--more-->

不过这两天正好碰到一个服务有个问题，是kafka相关的。消费kafka的设备上报日志，转存到elasticSearch以提供各种需要查用户相关设备的查询服务。我在调试时需要切换日志级别，查看更详细的打印信息，这时候就不得不做重启服务的操作。

如果熟悉kafka的同学应该知道，kafka的offset信息都是存在zookeeper集群里的，这时候，如果我粗暴的使用kill -9 pid这种方式停止程序，并重启的话，那我很可能要丢失一段时间offset信息，因为这时候，程序还没把offset写到zokeeper就已经被粗暴终止了。这时候当我重新启动时，程序就会从zookeeper读取一个最近的offset信息，并从这里开始消费日志信息。这样如果这时候这段时间，日志的量很大的话，就又重复做了这段时间的写入，完全是在浪费。

去翻官方的kafka文档，里面是有关于graceful的关闭kafka消费程序的。但是这时候我需要让程序知道，我在关闭时，它要去调kafka的关闭方法，做一些善后工作。

查了一些资料发现

1. kill -15 pid
使用15这个信号去关闭程序，并且在java程序中注册shutdownhook的调用，当程序接收到这个信号时，会调用回调的钩子，处理完善后，再进行退出。这样就比较合理了。所以有时候粗暴确实不太靠谱。


```java
public class TestStop{
private static final void shutdownCallback() {
System.out.println("Shutdown callback is invoked.");
}
public static void main(String[] args) throws Exception {
Runtime.getRuntime().addShutdownHook(new Thread() {
@Override
public void run() {
shutdownCallback();
}
});
Thread.sleep(60 * 1000 * 60 * 60);
}
}
```

如果想做实验的话，可以直接使用上面这个小例子。

这种方式对于spring里面的

context.registerShutdownHook();
方法也同样有效。spring容器会去执行lifecycle的doClose()方法，最后所有组件的重写的destroy()以及注解@destory的方法都会被执行。