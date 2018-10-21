title: Web Component初体验
tags:
    - 前端框架
comments: true
brief: Web Component初体验
date: 2018-10-10
categories:
    - 前端框架
---
# Web Component初体验
Web Components是w3c推出的关于组件化的一个标准，目的是希望它能将组件化更好的带进web开发，同时尽量保证标准规范，使得开发者可以更好的关注于开发。

<!-- more -->

## 基本概念
web component它由四项主要技术组成，它们可以一起使用来创建封装功能的定制元素，可以在你喜欢的任何地方重用，不必担心代码冲突。

- Custom elements（自定义元素）：一组JavaScript API，允许您定义custom elements及其行为，然后可以在您的用户界面中按照需要使用它们。
- Shadow DOM（影子DOM）：一组JavaScript API，用于将封装的“影子”DOM树附加到元素（与主文档DOM分开呈现）并控制其关联的功能。通过这种方式，您可以保持元素的功能私有，这样它们就可以被脚本化和样式化，而不用担心与文档的其他部分发生冲突。
- HTML templates（HTML模板）：`<template>` 和 `<slot>` 元素使您可以编写不在呈现页面中显示的标记模板。然后它们可以作为自定义元素结构的基础被多次重用。
- HTML Imports（HTML导入）：一旦定义了自定义组件，最简单的重用它的方法就是使其定义细节保存在一个单独的文件中，然后使用导入机制将其导入到想要实际使用它的页面中。HTML 导入就是这样一种机制，尽管存在争议 — Mozilla 根本不同意这种方法，并打算在将来实现更合适的。

## Custom elements
自定义元素分两类：

- 自定义标签元素（Autonomous custom elements）：完全独立于原始HTML元素标签的新标签元素，其所有行为需要开发者定义；
- 自定义内置元素（Customized built-in）：基于HTML原始元素标签的自定义元素，以便于使用原始元素的特性，开发者只需要定义拓展行为；

生命周期函数：
- connectedCallback：当 custom element首次被插入文档DOM时，被调用。
- disconnectedCallback：当 custom element从文档DOM中删除时，被调用。
- adoptedCallback：当 custom element被移动到新的文档时，被调用。
- attributeChangedCallback: 当 custom element增加、删除、修改自身属性时，被调用。

### 自定义标签元素
自定义标签元素继承自HTMLElement
```js
class PopUpInfo extends HTMLElement {
  constructor() {
    // 必须首先调用 super方法 
    super(); 

    // 元素的功能代码写在这里

    ...
  }
}
customElements.define('popup-info', PopUpInfo);
```

我们首先需要将shadow root附加到custom element上，然后通过一系列DOM操作创建custom element的内部阴影DOM结构，再将其附加到 shadow root上。

```js
// 1. 创建一个 shadow root
var shadow = this.attachShadow({mode: 'open'});

// 创建一个 spans
var wrapper = document.createElement('span');
wrapper.setAttribute('class','wrapper');
var icon = document.createElement('span');
icon.setAttribute('class','icon');
icon.setAttribute('tabindex', 0);
var info = document.createElement('span');
info.setAttribute('class','info');

// 获取text属性上的内容，并添加到一个span标签内
var text = this.getAttribute('text');
info.textContent = text;

// 插入 icon
var imgUrl;
// 判断标签是否存在该属性值，存在则使用
if(this.hasAttribute('img')) {
  imgUrl = this.getAttribute('img');
} else {
  imgUrl = 'img/default.png';
}
var img = document.createElement('img');
img.src = imgUrl;
icon.appendChild(img);

// 创建一些 CSS，并应用到 shadow dom上
var style = document.createElement('style');

style.textContent = '.wrapper {' +
// 简洁起见，省略了具体的CSS

// 将创建的元素附加到 shadow dom

// 2. 将根节点放入shadow中
shadow.appendChild(style);
shadow.appendChild(wrapper);
wrapper.appendChild(icon);
wrapper.appendChild(info);
```

### 自定义内置元素
自定义内置元素与自定义标签元素十分相像。区别在于创建自定义内置元素继承的不是HTMLElement对象而是具体的某个元素对象（如：HTMLButtonElement、HTMLULlistElement等等），使用上是使用继承的对象的标签加`is`属性来代表该元素的使用。

```js
class ExpandingList extends HTMLUListElement {
  constructor() {
    // 必须首先调用 super方法 
    super();

    // 元素的功能代码写在这里

    ...
  }
}

customElements.define('expanding-list', ExpandingList, { extends: "ul" });
```

在页面上使用

```html
<ul is="expanding-list">
  ...
</ul>
```

