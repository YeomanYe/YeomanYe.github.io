title: Vue2入门
tags:
    - Vue
    - 前端框架
comments: true
brief: Vue2入门概览
date: 2017-07-06
categories:
    - 前端框架
---
# Vue2入门
本文介绍Vue的相关概念，使用方式。目的是使读者对React有一个大致的了解，以便于能够更加深入的学习、快速上手Vue。学习Vue应该掌握好几个概念，Vue实例、数据绑定、模板语法、组件。

<!-- more -->

- Vue实例
    - 响应式数据
    - 计算属性
    - 方法
    - 生命周期
- 数据绑定
    - 绑定到属性
        - class与style绑定
        - 表单输入绑定
        - 事件绑定
    - 绑定到内容
    - 双向绑定
- 模板语法
    - 插值
    - 指令
        - 缩写
        - 条件渲染
        - 列表渲染
- 组件
    - 组件注册
    - 组件通信
    - 动态组件
    - 分发内容

## Vue实例
每个 Vue 应用都是通过 Vue 函数创建一个新的 Vue 实例开始的

Vue对象通过data方式传入响应式数据，这些数据与vue实例中的数据同步改变。vue实例暴露的接口都以$开头
```js
var data = { a: 1 }
var vm = new Vue({
  el: '#example',
  data: data,
  // 生命周期函数
  created: function () {
    // `this` 指向 vm 实例
    console.log('a is: ' + this.a)
  }
})
vm.$data === data // => true
vm.$el === document.getElementById('example') // => true
// $watch 是一个实例方法
vm.$watch('a', function (newValue, oldValue) {
  // 这个回调将在 `vm.a` 改变后调用
})
```

不要在选项属性或回调上使用箭头函数，比如 created: () => console.log(this.a) 或 vm.$watch('a', newValue => this.myMethod())。因为箭头函数是和父级上下文绑定在一起的，this 不会是如你做预期的 Vue 实例，且 this.a 或 this.myMethod 也会是未定义的。

### 响应式数据

响应式属性添加
```js
var vm = new Vue({
  data: {
    userProfile: {
      name: 'Anika'
    }
  }
})
//法一
Vue.set(vm.userProfile, 'age', 27)
//法二
this.$set(this.userProfile, 'age', 27)
//赋予多个属性
this.userProfile = Object.assign({}, this.userProfile, {
  age: 27,
  favoriteColor: 'Vue Green'
})

```

#### 被观察属性
使用watch当属性变动时，进行更新

```html
<div id="demo">{{ fullName }}</div>
```

```js
// 每当firstName和lastName发生变化就进行更新
var vm = new Vue({
  el: '#demo',
  data: {
    firstName: 'Foo',
    lastName: 'Bar',
    fullName: 'Foo Bar'
  },
  watch: {
    firstName: function (val) {
      this.fullName = val + ' ' + this.lastName
    },
    lastName: function (val) {
      this.fullName = this.firstName + ' ' + val
    }
  }
})
```


### 计算属性
当计算属性依赖的属性发生改变时才会自动更新，基于依赖进行缓存。

```html
<div id="example">
  <p>Original message: "{{ message }}"</p>
  <p>Computed reversed message: "{{ reversedMessage }}"</p>
</div>
```

```js
var vm = new Vue({
  el: '#example',
  data: {
    message: 'Hello'
  },
  computed: {
    // 计算属性默认只有getter方法
    reversedMessage: function () {
      // `this` points to the vm instance
      return this.message.split('').reverse().join('')
    },
    fullName: {
        // getter
        get: function () {
          return this.firstName + ' ' + this.lastName
        },
        // setter
        set: function (newValue) {
          var names = newValue.split(' ')
          this.firstName = names[0]
          this.lastName = names[names.length - 1]
        }
    }
  }
})
```

### 方法
方法没有缓存，每次访问都进行计算
```html
<p>Reversed message: "{{ reversedMessage() }}"</p>
```

```js
// in component
methods: {
  reversedMessage: function () {
    return this.message.split('').reverse().join('')
  }
}
```

### 生命周期
生命周期图示

![生命周期](lifecycle.png)

## 数据绑定
### 绑定到属性
#### Class与Style绑定
##### 对象绑定class
active、'text-danger':hasError表示当hasError为真时则启用对应名称的class
```html
<div class="static"
     v-bind:class="{ active: isActive, 'text-danger': hasError }">
</div>
```

```js
data: {
  isActive: true,
  hasError: false
}
```

