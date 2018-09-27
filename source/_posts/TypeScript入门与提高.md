title: TypeScript入门与提高
tags:
    - JavaScript
    - 前端
comments: true
brief: TypeScript入门与提高
date: 2018-06-03
categories:
    - 前端
---
# TypeScript入门与提高
TypeScript是一种由微软开发的自由和开源的编程语言。它是JavaScript的一个严格超集，并添加了可选的静态类型和基于类的面向对象编程。相比于当下的es6、es7、es8，ts并没有增加新的功能，而是建立了静态类型机制。方便项目的开发与维护。

<!-- more -->

## 基本
给变量设置类型，基本类型：boolean、number、string、null、undefined。
```ts
let isDone: boolean = false; // tsc => var isDone = false;
```

### 数组
数组类型可以通过以下两种方式表示
```ts
let names:Array<string>;
let persons:Person[];
let ages:ages[];
```

### 接口
在面向对象语言中，接口（Interfaces）是一个很重要的概念，它是对行为的抽象，而具体如何行动需要由类（classes）去实现（implements）。

TypeScript 中的接口是一个非常灵活的概念，除了可用于对类的一部分行为进行抽象以外，也常用于对「对象的形状（Shape）」进行描述。

描述对象的形状
```ts
interface Person {
  name: string;
  age: number;
}

let semlinker: Person = {
  name: 'Semlinker',
  age: 31
};
```

可选与只读属性，可选属性表示属性此属性可有可无；只读属性表示，此属性不可被改变。
```ts
interface Person{
    readonly name: string;
    age?: number;
}
```

#### 接口继承
与其他语言中一样接口可以继承接口，只需使用extends关键字即可。
```ts
interface Shape {
    color: string;
}

interface PenStroke {
    penWidth: number;
}

interface Square extends Shape, PenStroke {
    sideLength: number;
}

```

#### 接口继承类
与其他语言不同的，ts中接口可以继承类。但接口不会继承类的实现，接口同样会继承到private和protected的成员，这意味着当创建了一个接口继承了一个拥有私有或受保护的成员的类时，这个接口类型只能被这个类或其子类所实现。

```ts
class Control {
    private state: any;
}

interface SelectableControl extends Control {
    select(): void;
}

class Button extends Control implements SelectableControl {
    select() { }
}

class TextBox extends Control {
    select() { }
}

// 错误：“Image”类型缺少“state”属性。
class Image implements SelectableControl {
    select() { }
}

class Location {

}
```

### 函数类型
给函数设置类型，只要给函数的参数设置类型，设置返回值类型，即能确定一个函数的类型。
```ts
function setUser(name:string,age?:number,...rest:string[]):void{

}
let setUser:(name:string,age?:number,...rest:string[]) => void
```

age参数为可选参数，rest参数为剩余参数，除name和age以外的所有参数构成了剩余参数rest。

### 枚举
#### 数字枚举
不定义枚举初始化值时，枚举的值从0开始自增长。当定义了第一个枚举的值时，其他枚举的值根据第一个值进行自增长。
```ts
enum Direction {
    Up = 2,
    Down, // 3
    Left, // 4
    Right, // 5
}
```

#### 字符串枚举
在一个字符串枚举里，每个成员都必须用字符串字面量，或另外一个字符串枚举成员进行初始化。
```ts
enum E {
    X = 'E',Y = 5,X1 = X
}
```

可以混合使用数字与字符串作为枚举成员的值，不过不推荐这么使用。

#### 联合枚举
可以使用联合类型来设置枚举
```ts
let direction: 'up' | 'down' | 'left' | 'right';
```

### 其他类型
- any:表示任意类型
- tuple:元组类型允许表示一个已知元素数量和类型的数组。`let x: [string, number];`
- void:该类型像是与 any 类型相反，它表示没有任何类型。 用于函数没有返回值时
- never:该类型是那些总是会抛出异常或根本就不会有返回值的函数表达式或箭头函数表达式的返回值类型。


### 类型断言
使用尖括号`<>`来进行类型断言，即强制让编译器认为该变量是此类型
```ts
if ((<Fish>pet).swim) {
    (<Fish>pet).swim();
}
```

