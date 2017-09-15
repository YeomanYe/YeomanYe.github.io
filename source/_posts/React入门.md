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
本文介绍React的相关概念，使用方式。目的是使读者对React有一个大致的了解，以便于能够更加深入的学习、快速上手React。学习React要掌握其中的几个重要的概念JSX、元素（事件处理）、组件（props、state、ref、受控组件、生命周期）。

<!-- more -->

## React优缺点
React是一个前端框架，学习框架必然要了解框架的优缺点、以便根据不同的项目采用合适的框架。
优点：
- 能够实现服务器端的渲染，便于搜索引擎优化。
- 能够很好的和现有的代码结合。React只是MVC中的View层，对于其他的部分并没有硬性要求。
- 组件化的开发方式，能够更好的复用代码、更好的定位bug。
- 使用virtual dom，性能很好

缺点：
- 不是完整的开发框架需要加上其他东西才能写大型应用。

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

### 事件处理
驼峰式命名，使用函数名作为事件处理函数，需要使用e.preventDefault()来阻止默认行为，不能直接使用return false阻止返回值。

```html
<script type="text/babel">
class Toggle extends React.Component {
  constructor(props) {
    super(props);
    this.state = {isToggleOn: true};

    // This binding is necessary to make `this` work in the callback
    this.handleClick = this.handleClick.bind(this);
  }

  handleClick(e) {
    e.preventDefault();
    this.setState(prevState => ({
      isToggleOn: !prevState.isToggleOn
    }));
  }

  render() {
    return (
      <button onClick={this.handleClick}>
        {this.state.isToggleOn ? 'ON' : 'OFF'}
      </button>
    );
  }
}
</script>
```

e是一个合成事件不需要考虑跨浏览器的兼容性问题。


使用实验性的属性初始化器语法来绑定this

```html
<script type="text/babel">
class LoggingButton extends React.Component {
  // This syntax ensures `this` is bound within handleClick.
  // Warning: this is *experimental* syntax.
  handleClick = () => {
    console.log('this is:', this);
  }
  render() {
    return (
      <button onClick={this.handleClick}>
        Click me
      </button>
    );
  }
}
</script>
```


## 组件
顾明思议是用来将UI切分成可复用且独立的部件。

函数、类定义组件:
```html
<script type="text/babel">
function Welcome(props) {
  return <h1>Hello, {props.name}</h1>;
}

class Welcome extends React.Component {
   constructor(props) {
    super(props);
    this.state = {date: new Date()};
  }

  render() {
    return <h1>Hello, {this.props.name}</h1>;
  }
}

const element = <Welcome name="Sara" />;
</script>
```

组件之间可以像普通标签一样嵌套组合成新元素、新组件。

style属性的设置不能写成:style="opacity:{this.state.opacity};",而要写成style={{opacity: this.state.opacity}}。因为React组件样式是一个对象，所以第一重大括号表示这是JS语法，第二重大括号表示样式对象。

### props

class 属性需要写成 className ，for 属性需要写成 htmlFor ，这是因为 class 和 for 是 JavaScript 的保留字。

this.props 对象的属性与组件的属性一一对应，但是有一个例外，就是 this.props.children 属性。它表示组件的所有子节点

this.props.children 的值有三种可能：如果当前组件没有子节点，它就是 undefined ;如果有一个子节点，数据类型是 object ；如果有多个子节点，数据类型就是 array 。所以，处理 this.props.children 的时候要小心。

React 提供一个工具方法 React.Children 来处理 this.props.children 。我们可以用 React.Children.map 来遍历子节点，而不用担心 this.props.children 的数据类型是 undefined 还是 object。

props的值不能够被改变。

使用propTypes来验证别人使用组件时，提供的参数是否符合要求
使用defaultProps设置默认值

```js
Greeting.propTypes = {
    title: React.PropTypes.string.isRequired,
    //限制为一个子代
    children: PropTypes.element.isRequired
};
Greeting.defaultProps = {
    name:"test"
};
```

### state
每当组件的状态state发生改变时，组件就可以自动的更新。

state在构造函数中初始化，使用书面语的形式，即this.state = {}

状态的更新需要使用setState(可接收对象或函数(参数是上一个状态、props))函数，不能直接使用书面语(this.state.comment = "")

this.props 和 this.state 可能是异步更新的，不能直接依靠它们来计算state，而应该是使用函数的形式。

### 列表 & Keys
Keys可以在DOM中的某些元素被增加或删除的时候帮助React识别哪些元素发生了变化。因此你应当给数组中的每一个元素赋予一个确定的标识。

key应该在数组中被明确出来，可以使用id或索引来作为key

```html
<script type="text/babel">
const todoItems = todos.map((todo, index) =>
  // Only do this if items have no stable IDs
  <li key={index}>
    {todo.text}
  </li>
);
</script>
```

### 受控组件
在HTML当中，像`<input>`,`<textarea>`, 和 `<select>`这类表单元素会维持自身状态，并根据用户输入进行更新。但在React中，可变的状态通常保存在组件的状态属性中，并且只能用 setState(). 方法进行更新.

因此使用“受控组件”的形式来编写表单组件(值统一写在value属性中，更新方法写在onChange函数中)

