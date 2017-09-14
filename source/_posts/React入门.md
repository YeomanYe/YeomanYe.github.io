title: React入门
tags:
    - React
    - 前端框架
comments: true
brief: React入门概览
date: 2017-06-24
categories:
    - 前端框架
---
# React入门
本文介绍React的相关概念，使用方式。目的是使读者对React有一个大致的了解，以便于能够更加深入的学习、快速上手React。

<!-- more -->
## JSX
JSX是JavaScript Syntax eXtension的缩写，它是一种在JavaScript中嵌入XML的React语法，类似于E4X。React推荐使用JSX来描述用户界面

JSX语法需要写在`<script type="text/babel"></script>`标签中或者使用babel转码器进行转码

JSX基本语法规则:遇到 HTML 标签（以 < 开头），就用 HTML 规则解析；遇到代码块（以 { 开头），就用 JavaScript 规则解析。

JSX 允许直接在模板插入 JavaScript 变量。如果这个变量是一个数组，则会展开这个数组的所有成员

```html
<script type="text/babel">
var arr = [
  <h1>Hello world!</h1>,
  <h2>React is awesome</h2>,
];
ReactDOM.render(
  <div>{arr}</div>,
  document.getElementById('example')
);
</script>
```

## 元素
元素是构成React应用的最小单位，React中元素时普通的对象。React DOM可以确保浏览器DOM的数据内容与React元素保持一致。

```js
const element = <h1>Hello, world</h1>;
// 使用ReactDOM.render渲染到页面上
ReactDOM.render(
  element,
  document.getElementById('root')
);
```

当元素被创建之后，是无法改变其内容或属性的。如果想要改变需要将它传入ReactDOM.render()方法中。(react只会渲染必要的部分)

元素除了可以是DOM元素外，还可以是自定义的组件。

## 组件
顾明思议是用来将UI切分成可复用且独立的部件。

函数、类定义组件:
```js
function Welcome(props) {
  return <h1>Hello, {props.name}</h1>;
}

class Welcome extends React.Component {
  render() {
    return <h1>Hello, {this.props.name}</h1>;
  }
}

const element = <Welcome name="Sara" />;
```

组件之间可以像普通标签一样嵌套组合成新元素、新组件。

props的值不能够被改变。