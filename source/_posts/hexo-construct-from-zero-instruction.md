---
title: 史上最简单hexo博客搭建教程-4条命令搞定hexo！！
date: 2016-07-27 00:31:35
tags:
- hexo
- 博客
category:
- 博客
---


**四条命令搞定HEXO!!!**
```
npm install -g cnpm --registry=https://registry.npm.taobao.org

cnpm install nrm -g

nrm use taobao

npm install -g hexo-cli
```
<!--more-->

安装git和nodejs

git我本机已经装了

nodejs直接官网下载，各种下一步

使用hexo自带的命令安装超级慢，而且完全进行不下去

搞了一早上，了解了下npm，找到了淘宝的镜像，使用淘宝镜像安装成功

淘宝镜像直接google搜就有了，有安装教程，一条命令的事

`npm install -g cnpm --registry=https://registry.npm.taobao.org`

最后把`npm`换成`cnpm`就行了

安装hexo

`cnpm install -g hexo-cli`

使用了`cnpm`，hexo是安装成功了，但是在使用hexo时，`hexo init`命令执行又卡死

开了VPN还是继续卡死

猜测还是由于在使用默认的`npm`库，速度极慢导致的

然后就找到了，`nrm`,神器！简直了！

```
nrm 是一个 NPM 源管理器，允许你快速地在如下 NPM 源间切换：

npm
cnpm
strongloop
european
australia
nodejitsu
taobao
```

`npm install nrm -g`，安装`nrm`

`nrm use taobao`，切到淘宝的npm镜像

`nrm test`看各个节点npm的速度

切换到淘宝的npm之后，`hexo init`总算成功了！！

> **INFO  Start blogging with Hexo!**

看到这句话，简直感动。

在`hexo init`的目录下，执行`hexo server`命令启动hexo服务，cmd显示已经启动成功，默认是**4000**端口，直接在`http://localhost:4000/`访问

然而并没有什么卵用，没有反应，有点奇怪

想了下，猜是不是端口被占用了

直接改成`hexo server -p 8080` 换成8080启动，访问成功了

**hexo的服务这里有点坑，端口被占用了，居然都不报错，还显示启动正常**


**错误：**

```
npm ERR! Windows_NT 6.1.7601
npm ERR! argv "D:\\nodejs\\node.exe" "D:\\nodejs\\node_modules\\npm\\bin\\npm-cli.js" "install" "--production"
npm ERR! node v4.4.7
npm ERR! npm  v2.15.8

npm ERR! shasum check failed for C:\Users\ji\AppData\Local\Temp\npm-4836-c38b7b62\r.cnpmjs.org\core-js\download\core-js-1.2.7.tgz
npm ERR! Expected: 652294c14651db28fa93bd2d5ff2983a4f08c636
npm ERR! Actual:   406449c7d0bd5bdbbaf0cb21cf233a20d53cc0b3
npm ERR! From:     http://r.cnpmjs.org/core-js/download/core-js-1.2.7.tgz
npm ERR!
npm ERR! If you need help, you may report this error at:
npm ERR!     <https://github.com/npm/npm/issues>

npm ERR! Please include the following file with any support request:
npm ERR!     E:\hexo\blog\npm-debug.log
WARN  Failed to install dependencies. Please run 'npm install' manually!

```
不能使用`cnpm`的源，`cnpm`下载的包貌似有问题，checksum对不上，切换成`taobao`的就OK，可以解决这个问题



然后就是安装主题了

我选择了`NEXT`主题

> http://theme-next.iissnan.com/

我喜欢简洁风格，这个主题第一眼就看上了，而且文档写的非常不错，很详细，作者还是个逗逼

安装主题，直接安装这个主题的教程安装就可以了，很简单

在你的blog目录下，使用下面命令：

`git clone https://github.com/iissnan/hexo-theme-next themes/next`

git会clone `next`主题的文件到themes下面

等clone结束，next主题就安装完了

然后还需要到`blog`下的`_config.yml`文件里面，把theme这个参数改成next
`theme: next`

直接启动hexo，就可以看到next主题安装成功了

至此，hexo的博客搭建就结束了

鼓掌！！撒花！！

***以上。***