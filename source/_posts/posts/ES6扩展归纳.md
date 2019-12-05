title: ES6扩展归纳
tags:
    - JavaScript
comments: true
date: 2017-08-16
brief: ES6扩展归纳
categories:
    - JavaScript
---
# ES6扩展归纳
介绍ES6相比与ES5在原有对象上的扩展，包括字符串、正则、数值、函数、数组、对象等扩展，本文是阮一峰《ECMAScript 6入门》相关章节内容的总结

<!-- more -->

## 正则的扩展
ES6允许两个参数的写法，并且忽略原有修饰符
```js
new RegExp(/abc/ig, 'i').flags
// "i"
```

### u修饰符

使用u修饰符能正确处理四字节的utf-16编码
```js
/^\uD83D/u.test('\uD83D\uDC2A') // false
/^\uD83D/.test('\uD83D\uDC2A') // true
```

有些 Unicode 字符的编码不同，但是字型很相近，比如，\u004B与\u212A都是大写的K。
```js
/[a-z]/i.test('\u212A') // false
/[a-z]/iu.test('\u212A') // true
```

上面代码中，不加u修饰符，就无法识别非规范的K字符。

### y修饰符
y修饰符(“粘连”（sticky）修饰符)的作用与g修饰符类似，也是全局匹配，后一次匹配都从上一次匹配成功的下一个位置开始。不同之处在于，g修饰符只要剩余位置中存在匹配就可，而y修饰符确保匹配必须从剩余的第一个位置开始，这也就是“粘连”的涵义。

```js
var s = 'aaa_aa_a';
var r1 = /a+/g;
var r2 = /a+/y;

r1.exec(s) // ["aaa"]
r2.exec(s) // ["aaa"]

r1.exec(s) // ["aa"]
r2.exec(s) // null
```

与y修饰符相匹配，ES6 的正则对象多了sticky属性，表示是否设置了y修饰符
```js
var r = /hello\d/y;
r.sticky // true
```

### flags
```js
// ES5 的 source 属性
// 返回正则表达式的正文
/abc/ig.source
// "abc"

// ES6 的 flags 属性
// 返回正则表达式的修饰符
/abc/ig.flags
// 'gi'
```

### s修饰符：dotAll 模式
正则表达式中，点（.）是一个特殊字符，代表任意的单个字符，但是行终止符（line terminator character）除外。

以下四个字符属于”行终止符“。
- U+000A 换行符（\n）
- U+000D 回车符（\r）
- U+2028 行分隔符（line separator）
- U+2029 段分隔符（paragraph separator）

s修饰符使得.可以匹配任意字符
```js
/foo.bar/.test('foo\nbar')//false
//ES5匹配任意字符的变通方法
/foo[^]bar/.test('foo\nbar') // true 
const re = /foo.bar/s.test('foo\nbar') // true
re.dotAll // true
```

### 后行断言
”先行断言“指的是，x只有在y前面才匹配，必须写成`/x(?=y)/`。比如，只匹配百分号之前的数字，要写成/\d+(?=%)/。”先行否定断言“指的是，x只有不在y前面才匹配，必须写成`/x(?!y)/`。比如，只匹配不在百分号之前的数字，要写成/\d+(?!%)/
```js
/\d+(?=%)/.exec('100% of US presidents have been male')  // ["100"]
/\d+(?!%)/.exec('that’s all 44 of them')                 // ["44"]
```

“后行断言”正好与“先行断言”相反，x只有在y后面才匹配，必须写成`/(?<=y)x/`。x只有不在y后面才匹配，必须写成`/(?!<y)x/`。

```js
/(?<=\$)\d+/.exec('Benjamin Franklin is on the $100 bill')  // ["100"]
/(?<!\$)\d+/.exec('it’s is worth about €90')                // ["90"]
```

“后行断言”的实现，需要先匹配/(?<=y)x/的x，然后再回到左边，匹配y的部分。这种“先右后左”的执行顺序，与所有其他正则操作相反，导致了一些不符合预期的行为。
```js
/(?<=(\d+)(\d+))$/.exec('1053') // ["", "1", "053"]
/^(\d+)(\d+)$/.exec('1053') // ["1053", "105", "3"]
```

"后行断言"的反斜杠引用，也与通常的顺序相反，必须放在对应的那个括号之前。
```js
/(?<=(o)d\1)r/.exec('hodor')  // null
/(?<=\1d(o))r/.exec('hodor')  // ["r", "o"]
```

