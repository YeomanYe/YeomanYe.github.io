title: zepto源码分析-主体架构
tags:
    - zepto源码分析
    - JavaScript
comments: true
date: 2017-12-17
brief: 主体架构
categories:
    - 源码分析
---
Zepto是一个轻量级的针对现代高级浏览器的JavaScript库， 它与jquery有着类似的api。 因Zepto的轻量性、与JQ的相似性以及好用的移动事件(tap、swipe、doubleTap等)的封装，使得Zepto移动端开发中有着不少的应用场景。分析的版本是zepto当前的最新版本v1.2.0

<!-- more -->
zepto将整个库的功能拆分到了许多模块中，便于减小体积。无论开发者选用哪一个模块core模块是必不可少的。因此也必从core开始分析源码。

从github上下载源码后，打开src文件夹可以看到许多js文件，每个js文件对应一个模块。不用我说也能猜到js核心模块是zepto.js。


将代码折叠引入眼帘的是如下结构的代码,首先调用匿名函数进行初始化Zepto类库，然后将引用放到全局作用域中，并设置别名($)。非常的清晰易懂
```js
var Zepto = (function(){...})()
window.Zepto = Zepto
window.$ === undefined && (window.$ = Zepto)
```

显然核心模块的重中之重是匿名的初始化函数，打开初始化的折叠，认真观察可以发现匿名函数内部又可以分成四个作用域

```js
// 内部定义的函数、变量
function type(obj){...}
function isFunction(value){...}
function likeArray(obj){...}
function compact(array){...}
$ = function(selector, context){...}
// 内部对象zepto对象上定义的函数、对象
zepto.init = function(selector, context){...}
zepto.qsa = function(element, selector){...}
// 内部函数 $ 上定义的函数、对象
$.extend = function(target){...}
$.isArray = isArray
$.isPlainObject = isPlainObject
// 内部对象 $.fn 上定义的函数、对象
$.fn = {
    constructor: zepto.Z,
    length: 0,
    concat: function(){...},
    map: function(fn){...},
    slice: function(){...},
    ready: function(callback){...}
}
```

虽然知道了其中有四个作用域，但是还并不清楚这几个作用域之间存在的关联性。认真查找会发现，有代码表明其关联性:
```js
var Zepto = (function(){
    ...
    zepto.Z.prototype = Z.prototype = $.fn
    $.zepto = zepto
})()

```

`$.fn`被作为Z构造器的原型，zepto被置于`$.zepto`命名空间下。认真分析我们调用的入口函数$，会发现该函数最终返回的结果必定为Z对象。

入口函数 $
```js
// 调用的是zepto中的init方法
$ = function(selector, context){
    return zepto.init(selector, context)
}
//init方法，根据传入的不同的值进行不同的操作，能够传入函数在页面加载完成后调后。
//能够传入对象、字符串、元素、元素片段、Z对象来生成一个Z对象
zepto.init = function(selector, context) {
    var dom
    // 没有参数时，则生成一个空的z对象
    if (!selector) return zepto.Z()
    else if (typeof selector == 'string') {
      selector = selector.trim()
      //参数为html代码时，生成html代码对应的元素，并设置选择器为空
      if (selector[0] == '<' && fragmentRE.test(selector))
        dom = zepto.fragment(selector, RegExp.$1, context), selector = null
        //参数为选择器时，查找上下文环境对应的元素
      else if (context !== undefined) return $(context).find(selector)
      // 查找元素，上下文环境不存在，从头查找
      else dom = zepto.qsa(document, selector)
    }
    // 参数是函数，页面加载完成后调用
    else if (isFunction(selector)) return $(document).ready(selector)
    // 参数是z对象，直接返回
    else if (zepto.isZ(selector)) return selector
    // 参数为元素对象、元素数组或片段元素时
    else {
      if (isArray(selector)) dom = compact(selector)
      else if (isObject(selector))
        dom = [selector], selector = null
      else if (fragmentRE.test(selector))
        dom = zepto.fragment(selector.trim(), RegExp.$1, context), selector = null
      else if (context !== undefined) return $(context).find(selector)
      else dom = zepto.qsa(document, selector)
    }
    return zepto.Z(dom, selector)
}
```

