title: BOM模型
tags:
    - JavaScript
comments: true
brief: BOM模型
date: 2017-2-24
categories:
    - JavaScript
---
# BOM模型
浏览器对象模型（Browser Object Model），BOM对象是JavaScript的核心，该对象提供了与浏览器交互相关对象结构。BOM由多个子对象组成，其核心为window对象，它是BOM的顶层对象，表示在浏览器环境中的一个全局的顶级对象。除了window对象还具有frames、navigator、history、location、screen、document(DOM)。

<!-- more -->
## window
window对象既是通过JavaScript访问浏览器窗口的一个接口,又是ECMAScript规定的Gloal对象。

window.open() (返回打开的窗口的引用,即打开窗口的window对象)
- 第一个参数:打开窗口的URL
- 第二个参数:链接的目标,相当于a标签的target,当不存在target窗口时,将会创建一个窗口,以第二个参数命名;也可使用_self、_parent、_top或_blank等具有意义的参数
- 第三个参数:设置浏览器窗口的样式,通过”,”分隔个属性,并且只有第二个窗口创建一个新窗口才有效
- 第四个参数:是否打开一个新窗口,默认为是

原窗口以及弹窗有个属性指向打开他的原始窗口opener
```js
var newWin = window.open("http://www.abc.com","newWin");
newWin.opener = null ;
```

浏览器内置程序屏蔽弹出窗口时,window.open()返回空,扩展程序阻止时会抛出错误。因此可以通过检测是否抛出异常,来判断弹窗是否被屏蔽。

其他常用的全局函数还有:(超时调用)setTimeout/clearTimeout；(间歇调用)setInterval/clearInterval；系统对话框(alert、prompt、confirm同步窗口，js执行停止)；查找打印(print、find异步窗口，js执行不停止)

## frames
对于使用框架集的页面，每一个frame都拥有自己的window对象,并保存在frames集合中。

```html
<html>
<head></head>
<frameset rows="16,*">
    <frame src="frame.html" name="topFrame">
    <frame src="anotherframe.html" name="leftFrame">
</frameset>
</html>
```

可通过索引或框架名来访问。如:`window.frames[“topFrame”]`,也可用`top.frames[“topFrame”]`进行访问
- top:指向最外层的window
- parent:父层的window
- self:始终指向window(都是window的属性)

## location
提供了与当前窗口中加载的文档有关的信息,还提供了一些导航功能。既是window对象的属性,也是document对象的属性

location对象具有以下属性：

![location对象属性](location对象属性.png)

改变浏览器位置方式：
+ assign():立即打开url,并在浏览器中生成一条记录(与给window.location设置url相同)
+ replace():立即打开url,并且不生成历史记录当前页面的历史记录
+ reload():重新加载当前页面,如果不传递true参数,并且参数无变化,从缓存中加载。
+ 通过改变location的属性,也会改变浏览器位置

## navigator
navigator对象用于识别客户端浏览器

它具有很多与客户端浏览器相关的信息，比如：
- appName 完整浏览器名
- appVersion 浏览器的版本
- cookieEnabled 表示cookie是否启用
- javaEnabled() 表示当前浏览器是否启用了Java
- language 浏览器主语言
- onLine 浏览器是否连接到英特网
- plugins 浏览器中安装的插件信息的数组
- registerContentHandler() 针对特定的MIME类型将一个站点注册为处理程序
- registerProtocolHanlder() 针对特定的协议将一个站点注册为处理程序

检测插件(使用plugins数组)
```js
//检测是否存在插件
//IE以外的插件
    function hasPlugin(name){
        name = name.toLowerCase();
        for(var i=0;i<navigator.plugins.length;i++){
            if(navigator.plugins[i].name.toLowerCase().indexOf(name)>-1){
                return true;
            }
        }
        return false;
    }
//检测IE中的插件
function hasIEPlugin(name){
    try{
        //参数name,插件对应的COM对象的标识符
        new ActiveXObject(name);
        return true;
    }catch(ex){
        return false;
    }
}
```

