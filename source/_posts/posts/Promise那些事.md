title: Promise那些事
tags:
    - JavaScript
    - 前端
comments: true
brief: Promise那些事
date: 2018-03-15
categories:
    - JavaScript
---
# Promise那些事
Promise 是什么？Promise 是抽象异步处理对象以及对其进行各种操作的组件。在没有Promise之前，异步操作需要使用回调函数来完成。如果回调函数中还有异步操作，那么就必须层层嵌套，这使得代码，难以维护，难以复用。改用Promise则能变成链式调用，解决了代码难以维护，难以复用的问题。

<!-- more -->

callback

```js
asyncFun(
    () => callback1(
        () => callback2(
            () => callback3()
)));
```

promise
```js
asyncFun()
.then(() => callback1())
.then(() => callback2())
.then(() => callback3())
```

## [Promises/A+](https://promisesaplus.com/)
一个开放、健全且通用的 JavaScript Promise 标准，ES标准中的Promise，Q以及bluebird都是PromiseA+标准的实现。


1.只有一个then方法，没有catch，race，all等方法，甚至没有构造函数

Promise标准中仅指定了Promise对象的then方法的行为，其它一切我们常见的方法/函数都并没有指定，包括catch，race，all等常用方法，甚至也没有指定该如何构造出一个Promise对象，另外then也没有一般实现中（Q, $q等）所支持的第三个参数，一般称onProgress

2.then方法返回一个新的Promise
3.Promise的初始状态为pending，它可以由此状态转换为fulfilled或者rejected，一旦状态确定，就不可以再次转换为其它状态，状态确定的过程称为settle
4.不同的Promise的实现需要能无缝交互。Promise并不是JS一早就有的标准，不同第三方的实现之间是并不相互知晓的，如果你使用的某一个库中封装了一个Promise实现，想象一下如果它不能跟你自己使用的Promise实现交互的场景

## 实现Promise
实现Promise主要就是实现`executor(resolve,reject)`、`resolve`、`reject`、`then`方法。

### 1. Promise架构实现
实现Promise第一步，思考Promise内部有什么东西。
首先Promise内部应该有个属性表示Promise的状态，有resolve，reject方法，用来传递给executor,有个data属性用于保存数据，便于后期处理

```js
function Promise(executor) {
  this.status = 'pending' // Promise当前的状态
  this.data = undefined  // Promise的值
  this.onRejectedCallback = []
  this.onResolvedCallback = []
  const resolve = () => {/***/};
  const reject = () => {/**/};
   try {
    executor(resolve, reject) // 执行executor
   } catch(e) {
    reject(e)
   } 
}
```
为什么需要onRejectedCallback、onResolvedCallback。考虑下Promise的调用方式`new Promise().then(onResolve,onReject)`，不难发现then方法是同步调用的，而onResolve、onReject方法是在Promise状态改变后进行调用的。所以需要先将这两个方法保存起来，等到状态改变时再进行调用。

### 2. resolve与reject
改变promise的状态，设置值

```js
function Promise(executor) {
  // ...

  const resolve = (value) => {
    if (this.status === 'pending') {
      this.status = 'resolved'
      this.data = value
      for(var i = 0; i < this.onResolvedCallback.length; i++) {
        this.onResolvedCallback[i](value)
      }
    }
  }

  const reject = (reason) => {
    if (this.status === 'pending') {
      this.status = 'rejected'
      this.data = reason;
      for(var i = 0; i < this.onRejectedCallback.length; i++) {
        this.onRejectedCallback[i](reason)
      }
    }
  }

  // ...
}
```

### 3. then
处理resolve与reject函数设置的值

```js
Promise.prototype.then = function(onResolved, onRejected) {
  var self = this
  var promise

  // 根据标准，如果then的参数不是function，则我们需要忽略它，此处以如下方式处理
  onResolved = typeof onResolved === 'function' ? onResolved : function(v) {}
  onRejected = typeof onRejected === 'function' ? onRejected : function(r) {}

  if (self.status === 'resolved') {
    return promise = new Promise(function(resolve, reject) {
    try {
        var x = onResolved(self.data)
        if (x instanceof Promise) { // 如果onResolved的返回值是一个Promise对象，直接取它的结果做为promise的结果
          x.then(resolve, reject)
        }
        resolve(x) // 否则，以它的返回值做为promise的结果
      } catch (e) {
        reject(e) // 如果出错，以捕获到的错误做为promise的结果
      }
    })
  }

  if (self.status === 'rejected') {
    return promise = new Promise(function(resolve, reject) {
        try {
            var x = onRejected(self.data)
            if (x instanceof Promise) {
              x.then(resolve, reject)
            }
          } catch (e) {
            reject(e)
          }
    })
  }

  if (self.status === 'pending') {
    return promise = new Promise(function(resolve, reject) {
        self.onResolvedCallback.push(function(value) {
            try {
              var x = onResolved(self.data)
              if (x instanceof Promise) {
                x.then(resolve, reject)
              }
            } catch (e) {
              reject(e)
            }
          })

          self.onRejectedCallback.push(function(reason) {
            try {
              var x = onRejected(self.data)
              if (x instanceof Promise) {
                x.then(resolve, reject)
              }
            } catch (e) {
              reject(e)
            }
          })
    })
  }
}
```

至此一个简单的Promise就算是实现了

### 存在的问题
1.Promise需要能对值进行穿透，如：
```js
new Promise(resolve=>resolve(8))
  .then()
  .then()
  .then(function foo(value) {
    alert(value)
  })
```
最后要打印值8

