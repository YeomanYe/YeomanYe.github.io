title: JS对象和继承
tags:
    - JavaScript
comments: true
brief: JS对象、元属性和继承
date: 2017-7-20
categories:
    - JavaScript
---
# JS对象和继承
## 对象
### 字面量表示
JS最简单的表示对象的方式，应该就是通过字面量表示，这种表示方法，不便于扩展、但胜在简单。适合只表示一个对象的场景。

```javascript
var obj = {
 num:123,g",
 funct: function(){
    //...
 }
}
```

### 构造器
使用构造器创建对象比较为人熟知的是原型模式和构造函数模式：

```javascript
//原型模式
function Person(){}
Person.prototype = {
    constructor:Person,虽然这种方法使得每个实例都拥有独立的属性，但这种方法缺点是没有办法复用父类的方法，因为它虽然调用了父类的构造方法，却没有将SuperType.prototype加入到原型链中。
    name:”Tom”,
    sayName:function(){
        console.log(this.name);
    }
};

//构造函数模式
function Person(name){
    this.name = name;
    this.sayName = function(){
        console.log(this.name);
    }
}
```

我们知道同种对象的函数应该是相同的，而属性应该是不同的。在原型模式中，所有的对象可以顺着原型链指向Person.prototype对象，因此它们的函数是共用的，然而使用原型模式创造出来的对象无法给属性赋默认值，必须创造出对象后再加以覆盖。而在构造函数中虽然可以给对象赋予默认值，但是每个对象都创造了相同的函数，这无疑造成了空间的浪费。

因此结合这两种方法，能产生更好的构造器:

```javascript
function Person(name){
    this.name = name;
    // 判断函数存在，能避免反复声明。
    if(Person.prototype.sayName === undefined){
        // 所有的原型方法写在此处
        Person.prototype.sayName = function(){
            console.log(this.name);
        }
    }
}
```

## 对象的属性类型
对象的属性类型是用来描述对象属性的各种特征，ES5 规定了两种属性：数据属性和访问器属性。

### 数据属性
数据属性包括：configurable、enumerable、writable、value用于配置对象的属性的访问性和值，使用defineProperty进行定义

```javascript
//更改数据属性
var person = {};
Object.defineProperty(person,"name",{
    //定义是否可修改属性的特性，是否可以被delete，是否可以改为访问器属性
    configurable:false,
    //属性是否可枚举(可以通过for...in枚举出来)
    enumerable:false,
    //属性值是否可以被修改
    writable:true,
    //属性的值
    value:"Tony"
    });

delete person.name;
alert(person.name);//Tony

//抛出错误
Object.defineProperty(person,"name",{
    configurable:true,
    value:"Tom"
    })
```

### 访问器属性
访问器属性包括：configurable、enumerable、get、set。configurable、enumerable与数据属性表示的内容一致，set、get代表设置和得到数据的方法

```javascript
var book = {
    _year: 2004,
    name: "test"
};
Object.defineProperties(book, {
    name: {
        value: "Book"
    },
    year: {
        set: function(newValue) {
            this._year =  newValue - 1;
        },
        get: function() {
            return this._year;
        }
    }
});
book.year = 1995;
console.log(book.year, book.name);
//输出 1994 Book
```
从上面的输出可以看出，set和get方法会改变对象属性的设置，defineProperties可以批量设置对象属性的特性。

## 继承
### 原型式继承
使用Object.create()函数实现继承

```javascript
var person = {
    name:"",
    age:0,
    friends:[]
}
// 第二个参数和defineProperty中的一样
var xiaoming = Object.create(person,{
    name:{
        value:"xiaoming"
    }
});
xiaoming.friends.push(xiaohua.name);

var xiaohua = Object.create(person);
xiaohua.name = "xiaohua";
xiaohua.friends.push(xiaoming.name);
console.log(xiaoming.name,xiaohua.name,person.friends);
```

从上面的实例可以看出使用原型的继承方式，会使得对象类型被共用(如果没有被覆盖的话)。

### 原型链继承

```javascript
SubType.prototype = new SuperType();
```

这种继承方式缺点有：使用SubType生成的对象类型依然为SuperType，原因是SubType.prototype中的constructor被覆盖了；生成的对象属性是通过原型链共享的，对于属性是对象/数组类型，实例之间修改后会对其他实例产生影响。

### 借用构造函数式继承

```javascript
function SuperType(name){
    this.name = name;
    if(SuperType.prototype.func === undefined){
        SuperType.prototype.func = function(){
            //...
        }
    }
}
function SubType(){
    //继承了SuperType,同时还传递了参数
    SuperType.call(this,"Nicholas");
    //实例属性
    this.age = 29;
}
var instance = new SubType();
alert(instance.name);//Nicholas
alert(instance.age);//29
alert(instance.func());//报错

```

虽然这种方法使得每个实例都拥有独立的属性，但这种方法缺点是没有办法复用父类的方法，因为它虽然调用了父类的构造方法，却没有将SuperType.prototype加入到原型链中。


### 组合继承
组合继承，组合了原型链继承和借用构造函数式继承

组合模式结合了两者的优点使得各个实例拥有独立的属性，并能共享父类方法，而且最后得到的对象类型还是子类类型

```javascript
function SuperType(name){
    this.name = name;
    if(SuperType.prototype.callName === undefined){
        SuperType.prototype.callName = function(){
            console.log(this.name);
        }
    }
}
function SubType(name,age){
    SuperType.call(this,name);
    this.age = age;
}
function inheritPrototype(subType,superType){
    var prototype = new superType();
    prototype.constructor = subType;
    subType.prototype = prototype;
}
inheritPrototype(SubType,SuperType);
var instance = new SubType("Tom",25);
alert(instance.name);
alert(instance.age);
alert(instance instanceof SubType);
instance.callName();
```

## ES6中的类和继承
ES中类的表示

```javascript
let methodName = "getArea";
//定义类
class Point {
    //constructor方法默认返回实例对象（即this），完全可以指定返回另外一个对象。
  constructor(x, y) {
    this.x = x;
    this.y = y;
  }
//定义在类的prototype上
  toString() {
    return '(' + this.x + ', ' + this.y + ')';
  }
  //可以使用表达式
  [methodName]() {
    // ...
  }
}
```

ES6中的继承

```javascript
class Point {
  constructor(x, y) {
    this.x = x;
    this.y = y;
  }
}

class ColorPoint extends Point {
  constructor(x, y, color) {
    //this.color = color; ReferenceError
    super(x, y);
    this.color = color; // 正确
  }
}
```

参考文献：
ECMAScript 6 入门
JavaScript高级程序设计(第3版)

