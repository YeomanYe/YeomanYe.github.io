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

## Symbol
ES6引入了一种新的原始数据类型Symbol，表示独一无二的值。

```js
//不能有new,因为Symbol也是一种基础类型
//参数字符串只用与描述,同参情况下也不相等
var s1 = Symbol('foo');
var s2 = Symbol('bar');

s1 // Symbol(foo)
s2 // Symbol(bar)

s1.toString() // "Symbol(foo)"
s2.toString() // "Symbol(bar)"

// 没有参数的情况
var s1 = Symbol();
var s2 = Symbol();

s1 === s2 // false
```

### Symbol作为属性名

Symbol值作为对象属性名时，不能用点运算符。使用symbol保证属性不会被覆盖，symbol作为属性名不会被常规的方法遍历到，可以使用该特性为对象定义内部方法。
```js
var mySymbol = Symbol();

// 第一种写法
var a = {};
a[mySymbol] = 'Hello!';

// 第二种写法
var a = {
  [mySymbol]: 'Hello!'
};

// 第三种写法
var a = {};
Object.defineProperty(a, mySymbol, { value: 'Hello!' });
```

通过Object.getOwnPropertySymbols方法获取指定对象的所有Symbol属性名。
```js
var obj = {};
var a = Symbol('a');
var b = Symbol('b');

obj[a] = 'Hello';
obj[b] = 'World';

var objectSymbols = Object.getOwnPropertySymbols(obj);

objectSymbols
// [Symbol(a), Symbol(b)]
```

使用Reflect.ownKeys返回类型所有键名
```js
let obj = {
  [Symbol('my_key')]: 1,
  enum: 2,
  nonEnum: 3
};

Reflect.ownKeys(obj)
//  ["enum", "nonEnum", Symbol(my_key)]
```

### Symbol API
Symbol.for()与Symbol()这两种写法，都会生成新的Symbol。它们的区别是，前者会被登记在全局环境中供搜索，后者不会。

```js
var s1 = Symbol.for('foo');
var s2 = Symbol.for('foo');

s1 === s2 // true
```

Symbol.keyFor方法返回一个已登记的 Symbol 类型值的key
```js
var s1 = Symbol.for("foo");
Symbol.keyFor(s1) // "foo"

var s2 = Symbol("foo");
Symbol.keyFor(s2) // undefined
```

Symbol.for为Symbol值登记的名字，是全局环境的，可以在不同的 iframe 或 service worker 中取到同一个值。

对象有些内置的Symbol值，如:对象的Symbol.hasInstance属性，指向一个内部方法。
```js
class MyClass {
  [Symbol.hasInstance](foo) {
    return foo instanceof Array;
  }
}

[1, 2, 3] instanceof new MyClass() // true
```

其他还有：Symbol.iterator，Symbol.replace,Symbol.search,Symbol.split，Symbol.match指向对象默认的同名方法

## Set和Map数据结构
Set与数组
```js
//set与数组互换
var set = new Set([1, 2, 3, 4, 4]);
[...set]
// [1, 2, 3, 4]
set.size//4

// 去除数组的重复成员
[...new Set(array)]
```

Set中NaN可以等于自身
```js
let set = new Set();
let a = NaN;
let b = NaN;
set.add(a);
set.add(b);
set // Set {NaN}
```

求交、并和差集
```js
let a = new Set([1, 2, 3]);
let b = new Set([4, 3, 2]);

// 并集
let union = new Set([...a, ...b]);
// Set {1, 2, 3, 4}

// 交集
let intersect = new Set([...a].filter(x => b.has(x)));
// set {2, 3}

// 差集
let difference = new Set([...a].filter(x => !b.has(x)));
// Set {1}
```

在遍历操作中，同步改变原来的Set结构，目前没有直接的方法，但有两种变通方法。
```js
// 方法一
let set = new Set([1, 2, 3]);
set = new Set([...set].map(val => val * 2));
// set的值是2, 4, 6

// 方法二
let set = new Set([1, 2, 3]);
set = new Set(Array.from(set, val => val * 2));
// set的值是2, 4, 6
```

