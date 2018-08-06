---
title: mysql授权远程访问
date: 2016-07-24 21:36:24
tags: 
- linux
- mysql
category:
- mysql
---

```
GRANT ALL PRIVILEGES ON *.* TO 'username'@'%' IDENTIFIED BY 'password' WITH GRANT OPTION;
```