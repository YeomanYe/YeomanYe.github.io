title: dojo
tags:
    - 前端
comments: true
brief: dojo起步
categories:
    - 前端
---

# dojo起步
## 简介
dojo是前端js的一个框架,支持js异步加载机制,对js的语句进行了优化，还提供打包工具可以优化JS代码，还提供了所有的UI组件，支持IE6以上的浏览器。dojo解决了企业级开发中大量加载JS导致的浏览器崩溃问题。
<!-- more -->

## Getting Started
### Hello Dojo
#### 模块的使用

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Tutorial: Hello Dojo!</title>
</head>
<body>
    <h1 id="greeting">Hello</h1>
    <!-- load Dojo -->
    <!-- 此处只是加载dojo的异步加载模块,包括require,define两个全局函数 -->
    <script src="//ajax.googleapis.com/ajax/libs/dojo/1.10.4/dojo/dojo.js"
            data-dojo-config="async: true"></script>

    <script>
        require([
            <!-- dom操作相关的模块 -->
            'dojo/dom',
            'dojo/dom-construct'
            <!-- 异步加载模块，使用回调函数的机制 -->
        ], function (dom, domConstruct) {
            var greetingNode = dom.byId('greeting');
            domConstruct.place('<em> Dojo!</em>', greetingNode);
        });
    </script>
</body>
</html>
```

#### 模块的定义(参考路径是dojo的根目录)

```js
define([
    'dojo/dom'
], function(dom){

    var oldText = {};

    return {
        setText: function (id, text) {
            var node = dom.byId(id);
            oldText[id] = node.innerHTML;
            node.innerHTML = text;
        },

        restoreText: function (id) {
            var node = dom.byId(id);
            node.innerHTML = oldText[id];
            delete oldText[id];
        }
    };
});
```

#### 组合使用CDN模块与自定义模块
```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Tutorial: Hello Dojo!</title>
</head>
<body>
    <h1 id="greeting">Hello</h1>
    <!-- configure Dojo -->
    <script>
        var dojoConfig = {
            async: true,
            //配置自定义的路径
            packages: [{
                name: "demo",
                location: location.pathname.replace(/\/[^/]*$/, '') + '/demo'
            }]
        };
    </script>
    <!-- load Dojo -->
    <script src="//ajax.googleapis.com/ajax/libs/dojo/1.10.4/dojo/dojo.js"></script>

    <script>
        require([
            'demo/myModule'
        ], function (myModule) {
            myModule.setText('greeting', 'Hello Dojo!');

            setTimeout(function () {
                myModule.restoreText('greeting');
            }, 3000);
        });
    </script>
</body>
</html>
```

#### 等待DOM加载

```js
require([
    'dojo/dom',
    //domReady为插件,通过模块标识符后带"!"来激活，
    //dom加载完毕才执行回调。
    'dojo/domReady!'
], function (dom) {
    var greeting = dom.byId('greeting');
    greeting.innerHTML += ' from Dojo!';
});
```

### 使用dojoConfig配置dojo
dojoConfig相当于将配置发送到服务器上，服务器接收参数后定制模块。配置参数是在dojo/_base/config下。dojoConfig必须写在require前。
dojoConfig两种配置方式:

```html
<!-- 一:使用全局变量dojoConfig -->
<!-- set Dojo configuration, load Dojo -->
<script>
    dojoConfig= {
        has: {
            "dojo-firebug": true
        },
        parseOnLoad: false,
        foo: "bar",
        async: true
    };
</script>
<script src="//ajax.googleapis.com/ajax/libs/dojo/1.10.4/dojo/dojo.js"></script>

<script>
// Require the registry, parser, Dialog, and wait for domReady
require(["dijit/registry", "dojo/parser", "dojo/json", "dojo/_base/config", "dijit/Dialog", "dojo/domReady!"]
, function(registry, parser, JSON, config) {
    // Explicitly parse the page
    parser.parse();
    // Find the dialog
    var dialog = registry.byId("dialog");
    // Set the content equal to what dojo.config is
    dialog.set("content", "<pre>" + JSON.stringify(config, null, "\t") + "```");
    // Show the dialog
    dialog.show();
});
</script>

<!-- and later in the page -->
<div id="dialog" data-dojo-type="dijit/Dialog" data-dojo-props="title: 'dojoConfig / dojo/_base/config'"></div>



<!-- 二:写在script标签中 -->
<script src="//ajax.googleapis.com/ajax/libs/dojo/1.10.4/dojo/dojo.js"
        data-dojo-config="has:{'dojo-firebug': true}, parseOnLoad: false, foo: 'bar', async: 1">
</script>
```

#### 使用has()配置特性

```js
 has: {
            //启用firebug lite,chrome中的firebug调试插件
            "dojo-firebug": true,
            "dojo-debug-messages": true,
            "dojo-amd-factory-scan": false
        }
``` 

#### 加载配置
```json
//配置异步加载的基本url
baseUrl: "/js",
//配置包名和位置
packages: [{
        name: "myapp",
        location: "/js/myapp"
    }],
//使用dojo代表dojo16
map: {
        dijit16: {
            dojo: "dojo16"
        }
    },

//定制模块到不同的路径
packages: [
        "package1",
        "package2"
    ],
    paths: {
        package1: "../lib/package1",
        package2: "/js/package2"
    }
//等价于
 packages: [
        { name: "package1", location: "../lib/package1" },
        { name: "package2", location: "/js/package2" }
    ],
//是否异步加载
async: true,
//dojo加载完毕就开始加载
deps: ["dojo/parser"],
//当文档和deps加载完毕后，使用dojo/parser模块进行解析
parseOnLoad: true,
//deps中的加载完毕后执行
callback: function(parser) {
        // Use the resources provided here
    },
//发出模块请求后的等待时间
waitSeconds: 5,
//不使用缓存策略
cacheBust: true
```

#### 其他的配置对象
其他模块中使用的配置对象,主要是dojox,dijit。
- Dijit Editor
allowXdRichTextSave
- dojox GFX
dojoxGfxSvgProxyFrameUrl, forceGfxRenderer, gfxRenderer
- dojox.html metrics
fontSizeWatch
- dojox.io transports and plugins
xipClientUrl, dojoCallbackUrl
- dojox.image
preloadImages
- dojox.analytics plugins
sendInterval, inTransitRetry, analyticsUrl, sendMethod, maxRequestSize, idleTime, watchMouseOver, sampleDelay, targetProps, windowConnects, urchin
- dojox.cometd
cometdRoot
- dojox.form.FileUploader
uploaderPath
- dojox.mobile
mblApplyPageStyles, mblHideAddressBar, mblAlwaysHideAddressBar, mobileAnim, mblLoadCompatCssFiles

## 参考链接:
[Hello Dojo!](https://dojotoolkit.org/documentation/tutorials/1.10/hello_dojo/index.html)
[Configuring Dojo](https://dojotoolkit.org/documentation/tutorials/1.10/dojo_config/index.html)