---
title: 配置安装PHP开发环境，使用NGINX和PHP-FPM
date: 2016-10-30 15:26:43
tags:
- php
- web
category:
- php
---

> 虽然不是专门做php开发的，但是偶尔也会用到一下php，这时候有一个稳定的php开发环境还是挺重要的。而且我又是一个比较有技术洁癖的人，直接什么打包好的，一键安装的东西，WAMP之类的工具，我实在是不怎么喜欢用。最后还是选择花些时间，了解下PHP，了解下nginx结合php的运行方式，什么是CGI，什么是fast-cgi，什么是php-fpm。

<!-- more -->

# 名词解释

首先php本身，一开始也是一个解释型语言，也就是说，php的解释器会对于php的代码一行一行进行解释，然后返回结果。

我们到php的官方网站下载下来的php，包含了php运行需要的，核心程序。里面会有类似于`jdk`里面的java.exe，这样的程序，php下面叫php.exe（感觉我自己也是在废话）。（当然，我现在指的是windows平台下）

使用`php.exe`就可以解释运行php代码。不过问题来了，我们使用PHP都是在`web`环境，用来处理`http`请求，用这个php.exe怎么处理http请求。这时候就要说到`CGI`这个东西了。`公共网关接口`，定义了web请求应该如何交互，换句话说，实现了这个接口，就可以处理网络的HTTP请求。PHP下面里面的`php-cgi.exe`就实现了这个接口，也就可以处理web请求了。这个程序也像一个服务器，监听在某个端口，等着web服务器，比如`nginx`，接收到web请求，就转发给`php-cgi`去处理。处理完，返回结果给web服务器。这样整个web请求，对于`.php`后缀的web请求，就处理完了。对于`.html,js,css`，这些请求是不会转发过来的，这些静态资源请求在web服务器就已经处理完了。

那知道了`php-cgi`是什么了，那`fast-cgi`又是什么呢？`php-cgi`实现了`cgi`接口，可以处理web请求，但是cgi进程，同时只能处理一个web请求，被占用了，那后面的web请求全都阻塞了。这明显不行啊。后来就出现了`fast-cgi`，一种新的网关接口，这种网关接口使用一个总的`管家进程`来给手下的工作进程转发请求，实际处理全部交给手下的工作进程去处理，只要资源足够，可以起无数个工作进程，当然并发能力也就上去了。`PHP-FPM`就是实现了这个模式和接口，在某年某月某日，（具体日期参考官网）已经被php官方接纳为官方的一种实现。简单来说就是，用`php-fpm`可以提供web请求的并发处理数。

> 温馨提示：对于windows版本的php，只有php-cgi，没有php-fpm。（不知道是不是这个php-cgi就是fpm，没查到什么资料，我只能认为没有）所以生产环境，还是建议上linux的。

# PHP安装

## windows

这个不说了，直接官网下载，启动使用`./php-cgi.exe -b :9000`，让cgi启动，绑定在9000端口

## linux

可以选择yum安装，一条命令搞定。但是那样安装下来，最后文件夹路径都是默认的，我不怎么喜欢，还是自己编译比较好。

wget拉源码包，解压

安装命令：
`./configure --prefix=/usr/local/php5 --enable-fpm --with-mysql`

报错的话，都是依赖没有，缺什么yum装什么就可以了

看到下面的图，就安装成功了

![php安装成功](/images/配置安装PHP开发环境/1.png)

打开 php.ini:
vim /usr/local/php/php.ini

定位到 cgi.fix_pathinfo= 并将其修改为如下所示：
cgi.fix_pathinfo=0

# 安装nginx

## windows

也是一样，直接下载，找到`nginx.exe`，在命令行`./nginx.exe`,就可以启动了

## linux

也是下载源码包，缺什么依赖就用yum装什么依赖

安装命令：
`./configure --prefix=/usr/local/nginx --with-http_ssl_module`


nginx配置示例：
```
    server {
        listen       8080;
        server_name  localhost;

        location / {
            root   html;
            index  index.html index.htm;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

        location ~ \.php$ {
            root           html;
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
            include        fastcgi_params;
        }
    }

```

fastcgi_param  SCRIPT_FILENAME 一定要把/scripts,改成$document_root,否则会出现找不到文件,404错误。