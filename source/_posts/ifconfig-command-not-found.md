---
title: ifconfig command not found
date: 2016-07-20 22:52:46
tags:
- linux
category:
- linux
---
找不到ifconfig命令

新安装的centos7，准备配置网络设置时，使用ifconfig命令，发现居然找不到命令，command not found

问了下谷老师，看来linux也是更新了不少啊

ifconfig命令属于net-tools，但是centos7的默认minimal最小化安装中并没有安装net-tools

而且net-tools现在属于被废弃的，官方已经不推荐使用
所以有两种解决办法：
1.当然就是直接安装net-tools, yum install net-tools

2.使用 ip a，命令代替，官方也推荐这种做法
如果需要看各种包流量情况，需要更详细的信息，可以使用

```
-s (-stats, -statistics) 这个参数
ip -s addr
或者再加上人性化显示 -h
ip -s -h addr
```