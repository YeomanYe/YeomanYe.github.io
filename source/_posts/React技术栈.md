title: React技术栈
tags:
    - React
    - 前端框架
comments: true
brief: React技术栈
date: 2018-07-15
categories:
    - 前端
---
# React技术栈
React是facebook开源的一套用于构建用户界面的高效且灵活的前端框架。然而仅仅使用react，只能够做到页面UI的组件化，数据单向流动，UI随数据响应式变化。单单只使用react会造成多层级组件间数据交互的困难，以及组件状态维护的麻烦。因此出现了许多工具来帮助管理、维护react的状态，如：reflux、mobx、redux等。有了这两个工具后，就能很好的管理view与data的逻辑。一般react开发者还会添加react-router，来更好的处理view与路径的关系。

<!-- more -->
使用react开发，最常搭配的工具是redux、react-router。本文将介绍它们的核心功能。

## React
React主要作用：

- 使用简单的声明式更新视图UI
- 将UI进行组件化分割便于复用

### 声明式更新UI
react中每个组件可存在state（组件内部状态）、props（组件外部属性）两种数据源（使用函数声明的组件只存在props，使用类声明的组件可以存在state）。组件内部要想改变数据源，只能通过调用setState方法来改变state，从而触发state相关的视图的更新。组件外部要想改变组件，只能通过改变组件的props属性，来触发绑定的属性的视图的更新。

```jsx
function Child({text}){
    return(
        <p>{text}</p>
    )
}
class Root extends Component{
    constructor(props) {
      super(props);
        
      this.state = {text:''};
    }
    render(){
        return (
            <div>
                <Child text={text}/>
            </div>
        );
    }
}

```

由上可知Child的props通过Root传入，Root组件不改变state的话，则Root组件UI不会更新，也就不会导致Child组件UI更新。由此可知改变组件只能通过setState方式。

表单数据绑定比起一般的视图稍有不同，一般组件直接将数据绑定到UI的属性，文本上即可。
如:`<p className={pClass}>{pText}</p>`
表单绑定数据，需要绑定表单的value，并且需要编写对应的事件监听，当值发生变化时改变state
`<input value={msg} onChange={msg=>this.setState({msg})} type="text" />`

react还有一种让表单数据由dom进行处理的，非受控表单方式
```js
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
          <input type="text" ref={(input) => this.input = input} />
        </label>
        <input type="submit" value="Submit" />
      </form>
    );
  }
}
```

### UI组件分割
由上面例子可知，UI组件的分割可以使用函数，也可以使用类。使用函数则无法监听React生命周期，组件内部仅有props没有state，组件UI的更新完全由外部组件控制。使用类的方式，组件可以监听该组件的生命周期，组件内部可设置state数据源，组件内部可以更新组件UI。

虽然使用组件的方式功能更加丰富强大，但是React官方更推荐使用函数的方式来创建组件，其一是使用函数的方式创建的组件更简单、更易于维护；其二是使用类创建的组件，每次创建新组件就会生成一个新实例，比起使用函数方式创建组件，使用类方式创建组件资源消耗更大。

组件间通信：
父 -> 子，使用props传递
子 -> 父，传递函数，由子元素调用
任意两组件，使用全局事件

#### Fragments
使用Fragments可以让一个组件返回多个元素

```js
() = =>
<React.Fragment>
    <td>Hello</td>
    <td>World</td>
  </React.Fragment>
```
该组件将会返回`<td>Hello</td> <td>World</td>`两个元素，在react中`<></>`是React.Fragment的语法糖

#### React.Children
React.Children 提供了处理 this.props.children 这个不透明数据结构的工具。

React.Children.toArray(children)主要使用该函数，将子组件映射到父组件中需要的位置。

### 其他
#### React生命周期
![React生命周期](react-lifecycle.jpg)

从图中可以看出react生命周期可以分为三个阶段，四个流程：

组件加载阶段
getDefaultProps -> getInitialState -> componentWillMount -> render -> componentDidMount

组件更新阶段
- state改变引起的数据更新
shouldComponentUpdate -> componentWillUpdate -> render -> componentDidUpdate
- props改变引起的数据更新
componentWillReceiveProps -> state更新阶段

可以在shouldComponentUpdate与componentWillReceiveProps两个生命周期函数中进行逻辑处理减少不必要的视图更新。
注意：如果重写了componentWillReceiveProps方法，则必须在其中手动调用setState才能更新视图。

组件销毁阶段
componentWillMount

#### 高阶组件
高阶组件就是一个函数，且该函数接受一个组件作为参数，并返回一个新的组件