###  Set实例的属性和方法
- Set.prototype.constructor：构造函数，默认就是Set函数。
- Set.prototype.size：返回Set实例的成员总数。
- add(value)：添加某个值，返回Set结构本身。
- delete(value)：删除某个值，返回一个布尔值，表示删除是否成功。
- has(value)：返回一个布尔值，表示该值是否为Set的成员。
- clear()：清除所有成员，没有返回值。

### WeakSet
WeakSet中的对象都是弱引用，即垃圾回收机制不考虑WeakSet对该对象的引用，也就是说，如果其他对象都不再引用该对象，那么垃圾回收机制会自动回收该对象所占用的内存，不考虑该对象还存在于WeakSet之中

```js
//只能添加对象
var ws = new WeakSet();
ws.add(1)
// TypeError: Invalid value used in weak set
ws.add(Symbol())
// TypeError: invalid value used in weak set

//数组的成员只能是对象
var a = [[1,2], [3,4]];
var ws = new WeakSet(a);
//非对象时会报错
var b = [3, 4];
var ws = new WeakSet(b);
// Uncaught TypeError: Invalid value used in weak set(…)
```

- WeakSet.prototype.add(value)：向WeakSet实例添加一个新成员。
- WeakSet.prototype.delete(value)：清除WeakSet实例的指定成员。
- WeakSet.prototype.has(value)：返回一个布尔值，表示某个值是否在

WeakSet不能遍历，是因为成员都是弱引用，随时可能消失，遍历机制无法保证成员的存在，很可能刚刚遍历结束，成员就取不到了。WeakSet的一个用处，是储存DOM节点，而不用担心这些节点从文档移除时，会引发内存泄漏。

### Map
### 实例属性和方法
size属性
set(key,value)
get(key)
has(key)
delete(key)
clear() 清楚所有成员

### map与数组
数组
```js
let myMap = new Map().set(true, 7).set({foo: 3}, ['abc']);
[...myMap]
// [ [ true, 7 ], [ { foo: 3 }, [ 'abc' ] ] ]

new Map([[true, 7], [{foo: 3}, ['abc']]])
// Map {true => 7, Object {foo: 3} => ['abc']}
```

### WeakMap

它只接受对象作为键名（null除外），不接受其他类型的值作为键名，而且键名所指向的对象，不计入垃圾回收机制。

典型应用是，一个对应DOM元素的WeakMap结构，当某个DOM元素被清除，其所对应的WeakMap记录就会自动被移除。基本上，WeakMap的专用场合就是，它的键所对应的对象，可能会在将来消失。WeakMap结构有助于防止内存泄漏。

weakmap除了像weakset一样可以用作存放dom节点外，还能够用于部署私有属性
```js
let _counter = new WeakMap();
let _action = new WeakMap();

class Countdown {
  constructor(counter, action) {
    _counter.set(this, counter);
    _action.set(this, action);
  }
  dec() {
    let counter = _counter.get(this);
    if (counter < 1) return;
    counter--;
    _counter.set(this, counter);
    if (counter === 0) {
      _action.get(this)();
    }
  }
}

let c = new Countdown(2, () => console.log('DONE'));

c.dec()
c.dec()
// DONE
```

### 遍历方法
Set和Map都支持keys(),values(),entries(),forEach()等遍历方式，对于set,keys()、values()、entries()三种遍历方式一模一样。forEach()遍历方式接受一个回调函数其中的两个参数分别为集合中的元素以及序号（表示当前是第几项）。

## Proxy
Proxy 用于修改某些操作的默认行为，等同于在语言层面做出修改，所以属于一种“元编程”（meta programming），即对编程语言进行编程。

```js
var proxy = new Proxy({}, {
    /*
    target:目标对象
    property:访问的属性
     */
  get: function(target, property) {
    return 35;
  }
});

proxy.time // 35
proxy.name // 35
proxy.title // 35
```

