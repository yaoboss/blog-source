---
title: "Error:java: 无效的目标发行版: 1.8"
date: 2016-09-25 23:48:34
tags:
- java
category:
- java
- maven
---

今天在家里的机器编译spring-boot的代码，跑其中一些samples的项目的时候，报下面这个错误

`Error:java: 无效的目标发行版: 1.8`

<!--more-->

我使用的IDE是`IDEA`，我本机的`JDK`版本是1.7，在把`IDEA`的编译器，和项目structure的jdk都确定设置成1.7之后，还是报这个错误，果断感觉是`maven`的问题

这个samples是一个maven项目，估计maven项目的编译都依赖他的编译插件，我在pom文件中没有找到编译插件的设置项，估计就默认是1.8了，然后我本机又没有1.8，所以就导致编译失败

```
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <configuration>
                    <source>1.7</source>
                    <target>1.7</target>
                </configuration>
            </plugin>

```

在pom文件中加入上面的maven插件配置之后解决此问题。