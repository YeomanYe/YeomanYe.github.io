title: 这一次你一定要读懂Redux源码
tags:
    - 源码
    - 前端
comments: true
top: 100
brief: 这一次你一定要读懂Redux源码
date: 2019-06-23
photos:
    - "/images/article_banner/redux.jpeg"
categories:
    - 前端
---

Redux是业内鼎鼎有名的状态管理工具，据说作者Dan Abramov就是凭借这个作品在业内名声大振的。一开始我以为这个被广为流传使用的库代码，必然十分复杂，因而一直没有去研究它的设计与实现。直到有天心血来潮翻了下它的源码，发现不仅暴露出来的API少，内部的API也少，总共不超过10个的API加起来居然不到六百行代码。。。

<!-- more -->

<center>![真大哥](/images/meme/真大哥.jpg)</center>

本篇文章讨论的Redux源码是基于版本v4.0.1，只讨论其中核心API的实现并简单发表下对Redux框架发展的看法。首先，先上张Redux的数据流向图。

![Redux数据流](Redux数据流.png)

就不详细的介绍这个架构了，简单的说下这个数据流中Redux实现的部分和需要我们实现的部分分别是哪些：

__Redux实现：__ `store.dispatch`、`store.subscribe`、`combineReducers`、`applyMiddleware`
__我们实现：__ `actionCreator`、`reducer`

本篇文章我们只分析Redux实现部分的代码

## dispatch

dispatch在store对象中，而store又由createStore生成，因此找dispatch方法得从createStore中翻起。打开createStore文件，我们可以看到createStore中内部的同名方法，即为我们所寻。

