---
title: ElasticSearch2.3.2十分钟上手
date: 2016-12-24 21:34:27
tags:
- ElasticSearch
category:
- ElasticSearch
---


# ElasticSearch2.3.2十分钟上手

> 工作以来遇到很多次需要使用到ElasticSearch，主要用来做一些需要接近实时获取到查询结果的需求，或者是一些在mysql无法处理的复杂查询的非常大量级的数据，根据经验来说，mysql单表数据达到>5千万，想要在ms级查询出索引优化不是很好的数据，就比较难了。而ES是可以轻松做到的。当然这只是一个经验之谈。

<!-- more -->

## 0x00

ES的文档写的真的很好，英文稍微还可以的人，都可以直接去看英文，不是很难理解。章节也分的好清晰，可以很容易找到。要说不好的地方，可能也就是从官网找的话，页面目录层级比较深，有时候会不太好找。我这里写的内容，主要是作为我自己多次间隔很长时间，重新使用ES的一个快速回忆记录。这个十分钟可以快速帮助你，也帮助我自己找回ES的最基础概念和使用的记忆。说实话我的记性真的是不怎么好。

当然你没接触过ES，也是没有问题的，这篇文章可以从安装到使用，一步一步教你上手。

我个人是使用`JAVA语言`做开发的，ES也支持各种客户端API，但是这篇文章我都使用`JAVA`和标准`HTTP RESTFUL`做例子。



## 下载安装

elassticsearch包含好多产品，和spring一样，下面这个是elasticsearch的链接

官网：https://www.elastic.co/products/elasticsearch


下载地址：https://www.elastic.co/downloads/elasticsearch

windows下选择zip包，linux就tar包

其实文件都是一样的，都包含`bat`也包含`sh`脚本

只不过tar包在linux下解压比较方便

## 启动

ES就像`mysql`一样，也类似一个数据库服务，我们要使用需要先启动

在bin目录下，`elasticsearch.bat`使用这个脚本启动

linux是`elasticsearch`

这样会以默认的端口启动，`http`访问端口是9200，`socket`访问端口是9300


测试是否启动成功：

`http://127.0.0.1:9200/`

成功启动，可以看到下面这些信息

```

{
  "name" : "DEV_10_16_6_18",
  "cluster_name" : "elk_dev",
  "version" : {
    "number" : "2.3.2",
    "build_hash" : "b9e4a6acad4008027e4038f6abed7f7dba346f94",
    "build_timestamp" : "2016-04-21T16:03:47Z",
    "build_snapshot" : false,
    "lucene_version" : "5.5.0"
  },
  "tagline" : "You Know, for Search"
}

```

## 端口问题

ES会对外提供两个端口的服务：HTTP端口，socket端口

HTTP端口可以在配置文件中使用


## 基本概念

启动成功了，我们还需要知道一些基础概念

**index**:`索引`，ES的顶级存储单位，我们所有的数据都必须存储到一个index中，如果熟悉mysql，我们可以认为index就是mysql中的一个`database`，我们要使用mysql，我们先要建一个库，ES里是先要建一个index

**type**:`类型`，索引下的存储单位，一个index下可以存在任意多的type，对应mysql中，就想一个database下的表，但是这个表结构并不是固定的，比如都叫`book`的type不一定都要有`name`这个字段。但是为了不反人类，最好不要这么设计，还是统一type的结构会比较好

**shard**:`分片`，ES是个分布式的引擎，数据是分片存储的，每个index都分片存储在不同的shard下面，默认启动是5个shard

**replica**：`拷贝`，为了保证系统的可用性，ES的每个shard还有一个replica，相当于每份数据都有一份备份

**http restful API**:ES提供的基于HTTP协议的，restful风格的API，可用直接在浏览器调用（但是浏览器只支持get请求，其他post,put需要使用插件），或者也可以在linux上使用`curl`访问，非常方便

**JAVA API**：ES就是使用JAVA开发的，所以和JAVA集成是最方便的，提供了非常完善的JAVA API以进行各种查询，聚合调用，如果你的项目使用JAVA的话，那就可以直接使用JAVA API直接访问ES服务，它和使用HTTP访问的区别，主要是基于协议不太一样，JAVA API直接建立一个socket连接到某个节点上，建立一个`transport`进行访问数据

## 基本操作 CRUD 增删改查

```
// 增或改

curl -XPUT 'http://127.0.0.1:9200/twitter/tweet/1' -d '
{
    "user": "kimchy",
    "postDate": "2009-11-15T13:12:00",
    "message": "Trying out Elasticsearch, so far so good?"
}'

// 查
curl -XGET 'http://127.0.0.1:9200/twitter/tweet/1?pretty=true'

// 删
curl -XDELETE 'http://127.0.0.1:9200/twitter/tweet/1?pretty=true'


```

## 搜索

```
//获取用户名为kimchy的tweet
curl -XGET 'http://127.0.0.1:9200/twitter/tweet/_search?q=user:kimchy&pretty=true'

//获取twitter/tweet下面的所有数据，默认只会显示前十条，或者前5条
curl -XGET 'http://127.0.0.1:9200/twitter/tweet/_search?pretty=true'

```

注意：

ES的搜索，最大只能搜索前2W条数据，如果需要搜索2W条以后的数据，需要使用到scroll

也就是说，在ES里面，2W条以内可以使用from,size来分页查询，但是超出2W条就不行了，而且是from+size<=2W,超出就会报错，在我另一篇文章里有说明

## 彩蛋

最后介绍一个神器，写ES的查询语句，复杂的话是很蛋疼的，需要花比较多时间，还不一定能写对，但是大家对`sql语句`一定都很数据，那下面就有一个工具，可以把`sql语句`转换成对于的ES查询语句，爽飞！！

名字叫：**Elasticsearch-sql**

地址：https://github.com/NLPchina/elasticsearch-sql
