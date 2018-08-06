---
title: 将Sublime Text3添加到右键菜单中
date: 2016-08-20 16:46:27
tags:
- 开发工具
- sublime text3
category:
- 开发工具
---

> sublime text是我最喜欢的开发工具之一，也非常的强大。包括对各种格式文件的支持。对大文本文件的打开速度也非常好。还有搜索等功能，UI也是我喜欢的类型。总之爱不释手。不过新安装的sublime text，没有绑定所有文件的默认格式，也没用提供默认的鼠标右键"用Sublime text打开"支持，很不方便，每次需要拖拽文件到sublime里面。

在网上找了下，其实很简单，就是在注册表加入一些右键选项就可以了。

### 1.在`Sublime text3`的安装目录，新建一个文件，`sublime_addright.inf`


### 2.复制下面的代码，保存，退出

```
[Version]
Signature="$Windows NT$"

[DefaultInstall]
AddReg=SublimeText3

[SublimeText3]
hkcr,"*\\shell\\SublimeText3",,,"用 SublimeText3 打开"
hkcr,"*\\shell\\SublimeText3\\command",,,"""%1%\sublime_text.exe"" ""%%1"" %%*"
hkcr,"Directory\shell\SublimeText3",,,"用 SublimeText3 打开"
hkcr,"*\\shell\\SublimeText3","Icon",0x20000,"%1%\sublime_text.exe, 0"
hkcr,"Directory\shell\SublimeText3\command",,,"""%1%\sublime_text.exe"" ""%%1"""

```

或者，下载下面这个文件，直接放到`Sublime text3`的安装目录，右键选择文件，选择安装，也可以

**[这是一个可爱的下载链接](http://yaoboss.me/sublime_addright.inf)**

### 3.鼠标右键点击刚刚新建的文件，选择安装


**完成**

现在右键应该有`用Sublime text3`打开的选项了