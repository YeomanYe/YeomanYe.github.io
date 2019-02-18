title: WeUI源码分析-demo分析
tags:
    - 源码分析
    - JavaScript
comments: true
date: 2019-01-02
brief: WeUI源码分析-demo分析
categories:
    - 源码分析
---
# WeUI源码分析-demo分析

WeUI 是一套同微信原生视觉体验一致的基础样式库，由微信官方设计团队为微信 Web 开发量身设计，可以令用户的使用感知更加统一。WeUI是一套比较出众的移动端UI框架，我对比过许多同类框架，发现WeUI的star(18k)以及fork(5k)数量算是最高的。

其他框架

- [AmazeUI](https://github.com/amazeui/amazeui)：star(11.7k) fork(2.5k)
- [Mint UI](https://github.com/ElemeFE/mint-ui/):star(10.7k) fork(2.2k)
- [Pure.css](https://github.com/pure-css/pure):star(18.5k) fork(2k)

WeUI不仅仅框架本身出众，demo中页面的组织、页面组件化的方式也很值得人学习。本篇将讲解WeUI中值得人学习的部分，包括：页面组织、兼容性处理、性能优化。

<!-- more -->


## html组件化
第一个很值得学习的点是页面的组件化

demo中将页面拆分成不同的组件，然后使用如下的标签进行引入
```html
<link rel="import" href="./fragment/home.html">
```

一开始我以为rel="import"真的具有神奇的功能能够导入html片段到页面中。后来经过我认真的阅读，发现虽然确实存在rel="import"这种导入方式，但是这种方式存在兼容方面非常糟糕。而作者也并非使用这种方式导入组件。
作者真正导入组件的方式是使用gulp将该标签替换成文件中的内容，然后生成新的文件:

```js
var path = require('path');
var fs = require('fs');
var tap = require('gulp-tap');
var gulp = require('gulp');

gulp.task('build:example:html', function() {
  gulp
    .src('src/example/index.html', option)
    .pipe(
      tap(function(file) {
        var dir = path.dirname(file.path);
        var contents = file.contents.toString();
        contents = contents.replace(
          /<link\s+rel="import"\s+href="(.*)">/gi,
          function(match, $1) {
            var filename = path.join(dir, $1);
            var id = path.basename(filename, '.html');
            var content = fs.readFileSync(filename, 'utf-8');
            return (
              '<script type="text/html" id="tpl_' +
              id +
              '">\n' +
              content +
              '\n</script>'
            );
          }
        );
        file.contents = new Buffer(contents);
      })
    )
    .pipe(gulp.dest(dist))
    .pipe(browserSync.reload({ stream: true }));
});
```

可以看到`<link rel="import"/>`被替换成了`<script type="text/html">`。浏览器不会解析该标签，因此可以使用该标签作为内容的模板。不过想读取模板的内容就必须获取标签的innerHTML了。其中tap模块就起到了处理文件中内容的功能，path模块处理一些路径参数。

## history.state与hash组织整个网站
另外一个很值得学习的点是使用history.state与hash组织整个网站

demo中将所有的页面作为模板(使用`<script type="text/html">`)加载到一个文档中，如果打开下一个文档。加载对应的html模板内容覆盖到当前页面上(通过如下的样式)
```css
.page{
    top:0;
    left:0;
    right:0;
    bottom:0;
    z-index:1;
    position: absolute;
}
```

具体的实现方式是通过监听页面的hash值，如果hash值改变了，则进行相应的页面跳转。具体逻辑就是根据监听收到的hash值获取对应的模板，将模板添加到文档中即可。

这里有几个细节，如何当成真正的当成点击触发页面的效果。使浏览器中保存这条历史记录。作者使用的是state属性和replaceState方法。replaceState会要替换的state为空时新建一个state，在有state的情况下，则会替换掉state。

在老版本中是使用pushState和onpopstate的组合，改成replaceState的方式估计是为了节约资源。

```js
history.replaceState(stateObj,desc,href);
```

还有一个优化细节是当用户访问一个曾经访问过的页面时，直接将页面显示出来即可：

```js
$(window).on('hashchange', function () {
    var state = history.state || {};
    var url = location.hash.indexOf('#') === 0 ? location.hash : '#';
    var page = self._find('url', url) || self._defaultPage;
    //当堆栈中存在时，则直接显示出来
    if (state._pageIndex <= self._pageIndex || self._findInStack(url)) {
        self._back(page);
    } else {
        self._go(page);
    }
});
pageManager = {
    _back: function (config) {
            this._pageIndex --;

            var stack = this._pageStack.pop();
            if (!stack) {
                return;
            }

            var url = location.hash.indexOf('#') === 0 ? location.hash : '#';
            var found = this._findInStack(url);
            if (!found) {
                var html = $(config.template).html();
                var $html = $(html).addClass('js_show').addClass(config.name);
                $html.insertBefore(stack.dom);

                if (!config.isBind) {
                    this._bind(config);
                }

                this._pageStack.push({
                    config: config,
                    dom: $html
                });
            }

            stack.dom.addClass('slideOut').on('animationend webkitAnimationEnd', function () {
                stack.dom.remove();
            });

            return this;
        },
}
```

不得不说这种方式很适合小型站点的搭建。

## 其他
除了以上这两个重要的点之外，demo中还值得借鉴的部分有

预加载图片，减少后面加载时间
```js
function preload(){
    $(window).on("load", function(){
        var imgList = [
            "./images/layers/content.png",
            "./images/layers/navigation.png",
            "./images/layers/popout.png",
            "./images/layers/transparent.gif"
        ];
        for (var i = 0, len = imgList.length; i < len; ++i) {
            new Image().src = imgList[i];
        }
    });
}
```

android输入防遮挡
```js
function androidInputBugFix(){
        // .container 设置了 overflow 属性, 导致 Android 手机下输入框获取焦点时, 输入法挡住输入框的 bug
        // 相关 issue: https://github.com/weui/weui/issues/15
        // 解决方法:
        // 0. .container 去掉 overflow 属性, 但此 demo 下会引发别的问题
        // 1. 参考 http://stackoverflow.com/questions/23757345/android-does-not-correctly-scroll-on-input-focus-if-not-body-element
        //    Android 手机下, input 或 textarea 元素聚焦时, 主动滚一把
        if (/Android/gi.test(navigator.userAgent)) {
            window.addEventListener('resize', function () {
                if (document.activeElement.tagName == 'INPUT' || document.activeElement.tagName == 'TEXTAREA') {
                    window.setTimeout(function () {
                        document.activeElement.scrollIntoViewIfNeeded();
                    }, 0);
                }
            })
        }
    }
```

判断是否支持触摸事件，让设置点击事件的同时支持触摸事件。可使得网站同时适配移动端、PC端
```js
var supportTouch = function(){
    try {
        document.createEvent("TouchEvent");
        return true;
    } catch (e) {
        return false;
    }
}();

var _old$On = $.fn.on;

$.fn.on = function(){
    // 只扩展支持touch的当前元素的click事件
    if(/click/.test(arguments[0]) && typeof arguments[1] == 'function' && supportTouch){ 
        var touchStartY, callback = arguments[1];
        _old$On.apply(this, ['touchstart', function(e){
            touchStartY = e.changedTouches[0].clientY;
        }]);
        _old$On.apply(this, ['touchend', function(e){
            if (Math.abs(e.changedTouches[0].clientY - touchStartY) > 10) return;

            e.preventDefault();
            callback.apply(this, [e]);
        }]);
    }else{
        _old$On.apply(this, arguments);
    }
    return this;
};
```

使用animationend webkitAnimationEnd监听animation结束事件