[![dispatch](dispatch.png)](https://github.com/reduxjs/redux/blob/v4.0.1/src/createStore.js#L195-L208)

抛开头部的判断Action是否为纯对象，以及判断调用dispatch时是否dispatch正在调用中（不允许reducer中再次调用dispatch，否则容易造成无限递归）。可以看到dispatch直接调用了reducer，来获得一个新的state，并在获得了新state之后调用手动触发监听state改变的函数。

## subscribe

subscribe也在store对象中，翻阅createStore可以发现同名函数subscribe。

[![subscribe](subscribe.png)](https://github.com/reduxjs/redux/blob/v4.0.1/src/createStore.js#L126-L147)

逻辑很明显将监听的函数放入对应的数组中，再返回一个解除监听的函数。

- `isDispatching`：防止在中间件reducer中加入/解除监听函数
- `isSubscribed`：用于减少多次解除监听逻辑造成的性能损耗
- `ensureCanMutateNextListeners`：这个函数内容是当currentListeners和nextListeners相同时，从currentListeners浅复制一份给nextListeners。因为dispatch后执行的是currentListeners中监听器的内容，所以可以理解为在当前触发的监听函数中如果调用解除监听函数要下一次再触发时才能生效。

```js
function ensureCanMutateNextListeners() {
    if (nextListeners === currentListeners) {
      nextListeners = currentListeners.slice()
    }
  }
```

看完了store中的dispatch和subscribe已经看完了基本的redux骨架。剩下的都是给redux增强功能的。

## combineReducers

我们再看一个我们组织reducer都会使用上的函数combineReducers。它的逻辑就在同名文件中

[![combineReducers](combineReducers.png)](https://github.com/reduxjs/redux/blob/v4.0.1/src/combineReducers.js#L115-L177)

虽然代码看起来挺多，但是一点都不复杂，里面有很大一部分代码是用来确定，主要可以看成两个部分。一个部分是获取reducer进行预处理并返回一个统一的reducer处理函数，另一个部分就是实际调用reducer的处理逻辑了。(话外音：感觉所有高阶函数都能这么分--!)

预处理除了判断逻辑，真正的执行逻辑也只有两步。一是将合并的reducer拷贝到一个const对象中（我想之所以这么做是防止，reducer对象被意外修改了吧）。二是获取合并的reducer的所有key，放入数组中以备后续处理。

调用执行部分的逻辑也很直白，直接遍历所有reducer来获得对应reducer产生的新状态。除这之外就是判断是否状态发生改变，如果不发生改变就反回原始state。关于这一步我觉得是为了监听函数判断state是否发生变化，而nextState已经生成了应该没有什么优化的意义在其中了。

## applyMiddleware
要看懂applyMiddleware需要结合着createStore的enhancer才行，因为applyMiddleware是特殊的enhancer。

[![enhancer](enhancer.png)](https://github.com/reduxjs/redux/blob/v4.0.1/src/createStore.js#L48-L53)

可以看到`enhancer`接受`createStore`作为参数，并且返回的函数是一个接受`dispatch`、`preloadedState`（初始化的状态）作为参数的函数，并且调用后返回符合Redux规定API的store。

现在再来看applyMiddleware函数就能清楚它的函数签名是为了完全符合enhancer的接口。我们再看下applyMiddleware的内部逻辑：

![applyMiddleware](applyMiddleware.png)

要看懂applyMiddleware我们还应该看看，它提供给外界编写middleware的API是什么样的。下面的logger是官方提供的一个例子。next代表的是下一个中间件。

![logger](logger.png)

我们可以看到applyMiddleware前面的逻辑是在设计一个假的dispatch，为了防止在dispatch中再次dispatch造成死循环。核心的代码是我红圈圈出来的部分，现在还差一个compose素材就集齐了。

compose方法的作用是让参数函数逆序序执行并将结果作为下一个函数的参数，对于`compose(f, g, h)`会得出`(...args) => f(g(h(...args)))`。

现在再来看applyMiddleware中的核心代码，首先是使用map方法将middleware调用一遍，将返回值在组成一个数组。我们看logger签名，可以发现这相当于是将参数getState注入其中，再返回传入next参数的函数。

然后再将这一组函数经过compose组成一个链式调用，然后调用生成包装好的dispatch函数。compose是逆序调用，即写在前头的函数后调用，写后头的先调用。然而这一步调用的函数其实是作为前一个函数的next参数，还记得吗它是代表下一个中间件。在真正调用dispatch时还是先执行第一个中间件的逻辑，顺序又正回来了。顺便说下作为第一个参数传入的dispatch函数会作为最后的中间件被调用，高明高明！

## 发展历程

关于redux源码的分析就上面那么多了，下面主要是通过git对源码的追综，简述下自己对于redux这个框架发展的看法。

### Initial commit
__时间：__2015-05-30

最初的代码目录结构为：

```txt
- src
  - redux
    connect.js
    createDispatcher.js
    flux.js
  - stores
    CounterStore.js
    index.js
- App.js
```

可以看到最初的代码是没有脱离view的，并且灵感有flux的影子在其中。

### v0.2.0
__时间：__2015-06-02

然后到了0.2.0版本，目录变成如下：

```txt
- src
  createDispatcher.js
  observers.js
  performs.js
  providers.js
  index.js
```

虽然现在没有了样板文件，但是阅读其readme文档可以发现它还是根具体的view框架（react）绑定在一起的。这个版本有了初步的数据流想法。

```jsx
// We're gonna need some decorators
import React from 'react';
import { observes } from 'redux';

// Gonna subscribe it
@observes('CounterStore')
export default class Counter {
  render() {
    const { counter } = this.props; // injected by @observes
    return (
      <p>
        Clicked: {counter} times
      </p>
    );
  }
}
```

### v0.9.0
__时间：__2015-06-09

在此版本出现了与目前想类型的概念，已经出现了dispatch、getState方法。

```yml
- src
  - utils
  - components
  createDispatcher.js
  createRedux.js
  index.js
  Redux.js
```

其中的Redux与createDispatcher与现在的createStore概念相类似，但是还没有中间件和enhancer。

### v1.0.0
__时间：__2015-08-15

此版本与现在已经很相似，在这个版本中store概念改为了reducer，出现了createStore方法，虽然没有出现enhancer，但是有了middleware的概念。并且将与react相挂钩的内容剥离到了react-redux库中。

```yml
- src
  - util
  createStore.js
  index.js
```

### 总结

首先不得不为大佬的高产而叹服啊，不到3个月的时间内，就对代码进行了十次较大的版本变动。。。

其次我们可以发现，作者一开始只是根据已有的状态管理规范做的包装。然后逐步迭代才有了今天的redux。并且一开始状态管理是跟react捆绑的，直到后来才将它拆分到react-redux中。对于redux的接口开放也从简单逐渐到强大（先有applyMiddleware后有enhancer）。不断与时俱进，从15年开始一直更新到了19年，除了考虑与其他框架的兼容性，还将目前出现的与其相关未完全兼容的新特性（Symbol.observable）加入其中。

总结下redux的出现，不仅仅是作者有着广阔的视野（对react和状态管理工具）、深刻的认知（函数式编程），并且也因为他保持着热心与时俱进。

    公众号二分之一程序员，分享前端、计算机基础知识，欢迎关注 :)

<center>![公众号](/images/qrcode_wechat_office.jpg)</center>