### Unicode属性类
Unicode 属性类要指定属性名和属性值。

`\p{UnicodePropertyName=UnicodePropertyValue}`
对于某些属性，可以只写属性名。

`\p{UnicodePropertyName}`
\P{…}是\p{…}的反向匹配，即匹配不满足条件的字符。

```js
const regexGreekSymbol = /\p{Script=Greek}/u;
regexGreekSymbol.test('π') // true
```

### 具名组匹配

有一个“具名组匹配”（Named Capture Groups）的提案，允许为每一个组匹配指定一个名字，既便于阅读代码，又便于引用。
```js
const RE_DATE = /(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})/;

const matchObj = RE_DATE.exec('1999-12-31');
const year = matchObj.groups.year; // 1999
const month = matchObj.groups.month; // 12
const day = matchObj.groups.day; // 31

//非具名组匹配
const RE_DATE = /(\d{4})-(\d{2})-(\d{2})/;

const matchObj = RE_DATE.exec('1999-12-31');
const year = matchObj[1]; // 1999
const month = matchObj[2]; // 12
const day = matchObj[3]; // 31
```

有了具名组匹配以后，可以使用解构赋值直接从匹配结果上为变量赋值。
```js
let {groups: {one, two}} = /^(?<one>.*):(?<two>.*)$/u.exec('foo:bar');
one  // foo
two  // bar
```

字符串替换时，使用$<组名>引用具名组。
```js
let re = /(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})/u;

'2015-01-02'.replace(re, '$<day>/$<month>/$<year>')
// '02/01/2015'

//replace方法的第二个参数也可以是函数，该函数的参数序列如下。
'2015-01-02'.replace(re, (
   matched, // 整个匹配结果 2015-01-02
   capture1, // 第一个组匹配 2015
   capture2, // 第二个组匹配 01
   capture3, // 第三个组匹配 02
   position, // 匹配开始的位置 0
   S, // 原字符串 2015-01-02
   groups // 具名组构成的一个对象 {year, month, day}
 ) => {
 let {day, month, year} = args[args.length - 1];
 return `${day}/${month}/${year}`;
});
```

如果要在正则表达式内部引用某个“具名组匹配”，可以使用\k<组名>的写法。
```js
const RE_TWICE = /^(?<word>[a-z]+)!\k<word>$/;
RE_TWICE.test('abc!abc') // true
RE_TWICE.test('abc!ab') // false
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

### 新增函数
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

### 模板字符串
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

指数运算:
```js
2 ** 2 // 4
2 ** 3 // 8

let a = 1.5;
a **= 2;
// 等同于 a = a * a;
```

### Number扩展
新增函数
- Number.isFinite()
- Number.isNaN()
- Number.parseInt() 从全局对象移植到Number上
- Number.parseFloat() 同上
- Number.isInteger()
- Number.isSafeInteger()

新增属性
- Number.EPSILON 极小常量，用于浮点计算的误差判定
- Number.MIN_SAFE_INTEGER 2^53 - 1
- Number.MAX_SAFE_INTEGER -2^53 + 1

### Math扩展
Math.trunc()方法用于去除一个数的小数部分，返回整数部分。
Math.cbrt()方法用于计算一个数的立方根。
Math.hypot()方法返回所有参数的平方和的平方根。
Math.expm1(x)返回ex - 1，即Math.exp(x) - 1。
Math.log10(x)返回以10为底的x的对数。如果x小于0，则返回NaN。
Math.log2(x)返回以2为底的x的对数。如果x小于0，则返回NaN。
Math.log1p(x)方法返回1 + x的自然对数，即Math.log(1 + x)。如果x小于-1，返回NaN。

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
### 简写
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

### 新增扩展
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
用于解构赋值时，能够将对象的所有属性合并赋予最后的对象
用于赋值时，会运算对象取出其中的值
```js
//用于解构赋值
let { x, y, ...z } = { x: 1, y: 2, a: 3, b: 4 };
x // 1
y // 2
z // { a: 3, b: 4 }


// 用于赋值，会抛出错误，因为x属性被执行了
let runtimeError = {
  ...a,
  ...{
    get x() {
      throws new Error('thrown now');
    }
  }
};
```

## 参考文献:
[ECMAScript 6入门](http://es6.ruanyifeng.com/#README)