---
title: 烦人的Maven仓库
date: 2016-09-24 12:47:26
tags:
- maven
- java
category:
- java
---

> 由于众所周知那堵伟大的WALL，国内使用maven时最容易，也最烦的问题就是maven的仓库问题。时不时的大姨妈一下。没有可靠的镜像。也不知道从什么时候开始，开源中国的`maven镜像仓库`也已经是完全ping不同了，死翘翘了的感觉。


今天在家拉`spring`的源码，也是相当费劲。别看这么一个小小问题，但是很容易几个小时就耗在这上面。然而，解决这种问题，对于你的技术水平真的是一点进步都没有。sign~

今天就记录下，我花了一个小时搞的结果吧。让后面看到的人，可以5分钟搞定这个问题，我的目的就达到了。

<!-- more-->

因为镜像很难保证百分百一直稳定，所以我会一直保持更新，如果哪天我发现镜像不行了，我也会去找新的，然后更新到博客上来。

----

我选择的镜像是下面这个：

> http://uk.maven.org/maven2/

备用地址：
> http://maven.aliyun.com/nexus/content/groups/public

可以直接在浏览器里面访问这个地址，如果访问成功，那就说明还是可用的。

接下来是maven修改默认仓库地址的方法：

我选择修改的是`针对单用户生效`的方式，也就是只针对当前用户生效，这种方式会覆盖全局的设置方式

首先找到配置文件地址

我的是`window 7`系统，找到`C`盘->用户->{你的系统用户名}->.m2文件夹->settings.xml

找到`<mirrors></mirrors>`标签，在中间插入下面的代码

```xml

<mirror>
  <id>ui</id>
  <mirrorOf>central</mirrorOf>
  <name>Human Readable Name for this Mirror.</name>
 <url>http://uk.maven.org/maven2/</url>
</mirror>

```

配置完上面，所有的`jar`包都会去上面的仓库寻找拉取了

不过maven还依赖一些`plugins`，拉取`plugins`也需要去仓库，所以也需要配置镜像

在刚才的文件中，往下面找，找到`<profiles></profiles>`标签

在其中插入下面的代码

```xml
<profile>
    <id>jdk-1.7</id>
    <activation>
    <jdk>1.7</jdk>
    </activation>
    <repositories>
        <repository>
            <id>nexus</id>
            <name>local private nexus</name>
            <url>http://uk.maven.org/maven2/</url>
            <releases>
                <enabled>true</enabled>
            </releases>
            <snapshots>
                <enabled>false</enabled>
            </snapshots>
        </repository>
    </repositories>
    <pluginRepositories>
        <pluginRepository>
            <id>nexus</id>
            <name>local private nexus</name>
            <url>http://uk.maven.org/maven2/</url>
            <releases>
                <enabled>true</enabled>
            </releases>
            <snapshots>
                <enabled>false</enabled>
            </snapshots>
        </pluginRepository>
    </pluginRepositories>
</profile>

```

**需要特别注意：** 这段代码里面有`id`,`jdk`的标签，一定要改成你自己本地使用的`jdk`版本，否则，配置不能生效的，这段配置的触发是根据`jdk`版本来的

---

到此为止，配置结束。应该可以很快的拉取`repo`里的`jar`包了。

PS.

关于上面的`JDK版本`配置问题：
在`settings.xml`有段注释说明了这个问题，我一开始也没注意到，导致配置不成功。注释里举了个例子，并且做了说明：

```xml

    <!-- profile
     | Specifies a set of introductions to the build process, to be activated using one or more of the
     | mechanisms described above. For inheritance purposes, and to activate profiles via <activatedProfiles/>
     | or the command line, profiles have to have an ID that is unique.
     |
     | An encouraged best practice for profile identification is to use a consistent naming convention
     | for profiles, such as 'env-dev', 'env-test', 'env-production', 'user-jdcasey', 'user-brett', etc.
     | This will make it more intuitive to understand what the set of introduced profiles is attempting
     | to accomplish, particularly when you only have a list of profile id's for debug.
     |
     | **（This profile example uses the JDK version to trigger activation, and provides a JDK-specific repo.）** 主要就是这句话
    <profile>
      <id>jdk-1.4</id>

      <activation>
        <jdk>1.4</jdk>
      </activation>

      <repositories>
        <repository>
          <id>jdk14</id>
          <name>Repository for JDK 1.4 builds</name>
          <url>http://www.myhost.com/maven/jdk14</url>
          <layout>default</layout>
          <snapshotPolicy>always</snapshotPolicy>
        </repository>
      </repositories>
    </profile>
    -->

```