title: underscore源码分析
tags:
    - 源码分析
    - JavaScript
comments: true
date: 2018-01-28
brief: underscore源码分析
categories:
    - 源码分析
---
# underscore源码分析
Underscore一个JavaScript实用库，提供了一整套函数式编程的实用功能，前前后后总共100+个方法，但是没有扩展任何JavaScript内置对象。

<!-- more -->

underscore整体在一个闭包函数中，加载underscore类库时，执行代码自适应不同的JS环境。

```js
(function(){
//找出当前执行的环境的全局变量
var root = typeof self == 'object' && self.self === self && self ||
        typeof global == 'object' && global.global === global && global ||
        this ||
        {};
//...
    }())
```

仅供内部使用的函数都以驼峰命名法进行命名，供外部使用的函数都挂载在`_`上。当然能供外部使用的函数内部也有在使用。underscore主要有四个部分使用感到精彩，高内聚低耦合的内部方法、依据环境生成方法、特殊方法的实现、回调机制的实现。

## 高内聚低耦合的内部方法
optimizeCb返回一个绑定了上下文的方法

```js
var optimizeCb = function(func, context, argCount) {
    if (context === void 0) return func;
    switch (argCount) {
      case 1: return function(value) {
        return func.call(context, value);
      };
      //省略...
    }
    return function() {
      return func.apply(context, arguments);
    };
  };
```

cb 返回一个回调函数
```js
var cb = function(value, context, argCount) {
    // 当外部自定义回调生成器时使用回调生成器，生成一个回调函数
    if (_.iteratee !== builtinIteratee) return _.iteratee(value, context);
    // 返回一个默认的回调函数，该函数返回传入的第一个值
    if (value == null) return _.identity;
    // 生成一个绑定上下文的函数
    if (_.isFunction(value)) return optimizeCb(value, context, argCount);
    // 生成一个对象匹配器，随后可以使用数组、对象来判断是否匹配
    if (_.isObject(value) && !_.isArray(value)) return _.matcher(value);
    // 生成一个获取对象属性的函数
    return _.property(value);
  };
```

restArgs包装一个函数，将函数多余的参数包装为一个数组传递给最后一个参数，减少了每个函数中都是用arguments获取多余参数的麻烦
```js
  var restArgs = function(func, startIndex) {
    // func.length获取定义的形式参数个数
    startIndex = startIndex == null ? func.length - 1 : +startIndex;
    return function() {
      var length = Math.max(arguments.length - startIndex, 0),
          rest = Array(length),
          index = 0;
      // 从命名的形式参数的最后一个开始到结尾的所有参数包装成一个数组参数
      for (; index < length; index++) {
        rest[index] = arguments[index + startIndex];
      }
      switch (startIndex) {
        case 0: return func.call(this, rest);
        case 1: return func.call(this, arguments[0], rest);
        case 2: return func.call(this, arguments[0], arguments[1], rest);
      }
      var args = Array(startIndex + 1);
      for (index = 0; index < startIndex; index++) {
        args[index] = arguments[index];
      }
      args[startIndex] = rest;
      return func.apply(this, args);
    };
  };
```

在对外函数中的使用
```js
// 判断元素是否全部满足
_.every = _.all = function(obj, predicate, context) {
    predicate = cb(predicate, context);
    var keys = !isArrayLike(obj) && _.keys(obj),
        length = (keys || obj).length;
    for (var index = 0; index < length; index++) {
      var currentKey = keys ? keys[index] : index;
      if (!predicate(obj[currentKey], currentKey, obj)) return false;
    }
    return true;
  };
// 延迟函数执行
_.delay = restArgs(function(func, wait, args) {
    return setTimeout(function() {
      return func.apply(null, args);
    }, wait);
  });
```

## 依据环境生成代码
生成判断函数
```js
 _.each(['Arguments', 'Function', 'String', 'Number', 'Date', 'RegExp', 'Error', 'Symbol', 'Map', 'WeakMap', 'Set', 'WeakSet'], function(name) {
    _['is' + name] = function(obj) {
      return toString.call(obj) === '[object ' + name + ']';
    };
  });
//测试判断函数是否有效，无效则用新方法代替
if (!_.isArguments(arguments)) {
        _.isArguments = function(obj) {
            return _.has(obj, 'callee');
        };
    }

var nodelist = root.document && root.document.childNodes;
  if (typeof /./ != 'function' && typeof Int8Array != 'object' && typeof nodelist != 'function') {
    _.isFunction = function(obj) {
      return typeof obj == 'function' || false;
    };
  }
```

生成链式函数调用
```js
// 生成_对象,（只是将普通的对象包装为{_wrapped:obj}对象
var _ = function(obj) {
    if (obj instanceof _) return obj;
    if (!(this instanceof _)) return new _(obj);
    this._wrapped = obj;
  };
// 开启链式调用
_.chain = function(obj) {
    var instance = _(obj);
    instance._chain = true;
    return instance;
  };
// 如果上个对象为链式调用，则继续使用链式调用（将对象包装为_对象，并继续使用链式调用）
var chainResult = function(instance, obj) {
    return instance._chain ? _(obj).chain() : obj;
  };
// 混成，使用外部的方法覆盖内部方法、原型方法
// 原型方法为，使用_对象作为第一个参数，并将结果进行链式包装
_.mixin = function(obj) {
    _.each(_.functions(obj), function(name) {
      var func = _[name] = obj[name];
      _.prototype[name] = function() {
        var args = [this._wrapped];
        push.apply(args, arguments);
        return chainResult(this, func.apply(_, args));
      };
    });
    return _;
  };
// 生成原型方法
_.mixin(_);
```

## 特殊方法实现
_.partial 顺序填充一些参数给函数，并返回预处理后的函数使用`_`作为占位符

```js
var executeBound = function(sourceFunc, boundFunc, context, callingContext, args) {
    if (!(callingContext instanceof boundFunc)) return sourceFunc.apply(context, args);
    var self = baseCreate(sourceFunc.prototype);
    var result = sourceFunc.apply(self, args);
    if (_.isObject(result)) return result;
    return self;
  };
//根据预定义参数返回代理函数
_.partial = restArgs(function(func, boundArgs) {
    var placeholder = _.partial.placeholder;
    var bound = function() {
      var position = 0, length = boundArgs.length;
      var args = Array(length);
      for (var i = 0; i < length; i++) {
        //组装参数，如果预填充的参数为占位符，则使用调用时的参数来补齐。
        args[i] = boundArgs[i] === placeholder ? arguments[position++] : boundArgs[i];
      }
      //添加剩余的参数
      while (position < arguments.length) args.push(arguments[position++]);
      return executeBound(func, bound, this, this, args);
    };
    return bound;
  });
//占位符
_.partial.placeholder = _;
```

