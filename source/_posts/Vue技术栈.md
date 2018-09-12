title: Vue技术栈
tags:
    - Vue
    - 前端框架
comments: true
brief: Vue技术栈
date: 2018-09-12
categories:
    - 前端框架
---
# Vue技术栈
Vue是一套用于构建用户界面的渐进式框架，Vue 的核心库只关注视图层，不仅易于上手，还便于与第三方库或既有项目整合。在当下的前端开发中已经很少单单只用vue进行开发了，人们常常搭配其他的框架与组件如：vuex(状态管理工具)、vue-router(路由工具)、Element(UI)一起使用

<!-- more -->

## Vue 
Vue主要作用有两个：

- 一作为MVVM框架，将UI和数据进行绑定实现响应式的更新，减少前端开发的UI更新渲染逻辑，
- 二将UI进行组件化分割便于复用与操作。

### 数据绑定
- 使用vue的指令绑定表单、事件、属性、文本、标签等。如：v-show、v-text、v-html、v-bind(别名`:`)、v-on(别名`@`)

```html
<input :class="{completed:todo.completed,editing:todo==editedTodo}" 
v-model="todo.message" @keyup.enter="doneEdit(todo)" @keyup.esc="cancelEdit(todo)"
               @blur="doneEdit(todo)" v-todo-focus="todo == editedTodo" type="text" class="edit">
```
绑定class或style时还可以使用数组以及对象语法，具体参见官方文档

- 绑定的数据可以是组件data中的(相当于组件自身状态，在根组件中是对象，再其他组件中是函数的返回值)，也可以是从父级传下来的props属性，还可以是计算属性(computed)。绑定的方法写在methods属性中。

```js
Vue.component('todo-app',{
        data: ()=>({
            title: "todos",
            todoInput: "",
        }),
        props:['todos']
        methods: {
            editTodo(todo) {
                this.beforeEditCache = todo.message;
                this.editedTodo = todo;
            },
        },
        computed: {
            leftTodos() {
                let left = 0;
                for (todo of this.todos) {
                    left = todo.completed ? left : left + 1;
                }
                return left;
            }
        },
    });
```

- 侦听器(watch)与计算属性很相似，都是在属性变化时执行一定的操作。侦听器适合执行一些异步开销大的操作，计算属性主要用来观察和响应组件上的数据变动适合执行一些简单的同步的操作。
```js
Vue.component('todo',{
        props:['todo'],
        watch: {
            todo: {
                deep: true,
                handler() {
                    this.updateTodo(this.todo);
                }
            }
        },
    });
```

### 组件化
- 解析vue组件是从其根组件开始向下解析，只要在根组件或根组件中出现的子组件都会被解析

```js
var vContentWrap = new Vue({
    el:'#contentWrap',
    data:{
        curShow:CUR_FAV.ALL,//当前显示的tab内容
        items: [],//收藏的集合
        batch:false, //是否显示批量处理
        search:false,//是否显示搜索面板
        searchText:'',
        curShowFav:CUR_NAV.FAV //当前显示的收藏
    },
    template:`
    <div>
        <search-panel v-show="search" :searchText="searchText"></search-panel>
        <!-- 工具栏 -->
        <toolbar :batch="batch" ></toolbar>
        <!-- tab栏 -->
        <nav-panel :cur-show="curShow"></nav-panel>
    </div>
    `
});
```

更好的方式是使用vue-loader以单文件的形式来组织组件，能让vue组件更清晰合理。

```html
<template>
  <div class="example">{{ msg }}</div>
</template>

<script>
export default {
  data () {
    return {
      msg: 'Hello world!'
    }
  }
}
</script>

<style>
.example {
  color: red;
}
</style>
```

- Vue 实现了一套内容分发的 API，将 `<slot>` 元素作为承载分发内容的出口，形象点说就是通过它可以对组件标签下的子元素标签进行更改。

```html
<!-- 组件base-layout -->
<div class="container">
  <header>
    <slot name="header"></slot>
  </header>
  <main>
    <slot></slot>
  </main>
  <footer>
    <slot name="footer"></slot>
  </footer>
  <button type="submit">
  <slot name="sub-btn">Submit</slot>
  </button>
</div>

<!-- 调用 -->
<base-layout>
  <template slot="header">
    <h1>Here might be a page title</h1>
  </template>

  <p>A paragraph for the main content.</p>
  <p>And another one.</p>

    <p slot="footer">Here's some contact info</p>
</base-layout>

<!-- 结果 -->
<div class="container">
  <header>
    <h1>Here might be a page title</h1>
  </header>
    
    <main>
  <p>A paragraph for the main content.</p>
  <p>And another one.</p>
    </main>
    
    <footer>
    <p>Here's some contact info</p>
    </footer>
    
    <button type="submit">
        Submit
    </button>
</div>
```

