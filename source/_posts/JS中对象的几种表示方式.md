title: JS对象和继承
tags:
    - JavaScript
comments: true
brief: JS对象、元属性和继承
date: 2017-7-18
categories:
    - JavaScript
---
# JS对象和继承
## 对象
### 字面量表示
JS最简单的表示对象的方式，应该就是通过字面量表示，这种表示方法，不便于扩展、但胜在简单。适合只表示一个对象的场景。

```javascript
var obj = {
 num:123,
 str:"string",
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
    constructor:Person,
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

## 继承
### 原型式继承
使用Object.create()函数实现继承

```javascript
var person = {
    name:"",
    age:0,
    friends:[]
}
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

从上面的实例可以看出使用原型的继承方式，会使得对象类型被共用。