注册处理程序
```js
//将http://www.somereader.com注册为RSS源处理程序,%s表示RSS源URL
navigator.registerContentHandler("application/rss+xml","http://www.somereader.com?feed=%s","Some Reader");
//将http://www.somemailclient.com注册为邮件处理程序,%s表示原始请求
navigator.registerProtocolHandler("mailto","http://www.somemailclient.com?cmd=%s","Some Mail Client");
```

## history
history对象保存着用户上网的历史记录,从窗口被打开的那一刻算起。

历史记录跳转
- back():后退一页,等价于go(-1)
- forword():前进一页,等价于go(1)
- go():前进或后退任意一页
- length属性,保存着历史记录的数量。加载到窗口、标签页或框架中的第一个页面history.length等于0,有些浏览器等于1

## screen
screen对象中包含了用户显示器屏幕相关信息。通过该对象，可以访问用户显示器屏幕宽、高、色深等信息。
- colorDepth 表现颜色的位数
- height 屏幕的像素高度
- width 屏幕的像素宽度


## document
DOM可以认为是BOM的一个子集，DOM中有关文档操作相关对象，如：Node、Document、Element等DOM节点类型对象，都是做为window对象的子属性出现的。

document是window对象的了个属性，它是一个Document对象实例，表示当前窗口中文档对象。通过该对象，可以对文档和文档中元素、节点等进行操作。

## 其他
### 可视宽高
获取页面可视区域宽高

jQuery
```js
$(window).width();
$(window).height();
```

原生JS
```js
//不同浏览器下,取得页面视图大小
var clientWidth = window.innerWidth,clientHeight = window.innerHeight;
if(typeof clientWidth != "number"){
    //compatMode浏览器采用的渲染方式:BackCompact标准兼容模式关闭,CSS1Compat标准兼容模式开启
    if(document.compatMode == "CSS1Compat"){
        // 在页面指定了DOCTYPE时，需要使用这种方式来获取宽高
        clientWidth = document.documentElement.clientWidth;
        clientHeight = document.documentElement.clientHeight;
    }else{
        //有些浏览器用于保存初始的布局视图大小
        clientWidth = document.body.clientWidth;
        clientHeight = document.body.clientHeight;
    }
}
```

在页面指定了DOCTYPE时，需要使用`document.documentElement`这种方式来获取宽高，而不能使用`document.body`的方式来获取

### 文档宽高
获取整个文档的宽高

jQuery
```js
$(document).height();
$(document).width();
```

原生JS
```js
//compatMode浏览器采用的渲染方式:BackCompact标准兼容模式关闭,CSS1Compat标准兼容模式开启
if(document.compatMode == "CSS1Compat"){
    // 在页面指定了DOCTYPE时，需要使用这种方式来获取宽高
    pageWidth = document.documentElement.scrollWidth;
    pageHeight = document.documentElement.scrollHeight;
}else{
    //有些浏览器用于保存初始的布局视图大小
    pageWidth = document.body.scrollWidth;
    pageHeight = document.body.scrollHeight;
}
```

### 滚动宽高
获取滚动条到顶部或左边的宽度或高度

jQuery
```js
$(document).scrollTop();
$(document).scrollLeft();
```

原生JS
```js
//compatMode浏览器采用的渲染方式:BackCompact标准兼容模式关闭,CSS1Compat标准兼容模式开启
if(document.compatMode == "CSS1Compat"){
    // 在页面指定了DOCTYPE时，需要使用这种方式来获取宽高
    scrollHeight = document.documentElement.scrollTop;
    scrollWidth = document.documentElement.scrollLeft;
}else{
    //有些浏览器用于保存初始的布局视图大小
    scrollHeight = document.body.scrollTop;
    scrollWidth = document.body.scrollLeft;
}
```

## 参考文献
JS高程(第三版)
[JavaScript BOM对象](https://itbilu.com/javascript/js/4k9JcnZRl.html#BOM-frame)
[jQuery获取宽高](http://blog.csdn.net/jh0610y/article/details/46355833)
[js获取宽高](http://www.cnblogs.com/geektimi/p/5748664.html)