组件间的通信机制：
- 父->子，使用props
- 子->父，在子组件内部使用this.$emit发送事件，父组件监听并处理；父组件传递回调函数给子组件，子组件调用
- 任意两组件，使用全局事件。

```js
var eventHub = new Vue();
//事件发送
eventHub.$emit(eventName);
//事件监听
eventHub.$on(eventName,handler);
//移除监听
eventHub.$off(eventName,handler);
```

### 其他
#### Vue生命周期
初始化阶段
beforeCreate(未注入模板)->created(注入模板，但还未编译)->
beforeMount->(编译完成，虚拟dom未替换真实dom)mounted

数据变动引发的更新
beforeUpdate(更新前)->updated(更新完毕)

销毁阶段
beforeDestroy(销毁前)->destroyed(销毁后)

![Vue生命周期](vue-lifecycle.png)

#### Vue.filter(id, [definition])
Vue可以通过定义过滤器，进行一些常见的文本格式化，可以用于mustache插值和v-bind表达式当中，使用时通过管道符`|`添加在表达式尾部。

```html
<!-- in mustaches -->
{{ message | capitalize }}
<!-- in v-bind -->
<div v-bind:id="rawId | formatId"></div>

<!-- 可传参数 -->
<span>{{ message | filterA | filterB }}</span>
<span>{{ message | filterA("arg1", arg2) }}</span

<!-- capitalize filter -->
<script>
  new Vue({
    filters: {
      capitalize: function (value) {
        if (!value) return ""
        value = value.toString()
        return value.charAt(0).toUpperCase() + value.slice(1)
      }
    }
  })
</script>
```

#### Vue.use(plugin)
Vue通过插件来添加一些全局功能，Vue插件都会覆写其install()方法，该方法第1个参数是Vue构造器, 第2个参数是可选的option对象

```js
MyPlugin = {};
MyPlugin.install = function (Vue, options) {
  // 1. 添加全局方法或属性
  Vue.myGlobalMethod = function () {}
  // 2. 添加全局资源
  Vue.directive("my-directive", {
    bind (el, binding, vnode, oldVnode) {}
  })
  // 3. 注入组件
  Vue.mixin({
    created: function () {}
  })
  // 4. 添加实例方法
  Vue.prototype.$myMethod = function (methodOptions) {}
}

Vue.use(MyPlugin, {someOption: true})
```

#### Vue.mixin(mixin)
使用该方法会影响之后创建的所有实例，vue官方并不推荐项目中使用这种方式。混入合并策略是：混入数据则以组件为主；混入是方法，则以链式方式调用，混入的方法在前，组件方法再后。
也可以向 Vue.config.optionMergeStrategies 添加一个函数，来改变合并策略：

```js
Vue.config.optionMergeStrategies.myOption = function (toVal, fromVal) {
  // return mergedVal
}
```

示例：
```js
// 为自定义的选项 'myOption' 注入一个处理器。
Vue.mixin({
  created: function () {
    var myOption = this.$options.myOption
    if (myOption) {
      console.log(myOption)
    }
  }
})

new Vue({
  myOption: 'hello!'
})
// => "hello!"
```

#### Vue.directive(id, [definition])
该方法用于自定义全局指令

示例：
```js
directives: {
  focus: {
    // 指令的定义
    inserted: function (el) {
      el.focus()
    }
  }
}
```

指令的生命周期方法有:

- bind：只调用一次，指令第一次绑定到元素时调用。在这里可以进行一次性的初始化设置。
- inserted：被绑定元素插入父节点时调用 (仅保证父节点存在，但不一定已被插入文档中)。
- update：所在组件的 VNode 更新时调用，但是可能发生在其子 VNode 更新之前。指令的值可能发生了改变，也可能没有。但是你可以通过比较更新前后的值来忽略不必要的模板更新 (详细的钩子函数参数见下)。
- componentUpdated：指令所在组件的 VNode 及其子 VNode 全部更新后调用。
- unbind：只调用一次，指令与元素解绑时调用。