### 可拦截操作
- get(target, propKey, receiver) 拦截取值操作
- set(target, propKey, value, receiver) 拦截设值操作
- has(target, propKey) 拦截propKey in proxy操作
- deleteProperty(target, propKey) 拦截delete proxy[propKey]的操作
- ownKeys(target) 拦截Object.getOwnPropertyNames(proxy)、Object.getOwnPropertySymbols(proxy)、Object.keys(proxy)，返回一个数组。
- getOwnPropertyDescriptor(target, propKey) 拦截Object.getOwnPropertyDescriptor(proxy, propKey) 
- defineProperty(target, propKey, propDesc) 拦截Object.defineProperty(proxy, propKey, propDesc）、Object.defineProperties(proxy, propDescs) 
- preventExtensions(target) 拦截Object.preventExtensions(proxy)
- getPrototypeOf(target) 拦截Object.getPrototypeOf(proxy)
- isExtensible(target) 拦截Object.isExtensible(proxy)
- setPrototypeOf(target, proto) 拦截Object.setPrototypeOf(proxy, proto)
- apply(target, object, args) 拦截 Proxy 实例(即target函数的调用)作为函数调用的操作，比如proxy(…args)、proxy.call(object, …args)、proxy.apply(…)、Reflect.apply(proxy, null,args) 
- construct(target, args) 拦截 Proxy 实例作为构造函数调用的操作，比如new proxy(…args)。必须返回一个对象否则会报错

## Reflect
让Object操作都变成函数行为。某些Object操作是命令式，比如name in obj和delete obj[name]，而Reflect.has(obj, name)和Reflect.deleteProperty(obj, name)让它们变成了函数行为。

```js
// 老写法
'assign' in Object // true

// 新写法
Reflect.has(Object, 'assign') // true
```

Reflect对象的方法与Proxy对象的方法一一对应，只要是Proxy对象的方法，就能在Reflect对象上找到对应的方法。这就让Proxy对象可以方便地调用对应的Reflect方法，完成默认行为，作为修改行为的基础。也就是说，不管Proxy怎么修改默认行为，你总可以在Reflect上获取默认行为。

## Promise对象
Promise，简单说就是一个容器，里面保存着某个未来才会结束的事件（通常是一个异步操作）的结果。从语法上说，Promise 是一个对象，从它可以获取异步操作的消息。

Promise特点:
1. 对象的状态不受外界影响。Promise对象代表一个异步操作，有三种状态：Pending（进行中）、Resolved（已完成，又称 Fulfilled）和Rejected（已失败）。只有异步操作的结果，可以决定当前是哪一种状态，任何其他操作都无法改变这个状态
2. 一旦状态改变，就不会再变，任何时候都可以得到这个结果。

用法
```js
//两个函数resolve和reject由JS引擎提供不用自己部署。
var promise = new Promise(function(resolve, reject) {
  // ... some code

  if (/* 异步操作成功 */){
    resolve(value);
  } else {
    reject(error);
  }
});

//可以用then方法分别指定Resolved状态和Reject状态的回调函数。
promise.then(function(value) {
  // success
}, function(error) {
  // failure
});
```

Promise.all方法用于将多个Promise实例，包装成一个新的Promise实例。
```js
var p = Promise.all([p1, p2, p3]);
```

Promise.race只要p1、p2、p3之中有一个实例率先改变状态，p的状态就跟着改变。那个率先改变的 Promise 实例的返回值，就传递给p的回调函数。
```js
var p = Promise.race([p1, p2, p3]);
```

Promise.resolve将现有对象转为Promise对象，Promise.resolve方法就起到这个作用。
```js
Promise.resolve('foo')
// 等价于
new Promise(resolve => resolve('foo'))
```

### 两个有用的方法

done()Promise对象的回调链，不管以then方法或catch方法结尾，要是最后一个方法抛出错误，都有可能无法捕捉到（因为Promise内部的错误不会冒泡到全局）。因此，我们可以提供一个done方法，总是处于回调链的尾端，保证抛出任何可能出现的错误。
```js
Promise.prototype.done = function (onFulfilled, onRejected) {
  this.then(onFulfilled, onRejected)
    .catch(function (reason) {
      // 抛出一个全局错误
      setTimeout(() => { throw reason }, 0);
    });
};
```

finally方法用于指定不管Promise对象最后状态如何，都会执行的操作。它与done方法的最大区别，它接受一个普通的回调函数作为参数，该函数不管怎样都必须执行。
```js
Promise.prototype.finally = function (callback) {
  let P = this.constructor;
  return this.then(
    value  => P.resolve(callback()).then(() => value),
    reason => P.resolve(callback()).then(() => { throw reason })
  );
};
```

## Generator函数
Generator 函数是一个状态机，封装了多个内部状态。执行 Generator 函数会返回一个遍历器对象，可以依次遍历 Generator 函数内部的每一个状态。

### 基本使用
每次执行函数，会从yield返回对应的值

```js
function* f() {
  for(var i = 0; true; i++) {
    var reset = yield i;
    if(reset) { i = -1; }
  }
}

var g = f();

g.next() // { value: 0, done: false }
g.next() // { value: 1, done: false }
//next如果带参数，则yield会返回相应的参数
g.next(true) // { value: 0, done: false }
```

### Generator.prototype.throw()
Generator函数返回的遍历器对象，都有一个throw方法，可以在函数体外抛出错误，然后在Generator函数体内捕获。捕获后会顺带执行下一条yield，即执行一次next方法

```js
var g = function* () {
  try {
    yield;
  } catch (e) {
    console.log('内部捕获', e);
  }
};

var i = g();
i.next();

try {
  i.throw('a');
  i.throw('b');
} catch (e) {
  console.log('外部捕获', e);
}
// 内部捕获 a
// 外部捕获 b
```

一旦Generator执行过程中抛出错误，且没有被内部捕获，就不会再执行下去了。

### Generator.prototype.return()
return方法，可以返回给定的值，并且终结遍历Generator函数。如果Generator函数内部有try…finally代码块，那么return方法会推迟到finally代码块执行完再执行。

```js
function* numbers () {
  yield 1;
  try {
    yield 2;
    yield 3;
  } finally {
    yield 4;
    yield 5;
  }
  yield 6;
}
var g = numbers()
g.next() // { done: false, value: 1 }
g.next() // { done: false, value: 2 }
g.return(7) // { done: false, value: 4 }
g.next() // { done: false, value: 5 }
g.next() // { done: true, value: 7 }
```

### yield* 语句
yield*语句，用来在一个 Generator 函数里面执行另一个 Generator 函数。yield后面的Generator函数（没有return语句时），不过是for…of的一种简写形式，完全可以用后者替代前者。


```js
function* foo() {
  yield 'a';
  yield 'b';
}

function* bar() {
  yield 'x';
  yield* foo();
  yield 'y';
}

// 等同于
function* bar() {
  yield 'x';
  for (let v of foo()) {
    yield v;
  }
  yield 'y';
}
```

任何数据结构只要有Iterator接口，就可以被yield*遍历。

### 注意点
Generator函数总是返回一个遍历器，ES6规定这个遍历器是Generator函数的实例，也继承了Generator函数的prototype对象上的方法。

作为对象属性时generator的写法
```js
let obj = {
  * myGeneratorMethod() {
    ···
  }
};
//等价于
let obj = {
  myGeneratorMethod: function* () {
    // ···
  }
};
```

使得Generator能够使用this:
```js
function* F() {
  this.a = 1;
  yield this.b = 2;
  yield this.c = 3;
}
var f = F.call(F.prototype);

f.next();  // Object {value: 2, done: false}
f.next();  // Object {value: 3, done: false}
f.next();  // Object {value: undefined, done: true}

f.a // 1
f.b // 2
f.c // 3
```

使得Generator能够使用new:
```js
function* gen() {
  this.a = 1;
  yield this.b = 2;
  yield this.c = 3;
}

function F() {
  return gen.call(gen.prototype);
}

var f = new F();

f.next();  // Object {value: 2, done: false}
f.next();  // Object {value: 3, done: false}
f.next();  // Object {value: undefined, done: true}

f.a // 1
f.b // 2
f.c // 3
```

Generator函数被称为“半协程”（semi-coroutine），意思是只有Generator函数的调用者，才能将程序的执行权还给Generator函数。

除了for…of循环以外，扩展运算符（…）、解构赋值和Array.from方法内部调用的，都是遍历器接口。

## async
