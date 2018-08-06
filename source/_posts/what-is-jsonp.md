---
title: 什么是JSONP？关于前端的跨域问题
date: 2016-10-19 00:28:29
tags:
- web技术
category:
- web技术
---

> 在我来到酷狗之前，一直做游戏开发。虽然是做页游，也一样是在浏览器访问，但是和传统的做web开发，还是有着很大的区别。导致我一开始的时候，在做酷狗LIVE项目时和前端配合的不是很好，当时还让前端来给我解释为什么要使用JSONP，因为那时我还第一次听到这个名词。哈哈。

那么，到底什么是JSONP呢？

<!-- more-->

# 跨域

抛开不解释跨域问题的讨论`JSONP`，都是耍流氓。

凭胸而论，啊呸，平心而论，一开始我真的没理解为什么需要JSONP。JSONP是什么，很容易理解，但是为什么要用这种方式，我真的花了点时间才搞懂。原因就是网上大多文章就一句带过，解决跨域问题，但是没有很好的解释什么是跨域问题。像我这种对前端并不是特别擅长的人，就容易产生疑惑。


什么是跨域？最简单的解释：
> 我们部署网站都会有个域名去访问，比如 www.yaoboss.me，访问我的博客，这是我的网站的域名，也就是我的网站的域，当我在我网站域下面的页面中，要通过ajax请求去google的某个接口下面获取数据，那我访问的接口一定是http://www.google.com/xxxx/inteface/getXXX，那么谷歌接口所在的域就是，www.google.com，这样就是跨域了

最早的网景公司定的浏览器规范规定了一个`同源策略`的安全协议，这个安全协议规定，一个网页中除了特殊的某些标签，`<script>,<img>`等，可以访问跨域的资源，其他的请求禁止访问跨域的资源。也就是说像我们上面那样，使用原生的`AJAX`去请求谷歌接口的数据，是获取不到数据的，JS会报错的。我们在浏览器的`console`里面，可能会看到这样的错误，`MLHttpRequest cannot load https://www.google.com/. No 'Access-Control-Allow-Origin' header is present on the requested resource. Origin 'null' is therefore not allowed access.`


跨域的请求是一种合理的需求，我们无法避免的。在工作中，我们公司可能会有很多的域名，每个部门有自己的域名，业务线有业务线的域名。当需要互相调用时，就会有跨域问题。所以这时候就出现了`JSONP`,可以说是以一种`trick`的方式解决了跨域问题。那我们接下来就看看`JSONP`到底是什么。

# JSONP

```json

callbackFunction(["customername1","customername2"])

```

上面代码段里面就是`JSONP`格式，你看他像什么？不就是一个JS方法调用么！传递了一个数组参数！

没错，就是JS方法调用。这就是JSONP。我们就这样理解，就够了。至于什么`json padding`，不用管。术语而已，咱们就来实在的大实话。

上面就是JSONP的真容。

接下来我们说怎么用。

前面有提到，`<script></script>`标签不受跨域限制，里面的`src`属性，可以从任何地方加载js文件。这个地方就可以做文章了，其实这个标签本质上就是对目标发起一个`GET`请求，将返回值作为一段脚本代码，作用于当前域。

那我们完全可以在服务端做一个服务，返回一段拼装的JS代码，这样`script`标签获取到了，就当做JS代码执行了。

思路走到这里，我们就可以想到，像上面那样，返回一个拼装的`回调JS代码`，我们在当前域再定义一个同名函数，那这样就和一个AJAX请求一样了。请求成功就回调本地一个函数方法，并在参数里面传入请求成功的返回值。这样，就是一个`JSONP`了，也就解决了跨域问题。

下面是一个最简单的演示demo，借鉴了菜鸟教程的例子：

test.html

```
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>JSONP 实例</title>
</head>
<body>
    <div id="divCustomers"></div>
    <script type="text/javascript">
		function callbackFunction(result, methodName)
        {
            var html = '<ul>';
            for(var i = 0; i < result.length; i++)
            {
                html += '<li>' + result[i] + '</li>';
            }
            html += '</ul>';
            document.getElementById('divCustomers').innerHTML = html;
        }
	</script>
<script type="text/javascript" src="http://www.runoob.com/try/ajax/jsonp.php?jsoncallback=callbackFunction"></script>
<script src="//cdn.bootcss.com/jquery/3.1.1/jquery.min.js"></script>
<script type="text/javascript">
    
	//直接ajax请求google网站，如果你部署在google.com域之外，就会报错
	$.get("http://www.google.com/");

</script>

</body>
</html>

```

jsonp.php

```
<?php
header('Content-type: application/json');
//获取回调函数名
$jsoncallback = htmlspecialchars($_REQUEST ['jsoncallback']);
//json数据
$json_data = '["customername1","customername2"]';
//输出jsonp格式的数据
echo $jsoncallback . "(" . $json_data . ")";
?>

```

这个实验，你可以在本地分两个服务器部署，然后从一台调用另外一台。也可以在`hosts`里面配域名，模仿更真实的跨域场景。

或者最简单，就部署上面的test.html，看看效果，然后分析下，基本就可以明白`JSONP`了。


# 更好的使用JSONP

我们当然不愿意每一个请求都去写一个`script`标签，好在我们有`jquery`

我们使用`jquery`来调用`JSONP`请求将变得很简单：

```


<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>JSONP 实例</title>
    <script src="http://cdn.static.runoob.com/libs/jquery/1.8.3/jquery.js"></script>    
</head>
<body>
<div id="divCustomers"></div>
<script>

	//就是getJSON方法,更详细的用法请参考API吧
	$.getJSON("http://www.runoob.com/try/ajax/jsonp.php?jsoncallback=?", function(data) {
	    
	    var html = '<ul>';
	    for(var i = 0; i < data.length; i++)
	    {
	        html += '<li>' + data[i] + '</li>';
	    }
	    html += '</ul>';
	    
	    $('#divCustomers').html(html); 
	});
</script>
</body>
</html>

```


# 不只是JSONP

跨域的方式还有很多种，这里我们只说了JSONP这一种，最近好像还看到一种W3C支持的一种跨域方案，不过还没仔细去看，大家可以自己去搜搜