```js
function logProps(WrappedComponent) {
  return class extends React.Component {
    componentWillReceiveProps(nextProps) {
      console.log('Current props: ', this.props);
      console.log('Next props: ', nextProps);
    }
    render() {
      // 用容器组件组合包裹组件且不修改包裹组件，这才是正确的打开方式。
      return <WrappedComponent {...this.props} />;
    }
  }
}
```

高阶组件良好的设计模式：
1. 最大限度的使用组合
2. 将不想关的props属性传递给包裹组件
3. 包装显示名字以便调试

例如：
```js
function withSubscription(WrappedComponent) {
  class WithSubscription extends React.Component {
    render() {
      // 过滤掉与高阶函数功能相关的props属性，
      // 不再传递
      const { extraProp, ...passThroughProps } = this.props;

      // 向包裹组件注入props属性，一般都是高阶组件的state状态
      // 或实例方法
      const injectedProp = someStateOrInstanceMethod;

      // 向包裹组件传递props属性
      return (
        <WrappedComponent
          injectedProp={injectedProp}
          {...passThroughProps}
        />
      );
    }
  }
  WithSubscription.displayName = `WithSubscription(${getDisplayName(WrappedComponent)})`;
  return WithSubscription;
}

function getDisplayName(WrappedComponent) {
  return WrappedComponent.displayName || WrappedComponent.name || 'Component';
}
```

注意事项：
1. 不要再render函数中使用高阶组件
2. 必须将静态方法做拷贝(原始组件被容器组件包裹，意味着新组件会丢失原始组件的所有静态方法。)
3. refs属性不能传递

## Redux
Redux是使用JavaScript编写的一个状态管理工具，它并非针对react，它还可用在其他的前端框架上如vue、angular等等。

redux本身的api极少只有：createStore、Store、combineReducers、applyMiddleware、bindActionCreators、compose这几个。

但是通过中间件，以及store增强器又让redux变的可无限延展。

![redux](redux.jpg)

从图中可以看出view从store中获取数据展示，view产生action，action经过reducer过滤最终将数据存储进store中。

示例计数器：

```js
const Counter = ({ value, onIncrement, onDecrement }) => (
  <div>
  <h1>{value}</h1>
  <button onClick={onIncrement}>+</button>
  <button onClick={onDecrement}>-</button>
  </div>
);

const reducer = (state = 0, action) => {
  switch (action.type) {
    case 'INCREMENT': return state + action.num;
    case 'DECREMENT': return state - action.num;
    default: return state;
  }
};

const store = createStore(reducer);

const render = () => {
  ReactDOM.render(
    <Counter
      value={store.getState()}
      onIncrement={() => store.dispatch({type: 'INCREMENT',num:2})}
      onDecrement={() => store.dispatch({type: 'DECREMENT',num:3})}
    />,
    document.getElementById('root')
  );
};

render();
store.subscribe(render);
```
从代码中可以看出，redux使用reducer函数作为createStore函数参数生成store。store能够获得state也能分发action。store.subscribe用于设置监听函数，当store中的state改变时，自动调用监听函数。

直接使用redux管理react的状态明显还是很麻烦，因此react官方又编写了react-redux模块用以方便管理react状态。

将上面的计数器使用react-redux改造将会变成

```js
import React from 'react';
import ReactDOM from 'react-dom';
import {Provider,connect} from 'react-redux';
const Counter = ({ value, onIncrement, onDecrement }) => (
  <div>
  <h1>{value}</h1>
  <button onClick={onIncrement}>+</button>
  <button onClick={onDecrement}>-</button>
  </div>
);

const reducer = (state = 0, action) => {
  switch (action.type) {
    case 'INCREMENT': return state + action.num;
    case 'DECREMENT': return state - action.num;
    default: return state;
  }
};

const mapStateToProps = (state,ownProps) => ({value:state});
const mapDispatchToProps = dispatch => ({
    onIncrement:() => dispatch({type: 'INCREMENT',num:2}),
    onDecrement:() => dispatch({type: 'DECREMENT',num:2}),
})

const CounterContainer = connect(mapStateToProps,mapDispatchToProps)(Counter);

const store = createStore(reducer);

ReactDOM.render(
    <Provider store={store}>
        <CounterContainer />
    </Provider>,
    document.getElementById('root')
  );
```

react-redux的主要作用就是将store中的state与组件对应的props相关联，将发送dispatch的逻辑函数与props相关联生成容器组件，解耦视图与数据的耦合关系。

### middleware
Redux 的中间件提供的是位于 action 被发起之后，到达 reducer 之前的扩展点，换而言之，原本 view -> action -> reducer -> store 的数据流加上中间件后变成了 view -> action -> middleware -> reducer -> store ，在这一环节我们可以做一些 “副作用” 的操作，如 异步请求、打印日志等。