只关注 bind 和 update 时触发相同行为，而不关心其它的钩子。可以这样写:

```js
Vue.directive('color-swatch', function (el, binding) {
  el.style.backgroundColor = binding.value
})
```

## Vuex 
Vuex是Vue的一个状态管理插件，Vuex采用集中式存储管理应用的所有组件的状态，可以让状态的管理更加清晰易于维护。

[Vuex架构](vuex.png)

从图中的架构我们可以看出，state的变动造成vue组件的重新渲染，vue组件内部通过dispatch action来与后台进行交互，action又通过commit mutations来改变state。

因此可以想象使用vuex进行状态管理，是将vuex的state与vue中的属性、计算属性进行关联。在方法内部使用dispatch分发action。

初始化vuex
```js
let visibility = 'all';

const mutations = {
    toggleVisibility(state,visibility){
        state.visibility = visibility;
    }
};

const actions = {
    toggleVisibility({commit},visibility){
        commit('toggleVisibility',visibility);
    }
};

Vue.use(Vuex);

export default const store =  new Vuex.Store({
    state:{
        visibility
    },
    mutations,
    actions
});

// 在Vue入口初始化方法传入store对象即可
new Vue({
    render: h => h(App),
    store,
}).$mount('#app');
```
生成的store可以直接使用dispatch分发action，使用commit提交mutation,可以直接读取state，从入口处传入组件后，在组件内部就可以直接使用`this.$store.state.visibility`来获取属性,使用`this.$store.dispatch`来分发action。

为了方便起见，一般是使用mapState来将store中的state映射到计算属性中，使用mapAction将action映射到methods中

```js
export default {
        methods: {
            ...mapActions(['removeTodo']),
            removeAllCompl() {
                let ids = [];
                for (let i = this.todos.length - 1; i >= 0; i--) {
                    let todo = this.todos[i];
                    if (todo.completed) {
                        ids.unshift(todo.id);
                    }
                }
                this.removeTodo(ids);
            },
        },
        computed: {
            ...mapState({
                todos:state => state.todo.todos,
                visibility:state => state.visibility.visibility
            }),
            ...mapGetters(['leftTodos'])
        },
    }
```

### 模块化
不加命名空间的话，mutations、actions、getters都在根目录下
```js
const moduleA = {
  state: { ... },
  mutations: { ... },
  actions: { ... },
  getters: { ... }
}

const moduleB = {
  state: { ... },
  mutations: { ... },
  actions: { ... }
}

const store = new Vuex.Store({
  modules: {
    a: moduleA,
    b: moduleB
  }
})

store.state.a // -> moduleA 的状态
store.state.b // -> moduleB 的状态
```

### getter
类似于vue中的计算属性，使用现有的属性计算出需要的属性，可以引用不同模块的内容

### 热重载
使用 webpack 的 Hot Module Replacement API,Vuex支持在开发过程中热重载。
```js
if (module.hot) {
  // 使 action 和 mutation 成为可热重载模块
  module.hot.accept(['./mutations', './modules/a'], () => {
    // 获取更新后的模块
    // 因为 babel 6 的模块编译格式问题，这里需要加上 `.default`
    const newMutations = require('./mutations').default
    const newModuleA = require('./modules/a').default
    // 加载新模块
    store.hotUpdate({
      mutations: newMutations,
      modules: {
        a: newModuleA
      }
    })
  })
}
```

