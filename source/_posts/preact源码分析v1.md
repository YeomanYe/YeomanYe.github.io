title: preact源码分析v1
tags:
    - 源码分析
    - javascript
comments: true
date: 2018-06-03
brief: preact源码分析v1
categories:
    - 源码分析
---
# preact源码分析v1

preact是react的轻量级解决方案，它与react的api十分相近，并且有着许多的周边:redux、router等等。无论是通过学习源码来深入的了解react，还是为了日后使用react轻量级解决方案都非常有价值。虽然preact比起react精简了不少，但是仍然很复杂。为了最快速的了解核心，我从preact的早起版本开始阅读起，这篇分析的是v1.5.2版本的源码

[Github](https://github.com/developit/preact) | [文档](https://preactjs.com/) | [Demo](http://jsfiddle.net/developit/u9m5x0L7/embedded/result,js/)
<!-- more -->

## 使用
```js
import { h, render } from 'preact';

render((
    <div id="foo">
        <span>Hello, world!</span>
        <button onClick={ e => alert("hi!") }>Click Me</button>
    </div>
), document.body);
```

For Babel 6:
```json
{
  "plugins": [
    ["transform-react-jsx", { "pragma":"h" }]
  ]
}
```

对比于React,在使用上只要将导入的React替换为h，并且在babel中配置pragma即使用h函数包裹转换的jsx代码。

如果想要将react项目转换为preact项目，或者让preact项目与react项目兼容好使用其他第三方框架可以参考[preact-compat](https://github.com/developit/preact-compat)

## 源码分析
### jsx解析
首先从入口的jsx开始解析，根据[官网的资料](https://preactjs.com/guide/differences-to-react)，和通过断点跟踪源码发现。preact中的jsx被解析成如下的形式:
```js
h(Home,null,h('a', { href:'/' }, h('span', null, 'Home')))
```
自定义的组件以组件类作为第一个参数，页面的标签元素以标签名字符串作为第一个参数，第二个参数为属性对象。随后的参数为子节点对象。正因为如此h函数是一定要在入口文件导出的函数。

h函数源代码
```js
export function h(nodeName, attributes, ...args) {
    let children,
        sharedArr = [],
        len = args.length,
        arr, lastSimple;
    if (len) {
        children = [];
        for (let i=0; i<len; i++) {
            let p = args[i];
            //将子节点包裹为一个数组
            if (empty(p)) continue;
            if (p.join) {
                arr = p;
            }
            else {
                arr = sharedArr;
                arr[0] = p;
            }
            //使用两个循环处理子节点为数组的情况
            for (let j=0; j<arr.length; j++) {
                let child = arr[j],
                    simple = !empty(child) && !isVNode(child);
                if (simple) child = String(child);
                //对于文本节点进行拼接处理
                if (simple && lastSimple) {
                    children[children.length-1] += child;
                }
                else if (!empty(child)) {
                    children.push(child);
                }
                lastSimple = simple;
            }
        }
    }
//去除原先生成的attributes中的子节点属性
    if (attributes && attributes.children) {
        delete attributes.children;
    }

    let p = new VNode(nodeName, attributes || undefined, children || undefined);
    //hook执行 hooks对象上的vnode方法，并将p作为参数传入
    hook(hooks, 'vnode', p);
    return p;
}
```

preact中组件在内部是通过VNode节点来表示的
```js
export class VNode {
    constructor(nodeName, attributes, children) {
        /** @type {string|class} */
        this.nodeName = nodeName;

        /** @type {object<string>|undefined} */
        this.attributes = attributes;

        /** @type {array<VNode>|undefined} */
        this.children = children;
    }
}
//每个VNode节点都有一个__isVNode内部属性
VNode.prototype.__isVNode = true;
```

### render入口分析
preact的入口函数是render函数，通过分析render函数我们可以知道preact是如何将组件变为元素渲染到节点中。
```js
/** @public Render JSX into a `parent` Element. */
export function render(component, parent) {
    let built = build(null, component),
        c = built._component;
        //执行组件的componentWillMount
    if (c) hook(c, 'componentWillMount');
    parent.appendChild(built);
    //执行componentDidMount
    if (c) hook(c, 'componentDidMount');
    return built;
}
```

render首先通过build方法生成元素，调用对应组件的生命周期方法componentWillMount,之后将元素插入到页面中，最后再调用组件的生命周期方法componentDidMount

主要生成dom的逻辑就在build中了
```js
function build(dom, vnode, rootComponent){
let out = dom,
    nodeName = vnode.nodeName;
/*当传入的参数是组件的时候，使用buildComponentFromVNode生成页面元素*/
if (typeof nodeName==='function') {
    return buildComponentFromVNode(dom, vnode);
}
/*当传入的参数是字符串时，生成text节点*/
if (typeof vnode==='string') {
    if (dom) {
        if (dom.nodeType===3) {
            dom.textContent = vnode;
            return dom;
        }
        else {
            if (dom.nodeType===1) recycler.collect(dom);
        }
    }
    return document.createTextNode(vnode);
}
/*传入的参数是正常的节点时，进行属性替换*/
if (!dom) {
    //dom节点不存在，即首次调用build时，创建dom节点
    out = recycler.create(nodeName);
}else if (dom.nodeName.toLowerCase()!==nodeName) {
    //dom节点不匹配时，创建一个新的dom节点，并回收当前节点
    out = recycler.create(nodeName);
    appendChildren(out, slice.call(dom.childNodes));
    // reclaim element nodes
    if (dom.nodeType===1) recycler.collect(dom);
}
else if (rootComponent && dom._component && dom._component!==rootComponent) {
    //dom的component与根节点的不相同时，意味着卸载掉该组件
    unmountComponent(dom, dom._component);
}
//属性替换，先移除旧属性，在设置新的属性。
// apply attributes
let old = getNodeAttributes(out) || EMPTY,
    attrs = vnode.attributes || EMPTY;

// removed attributes
if (old!==EMPTY) {
    for (let name in old) {
        if (hop.call(old, name)) {
            let o = attrs[name];
            if (o===undefined || o===null || o===false) {
                setAccessor(out, name, null, old[name]);
            }
        }
    }
}

// new & updated attributes
if (attrs!==EMPTY) {
    for (let name in attrs) {
        if (hop.call(attrs, name)) {
            let value = attrs[name];
            if (value!==undefined && value!==null && value!==false) {
                let prev = getAccessor(out, name, old[name]);
                if (value!==prev) {
                    setAccessor(out, name, value, prev);
                }
            }
        }
    }
}

//循环创建子节点
let children = slice.call(out.childNodes);
    let keyed = {};
//使用子节点创建对象，形式为key:component
    for (let i=children.length; i--; ) {
        let t = children[i].nodeType;
        let key;
        if (t===3) {
            key = t.key;
        }
        else if (t===1) {
            key = children[i].getAttribute('key');
        }
        else {
            continue;
        }
        if (key) keyed[key] = children.splice(i, 1)[0];
    }
    let newChildren = [];
//递归生成新的子节点数组
    if (vnode.children) {
        for (let i=0, vlen=vnode.children.length; i<vlen; i++) {
            let vchild = vnode.children[i];
            let attrs = vchild.attributes;
            let key, child;
            //使用key值找到原始对应的component
            if (attrs) {
                key = attrs.key;
                child = key && keyed[key];
            }

//如果不存在key值，则遍历找到第一个相同类型的组件
            // attempt to pluck a node of the same type from the existing children
            if (!child) {
                let len = children.length;
                if (children.length) {
                    for (let j=0; j<len; j++) {
                        if (isSameNodeType(children[j], vchild)) {
                            child = children.splice(j, 1)[0];
                            break;
                        }
                    }
                }
            }

            // morph the matched/found/created DOM child to match vchild (deep)
            newChildren.push(build(child, vchild));
        }
    }
//插入子节点并调用生命周期方法
    // apply the constructed/enhanced ordered list to the parent
    for (let i=0, len=newChildren.length; i<len; i++) {
        // we're intentionally re-referencing out.childNodes here as it is a live NodeList
        if (out.childNodes[i]!==newChildren[i]) {
            let child = newChildren[i],
                c = child._component,
                next = out.childNodes[i+1];
            if (c) hook(c, 'componentWillMount');
            if (next) {
                out.insertBefore(child, next);
            }
            else {
                out.appendChild(child);
            }
            if (c) hook(c, 'componentDidMount');
        }
    }
//移除子节点并调用生命周期方法
    // remove orphaned children
    for (let i=0, len=children.length; i<len; i++) {
        let child = children[i],
            c = child._component;
        if (c) hook(c, 'componentWillUnmount');
        child.parentNode.removeChild(child);
        if (c) {
            hook(c, 'componentDidUnmount');
            componentRecycler.collect(c);
        }
        else if (child.nodeType===1) {
            recycler.collect(child);
        }
    }

    return out;
}
```

一般的根组件都是我们自定义的组件，所以通常走的是buildComponentFromVNode逻辑
```js
function buildComponentFromVNode(dom, vnode) {
    let c = dom && dom._component;
    /*不存在render方法，即使用函数创建的组件走此逻辑*/
    if (!vnode.nodeName.prototype.render) {
        let p = build(dom, vnode.nodeName(getNodeProps(vnode)) || EMPTY_BASE);
        p._componentConstructor = vnode.nodeName;
        return p;
    }
    /*要生成的组件与dom对应的组件相同时，给dom对应组件重新设置props来触发其渲染*/
    if (c && dom._componentConstructor===vnode.nodeName) {
        let props = getNodeProps(vnode);
        c.setProps(props, SYNC_RENDER);
        return dom;
    }
    else {
        /*dom组件与新组件不同时，移除dom组件*/
        if (c) unmountComponent(dom, c);
        /*生成新组件*/
        return createComponentFromVNode(vnode);
    }
}
```

createComponentFromVNode是具体的组件生成方法
```js
function createComponentFromVNode(vnode) {
    //是否回收保存过对应的组件，有则返回，没有则新建一个返回
    let component = componentRecycler.create(vnode.nodeName);


    //获取组件的属性
    let props = getNodeProps(vnode);
    //设置属性但不渲染
    component.setProps(props, NO_RENDER);
    //渲染组件
    component._render(DOM_RENDER);

    //获取dom节点，并进行关联
    let node = component.base;
    node._component = component;
    node._componentConstructor = vnode.nodeName;

    //返回dom节点
    return node;
}
```

setProps设置props,并调用生命周期方法
_render调用生命周期方法并执行渲染
```js
export class Component{
    setProps(props, opts=EMPTY) {
        let d = this._disableRendering;
        this._disableRendering = true;
        hook(this, 'componentWillReceiveProps', props, this.props);
        this.nextProps = props;
        this._disableRendering = d;
        //组件更新state时进行渲染，第一次创建不渲染
        if (opts.render!==false) {
            if (opts.renderSync || options.syncComponentUpdates) {
                this._render();
            }
            else {
                this.triggerRender();
            }
        }
    }
    _render(opts) {
        if (this._disableRendering) return;

        this._dirty = false;

        let p = this.nextProps,
            s = this.state;
//this.base代表使用state与props两个状态生成的前一个组件
//首次调用时base为空
        if (this.base) {
//如果shouldComponentUpdate为fasle则不更新组件
            if (hook(this, 'shouldComponentUpdate', p, s)===false) {
                this.props = p;
                return;
            }

            hook(this, 'componentWillUpdate', p, s);
        }

        this.props = p;

        let rendered = hook(this, 'render', p, s);
//首次生成组件时base为空，因此传入opts.build来执行生成方法
        if (this.base || (opts && opts.build)) {
            let base = build(this.base, rendered || EMPTY_BASE, this);

            if (this.base && base!==this.base) {
                let p = this.base.parentNode;
                if (p) p.replaceChild(base, this.base);
            }
            this.base = base;

            hook(this, 'componentDidUpdate', p, s);
        }

        return rendered;
    }
}
```

### Component类
创建preact组件要么通过函数返回jsx，要么通过继承Component类。分析render函数时已经知道，如果是通过函数实现component的直接调用函数，并传入props生成component。通过继承Component实现的，会调用`componentRecycler.create`函数来得到组件。

componentRecycler会先查看回收的component组件中是否存在对应的组件，如果有则从列表中去掉并返回，如果没有则创建新的。
```js
let componentRecycler = {
    components: {},
    collect(component) {
        let name = component.constructor.name,
            list = componentRecycler.components[name];
        if (list) list.push(component);
        else componentRecycler.components[name] = [component];
    },
    create(ctor) {
        let list = componentRecycler.components[ctor.name];
        if (list && list.length) {
            for (let i=list.length; i--; ) {
                if (list[i].constructor===ctor) {
                    return list.splice(i, 1)[0];
                }
            }
        }
        return new ctor();
    }
};
```

除了`componentRecycler`，preact还实现了一套DOM组件的回收机制`recycler`，除了回收时需要去掉元素上的属性外，其他基本一致。这里就不赘述了

Component构建时设置一些内部属性，并初始化props和state

```js
export class Component {
    constructor() {
        //disableRendering禁止渲染,dirty防止在渲染未完成又执行渲染
        /** @private */
        this._dirty = this._disableRendering = false;
        //nextProps下一个属性，base当前组件
        /** @public */
        this.nextProps = this.base = null;
        //设置默认属性
        /** @type {object} */
        this.props = hook(this, 'getDefaultProps') || {};
        //设置默认state
        /** @type {object} */
        this.state = hook(this, 'getInitialState') || {};
        // @TODO remove me?
        hook(this, 'initialize');
    }
}
```

preact与react相同，组件的重渲染是通过setState方法
```js
class Component{
    setState(state) {
        extend(this.state, state);
        //通过调用triggerRender达到渲染的目的
        this.triggerRender();
    }
    triggerRender() {
        //dirty保证渲染还没开始时，如果又触发了渲染不进行渲染
        if (!this._dirty) {
            this._dirty = true;
            renderQueue.add(this);
        }
    }
}

```

renderQueue使用队列的形式保证渲染的同步
```js
let renderQueue = {
    items: [],
    itemsOffline: [],
    add(component) {
        //一次生成的渲染队列只调用一次，process方法，保证效率
        if (renderQueue.items.push(component)!==1) return;

        let d = hooks.debounceRendering;
        if (d) d(renderQueue.process);
        else setTimeout(renderQueue.process, 0);
    },
    process() {
        let items = renderQueue.items,
            len = items.length;
        if (!len) return;
        //清空需要渲染的队列
        renderQueue.items = renderQueue.itemsOffline;
        renderQueue.items.length = 0;
        //放置已经渲染的队列，暂未发现其他用途
        renderQueue.itemsOffline = items;
        while (len--) {
            if (items[len]._dirty) {
                items[len]._render();
            }
        }
    }
};
```

_render方法前面已经说过，通过执行生命周期方法`shouldComponentUpdate`先判断是否需要更新，如果需要更新则执行对应的生命周期方法，并更新元素

## 总结
preact的主要部分就如上面分析的一样，当然其中还有一些琐碎的细节就不详谈了。如：

- 设置属性需要将style和class两者单独抽出来处理。
    - style还需要将驼峰命名法的属性，改为css中对应的-。并且给需要加单位的数字属性加上单位。
    - 将className属性，设置在class属性上
- 使用代理事件代替原有的事件

阅读preact源码除了收获到preact中通过jsx构建dom的方式方法、virtual dom的计算方法，以及生命周期顺序之外。

还学到了通过制定回收机制（`recycler`、`componentRecycler`），减少不必要的创建开销。

小于两个的时候分别插入，大于两个的时候进行合并成一个片段插入减小多次插入节点造成的性能问题。
```js
function appendChildren(parent, children) {
    let len = children.length;
    if (len<=2) {
        parent.appendChild(children[0]);
        if (len===2) parent.appendChild(children[1]);
        return;
    }

    let frag = document.createDocumentFragment();
    for (let i=0; i<len; i++) frag.appendChild(children[i]);
    parent.appendChild(frag);
}
```

使用取值策略先生成取值函数，再通过key进行取值
```js
let memoize = (fn, mem={}) => k => mem.hasOwnProperty(k) ? mem[k] : (mem[k] = fn(k));
```