使用!去除null、undefined等空值
```ts
function broken(name: string | null): string {
  function postfix(epithet: string) {
    return name.charAt(0) + '.  the ' + epithet; // error, 'name' is possibly null
  }
  name = name || "Bob";
  return postfix("great");
}

function fixed(name: string | null): string {
  function postfix(epithet: string) {
    return name!.charAt(0) + '.  the ' + epithet; // ok
  }
  name = name || "Bob";
  return postfix("great");
}
```

## 高级类型
### 交叉类型
使用`&`符号来表示，如：`A & B`表示这个类型是A类型并且是B类型

### 联合类型
使用`|`符号来表示，如：`A | B`表示这个类型是A类型或者是B类型

### 类型保护
用于当值为不同类型，处理方式不同的情况。类型保护就是一些表达式，它们会在运行时检查以确保在某个作用域里的类型。 要定义一个类型保护，我们只要简单地定义一个函数，它的返回值是一个 类型谓词

#### 用户自定义
使用能力判断是否为某种类型，两种类型时判定一种，第二种自然确定
```ts
function isFish(pet: Fish | Bird): pet is Fish {
    return (<Fish>pet).swim !== undefined;
}
```

#### 使用typeof进行判定
```ts
function isNumber(x: any): x is number {
    return typeof x === "number";
}

function isString(x: any): x is string {
    return typeof x === "string";
}

function padLeft(value: string, padding: string | number) {
    if (isNumber(padding)) {
        return Array(padding + 1).join(" ") + value;
    }else if (isString(padding)) {
        return padding + value;
    }
    throw new Error(`Expected string or number, got '${padding}'.`);
}
```

### 类型别名
可以使用泛型
```ts
type LinkedList<T> = T & { next: LinkedList<T> };

interface Person {
    name: string;
}

var people: LinkedList<Person>;
var s = people.name;
var s = people.next.name;
var s = people.next.next.name;
var s = people.next.next.next.name;
```
类型别名不能被 extends和 implements，如果无法通过接口来描述一个类型并且需要使用联合类型或元组类型，这时通常会使用类型别名。

### 可辨识联合
将具有相同属性的类型联合成为一个类型，判断那个相同的属性即可知道类型。
```ts
interface Square {
    kind: "square";
    size: number;
}
interface Rectangle {
    kind: "rectangle";
    width: number;
    height: number;
}
interface Circle {
    kind: "circle";
    radius: number;
}

type Shape = Square | Rectangle | Circle;

//断言函数，用于完整性检查
function assertNever(x: never): never {
    throw new Error("Unexpected object: " + x);
}

function area(s: Shape) {
    switch (s.kind) {
        case "square": return s.size * s.size;
        case "rectangle": return s.height * s.width;
        case "circle": return Math.PI * s.radius ** 2;
        default: return assertNever(s); // 如果switch没有涵盖所有情况，编译器会报错
    }
}
```

### this类型
用于连贯性的操作
```ts
class BasicCalculator {
    public constructor(protected value: number = 0) { }
    public currentValue(): number {
        return this.value;
    }
    public add(operand: number): this {
        this.value += operand;
        return this;
    }
    public multiply(operand: number): this {
        this.value *= operand;
        return this;
    }
    // ... other operations go here ...
}

class ScientificCalculator extends BasicCalculator {
    public constructor(value = 0) {
        super(value);
    }
    public sin() {
        this.value = Math.sin(this.value);
        return this;
    }
    // ... other operations go here ...
}

let v = new ScientificCalculator(2)
        .multiply(5)
        .sin()
        .add(1)
        .currentValue();
```

如果不存在this，multiply返回的对象调用sin编译器就会报错。

### 索引类型
使用索引类型，编译器就能够检查使用了动态属性名的代码。

```ts
function pluck<T, K extends keyof T>(o: T, names: K[]): T[K][] {
  return names.map(n => o[n]);
}
let personProps: keyof Person; // 'name' | 'age'
```
索引访问操作符`T[K]`，只要确保类型变量 K extends keyof T就可以在普通的上下中使用。返回的类型，会随着需要而改变

```ts
function getProperty<T, K extends keyof T>(o: T, name: K): T[K] {
    return o[name]; // o[name] is of type T[K]
}

let name: string = getProperty(person, 'name');
let age: number = getProperty(person, 'age');
let unknown = getProperty(person, 'unknown'); // error, 'unknown' is not in 'name' | 'age'
```

 如果你有一个带有字符串索引签名的类型，那么 keyof T会是 string。 并且 T[string]为索引签名的类型

