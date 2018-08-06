---
title: 使用vscode开发go语言-vscode中go语言的开发与调试环境搭建教程
date: 2016-07-27 23:50:01
tags:
- vscode
- go
category:
- go
---

- 第一步下载Go的安装包，

 > https://golang.org/project/

 这个应该没什么说的

 截止我写这篇教程时，Go的最新版本是1.6.2，本教程也是使用的此版本
 <!--more-->

- 直接全部下一步安装，如果你也是默认下一步安装完成，那你的Go应该安装在C盘的Go文件夹下

 ![vscode](/images/vscode/1.png)

- 这样Go的运行环境就安装完了，感觉智障都不会有困难的。我还写这么详细，我也是智障。。。

	 安装完了，还得配置

	 一开始，我们没有IDE，只能使用windows下面的CMD命令行运行，为了在每个路径下都可以直接运行Go命令，我们需要配置 系统环境变量的 Path

	 别告诉我不知道怎么配，复制 C:\Go\bin 到下图

	 ![vscode](/images/vscode/2.png)

	 用分号分隔。

	 接下来配置GOPATH

	 ![vscode](/images/vscode/3.png)

	 GOPATH是你的项目路径，用于运行时默认寻找Go依赖包的地址，如果学过Java，可以认为是classpath，不过Go更加依赖这个Path

	 比如图里的E:\goDemo就是我的项目存放地址，后面各种下载包也会下载到这里

	 还没完！

	 配置GOROOT!

	 ![vscode](/images/vscode/4.png)

	 就是Go的根路径，类似Java_home



- 这样整个环境算OK了，可以在CMD中试试，go version，可以查看Go的版本号
	这样说明Go已经配置好


- 写个helloworld.go吧，测试下gopath啥的，helloworld怎么写呢

	```go
	package main

	import "fmt"

	func main(){
	    fmt.Println("hello world");
	}
	```
	使用go run helloworld.go运行，打印出helloworld 就算OK了。

-  好了运行环境，已经OK了，现在来搭建IDE，我试了几款，最后选择了VSCODE，类似Sublime的一个文本编辑器，但是也是很多插件，对Go支持还是不错的，支持代码补全，提示，调试断点

	先去下载VSCODE，
	> https://code.visualstudio.com/

	一直下一步，不说了，最多改下安装路径哈。

- 安装好后，安装go插件，在vscode界面上，使用快捷键，ctrl+shift+p,呼出命令窗口，跟sublime其实快捷键都是一样的，然后敲几个install字母，就出来安装扩展的提示，选择安装扩展

 ![vscode](/images/vscode/5.png)

 然后就会出来下面这个界面，有时可能比较慢，感觉微软的服务器也不怎么快

 ![vscode](/images/vscode/6.png)

 看到Go了么，直接点他安装，然后等，有时还挺久的

 装的时候没有进度条，只有左下角，有个发亮在动的图标在告诉你，正在下载安装

 ![vscode](/images/vscode/7.png)

 等丫安装完。

 安装完以后重启。

 重启VS CODE啊，不是电脑哈~

 重启完之后并不是就都完了，真正麻烦的事来了，因为整个VSCODE其实就是依赖GO的各种工具在运行，其实他就是整合下Go的各个工具，所以他需要依赖Go的各种工具

 但是，你懂得，我们有墙，会比较难下载，经常会失败

 好了，现在看右下角

 ![vscode](/images/vscode/8.png)

 缺失了很多工具，点一下，会提示让你安装，你就点一下嘛，也不会吃亏


 ![vscode](/images/vscode/9.png)


 点一下，就告诉你，GOPATH下没有工具，玩不下去了，好了，点install，不废话

 install完，看是不是还会报，有tool找不到，如果还报，就上大招

 在命令行中执行 `"git clone https://github.com/golang/tools.git"(需要提前安装git) `，自己去拉工具的源码，其实这些工具都是一个一个的GO源码文件，编译完就成了工具

 把克隆下来的tools文件夹复制到你的GOPATH下面的，src\golang.org\x文件夹中，记得要自己新建这个文件目录，如果没有的话

 OK以后，重启VSCODE

 这时候VSCODE又会重新编译GOPATH下面的源码，然后生成一堆工具，最后会这样


 ![vscode](/images/vscode/10.png)

 debug那个文件无视，dlv现在你们也还没有

 如果不愿去拉，也可以直接下载，我的打包，直接放到对应BIN目录就行，重启

 > **[点这个可爱的链接下载(＾－＾)V](http://yaoboss.me/bin.zip "点这个可爱的链接") **

 这样，提示，补全，等功能都应该有了，但是还是没法运行，和调试



- 在命令行中执行“go get -u -v github.com/derekparker/delve/cmd/dlv”

 去拉DLV的代码，这个工具是调试用的，一样，拉下了以后，重启

 刚才我的那个BIN包已经包含dlv，你们可以直接用，一条龙！

- 现在就可以调试了

 但是要注意几点，

 第一次点调试运行的时候，会让你选择，要用什么调试环境，有node啥的选择，当然选Go拉！

 然后就会弹出一个配置文件

 ![vscode](/images/vscode/11.png)

 这个文件只要注意我圈红的地方

 这个路径，是你需要调试的main函数执行的文件的所在文件夹路径

 必须要配置，否则，默认就在你打开的那个文件路径下

 如果你不配置就会出现下面这个错误

 ![vscode](/images/vscode/12.png)

 找不到可执行的包。



**好了，最后，这样整个GO的环境搭建，已经开发调试环境，都配置完了。愉快的日狗(GO)了！**