---
title: ElasticSearch2.3.2报错NoNodeAvailableException
date: 2016-12-24 21:37:06
tags:
- ElasticSearch
- java
category:
- ElasticSearch
---


# ElasticSearch2.3.2报错NoNodeAvailableException

## elasticsearch版本

版本：2.3.2

JAVA客户端：2.3.2

服务器环境：centos6.3

## 错误描述

使用java的client`transport`方式连接ES，报以下错误：


```


12:56:47.761 [main] WARN  org.elasticsearch.client.transport - [Curtis Connors] node {#transport#-1}{10.16.6.18}{10.16.6.18:9300} not part of the cluster Cluster [elasticsearch], ignoring...
Disconnected from the target VM, address: '127.0.0.1:20962', transport: 'socket'
Exception in thread "main" NoNodeAvailableException[None of the configured nodes are available: [{#transport#-1}{10.16.6.18}{10.16.6.18:9300}]]
	at org.elasticsearch.client.transport.TransportClientNodesService.ensureNodesAreAvailable(TransportClientNodesService.java:290)
	at org.elasticsearch.client.transport.TransportClientNodesService.execute(TransportClientNodesService.java:207)
	at org.elasticsearch.client.transport.support.TransportProxyClient.execute(TransportProxyClient.java:55)
	at org.elasticsearch.client.transport.TransportClient.doExecute(TransportClient.java:288)
	at org.elasticsearch.client.support.AbstractClient.execute(AbstractClient.java:359)
	at org.elasticsearch.action.ActionRequestBuilder.execute(ActionRequestBuilder.java:86)
	at org.elasticsearch.action.ActionRequestBuilder.execute(ActionRequestBuilder.java:56)
	at com.kugou.fanxing.admin.TestElasticSearch.main(TestElasticSearch.java:33)
	
```

<!-- more -->

连接代码如下：

> 连接的代码为ElasticSearch官网文档给的例子，只是加上了构造query语句，原代码地址为 https://www.elastic.co/guide/en/elasticsearch/client/java-api/2.3/transport-client.html

```java

package demo;

import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.client.Client;
import org.elasticsearch.client.transport.TransportClient;
import org.elasticsearch.common.settings.Settings;
import org.elasticsearch.common.transport.InetSocketTransportAddress;
import org.elasticsearch.index.query.QueryBuilders;

import java.net.InetAddress;
import java.net.UnknownHostException;

/**
 * Created by williamyao on 2016/12/15.
 */
public class TestElasticSearch {

	public static void main(String[] args) {
		try {

			Settings settings = Settings.settingsBuilder()
					.put("cluster.name", "elk_dev").put("client.transport.sniff", true).build();
			Client client = TransportClient.builder().
			// 就是这个setting,一开始忘记set进来
			//.settings(settings)
			build()
					.addTransportAddress(new InetSocketTransportAddress(InetAddress.getByName("10.16.6.18"), 9300));

			long startTime = 1481644800000L;
			long endTime = 1481731200000L;

			SearchResponse sr = client.prepareSearch()
					.setQuery(QueryBuilders.rangeQuery("ts").from(startTime).to(endTime))
					.execute().actionGet();
			sr.getHits().hits();
			client.close();
		} catch (UnknownHostException e) {
			e.printStackTrace();
		}
	}
}


```

## 排错思路

说实话，好久没用ES，很多都又忘记了，真是学一次忘一次，挫败感极强，再加上这个错当时被情绪影响严重，导致我浪费不少时间

1. 

看到这个错，首先是确认`ES`的服务到底正不正常，可以通过下面的请求：

> http://127.0.0.1:9200/

可以看到ES的版本信息，集群名字，那就说明ES服务倒没什么问题

2. 

接下来，我选择去查看`9300`端口是不是有监听，因为刚才是用http服务的端口查看的，使用的是`9200`端口，而JAVA是连接socket端口的，也就是9300，只要是socket服务，那telnet肯定是万能的，直接telnet验证

