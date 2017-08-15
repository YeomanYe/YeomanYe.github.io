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

## 字符串扩展
字符串可以被for…of循环遍历,并且可以正确识别大于0xffff的码点

```js
var text = String.fromCodePoint(0x20BB7);

for (let i = 0; i < text.length; i++) {
  console.log(text[i]);
}
// " "
// " "

for (let i of text) {
  console.log(i);
}
// "𠮷"
```

新增函数
- includes()：返回布尔值，表示是否找到了参数字符串。
- startsWith()：返回布尔值，表示参数字符串是否在源字符串的头部。
- endsWith()：返回布尔值，表示参数字符串是否在源字符串的尾部。
- at()：能正确返回大于0xffff的字符,目前需要通过垫片库来实现
- repeat()：方法返回一个新字符串,表示将原字符串重复n次。
- padStart(),padEnd()：字符串补全功能

```js
'x'.padStart(5, 'ab') // 'ababx'
'x'.padStart(4, 'ab') // 'abax'

'hello'.repeat(2) // "hellohello"
'na'.repeat(0) // ""
```

模板字符串
可以使用多行字符串，可以在字符串中使用变量，其他与普通字符串一样。模板字符串使用反引号(`)括起

```js
// 普通字符串
`In JavaScript '\n' is a line-feed.`

// 多行字符串
`In JavaScript this is
 not legal.`

console.log(`string text line 1
string text line 2`);

// 字符串中嵌入变量
var name = "Bob", time = "today";
`Hello ${name}, how are you ${time}?`

var greeting = `\`Yo\` World!`;
```

还可以紧跟在一个函数名后面，该函数将被调用来处理这个模板字符串。这被称为“标签模板”功能

```js
var a = 5;
var b = 10;

tag`Hello ${ a + b } world ${ a * b }`;
// 等同于
tag(['Hello ', ' world ', ''], 15, 50);


function tag(stringArr, value1, value2){
  // ...
}

// 等同于

function tag(stringArr, ...values){
  // ...
}
```

用于过滤输入HTML字串，使得输入更加安全

```js
var message =
  SaferHTML`<p>${sender} has sent you a message.</p>`;

function SaferHTML(templateData) {
  var s = templateData[0];
  for (var i = 1; i < arguments.length; i++) {
    var arg = String(arguments[i]);

    // Escape special characters in the substitution.
    s += arg.replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;");

    // Don't escape special characters in the template.
    s += templateData[i];
  }
  return s;
}

var sender = '<script>alert("abc")</script>'; // 恶意代码
var message = SaferHTML`<p>${sender} has sent you a message.</p>`;

message
// <p>&lt;script&gt;alert("abc")&lt;/script&gt; has sent you a message.</p>
```

使用row[0]获得转义之前的模板原型

```js
tag`First line\nSecond line`

function tag(strings) {
    //raw[0]便于获取转义之前的模板原型
  console.log(strings.raw[0]);
  // "First line\\nSecond line"
}
```

## 数值修改
八进制使用0o表示,二进制使用0b表示

Number新增函数
- Number.isFinite()
- Number.isNaN()
- Number.parseInt() 从全局对象移植到Number上
- Number.parseFloat() 同上
- Number.isInteger()
- Number.isSafeInteger()

Number新增属性
- Number.EPSILON 极小常量，用于浮点计算的误差判定
- Number.MIN_SAFE_INTEGER 2^53 - 1
- Number.MAX_SAFE_INTEGER -2^53 + 1

Math扩展
Math.trunc()方法用于去除一个数的小数部分，返回整数部分。
Math.cbrt()方法用于计算一个数的立方根。
Math.hypot()方法返回所有参数的平方和的平方根。
Math.expm1(x)返回ex - 1，即Math.exp(x) - 1。
Math.log10(x)返回以10为底的x的对数。如果x小于0，则返回NaN。
Math.log2(x)返回以2为底的x的对数。如果x小于0，则返回NaN。
Math.log1p(x)方法返回1 + x的自然对数，即Math.log(1 + x)。如果x小于-1，返回NaN。

指数运算:
```js
2 ** 2 // 4
2 ** 3 // 8

let a = 1.5;
a **= 2;
// 等同于 a = a * a;
```

## 数组扩展
### Array扩展

Array.from方法用于将两类对象转为真正的数组：类似数组的对象（array-like object）和可遍历（iterable）的对象（包括ES6新增的数据结构Set和Map）

常见的类似数组的对象是DOM操作返回的NodeList集合，以及函数内部的arguments对象。Array.from都可以将它们转为真正的数组。

```js
Array.from([1, , 2, , 3], (n) => n || 0)
// [1, 0, 2, 0, 3]
```

Array.of方法用于将一组值，转换为数组。这个方法的主要目的，是弥补数组构造函数Array()的不足。

```js
Array.of(3, 11, 8) // [3,11,8]
Array.of(3) // [3]
```

### 数组实例扩展
find方法

```js
[1, 4, -5, 10].find((n) => n < 0)
// -5

[1, 5, 10, 15].find(function(value, index, arr) {
  return value > 9;
}) // 10
```

includes()表示某个数组是否包含给定的值，indexOf不能用于判断NaN。该方法属于ES7，但Babel转码器已经支持。

```js
[1, 2, 3].includes(2);     // true
[1, 2, 3].includes(4);     // false
[1, 2, NaN].includes(NaN); // true
```

## 函数的扩展
### rest参数
rest 参数（形式为“…变量名”），用于获取函数的多余参数，这样就不需要使用arguments对象了。

```js
function add(...values) {
  let sum = 0;
  for (var val of values) {
    sum += val;
  }
  return sum;
}

add(2, 5, 3) // 10
```

### 参数默认值

使用默认值时，函数参数变量是默认声明的，所以不能用let或const再次声明。

```js
function foo(x = 5) {
  let x = 1; // error
  const x = 2; // error
}
```

指定了默认值以后，函数的length属性，将返回没有指定默认值的参数个数。

```js
(function (a) {}).length // 1
(function (a = 5) {}).length // 0
(function (a, b, c = 5) {}).length // 2
(function(...args) {}).length // 0
```

利用参数默认值，可以指定某一个参数不得省略，如果省略就抛出一个错误。

```js
function throwIfMissing() {
  throw new Error('Missing parameter');
}
/*
，参数mustBeProvided的默认值等于throwIfMissing函数的运行结果（即函数名之后有一对圆括号），这表明参数的默认值不是在定义时执行，而是在运行时执行
 */
function foo(mustBeProvided = throwIfMissing()) {
  return mustBeProvided;
}

foo()
// Error: Missing parameter
```

### 扩展运算符
扩展运算符（spread）是三个点（…）。它好比 rest 参数的逆运算，将一个数组转为用逗号分隔的参数序列。

```js
console.log(...[1, 2, 3])
// 1 2 3

console.log(1, ...[2, 3, 4], 5)
// 1 2 3 4 5

[...document.querySelectorAll('div')]
// [<div>, <div>, <div>]
```

### 箭头函数

```js
//单参数，单语句
var f = v => v;
//多参数，单语句
var sum = (num1, num2) => num1 + num2;
//如果箭头函数的代码块部分多于一条语句，就要使用大括号将它们括起来，并且使用return语句返回。
var sum = (num1, num2) => { return num1 + num2; }
//由于大括号被解释为代码块，所以如果箭头函数直接返回一个对象，必须在对象外面加上括号。
var getTempItem = id => ({ id: id, name: "Temp" });
```

注意点：
（1）函数体内的this对象，就是定义时所在的对象，而不是使用时所在的对象。以下三个变量在箭头函数之中也是不存在的，指向外层函数的对应变量：arguments、super、new.target。

new.target属性允许你检测函数或构造方法是否通过是通过new运算符被调用的。在通过new运算符被初始化的函数或构造方法中，new.target返回一个指向构造方法或函数的引用。在普通的函数调用中，new.target 的值是undefined。

```js
window.name = "abc";
var a = () => console.log(this.name);

var obj = {
    fun:a,
    name:"def"
}
obj.fun();//abc

function d(){
    console.log(this.name);
}

obj.fun = d;
obj.fun();//def
```

（2）不可以当作构造函数，也就是说，不可以使用new命令，否则会抛出一个错误。

（3）不可以使用arguments对象，该对象在函数体内不存在。如果要用，可以用Rest参数代替。

（4）不可以使用yield命令，因此箭头函数不能用作Generator函数。

### 绑定this
函数绑定运算符是并排的两个双冒号（::），双冒号左边是一个对象，右边是一个函数。该运算符会自动将左边的对象，作为上下文环境（即this对象），绑定到右边的函数上面。该语法还是ES7的一个提案，但是Babel转码器已经支持。

```js
window.name = "abc";
var a = {name:"def"};
function sayName(){
    console.log(this.name);
}
a::sayName();//def
```

## 对象的扩展
ES6允许直接写入变量和函数，作为对象的属性和方法

```js
var foo = 'bar';
var baz = {foo};
baz // {foo: "bar"}

// 等同于
var baz = {foo: foo};
```

方法简写

```js
var o = {
  method() {
    return "Hello!";
  }
};

// 等同于

var o = {
  method: function() {
    return "Hello!";
  }
};
```

Generator方法简写

```js
var obj = {
  * m(){
    yield 'hello world';
  }
};
```

属性名可以采用表达式进行计算

```js
// 方法二
obj['a' + 'bc'] = 123;
```

Object.is(arg1,arg2) 比较两个数，一 +0不等于-0，二 NaN等于自身
Object.assign(target,...sources) 将原对象的可枚举属性复制到目标对象
Object.getOwnPropertyDescriptor(object,string)用于获取对象该属性的描述对象

```js
let obj = { foo: 123 };
Object.getOwnPropertyDescriptor(obj, 'foo')
//  {
//    value: 123,
//    writable: true,
//    enumerable: true,
//    configurable: true
//  }
```

__proto__属性（前后各两个下划线），用来读取或设置当前对象的prototype对象

Object.setPrototypeOf()用来设置一个对象的prototype对象
```js
// 格式
Object.setPrototypeOf(object, prototype)
```

Object.getPrototypeOf()用于读取一个对象的原型对象。
```js
Object.getPrototypeOf(obj);
```

Object.getOwnPropertyDescriptors()ES2017 引入方法，返回指定对象所有自身属性描述对象
```js
const obj = {
  foo: 123,
  get bar() { return 'abc' }
};

Object.getOwnPropertyDescriptors(obj)
// { foo:
//    { value: 123,
//      writable: true,
//      enumerable: true,
//      configurable: true },
//   bar:
//    { get: [Function: bar],
//      set: undefined,
//      enumerable: true,
//      configurable: true } }
```


### 扩展运算符


归纳下会忽略enumerable为false的操作：
- for…in循环：只遍历对象自身的和继承的可枚举的属性
- Object.keys()：返回对象自身的所有可枚举的属性的键名
- JSON.stringify()：只串行化对象自身的可枚举的属性
- Object.assign():对象合并

不忽略的操作:
- Object.getOwnPropertyNames(obj)
- Object.getOwnPropertySymbols(obj)
- Reflect.ownKeys(obj)