Z 对象(类数组，0~n是元素,length是长度，selector选择器)
```js
function Z(dom, selector) {
    var i, len = dom ? dom.length : 0
    for (i = 0; i < len; i++) this[i] = dom[i]
    this.length = len
    this.selector = selector || ''
}
zepto.Z = function(dom, selector) {
    return new Z(dom, selector)
}
```

所以`$.fn`是以Z对象作为上下文环境(`即$.fn`中的this代表着Z对象)调用的函数。`$`下的函数则是以`$`函数为上下文的函数。

因此除了`$ $.fn zepto`下定义的函数、对象，其余的函数、对象都是为了实现接口的功能而定义的更基本的函数。

## 个人收获
zepto核心代码不过900多行，不过确实让我获益良多。

首先结构上，zepto将工具方法置于其命名空间`$`下，用户使用入口函数`$`获取需要操作的元素后，将其包装为Z对象。将可以操作Z对象的方法置于`$.fn`下，并将其作为Z对象的原型，使函数唯一。结构清晰、而又不失优雅

在语言机制上。使我学习到了，可以使用\n(n代表任意整数)来在正则匹配中获得括号中的内容，匹配后可以使用RegExp.$n来获得括号中的内容，也可以在replace等API中使用`$n`来获得匹配的内容(如 `.replace(/([A-Z]+)([A-Z][a-z])/g, '$1_$2')`)，可以使用(?:)表示非捕获匹配。

学习到了array的各种好用的API：slice、map、reduce、concat、some、every。节点的各种属性：previousElementSibling、nextElementSibling、parentNode、offsetParent、scrollTop（兼容处理时pageYOffset）。节点的各种API：getBoundingClientRect（获取相对于父节点的位置信息，宽高等)

~0 //按位非，0变-1，-1变0。适合从indexOf等函数获得的值（即-1代表假）判断是否存在该值时的函数。
slice.call(arguments) 将类数组变为数组
multiple 多选属性，只存在于`<select><option>`中
定义undefined变量，防止undefined被覆盖成非空值

其他的还有如hide，在调用时，用闭包的方式先保存元素对应的显示状态，在show时将显示状态还原等细节操作。

许多API的概念：

likeArray 检测是否为类数组(length为正数，并且length不为0时，length-1的值存在)
```js
function likeArray(obj) {
    var length = !!obj && 'length' in obj && obj.length,
      type = $.type(obj)

    return 'function' != type && !isWindow(obj) && (
      'array' == type || length === 0 ||
        (typeof length == 'number' && length > 0 && (length - 1) in obj)
    )
  }
```

classRE 生成匹配类名的正则表达式的函数
```js
function classRE(name) {
    return name in classCache ?
      classCache[name] : (classCache[name] = new RegExp('(^|\\s)' + name + '(\\s|$)'))
  }
```

isEmpty检测空对象
```js
$.isEmptyObject = function(obj) {
    var name
    for (name in obj) return false
    return true
  }
```

removeProp 移除元素中的属性
```js
removeProp: function(name){
      name = propMap[name] || name
      return this.each(function(){ delete this[name] })
    }
```

extend 对象的深拷贝
```js
function extend(target, source, deep) {
    for (key in source)
      if (deep && (isPlainObject(source[key]) || isArray(source[key]))) {
        if (isPlainObject(source[key]) && !isPlainObject(target[key]))
          target[key] = {}
        if (isArray(source[key]) && !isArray(target[key]))
          target[key] = []
        extend(target[key], source[key], deep)
      }
      else if (source[key] !== undefined) target[key] = source[key]
    }
```

compact 去除数组中的空元素
```js
function compact(array) { 
    return filter.call(array, function(item){ return item != null }) 
}
```

flatten 将二维数组变成一维
```js
function flatten(array) { 
    return array.length > 0 ? $.fn.concat.apply([], array) : array 
}
```

pluck 获取元素中的某属性，并组成为对应数组
```js
pluck: function(property){
      return $.map(this, function(el){ return el[property] })
    }
```

traverseNode 遍历节点
```js
function traverseNode(node, fun) {
    fun(node)
    for (var i = 0, len = node.childNodes.length; i < len; i++)
      traverseNode(node.childNodes[i], fun)
  }
```

funcArg 将传递的值或函数的情况抽象为一个处理函数，以便复用
```js
// context通常为z对象,idx通常为z对象中的节点，payload为自定义的数据
function funcArg(context, arg, idx, payload) {
    return isFunction(arg) ? arg.call(context, idx, payload) : arg
  }
```