> telnet 10.16.6.18 9300

这时候我发现不通，一连就被断开，这个是让我最误导的地方

去查看ES启动日志，发现有成功`bound`到9300端口日志，但是telnet就是不通

3.

这时候我选择去下载一个2.3.2的ES，放到我本地运行，看下是不是可以telnet通，代码是不是可以连接上，结果是可以的，没问题

4.

因为我本地是windows，怕环境不同而无法重现问题，我又去线上机器，外网线上跑的相同版本ES，telnet试下，发现也是没问题！

5.

这样就比较蛋疼了，只能是认为那台测试虚拟机有问题了，这个问题就比较难查了，但这时候，我突然想到一个点，读文档的时候有个细节

> Note that you have to set the cluster name if you use one different than "elasticsearch"

这时候我才想起去检查下我的代码，看下我的clustername是不是设置对了，才发现，clustername是对了，但是setting没有set到TransportClient里面

都是泪啊！！！！！低级失误！！！查了我这么久！！！！！


## 总结

ES的问题有时候真的是挺难查的，特别是当自己写代码不仔细时，这种问题也是真的蛋疼

当然也和我好久没用ES有关系

写代码这东西，有时候也真是那句话，`无他，但手熟尔`

还是要沉下心去排查，不能浮躁，当一个小时都找不到问题时，人会变得很燥，这时候很多细节都容易被忽略


## 彩蛋

```
13:26:51.323 [elasticsearch[Vibro][generic][T#2]] INFO  org.elasticsearch.client.transport - [Vibro] failed to get local cluster state for {#transport#-1}{10.16.6.18}{10.16.6.18:9200}, disconnecting...
org.elasticsearch.transport.ReceiveTimeoutTransportException: [][10.16.6.18:9200][cluster:monitor/state] request_id [0] timed out after [5001ms]
	at org.elasticsearch.transport.TransportService$TimeoutHandler.run(TransportService.java:679) [elasticsearch-2.3.2.jar:2.3.2]
	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1142) [na:1.8.0_45]
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:617) [na:1.8.0_45]
	at java.lang.Thread.run(Thread.java:745) [na:1.8.0_45]
13:26:51.323 [elasticsearch[Vibro][generic][T#2]] DEBUG org.elasticsearch.transport.netty - [Vibro] disconnecting from [{#transport#-1}{10.16.6.18}{10.16.6.18:9200}] due to explicit disconnect call
13:26:51.326 [elasticsearch[Vibro][management][T#1]] DEBUG org.elasticsearch.transport.netty - [Vibro] connected to node [{#transport#-1}{10.16.6.18}{10.16.6.18:9200}]
Disconnected from the target VM, address: '127.0.0.1:32427', transport: 'socket'
Exception in thread "main" NoNodeAvailableException[None of the configured nodes are available: [{#transport#-1}{10.16.6.18}{10.16.6.18:9200}]]
	at org.elasticsearch.client.transport.TransportClientNodesService.ensureNodesAreAvailable(TransportClientNodesService.java:290)
	at org.elasticsearch.client.transport.TransportClientNodesService.execute(TransportClientNodesService.java:207)
	at org.elasticsearch.client.transport.support.TransportProxyClient.execute(TransportProxyClient.java:55)
	at org.elasticsearch.client.transport.TransportClient.doExecute(TransportClient.java:288)
	at org.elasticsearch.client.support.AbstractClient.execute(AbstractClient.java:359)
	at org.elasticsearch.action.ActionRequestBuilder.execute(ActionRequestBuilder.java:86)
	at org.elasticsearch.action.ActionRequestBuilder.execute(ActionRequestBuilder.java:56)
	at com.kugou.fanxing.admin.TestElasticSearch.main(TestElasticSearch.java:33)

```

如果连接端口写错，错误的使用了`http`的端口，最后也会报`NoNodeAvailableException`,但是他会先报个5S超时

如果看到莫名其妙的超时，请检查端口是不是写错了

啊嘻嘻嘻~