使用对象进行绑定
```html
<div v-bind:class="classObject"></div>
```

```js
data: {
  classObject: {
    active: true,
    'text-danger': false
  }
}
```

##### 数组绑定class
```html
<div v-bind:class="[activeClass, errorClass,{ active: isActive }]"></div>
```

```js
data: {
  activeClass: 'active',
  errorClass: 'text-danger'
}
```

class绑定用在组件上，则是与html的class相互叠加的方式。

##### 对象绑定style
使用data中的属性
```html
<div v-bind:style="{ color: activeColor, fontSize: fontSize + 'px' }"></div>
```

```js
data: {
  activeColor: 'red',
  fontSize: 30
}
```

直接绑定一个对象
```html
<div v-bind:style="styleObject"></div>
```

```js
data: {
  styleObject: {
    color: 'red',
    fontSize: '13px'
  }
}
```

##### 数组绑定style
```html
<div v-bind:style="[baseStyles, overridingStyles]"></div>
```

#### 事件绑定
##### 监听事件
绑定方式
```html
<div id="example-1">
    <!-- 字面量方式（此处使用了修饰符，修饰符可串联） -->
  <button v-on:click.stop.prevent="counter += 1">增加 1</button>
  <!-- 方法方式 -->
  <button v-on:click="greet">问候</button>
  <!-- 内联处理器,$event传入事件到方法 -->
  <button v-on:click="warn('Form cannot be submitted yet.', $event)">
  <p>这个按钮被点击了 {{ counter }} 次。</p>
</div>
```

```js
var example1 = new Vue({
  el: '#example-1',
  data: {
    counter: 0
  },
  methods:{
    greet:function(event){
         // `this` 在方法里指当前 Vue 实例
      alert('Hello ' + this.name + '!')
      // `event` 是原生 DOM 事件
      if (event) {
        alert(event.target.tagName)
      }
    },
    warn: function (message, event) {
        // 现在我们可以访问原生事件对象
        if (event) event.preventDefault()
        alert(message)
    }
  }
})
```

##### 修饰符
- 事件修饰符：.stop(阻止冒泡)，.prevent(阻止默认事件)，.capture(监听器加在捕获模式上)，.self(只有事件在该元素本身时触发回调)，.once(只触发一次事件)
- 键值修饰符：.enter，.tab，.delete (捕获“删除”和“退格”键)，.esc，.space，.up，.down，.left，.right；.ctrl，.alt，.shift，.meta
- 鼠标按钮修饰符：.left，.right，.middle

自定义键值修饰符别名：
```js
// 可以使用 v-on:keyup.f1
Vue.config.keyCodes.f1 = 112
```

#### 表单输入绑定
使用v-model对表单进行双向绑定，绑定的数据为表单的值value,复选框和多选列表可以绑定到数组上。

```html
<!-- 当选中时，`picked` 为字符串 "a" -->
<input type="radio" v-model="picked" value="a">
<!-- `toggle` 为 true 或 false -->
<input type="checkbox" v-model="toggle">
<!-- 当选中时，`selected` 为字符串 "abc" -->
<select v-model="selected">
  <option value="abc">ABC</option>
</select>
```

修改绑定的值到响应元素上
```html
<input
  type="checkbox"
  v-model="toggle"
  v-bind:true-value="a"
  v-bind:false-value="b"
>
```

```js
// 当选中时
vm.toggle === vm.a
// 当没有选中时
vm.toggle === vm.b
```

修饰符：.lazy（同步事件由input改为change），.number（将用户的输入结果转换为number类型，转换结果为NaN则返回原值），.trim(自动过滤用户输入首位空格)

### 绑定到内容
使用模板的插值语法进行数据的绑定

```html
<!-- 数据绑定 -->
<span>Message: {{ msg }}</span>
<!-- 数据不绑定 -->
<span v-once>这个将不会改变: {{ msg }}</span>
```

### 双向绑定
使用v-model在表单元素上进行双向绑定。

## 模板语法
### 插值
```html
<!-- 数据绑定 -->
<span>Message: {{ msg }}</span>
<!-- 数据不绑定 -->
<span v-once>这个将不会改变: {{ msg }}</span>
```

使用v-bind命令让mustache语法作用在HTML上

```html
<div v-bind:id="dynamicId"></div>
<button v-bind:disabled="isButtonDisabled">Button</button>
```

绑定使用的js表达式只能包含单个表达式