```ts
interface Map<T> {
    [key: string]: T;
}
let keys: keyof Map<number>; // string
let value: Map<number>['foo']; // number
```

### 映射类型
映射类型是一种从旧类型创建新类型的方式。

```ts
type Readonly<T> = {
    readonly [P in keyof T]: T[P];
}

type Partial<T> = { [P in keyof T]?: T[P] }
//使用
type WrapPerson = Partial<Readonly<Person>>;
```



## 命名空间
使用命名空间相当于使用了一个命名对象,包裹了原有的模块，原有模块中的内容不使用export导出，在外部是不可见的。

在外部文件引用模块需要可以使用import也可以使用形如`/// <reference path="Validation.ts" />`这样的注释。使用注释的好处是可以将同名的命名空间分割到不同的文件中，通过注释引入可以自动合并，并且通过注释引入不需要使用export关键字导入。

```ts
namespace Validation {
    export interface StringValidator {
        isAcceptable(s: string): boolean;
    }

    const lettersRegexp = /^[A-Za-z]+$/;
    const numberRegexp = /^[0-9]+$/;

    export class LettersOnlyValidator implements StringValidator {
        isAcceptable(s: string) {
            return lettersRegexp.test(s);
        }
    }

    export class ZipCodeValidator implements StringValidator {
        isAcceptable(s: string) {
            return s.length === 5 && numberRegexp.test(s);
        }
    }
}

/// <reference path="Validation.ts" />
// Some samples to try
let strings = ["Hello", "98052", "101"];

// Validators to use
let validators: { [s: string]: Validation.StringValidator; } = {};
validators["ZIP code"] = new Validation.ZipCodeValidator();
validators["Letters only"] = new Validation.LettersOnlyValidator();
```

命名空间可以被嵌套，也可以设置别名

```ts
//嵌套命名空间
namespace Shapes {
    export namespace Polygons {
        export class Triangle { }
        export class Square { }
    }
}

//设置别名，注意与import导入的区别
import polygons = Shapes.Polygons;
let sq = new polygons.Square(); // Same as "new Shapes.Polygons.Square()"
```

## 声明合并
### 接口合并
接口的非函数的成员应该是唯一的。如果它们不是唯一的，那么它们必须是相同的类型。如果两个接口中同时声明了同名的非函数成员且它们的类型不同，则编译器会报错。

对于函数成员，每个同名函数声明都会被当成这个函数的一个重载。 同时需要注意，当接口 A与后来的接口 A合并时，后面的接口具有更高的优先级。

如果签名里有一个参数的类型是 单一的字符串字面量（比如，不是字符串字面量的联合类型），那么它将会被提升到重载列表的最顶端。

### 命名空间合并
对于命名空间的合并，模块导出的同名接口进行合并，构成单一命名空间内含合并后的接口。

对于命名空间里值的合并，如果当前已经存在给定名字的命名空间，那么后来的命名空间的导出成员会被加到已经存在的那个模块里。非导出成员仅在其原有的（合并前的）命名空间内可见。

### 命名空间与其他类型
从宏观角度来看都是给它们增加属性。

#### 类
给类添加成员、方法、内部类
```ts
class Album {
    label: Album.AlbumLabel;
}
namespace Album {
    export class AlbumLabel { }
}
```

#### 函数
扩展函数，给它增加一些属性
```ts
function buildLabel(name: string): string {
    return buildLabel.prefix + name + buildLabel.suffix;
}

namespace buildLabel {
    export let suffix = "";
    export let prefix = "Hello, ";
}

alert(buildLabel("Sam Smith"));
```

#### 枚举
给枚举添加方法
```ts
enum Color {
    red = 1,
    green = 2,
    blue = 4
}

namespace Color {
    export function mixColor(colorName: string) {
        if (colorName == "yellow") {
            return Color.red + Color.green;
        }
        else if (colorName == "white") {
            return Color.red + Color.green + Color.blue;
        }
        else if (colorName == "magenta") {
            return Color.red + Color.blue;
        }
        else if (colorName == "cyan") {
            return Color.green + Color.blue;
        }
    }
}
```

## 参考文献
[TypeScript手册](https://www.tslang.cn/docs/handbook/basic-types.html)
[TypeScript简介及编码规范](https://semlinker.com/ts-intro-and-guide/#%E5%8F%AF%E9%80%89-%E5%8F%AA%E8%AF%BB%E5%B1%9E%E6%80%A7)