示例：[TodoMVC](https://github.com/YeomanYe/todomvc-example)

## Vue-Router
Vue Router 是 Vue.js 官方的路由管理器，有了它构建单页面应用变得易如反掌。

通常页面的分区路由
```html
<template>
<div id="app">
  <h1>Hello App!</h1>
  <p>
    <!-- 使用 router-link 组件来导航. -->
    <!-- 通过传入 `to` 属性指定链接. -->
    <!-- <router-link> 默认会被渲染成一个 `<a>` 标签 -->
    <router-link to="/foo">Go to Foo</router-link>
    <router-link to="/bar">Go to Bar</router-link>
  </p>
  <!-- 路由出口 -->
  <!-- 路由匹配到的组件将渲染在这里 -->
  <router-view></router-view>
</div>
</template>

<script>
// 0. 如果使用模块化机制编程，导入Vue和VueRouter，要调用 Vue.use(VueRouter)

// 1. 定义 (路由) 组件。
// 可以从其他文件 import 进来
const Foo = { template: '<div>foo</div>' }
const Bar = { template: '<div>bar</div>' }

// 2. 定义路由
// 每个路由应该映射一个组件。 其中"component" 可以是
// 通过 Vue.extend() 创建的组件构造器，
// 或者，只是一个组件配置对象。
const routes = [
  { path: '/foo', component: Foo },
  { path: '/bar', component: Bar }
]

// 3. 创建 router 实例，然后传 `routes` 配置,还可以传别的配置参数
const router = new VueRouter({
  routes // (缩写) 相当于 routes: routes
})

// 4. 创建和挂载根实例。
// 记得要通过 router 配置参数注入路由，
// 从而让整个应用都有路由功能
const app = new Vue({
  router
}).$mount('#app')
</script>
```

### 多页面路由
路径`/`,`/parent`都可以通过地址导航到
```js
const router = new VueRouter({
  routes: [
    { path: '/', component: Home },
    { path: '/parent', component: Parent, props: { newsletterPopup: false },
      children: [
        { path: '', component: Default },
        { path: 'foo', component: Foo },
        { path: 'bar', component: Bar }
      ]
    }
  ]
})

new Vue({
  router,
  template: `
        <router-view class="view"></router-view>
  `
}).$mount('#app');
```

### 权限校验
vue-router的权限校验是通过路由守卫来实现的，类似于一种拦截器的形式。路由守卫可以添加在全局、也可添加在路由的配置中（独享守卫）、还可添加在组件内。

全局守卫
```js
const router = new VueRouter({ ... })

router.beforeEach((to, from, next) => {
  // ...
})
```
next:
- next()进入下一个钩子
- next(false)中断当前导航，url地址重置到from对应地址
- next('/')当前导航被中断，跳转到一个不同的地址
- next(error)导航会被终止且该错误会被传递给 router.onError() 注册过的回调。

全局守卫类型有：beforeEach、afterEach
独享守卫类型有：beforeEnter
组件守卫类型有：beforeRouteEnter、beforeRouteUpdate、beforeRouteLeave 

完整的导航解析流程
(失活组件中)beforeRouteLeave ->
beforeEach -> beforeRouteUpdate (重用组件) -> beforeEnter(路由配置) ->
beforeRouteEnter -> beforeResolve -> 导航被确认 -> afterEach -> 触发dom更新

### 编程式导航
除了通过组件的形式来配置路由以外，还可以使用路由api来设置路由

```js
router.push(location, onComplete?, onAbort?)
router.replace(location, onComplete?, onAbort?)
router.go(n)
```

### 过渡动效
```html
<template>
<!-- 使用动态的 transition name -->
<transition :name="transitionName">
  <router-view></router-view>
</transition>
</template>
<script>
// 接着在父组件内
// watch $route 决定使用哪种过渡
export default {
    watch: {
      '$route' (to, from) {
        const toDepth = to.path.split('/').length
        const fromDepth = from.path.split('/').length
        this.transitionName = toDepth < fromDepth ? 'slide-right' : 'slide-left'
      }
    }
}
</script>
```

### 其他
vue-router还可以通过给路由设置别名来重用路由，设置重定向方法，再特定的情况下重定向页面。

vue-router默认 hash 模式 —— 使用 URL 的 hash 来模拟一个完整的 URL，于是当 URL 改变时，页面不会重新加载。如果不想要很丑的 hash，我们可以用路由的 history 模式，这种模式充分利用 history.pushState API 来完成 URL 跳转而无须重新加载页面。

```js
const router = new VueRouter({
  mode: 'history',
  routes: [...]
})
```

## 参考文献:
[Vue官方教程](https://cn.vuejs.org/v2/guide/computed.html#%E8%AE%A1%E7%AE%97%E5%B1%9E%E6%80%A7%E7%BC%93%E5%AD%98-vs-%E6%96%B9%E6%B3%95)
[Vue API](https://cn.vuejs.org/v2/api/)
[Vue2技术归纳与精粹](https://blog.csdn.net/sinat_17775997/article/details/78913968#Vue-directive-id-definition)
[Vuex文档](https://vuex.vuejs.org/zh/guide/)
[Vue Router](https://router.vuejs.org/zh/)
