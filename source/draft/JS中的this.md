title: JS中的this
tags:
    - JavaScript
comments: true
brief: this解析
date: 2017-7-16
categories:
    - JavaScript
---

# JS中的this

众所周知，JS中this的代表的是当前函数调用者的上下文。JS是解释性的动态类型语言，函数在调用时刻才解释其中的语句，因此this所表示的对象也是动态决定的。

<!-- more -->

## 默认绑定
默认情况下this总是指向调用该函数的对象和全局对象(在最外层调用函数)，无论函数嵌套了多少层

```javascript
function testThis(){
    console.log(this);
}

var obj = {
    testThis:testThis
};

testThis();
obj.testThis();
```
在浏览器下分别输出Window对象和Object对象


```javascript
function foo(){
    setTimeout(() => {
        //这里的this在此法上继承自foo()
        console.log(this.a);
        },100);
}
var a = 9;
foo(); // 9
```
结果为9，说明内层函数和外层函数一样指向了window对象;

## 显示绑定
显示绑定指的是人为改变this的指向,如call、apply、bind函数

```javascript
var test = (function(){
    var num = 0;
    return function(){
        console.log(++num + ": ",this);
    }
})();

test.call(123);
test.call("123");
test.call(true);
test.call(null);
test.call(undefined);

test.apply(123);
test.apply("123");
test.apply(false);
test.apply(null);
test.apply(undefined);

test.bind(123)();
test.bind("123")();
test.bind(true)();
test.bind(null)();
test.bind(undefined)();
```
输出结果皆是Number、String、Boolean、Window、Window

从输出的结果可以看出this指向被修改了，并且如果是基本类型数字、字符串、布尔值等情况，this会将其转换成对应的包装类型。如果类型为null,undefined则会使用全局对象(window)。

## new绑定
使用new创建一个对象时：

1. 先创建一个空对象，把this指向该对象，创建原型链
2. 运行函数的逻辑
3. 如果函数中有返回值则返回的对象为返回值，否则默认返回this作为返回对象

```javascript
function Test1(){
    console.log(this);
    this.func = function(){
        console.log("in test1");
    };
}

function Test2(){
    console.log(this);
    this.func = function(){
        console.log("in test2")
    };
    return new Test1();
}

var test1 = new Test1();
var test2 = new Test2();
test1.func();
test2.func();
```
可以看到输出为Test1、Test2、Test1、"in test1"、"in test2"

说明:
- 使用new确实要执行一遍函数;
- 返回值影响到最后的生成对象;
- 没有返回值时默认返回this

参考文献：
你不知道的JavaScript（上卷）
JavaScript高级程序设计（第三版）
