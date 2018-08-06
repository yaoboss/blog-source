---
title: webpack configuration has an unknown property 'babel'. These properties are valid
date: 2017-07-17 00:42:13
tags:
- 前端
category:
- 前端
---

在本地编译搭建网上的一个开源项目，启动前端的server时，一直无法启动成功，报标题这个错误。因为对大前端实在是不太熟悉，百度还是花了点时间的，在这里把这错误记录下，以免以后再碰到，特别是这种坑爹的版本问题。

<!--more-->

开源的这个项目是使用node的npm直接启动server的，这个启动方式也给我造成了一定困扰，一直也只是知道Node，知道npm，但是也都只是执行命令，这次报错了，就懵逼了。

根据那个项目的指南，是直接npm的各种模块install好了以后，就直接 `npm run server` 启动就行了，我直接运行以后，系统无情的给了我下面这些信息：

```
0 info it worked if it ends with ok
1 verbose cli [ 'D:\\nodejs\\node.exe',
1 verbose cli   'D:\\nodejs\\node_modules\\npm\\bin\\npm-cli.js',
1 verbose cli   'run',
1 verbose cli   'server' ]
2 info using npm@2.15.8
3 info using node@v4.4.7
4 verbose run-script [ 'preserver', 'server', 'postserver' ]
5 info preserver web@1.0.0
6 info server web@1.0.0
7 verbose unsafe-perm in lifecycle true
8 info web@1.0.0 Failed to exec server script
9 verbose stack Error: web@1.0.0 server: `webpack-dev-server --content-base html  --hot --progress --colors`
9 verbose stack Exit status 1
9 verbose stack     at EventEmitter.<anonymous> (D:\nodejs\node_modules\npm\lib\utils\lifecycle.js:217:16)
9 verbose stack     at emitTwo (events.js:87:13)
9 verbose stack     at EventEmitter.emit (events.js:172:7)
9 verbose stack     at ChildProcess.<anonymous> (D:\nodejs\node_modules\npm\lib\utils\spawn.js:24:14)
9 verbose stack     at emitTwo (events.js:87:13)
9 verbose stack     at ChildProcess.emit (events.js:172:7)
9 verbose stack     at maybeClose (internal/child_process.js:827:16)
9 verbose stack     at Process.ChildProcess._handle.onexit (internal/child_process.js:211:5)
10 verbose pkgid web@1.0.0
11 verbose cwd F:\githubRepo\apiManager\web
12 error Windows_NT 6.1.7601
13 error argv "D:\\nodejs\\node.exe" "D:\\nodejs\\node_modules\\npm\\bin\\npm-cli.js" "run" "server"
14 error node v4.4.7
15 error npm  v2.15.8
16 error code ELIFECYCLE
17 error web@1.0.0 server: `webpack-dev-server --content-base html  --hot --progress --colors`
17 error Exit status 1
18 error Failed at the web@1.0.0 server script 'webpack-dev-server --content-base html  --hot --progress --colors'.
18 error This is most likely a problem with the web package,
18 error not with npm itself.
18 error Tell the author that this fails on your system:
18 error     webpack-dev-server --content-base html  --hot --progress --colors
18 error You can get information on how to open an issue for this project with:
18 error     npm bugs web
18 error Or if that isn't available, you can get their info via:
18 error
18 error     npm owner ls web
18 error There is likely additional logging output above.
19 verbose exit [ 1, true ]

```

没办法只能耐心去看看，一开始使用error里面的错误直接去百度，但是没找到什么有用得消息，但是看起来好像是执行`webpack-dev-server --content-base html  --hot --progress --colors` 这个命令失败了，只能先放下这个，先去看了下npm的run server是啥原理

还好这个也比较简单，npm的`run`也就是直接在`package.json`里面写了两句脚本，`server`就是命令的名字，这样就直接找到`package.json`，找到这个命令`server`，
确实server就是运行的：`webpack-dev-server --content-base html  --hot --progress --colors`

找到这里以后，那就直接把这个命令放到命令行里运行试下，试过以后，报了下面这些错误：

```
webpack-dev-server --content-base html  --hot --progress --colors
Invalid configuration object. Webpack has been initialised using a configuration object that does not match the API schema.
 - configuration has an unknown property 'babel'. These properties are valid:
   object { amd?, bail?, cache?, context?, dependencies?, devServer?, devtool?, entry, externals?, loader?, module?, name?, node?, output?, performance?, plugins?, profile?, recordsInputPath?, recordsOutputPath?, recordsPath?, resolve?, resolveLoader?, stats?, target?, watch?, watchOptions? }
   For typos: please correct them.
   For loader options: webpack 2 no longer allows custom properties in configuration.
     Loaders should be updated to allow passing options via loader options in module.rules.
     Until loaders are updated one can use the LoaderOptionsPlugin to pass these options to the loader:
     plugins: [
       new webpack.LoaderOptionsPlugin({
         // test: /\.xxx$/, // may apply this only for some modules
         options: {
           babel: ...
         }
       })
     ]
 - configuration.resolve.extensions[0] should not be empty.

```

这个错误就比较容易找了，直接复制关键信息，一下就百度到原因了，**webpack2**不再支持这种自定义命名的模式，虽然我也完全不懂这里面啥模式，反正那2不支持，那我就直接换**1**吧

直接`npm uninstall -g webpack-dev-server`卸载掉现有的模块

安装`npm install webpack-dev-server@1.*` 指定1版本的wenpack

OK，齐活！


嘻嘻。美滋滋。༺王者༻