```html
<!-- 这是语句，不是表达式 -->
{{ var a = 1 }}
<!-- 流控制也不会生效，应使用三元表达式 -->
{{ if (ok) { return message } }}
```

### 指令
指令 (Directives) 是带有 v- 前缀的特殊属性。指令的职责是，当表达式的值改变时，将其产生的连带影响，响应式地作用于 DOM。

```html
<p v-if="seen">现在你看到我了</p>
<!-- 带参数的指令 -->
<a v-bind:href="url"></a>
<a v-on:click="doSomething">
<!-- 表示以特殊方式绑定，当提交表单时阻止默认行为 -->
<form v-on:submit.prevent="onSubmit"></form>
```

#### 缩写
v-bind缩写

```html
<!-- 完整语法 -->
<a v-bind:href="url"></a>
<!-- 缩写 -->
<a :href="url"></a>
```

v-on缩写
```html
<!-- 完整语法 -->
<a v-on:click="doSomething"></a>
<!-- 缩写 -->
<a @click="doSomething"></a>
```

#### 条件渲染
条件渲染的使用形式如下:
```html
<div v-if="type === 'A'">
  A
</div>
<div v-else-if="type === 'B'">
  B
</div>
<div v-else-if="type === 'C'">
  C
</div>
<div v-else>
  Not A/B/C
</div>

<template v-if="loginType === 'username'">
  <label>Username</label>
  <input placeholder="Enter your username" key="username-input">
</template>
<template v-else>
  <label>Email</label>
  <input placeholder="Enter your email address" key="email-input">
</template>
```

v-if用于切换显示单个元素时，加在元素上就好了，切换多个元素时需要用template包裹多个元素。如果没有使用key进行区分元素将会被复用。

v-show不管初始条件是什么，元素总是会被渲染，并且只是简单地基于 CSS 进行切换。

#### 列表渲染
##### 使用数组
使用v-for将数组对应为一组元素，可以使用of代替in

```html
<ul id="example-1">
  <li v-for="(item,index) in items">
    {{ item.message }}
  </li>
</ul>
```

```js
var example1 = new Vue({
  el: '#example-1',
  data: {
    items: [
      { message: 'Foo' },
      { message: 'Bar' }
    ]
  }
})
```

##### 使用对象

```html
<ul id="v-for-object" class="demo">
  <li v-for="(value,key,index) in object">
    {{ value }}
  </li>
</ul>
```

```js
new Vue({
  el: '#v-for-object',
  data: {
    object: {
      firstName: 'John',
      lastName: 'Doe',
      age: 30
    }
  }
})
```

##### template
类似于 v-if，你也可以利用带有 v-for 的 `<template> `渲染多个元素。
```html
<ul>
  <template v-for="item in items"  v-if="!item.isComplete">
    <li>{{ item.msg }}</li>
    <li class="divider"></li>
  </template>
</ul>
```

##### key值
为了给 Vue 一个提示，以便它能跟踪每个节点的身份，从而重用和重新排序现有元素，你需要为每项提供一个唯一 key 属性。理想的 key 值是每项都有的且唯一的 id。你需要用 v-bind 来绑定动态值

```html
<div v-for="item in items" :key="item.id">
  <!-- 内容 -->
</div>
```

##### 更新检测
当数组结构发生改变时，就会自动更新。（如:unshift、push()、pop()、shift()、unshift()、splice()、sort()、reverse()）

以下两种方法不会触发自动更新：
- vm.items[indexOfItem] = newValue（触发更新Vue.set(example1.items, indexOfItem, newValue)、example1.items.splice(indexOfItem, 1, newValue)）
- vm.items.length = newLength （触发更新example1.items.splice(newLength)
）

## 组件
组件可以扩展 HTML 元素，封装可重用的代码。

### 组件注册
```js
//全局注册
Vue.component('my-component', {
  // 选项
})
//局部注册，组件仅在该实例中可用
new Vue({
  // ...
  components: {
    // <my-component> 将只在父模板可用
    'my-component': Child
  }
})
```

#### 使用DOM模板
由于浏览器的解析机制，使用DOM作为模板时，添加自定义属性应该使用is属性

```html
<table>
  <tr is="my-row"></tr>
  <!-- <my-row>...</my-row>不能使用标签的形式 -->
</table>
```

组件间的class与style使用并集的方式获取。

#### 组件data为函数
所有组件共用一个data

