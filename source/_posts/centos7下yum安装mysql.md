---
title: centos7下yum安装mysql
date: 2016-04-2 22:52:54
tags: 
- linux
- mysql
- centos
category: linux
---

我的博客部署的服务器是centos7，centos7中默认不包含mysql的安装文件

就算有好像也是一个很老的版本

可以根据下面的步骤安装mysql

<!-- more-->

CentOS 7的yum源中貌似没有正常安装mysql时的mysql-sever文件，需要去官网上下载

```
# wget http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm
# rpm -ivh mysql-community-release-el7-5.noarch.rpm
# yum install mysql-community-server
```
成功安装之后重启mysql服务
```
# service mysqld restart
```
初次安装mysql是root账户是没有密码的
设置密码的方法
```
# mysql -uroot
mysql> set password for ‘root’@‘localhost’ = password(‘mypasswd’);
mysql> exit
```
搞定！