如打印日志:
```js
import { createStore, applyMiddleware } from 'redux'
/** 定义中间件 **/
const logger = ({ getState, dispatch }) => next => action => {
  console.log('【logger】即将执行:', action)

    // 调用 middleware 链中下一个 middleware 的 dispatch。
  let returnValue = next(action)

  console.log('【logger】执行完成后 state:', getState())
  return returnValue
}
/** 创建 store**/
let store = createStore(reducer, initState, applyMiddleware(logger))

/** 现在尝试发送一个 action**/
store.dispatch({
  type: 'CHANGE_SCORE',
  score: 0.8
})
/** 打印:**/
// 【logger】即将执行: { type: 'CHANGE_SCORE', score: 0.8 }
// 【logger】执行完成后 state: { score: 0.8 }
```

为了解耦合分发action与业务逻辑的耦合关系。一般使用形如：redux-thunk、redux-promise、redux-saga（当下最为流行）的中间件来实现如dispatch分发函数、promise、监听分发的action等方式。从而达到业务逻辑与分发action的解耦。

### store enhancer
与React高阶组件相似的，store enhancer是一个高阶函数，它的参数是创建store的函数（store creator），返回值是一个可以创建功能更加强大的store的函数(enhanced store creator)。它出现在createStore的api中,`createStore(reducer, [preloadedState], [enhancer])`

打印日志功能的enhancer：
```js
// autoLogger.js
// store enhancer
export default function autoLogger() {
  return createStore => (reducer, initialState, enhancer) => {
    const store = createStore(reducer, initialState, enhancer)
    function dispatch(action) {
      console.log(`dispatch an action: ${JSON.stringify(action)}`);
      const res = store.dispatch(action);
      const newState = store.getState();
      console.log(`current state: ${JSON.stringify(newState)}`);
      return res;
    }
    return {...store, dispatch}
  }
}

// configureStore.js
import { createStore, applyMiddleware } from 'redux';
import rootReducer from 'path/to/reducers';
import autLogger from 'path/to/autoLogger';

const store = createStore(
  reducer，
  autoLogger()
);
```

applyMiddleware(...middlewares)的执行结果就是一个store enhancer，它主要用来修改store的dispatch方法，这也确实是middleware的作用：增强store的dispatch功能。middleware实际上是在applyMiddleware(...middlewares) 这个store enhancer之上的一层抽象。

applyMiddleware(...middlewares) 传递给每一个middleware参数{getState, dispatch}，middleware对dispatch方法进行加强。

同时使用多个enhancer时，可以使用redux提供的compose方法，将它们合并成一个。
```js
// configureStore.js
import { createStore, applyMiddleware, compose } from 'redux';
import rootReducer from 'path/to/reducers';
import autLogger from 'path/to/autoLogger';

const enhancer = compose(
  applyMiddleware(...middlewares),
  autLogger()
);

const store = createStore(
  reducer，
  enhancer
);
```