```js
var data = { counter: 0 }
Vue.component('simple-counter', {
  template: '<button v-on:click="counter += 1">{{ counter }}</button>',
  data: function () {
    return data
  }
})
new Vue({
  el: '#example-2'
})
```

每个组件使用不同的data对象
```js
data: function () {
  return {
    counter: 0
  }
}
```

### 通信方式
父组件使用Props的方式与子组件通信，子组件通过事件的方式与父组件通信。


#### Props
父组件向子组件传递消息

模板之间使用-隔开，props中使用驼峰命名法
```html
<child v-bind:my-message="parentMsg"></child>
```

```js
Vue.component('child', {
  // 
  props: ['myMessage'],
  // 
  template: '<span>{{ myMessage }}</span>'
})
```

Prop验证
```js
Vue.component('example', {
  props: {
    // 基础类型检测 (`null` 意思是任何类型都可以)
    propA: Number,
    // 多种类型
    propB: [String, Number],
    // 必传且是字符串
    propC: {
      type: String,
      required: true
    },
    // 数字，有默认值
    propD: {
      type: Number,
      default: 100
    },
    // 数组/对象的默认值应当由一个工厂函数返回
    propE: {
      type: Object,
      default: function () {
        return { message: 'hello' }
      }
    },
    // 自定义验证函数
    propF: {
      validator: function (value) {
        return value > 10
      }
    }
  }
})
```

#### 自定义事件
自定义事件是子组件向父组件传递消息的方式。

```html
<div id="counter-event-example">
  <p>{{ total }}</p>
  <button-counter v-on:increment="incrementTotal"></button-counter>
  <button-counter v-on:increment="incrementTotal"></button-counter>
</div>
```

```js
Vue.component('button-counter', {
  template: '<button v-on:click="incrementCounter">{{ counter }}</button>',
  data: function () {
    return {
      counter: 0
    }
  },
  methods: {
    incrementCounter: function () {
      this.counter += 1
      this.$emit('increment')
    }
  },
})
new Vue({
  el: '#counter-event-example',
  data: {
    total: 0
  },
  methods: {
    incrementTotal: function () {
      this.total += 1
    }
  }
})
```

给组件绑定原生事件需要添加修饰符.native

### 使用插槽分发内容
父组件与子组件中的内容使用插槽来混合

#### 具名插槽
子组件模板
```html
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
</div>
```

父组件模板
```html
<app-layout>
  <h1 slot="header">这里可能是一个页面标题</h1>
  <p>主要内容的一个段落。</p>
  <p>另一个主要段落。</p>
  <p slot="footer">这里有一些联系信息</p>
</app-layout>
```

渲染结果
```html
<div class="container">
  <header>
    <h1>这里可能是一个页面标题</h1>
  </header>
  <main>
    <p>主要内容的一个段落。</p>
    <p>另一个主要段落。</p>
  </main>
  <footer>
    <p>这里有一些联系信息</p>
  </footer>
</div>
```

#### 作用域插槽
作用域插槽是一种特殊类型的插槽，用作使用一个 (能够传递数据到) 可重用模板替换已渲染元素。

```html
<div class="child">
  <slot text="hello from child"></slot>
</div>
```

在父级中，具有特殊属性 scope 的 <template> 元素必须存在，表示它是作用域插槽的模板。scope 的值对应一个临时变量名

```html
<div class="parent">
  <child>
    <template scope="props">
      <span>hello from parent</span>
      <span>{{ props.text }}</span>
    </template>
  </child>
</div>
```

### 动态组件
通过使用保留的 <component> 元素，动态地绑定到它的 is 特性，我们让多个组件可以使用同一个挂载点，并动态切换

```html
<component v-bind:is="currentView">
  <!-- 组件在 vm.currentview 变化时改变！ -->
</component>
```

```js
var vm = new Vue({
  el: '#example',
  data: {
    currentView: 'home'
  },
  components: {
    home: { /* ... */ },
    posts: { /* ... */ },
    archive: { /* ... */ }
  }
})
```

也可以直接绑定到组件对象上
```js
var Home = {
  template: '<p>Welcome home!</p>'
}
var vm = new Vue({
  el: '#example',
  data: {
    currentView: Home
  }
})
```

使用keep-alive标签，可以把切换出去的组件保留在内存中，可以保留它的状态或避免重新渲染。

```html
<keep-alive>
  <component :is="currentView">
    <!-- 非活动组件将被缓存！ -->
  </component>
</keep-alive>
```


参考文献：
[Vue2.x官方文档](https://cn.vuejs.org/)