---
title: 'git warning: LF will be replaced by CRLF in xxxx解决办法'
date: 2016-05-01 22:49:44
tags:
- git
category:
- git
---
这两天在家改用git的命令行bash工具了，在公司一直都是用smartgit，心血来潮也玩下bash.

不过在使用的时候，好多警告真的是好烦，比如：

在 git add xx.file 的时候，提示

>warning: LF will be replaced by CRLF in XXXXXXXXXXXXXX.

大概好像是换行符转换的问题，网上搜了下可以直接关闭这种警告，这样干：

>it config core.autocrlf  false

然后就不会在有之前的那个警告啦。