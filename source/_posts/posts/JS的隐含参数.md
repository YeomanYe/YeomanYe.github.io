title: JS中的隐含参数
tags:
    - JavaScript
comments: true
brief: callee、caller、arguments解析
date: 2017-7-12
categories:
    - JavaScript
---

# JS中的隐含参数

介绍JS的隐含参数callee、callee、arguments的含义，并通过实验证明。

<!-- more -->

## caller
caller是函数的属性，代表调用当前函数的函数的引用。如果在全局作用域中调用，它的值为null。

```javascript
function func() {
     if (func.caller) {
         var a= func.caller.toString();
         console.log(a);
         console.log(func.caller === callerFunc);
     } else {
         console.log("this is not caller");
     }
}
function callerFunc() {
     func();
     if (callerFunc.caller) {
         var a= callerFunc.caller.toString();
         console.log(a);
     } else {
         console.log("this is not caller");
     }
}
callerFunc();
//输出为：
//function ...
//true
//this is not caller
```

看到输出结果：
第一个为函数的字符串表示(chrome的控制台似乎是输出函数的字符串表示)
第二个为true，表明caller是等于它的调用函数
第三个为this is not caller，表明最外层调用函数时不存在caller

## callee
callee是arguments的属性，代表当前正在执行的函数

```javascript
function func() {
     if (arguments.callee) {
         var a= arguments.callee.toString();
         console.log(a);
         console.log(arguments.callee === func);
     } else {
         console.log("this is not callee");
     }
}
function Func() {
     func();
     if (arguments.callee) {
         var a= arguments.callee.toString();
         console.log(arguments.callee === Func)
         console.log(a);
     } else {
         console.log("this is not callee");
     }
}
Func();
//结果为:
//function ...
//true
//true
//function ...
```

从输出结果可以看到无论调用在不在最外层arguments的callee属性都存在，且都等价于该函数本身

## arguments
arguments是一个类数组对象不是一个数组实例；arguments和命名参数共用同一块内存空间
```javascript
function argumentsTest(arg1,arg2){
    console.log("arguments instanceof Array?",arguments instanceof Array);
    console.log("arguments instanceof Object?",arguments instanceof Object);
    console.log("arguments[0] === arg1?", arg1 === arguments[0]);
}
argumentsTest(1,2,3,4,5);
//输出结果为：
//arguments instanceof Array? false
//arguments instanceof Object? true
//arguments[0] === arg1? true
```

显然arguments是个类数组，并且各个位置的值等价于同名变量。