对比以上的实现不难发现，只需要将then的参数onResolve和onReject的默认实现改为返回输入值，即`v => v`即可实现

2.不同的Promise的实现不能无缝交互
只要按照标准完成resolvePromise函数([Promise Resolution Procedure](https://promisesaplus.com/#point-47)),根据`promise2 = promise1.then(onResolved, onRejected)`里`onResolved/onRejected`的返回值来确定promise2的状态的函数

此处借用@xieranmaya的[实现](https://github.com/xieranmaya/blog/issues/3#h5o-3)
```js
/*
x为`promise2 = promise1.then(onResolved, onRejected)`里`onResolved/onRejected`的返回值
`resolve`和`reject`实际上是`promise2`的`executor`的两个实参，因为很难挂在其它的地方，所以一并传进来。
*/
function resolvePromise(promise2, x, resolve, reject) {
  var then
  var thenCalledOrThrow = false

  if (promise2 === x) { // 对应标准2.3.1节
    return reject(new TypeError('Chaining cycle detected for promise!'))
  }

  if (x instanceof Promise) { // 对应标准2.3.2节
    // 如果x的状态还没有确定，那么它是有可能被一个thenable决定最终状态和值的
    // 所以这里需要做一下处理，而不能一概的以为它会被一个“正常”的值resolve
    if (x.status === 'pending') {
      x.then(function(value) {
        resolvePromise(promise2, value, resolve, reject)
      }, reject)
    } else { // 但如果这个Promise的状态已经确定了，那么它肯定有一个“正常”的值，而不是一个thenable，所以这里直接取它的状态
      x.then(resolve, reject)
    }
    return
  }

  if ((x !== null) && ((typeof x === 'object') || (typeof x === 'function'))) { // 2.3.3
    try {

      // 2.3.3.1 因为x.then有可能是一个getter，这种情况下多次读取就有可能产生副作用
      // 即要判断它的类型，又要调用它，这就是两次读取
      then = x.then 
      if (typeof then === 'function') { // 2.3.3.3
        then.call(x, function rs(y) { // 2.3.3.3.1
          if (thenCalledOrThrow) return // 2.3.3.3.3 即这三处谁选执行就以谁的结果为准
          thenCalledOrThrow = true
          return resolvePromise(promise2, y, resolve, reject) // 2.3.3.3.1
        }, function rj(r) { // 2.3.3.3.2
          if (thenCalledOrThrow) return // 2.3.3.3.3 即这三处谁选执行就以谁的结果为准
          thenCalledOrThrow = true
          return reject(r)
        })
      } else { // 2.3.3.4
        resolve(x)
      }
    } catch (e) { // 2.3.3.2
      if (thenCalledOrThrow) return // 2.3.3.3.3 即这三处谁选执行就以谁的结果为准
      thenCalledOrThrow = true
      return reject(e)
    }
  } else { // 2.3.4
    resolve(x)
  }
}
```

然后将then中resolve状态时对应的处理方式改为
```js
if (self.status === 'resolved') {
    return promise2 = new Promise(function(resolve, reject) {
      setTimeout(function() { // 异步执行onResolved
        try {
          var x = onResolved(self.data)
          resolvePromise(promise2, x, resolve, reject)
        } catch (reason) {
          reject(reason)
        }
      })
    })
  }
```

## Promise存在的问题

### 性能
因为promise本身并不存在异步操作，它只是对异步的包装，它依赖于原生的异步方案。node中使用的是process.nextTick或者setImmediate因为它们比原生更快。而浏览器中，可以使用下面的方案：

```js
let setZeroTimeout = (function() {
    if (window.setImmediate) {
        //IE10+版本，使用原生setImmediate
        return window.setImmediate;
    }
    else if ("onreadystatechange" in document.createElement("script")) {
        return function(func) {
            let newScript = document.createElement("script");
            newScript.id = 'script_timeout';
            newScript.innerHTML = `
                let scriptNode = document.getElementById('script_timeout');
                let container = document.getElementsByTagName("head")[0];
                container.removeChild(scriptNode);
            `;
            newScript.onreadystatechange = func;
            document.documentElement.appendChild(newScript);
        }
    }
    else if (window.postMessage) {
        return function(func) {
            let onListener = ()=>{
                func();
                window.removeEventListener('message',onListener);
            };
            window.addEventListener("message", onListener, true);
            window.postMessage("", "*");
        }
    }
    else {
        return window.setTimeout;
    }
})();
```

### 终断Promise
- 在外部终止Promise
```js
function race(p){
    let obj = {};
    let p1 = new Promise(function(resolve, reject){
        obj.resolve = resolve;
        obj.reject = reject;
    });
    obj.promise = Promise.race([p, p1]);
    return obj;
}
let obj = race(promise);
obj.promise.then(onResolve, onReject);
obj.reject(new Error());
```

- 在链式中终止Promise。
以下方式不是真正意义上的终止，只是不让Promise继续向下调用，也不返回
```js
Promise.cancel = Promise.stop = function() {
  return new Promise(function(){})
}

new Promise(function(resolve, reject) {
  resolve(42)
})
  .then(function(value) {
    // "Big ERROR!!!"
    return Promise.stop()
  })
  .catch()
  .then()
  .then()
  .catch()
  .then()
```

## 参考文献
[剖析Promise内部结构](https://github.com/xieranmaya/blog/issues/3)

[更快的异步执行](http://www.alloyteam.com/2014/03/faster-asynchronous-execution/)

[如何取消一个Promise](https://blog.csdn.net/l908825925/article/details/80619821)