多个受控组件的统一解决方案，动态确定state的属性

```html
<script type="text/babel">
class Reservation extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      isGoing: true,
      numberOfGuests: 2
    };

    this.handleInputChange = this.handleInputChange.bind(this);
  }

  handleInputChange(event) {
    const target = event.target;
    const value = target.type === 'checkbox' ? target.checked : target.value;
    const name = target.name;

    this.setState({
      [name]: value
    });
  }

  render() {
    return (
      <form>
        <label>
          Is going:
          <input
            name="isGoing"
            type="checkbox"
            checked={this.state.isGoing}
            onChange={this.handleInputChange} />
        </label>
        <br />
        <label>
          Number of guests:
          <input
            name="numberOfGuests"
            type="number"
            value={this.state.numberOfGuests}
            onChange={this.handleInputChange} />
        </label>
      </form>
    );
  }
}
</script>
```

### 非受控组件
在受控组件中，表单数据由 React 组件处理。如果让表单数据由 DOM 处理时，替代方案为使用非受控组件。(使用ref获取DOM并取值(必须要等到DOM插入后才能获得DOM)，使用defaultValue设置默认值)

```html
<script type="text/babel">
class NameForm extends React.Component {
  constructor(props) {
    super(props);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleSubmit(event) {
    alert('A name was submitted: ' + this.input.value);
    event.preventDefault();
  }
    render() {
      return (
        <form onSubmit={this.handleSubmit}>
          <label>
            Name:
            <input
              defaultValue="Bob"
              type="text"
              ref={(input) => this.input = input} />
          </label>
          <input type="submit" value="Submit" />
        </form>
      );
    }
}
</script>
```

### 状态提升
如果多个组件中有需要共用的状态，应该将该状态设置在父组件上，来实现状态共享。

```html
<script type="text/babel">
const scaleNames = {
  c: 'Celsius',
  f: 'Fahrenheit'
};

function toCelsius(fahrenheit) {
  return (fahrenheit - 32) * 5 / 9;
}

function toFahrenheit(celsius) {
  return (celsius * 9 / 5) + 32;
}

function tryConvert(temperature, convert) {
  const input = parseFloat(temperature);
  if (Number.isNaN(input)) {
    return '';
  }
  const output = convert(input);
  const rounded = Math.round(output * 1000) / 1000;
  return rounded.toString();
}

function BoilingVerdict(props) {
  if (props.celsius >= 100) {
    return <p>The water would boil.</p>;
  }
  return <p>The water would not boil.</p>;
}

class TemperatureInput extends React.Component {
  constructor(props) {
    super(props);
    this.handleChange = this.handleChange.bind(this);
  }

  handleChange(e) {
    this.props.onTemperatureChange(e.target.value);
  }

  render() {
    const temperature = this.props.temperature;
    const scale = this.props.scale;
    return (
      <fieldset>
        <legend>Enter temperature in {scaleNames[scale]}:</legend>
        <input value={temperature}
               onChange={this.handleChange} />
      </fieldset>
    );
  }
}

class Calculator extends React.Component {
  constructor(props) {
    super(props);
    this.handleCelsiusChange = this.handleCelsiusChange.bind(this);
    this.handleFahrenheitChange = this.handleFahrenheitChange.bind(this);
    this.state = {temperature: '', scale: 'c'};
  }

  handleCelsiusChange(temperature) {
    this.setState({scale: 'c', temperature});
  }

  handleFahrenheitChange(temperature) {
    this.setState({scale: 'f', temperature});
  }

  render() {
    const scale = this.state.scale;
    const temperature = this.state.temperature;
    const celsius = scale === 'f' ? tryConvert(temperature, toCelsius) : temperature;
    const fahrenheit = scale === 'c' ? tryConvert(temperature, toFahrenheit) : temperature;

    return (
      <div>
        <TemperatureInput
          scale="c"
          temperature={celsius}
          onTemperatureChange={this.handleCelsiusChange} />
        <TemperatureInput
          scale="f"
          temperature={fahrenheit}
          onTemperatureChange={this.handleFahrenheitChange} />
        <BoilingVerdict
          celsius={parseFloat(celsius)} />
      </div>
    );
  }
}

ReactDOM.render(
  <Calculator />,
  document.getElementById('root')
);

</script>
```

### 生命周期
组件的生命周期分成三个状态：
- Mounting：已插入真实 DOM
- Updating：正在被重新渲染
- Unmounting：已移出真实 DOM

React 为每个状态都提供了两种处理函数，will 函数在进入状态之前调用，did 函数在进入状态之后调用，三种状态共计五种处理函数。
- componentWillMount()
- componentDidMount()
- componentWillUpdate(object nextProps, object nextState)
- componentDidUpdate(object prevProps, object prevState)
- componentWillUnmount()

此外，React 还提供两种特殊状态的处理函数。
- componentWillReceiveProps(object nextProps)：已加载组件收到新的参数时调用
- shouldComponentUpdate(object nextProps, object nextState)：组件判断是否重新渲染时调用


参考文献：
[React入门实例教程——阮一峰](http://www.ruanyifeng.com/blog/2015/03/react.html)
[React文档15.6](https://discountry.github.io/react/)
[React优缺点](https://www.zhihu.com/question/33471134)