示例：[TodoMVC](https://github.com/YeomanYe/todomvc-example)

## React Router v4
react router作为react的路由，已经成为react技术栈的标准。v4版的react-router被拆分成了四个包，react-router、react-router-dom、react-router-native、react-router-config。
- react-router:核心包一般不直接使用，而是在特定的环境下使用它封装好的包。
- react-router-config:配置静态路由的小助手配合react-router-dom、react-router-native一起使用。
- react-router-dom：react-router在web环境中的组件化封装
- react-router-native：react-router在react-native环境中的组件化封装

以下介绍的是在web环境中使用的的react-router-dom。在react-native中官方更推荐使用react-navigation

### 基础
创建一个能被浏览器导航到的路由，最基本的是使用`<Router>`和`<Route>`组件。

```html
<Router>
  <Route exact path="/" component={Home}/>
</Router>
```
#### Router
`<Router>`作为根组件保证 UI 界面和 URL 保持同步。
- BrowserRouter使用了HTML5 history API来记录历史的高级组件
- HashRouter使用hash部分来记录，兼容老式浏览器

#### Route
`<Route>`
它基本的职责是当页面的访问地址与 Route 上的 path 匹配时，就渲染出对应的 UI 界面。
它具有三种渲染方式（同一个Route只能使用其中一种渲染方式），所有渲染方式都会传入props({match、location、history})：
- `<Route component>` router 将使用 React.createElement 根据给定的 component 创建一个新的 React 元素。这意味着如果你使用内联函数（inline function）传值给 component 将会产生不必要的重复装载。
- `<Route render>` 此方法适用于内联渲染，而且不会产生上文说的重复装载问题。
- `<Route children>` childrenprop跟render很类似，也期望一个函数返回一个React元素。然而，不管路径是否匹配，children都会渲染。

match 对象包含了 `<Route path>` 如何与 URL 匹配的信息，具有以下属性：
其他props：
- path 任何可以被path-to-regexp解析的有效 URL 路径
- exact: bool 如果为 true，path 为 '/one' 的路由将不能匹配 '/one/two'，反之，亦然。
- strict: bool 对路径末尾斜杠的匹配。如果为 true。path 为 '/one/' 将不能匹配 '/one' 但可以匹配 '/one/two'。

location 是指你当前的位置，将要去的位置，或是之前所在的位置
```js
{
  key: 'sdfad1'
  pathname: '/about',
  search: '?name=minooo'
  hash: '#sdfas',
  state: {
    price: 123
  }
}
```

history是用于控制历史的api，Link相当于history的push。Redirect相当于history的replace。

#### Link 与 NavLink
`<Link>`用来跳转页面。可以类比HTML的锚元素。然而，使用锚链接会导致浏览器的刷新，这不是我们想要的。所以，我们可以使用`<Link>`来跳转至具体的URL，并且视图重新渲染不会导致浏览器刷新。

`<NavLink>`相比于Link多了activeClassName，activeStyle以及isActive，它是当导航需要有激活状态时，使用的。

#### Redirect
`<Redirect>`渲染时将导航到一个新地址，这个新地址覆盖在访问历史信息里面的本该访问的那个地址。

#### Switch
只渲染出第一个与当前访问地址匹配的 `<Route>` 或 `<Redirect>`。

### 多页面路由
使用switch加route即可实现多页面路由的配置

```html
<Switch>
    <Route path='/' component={HomePage} exact/>
    <Route path='/login' component={Login} exact/>
    <Route path='/download' component={Download} exact/>
    <!-- 什么都未匹配时，匹配该路由 -->
    <Route component={Default} /> 
</Switch>
```

### 权限校验
使用Route的render方法进行权限校验，授权返回对应的组件，未授权使用返回Redirect组件进行重定向。

```js
/* PrivateRoute component definition */
const PrivateRoute = ({component: Component, authed, ...rest}) => {
  return (
    <Route
      {...rest}
      render={(props) => authed === true
        ? <Component {...props} />
        : <Redirect to={{pathname: '/login', state: {from: props.location}}} />} />
  )
}
```

```html
<Switch>
  <Route exact path="/" component={Home} data={data}/>
  <Route path="/category" component={Category}/>
  <Route path="/login" component={Login}/>
  <PrivateRoute authed={fakeAuth.isAuthenticated} path='/products' component = {Products} />
</Switch>
```

### 嵌套路由
```js
import React, { Component } from 'react';
import { Link, Route, Switch } from 'react-router-dom';
import Category from './Category';

class App extends Component {
  render() {

    return (
      <div>
        <nav className="navbar navbar-light">
          <ul className="nav navbar-nav">
            <li><Link to="/">Homes</Link></li>
            <li><Link to="/category">Category</Link></li>
            <li><Link to="/products">Products</Link></li>
          </ul>
       </nav>

    <Switch>
      <Route exact path="/" component={Home}/>
      <Route path="/category" component={Category}/>
       <Route path="/products" component={Products}/>
    </Switch>

    </div>
    );
  }
}
export default App;

```

Category.jsx

```js
import React from 'react';
import { Link, Route } from 'react-router-dom';

const Category = ({ match }) => {
return( <div> <ul>
    <li><Link to={`${match.url}/shoes`}>Shoes</Link></li>
    <li><Link to={`${match.url}/boots`}>Boots</Link></li>
    <li><Link to={`${match.url}/footwear`}>Footwear</Link></li>

  </ul>
  <Route path={`${match.path}/:name`} render= {({match}) =>( <div> <h3> {match.params.name} </h3></div>)}/>
  </div>)
}
export default Category;
```

### 其他
路由的匹配时先从当前组件开始寻找，如果未发现匹配的才向上到父组件寻找匹配的路由

## 参考文献
[React文档](https://react.docschina.org/tutorial/tutorial.html#react-%E6%98%AF%E4%BB%80%E4%B9%88%EF%BC%9F)
[React生命周期及事件详解](https://www.jianshu.com/p/b49fe87d2153)
[React+Redux最佳实践](https://github.com/sorrycc/blog/issues/1)
[Redux](https://cn.redux.js.org/)
[Redux入门教程](http://www.ruanyifeng.com/blog/2016/09/redux_tutorial_part_one_basic_usages.html)
[解读Redux中间件原理](https://juejin.im/post/59dc7e43f265da4332268906)
[浅析Redux 的 store enhancer](https://juejin.im/post/5a4874096fb9a044fa1a34c7)
[React Router V4完全指北](https://www.zcfy.cc/article/react-router-v4-the-complete-guide-mdash-sitepoint-4448.html)
[初探React Router](https://www.jianshu.com/p/e3adc9b5f75c#h5o-5)
[React Router文档](https://reacttraining.com/react-router/web/guides/philosophy)