## Shadow Dom
影子DOM API提供了attachShadow()方法，创建一个影子DOM，支持将封装的内容或组件作为一个独立DOM子树附加进一个HTML文档，组件内与外部隔离，样式互不影响，这也印证了组件开发的封装性需求。

Shadow Dom相关术语：
- Shadow host： 一个常规 DOM节点，Shadow DOM会被添加到这个节点上。
- Shadow tree：Shadow DOM内部的DOM树。
- Shadow boundary：Shadow DOM结束的地方，也是常规 DOM开始的地方。
- Shadow root: Shadow tree的根节点。

### 创建
要创建一个shadow dom，只需要用一个页面元素对象的attachShadow()方法即可。调用该方法，即可将一个shadow dom绑定到文档中存在的元素上。

```js
var frag = document.querySelector('#frag');
var shadowRoot = frag.attachShadow({mode: 'open'});
shadowRoot.innerHTML = '<p>Shadow DOM Content</p>';
```

该对象有一个mode属性，值可以是open或者closed。open 表示你可以通过页面内的 JavaScript 方法来获取 Shadow DOM，例如使用Element.shadowRoot 属性 `frag.shadowRoot`

影子DOM树的渲染，其方式与web文档DOM树的渲染方式并无区别，均由浏览器渲染引擎进行渲染，需要注意的是，影子树的DOM渲染过程和文档DOM树的渲染是独立分别进行的。

## HTML templates
### slot
当一个元素（即影子主体）内存在影子DOM，浏览器默认只会渲染该影子DOM的影子树，而不渲染影子主体的其他子内容，如果想要渲染其他内容那就需要使用插槽(slot)了。

页面结构

```html
<div class="menus">
    <h1>title</h1>
    <slot></slot>
    <slot name="top"></slot>
    <slot name="right"></slot>
</div>
```

影子树结构如下

```html
<h2>Menus</h2>
<ul slot="top">
    <li>Home</li>
    <li>About</li>
</ul>
<ul slot="right">
    <li>Home</li>
    <li>Top</li>
</ul>
```

渲染结果
```html
<div class="menus">
    <h1>title</h1>
    <h2>Menus</h2>
    <ul>
        <li>Home</li>
        <li>About</li>
    </ul>
    <ul>
    <li>Home</li>
    <li>Top</li>
    </ul>
</div>
```
### template
为了更友好的处理组件模板，Web Components规范，支持`<template>`模板标签，HTML模板定义了使用`<template>`标签声明可以通过脚本操作插入文档的HTML模板片段。

`<template>`标签本质上与其他HTML内置标签一样，可以使用DOM API进行操作，但是需要明白，在将模板激活（生成DOM或插入文档）前：

- `<template>`标签内的内容不会被渲染；
- 标签内的图片，等媒体资源不会被加载；
- 标签不会出现在DOM树，审查元素看不到

```html
<template id="menusTemplate">
    <ul>
        <li>Home</li>
        <li>About</li>
    </ul>
</template>
```

使用js操作
```js
var menusTemplate = document.querySelector('#menusTemplate');
var frag = document.importNode(menusTemplate.content, true);
document.querySelector('.menus').appendChild(frag);
```

### 结合Custom elements
与Custom elements一起使用，就不必再使用js创建shadow dom树了。
```js
customElements.define('my-paragraph',
  class extends HTMLElement {
    constructor() {
      super();
      let template = document.getElementById('my-paragraph');
      let templateContent = template.content;

      const shadowRoot = this.attachShadow({mode: 'open'})
        .appendChild(templateContent.cloneNode(true));
  }
})
```

注意这里使用Node.cloneNode() 方法添加了模板(template) 的拷贝到阴影（shadow) 的根结点上！！！

```html
<template id="my-paragraph">
  <style>
    p {
      color: white;
      background-color: #666;
      padding: 5px;
    }
  </style>
  <p>My paragraph</p>
</template>
```

## HTML Imports
在文档内直接引入外链资源的文档或web组件，使用`<link>`标签：

```html
<link rel="import" href="components.html">
```

假如在components.html中定义了got-top自定义元素，则在本文档内可以直接使用：

```html
<go-top>GoTop</go-top>
```

值得注意的是：为了避免重复执行引入文档内的脚本，对于已加载文档，import方式将跳过其加载和执行过程。

## 其他
虽然web components是一个挺让人激动的特性，但是从can I Use网站可以看出，该特性浏览器支持率还比较低，还不能用于开发环境中。

![Can I Use](canIUse.png)

虽然支持率低，但是也已经有不少基于此开发的组件库了，如:polymer、slim、X-Tag

## 参考文献

[MDN](https://developer.mozilla.org/zh-CN/docs/Web/Web_Components)

[Web Components简述](https://zhuanlan.zhihu.com/p/26925466?refer=dreawer)

