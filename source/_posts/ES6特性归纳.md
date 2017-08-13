title: ES6特性归纳
tags:
    - JavaScript
    - 前端
comments: true
date: 2017-08-08
brief: ES6特性归纳
categories:
    - 前端
---
# ES6特性归纳
ES的全称是ECMAScript，它是JavaScript的规格，JS是ES的一种实现。ES还有JScript(IE中实际使用的是这种脚本语言)，ActionScript(Flash中使用的脚本语言)等实现形式。这篇文章主要是针对JS对ES的实现。

<!-- more -->

## let和const
let只在块级作用域内有效，const声明的变量的值不能被改变


## 变量的解构赋值
用于将值从数组或属性从对象提取到不同的变量中，一次给多个变量赋值的一种语法

### 数组解构赋值

完全解构赋值（左边与右边的量相等，或者大于右边的量。即右边的值被使用完全）

```js
let [foo, [[bar], baz]] = [1, [[2], 3]];
foo // 1
bar // 2
baz // 3

let [x, , y] = [1, 2, 3];
x // 1
y // 3

let [head, ...tail] = [1, 2, 3, 4];
head // 1
tail // [2, 3, 4]

let [x, y, ...z] = ['a'];
x // "a"
y // undefined
z // []
```

不完全解构赋值(即等号左边的模式，只匹配一部分的等号右边的数组)

```js
let [x, y] = [1, 2, 3];
x // 1
y // 2

let [a, [b], d] = [1, [2, 3], 4];
a // 1
b // 2
d // 4
```

默认值

```js
let [foo = true] = [];
foo // true
//必须为空或者undefined默认值才生效
let [x, y = 'b'] = ['a', undefined]; // x='a', y='b'
let [x, y = 'b'] = ['a', null]; // x='a', y=null
```

等号右边的值，需要对象或转为对象以后具备 Iterator 接口

### 对象的解构赋值
根据左右两边的属性名进行赋值，变量名默认为属性名，如果属性有值则变量名为属性值

```js
let { bar, foo } = { foo: "aaa", bar: "bbb" };
foo // "aaa"
bar // "bbb"

var { foo: baz } = { foo: 'aaa', bar: 'bbb' };
baz // "aaa"

let obj = { first: 'hello', last: 'world' };
let { first: f, last: l } = obj;
f // 'hello'
l // 'world'
```

对于let和const来说，变量不能重新声明，所以一旦赋值的变量以前声明过，就会报错。var可以

```js
let foo;
let {foo} = {foo: 1}; // SyntaxError: Duplicate declaration "foo"

let baz;
let {bar: baz} = {bar: 1}; // SyntaxError: Duplicate declaration "baz"

let foo;
({foo} = {foo: 1}); // 成功

let baz;
({bar: baz} = {bar: 1}); // 成功
```

嵌套解构的对象解构赋值

```js
//loc,start是模式不是变量不会被赋值
var node = {
  loc: {
    start: {
      line: 1,
      column: 5
    }
  }
};

var { loc: { start: { line }} } = node;
line // 1
loc  // error: loc is undefined
start // error: start is undefined

// 报错,因为foo为undefined无法取得bar
let {foo: {bar}} = {baz: 'baz'};
```

对数组进行对象属性的解构

```js
let arr = [1, 2, 3];
//方括号这种写法，属于“属性名表达式”
let {0 : first, [arr.length - 1] : last} = arr;
first // 1
last // 3
```

等号右边的值，需要对象或转为对象后进行结构赋值

### 函数解构赋值
```js
function add([x, y]){
  return x + y;
}

add([1, 2]); // 3
```

为函数变量指定默认值，当x或y没有值时，就会启用默认值

```js
function move({x = 0, y = 0} = {}) {
  return [x, y];
}

move({x: 3, y: 8}); // [3, 8]
move({x: 3}); // [3, 0]
move({}); // [0, 0]
move(); // [0, 0]
```

为函数参数指定默认值，默认值是整体{x,y}的，所以只要有参数就不启用默认值

```js
function move({x, y} = { x: 0, y: 0 }) {
  return [x, y];
}

move({x: 3, y: 8}); // [3, 8]
move({x: 3}); // [3, undefined]
move({}); // [undefined, undefined]
move(); // [0, 0]
```

