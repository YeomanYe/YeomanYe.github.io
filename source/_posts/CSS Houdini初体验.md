title: CSS Houdini初体验
tags:
    - CSS
comments: true
brief: CSS Houdini初体验
date: 2018-11-20
categories:
    - 前端
---
# CSS Houdini初体验
CSS Houdini 是由一群來自 Mozilla, Apple, Opera, Microsoft, HP, Intel, IBM, Adobe 与 Google 的工程师所组成的工作小组，志在建立一系列的 API，让开发者能够介入浏览器的 CSS engine 操作，帶给开发者更多的解決方案，用来解決 CSS 长久以来的问题：

- 统一跨浏览器行为
- 开发新特性或者给新特性打补丁，让人们可以立刻使用到新特性

<!-- more -->

浏览器渲染与houdini作用期对比：

![浏览器渲染期与houdini作用期比对](浏览器渲染期与houdini作用期比对.png)

灰色部分就是只在规划阶段，黃色部份是已经写入规范正在推行中。

## CSS Properties and Values API
CSS Properties and Values API中目前最实用的的是CSS变量技术

### CSS变量
变量可以定义在 root,element,selector 內，也能在一般 selector 內，甚至是给別的变量 reuse：

```css
/* root element selector (全域) */
:root {
    --main-color: #ff00ff;
    --main-bg: rgb(200, 255, 255);
    --block-font-size: 1rem;
}
.btn__active::after{
    --btn-text: 'This is btn';
    /* 相等於 --box-highlight-text:'This is btn been actived'; */
    --btn-highlight-text: var(--btn-text)' been actived';
    content: var(--btn-highlight-text);
    /* 也能使用 calc 來做運算 */
    font-size: calc(var(--block-font-size)*1.5);
}
body {
    /* variable usage */
    color: var(--main-color);
}
```

**html中创建变量：** 在html中的style中即可创建;
```html
<div id="box" style="--color: #cd0000;">
    <img src="mm.jpg" style="border: 10px solid var(--color);">
</div>
```

**使用js的方式设置变量：**

```js
// 获取 --color CSS 变量值
var cssVarColor = getComputedStyle(box).getPropertyValue('--color');
// 输出cssVarColor
// 输出变量值是：#cd0000 
console.log(cssVarColor);

//设置 css color的变量值
box.style.setProperty('--color', '#cd0000');
```

有了这个技术，我们改变样式时，可以通过只修改一个或几个CSS变量达到改变样式的目的。而不用使用CSS类名来大段大段的重写样式。更便于维护。

具体示例，大家可以参考张鑫旭老师的这篇文章[CSS背景自动配色](https://www.zhangxinxu.com/wordpress/2018/11/css-background-color-font-auto-match/)

## Worklet
### CSS Layout API
CSS Layout API提供开发者撰写自己的Layout module，Layout module 也就是用来 assign 给 display 属性的值，像是 display: grid 或 display: flex。

创建一个Layout Module固定的套路：

- CSS中需要引用该布局的样式，使用`display:layout('block-like')；`来引用
- JS添加模块`CSS.layoutWorklet.addModule('block-like.js');`
- block-like.js中编写布局方式，感兴趣的可以参见见如下代码：

__编写模块__

```js
registerLayout('block-like', class extends Layout {
    static blockifyChildren = true;
    static inputProperties = super.inputProperties;
    *layout(space, children, styleMap) {
        const inlineSize = resolveInlineSize(space, styleMap);
        const bordersAndPadding = resolveBordersAndPadding(constraintSpace, styleMap);
        const scrollbarSize = resolveScrollbarSize(constraintSpace, styleMap);
        const availableInlineSize = inlineSize -
                                    bordersAndPadding.inlineStart -
                                    bordersAndPadding.inlineEnd -
                                    scrollbarSize.inline;
        const availableBlockSize = resolveBlockSize(constraintSpace, styleMap) -
                                bordersAndPadding.blockStart -
                                bordersAndPadding.blockEnd -
                                scrollbarSize.block;
        const childFragments = [];
        const childConstraintSpace = new ConstraintSpace({
            inlineSize: availableInlineSize,
            blockSize: availableBlockSize,
        });
        let maxChildInlineSize = 0;
        let blockOffset = bordersAndPadding.blockStart;
        for (let child of children) {
            const fragment = yield child.layoutNextFragment(childConstraintSpace);
            // 這段控制 Layout 下的 children 要 inline 排列
            // fragment 應該就是前述的 Box Tree API 內提到的 fragment
            fragment.blockOffset = blockOffset;
            fragment.inlineOffset = Math.max(
                bordersAndPadding.inlineStart,
                (availableInlineSize - fragment.inlineSize) / 2);
            maxChildInlineSize =
                Math.max(maxChildInlineSize, childFragments.inlineSize);
            blockOffset += fragment.blockSize;
        }
        const inlineOverflowSize = maxChildInlineSize + bordersAndPadding.inlineEnd;
        const blockOverflowSize = blockOffset + bordersAndPadding.blockEnd;
        const blockSize = resolveBlockSize(
            constraintSpace, styleMap, blockOverflowSize);
        return {
            inlineSize: inlineSize,
            blockSize: blockSize,
            inlineOverflowSize: inlineOverflowSize,
            blockOverflowSize: blockOverflowSize,
            childFragments: childFragments,
        };
    }
});
```

__引入模块__

```js
if (window.CSS) {
    CSS.layoutWorklet.addModule('block-like.js');
}
```

__使用__

```css
.box {
    display: layout('block-like');
}
```

示例代码是一种类block的布局方式，它让子元素在block方向（正常流中指的是竖直方向）依序排列，让子元素在inline方向(正常流中是水平方向)居中。[原草案地址](https://drafts.css-houdini.org/css-layout-api/#examples)

### CSS Painting API
CSS Painting API用来提供动态的图片，可以简单理解为把Canvas画布作为普通元素的背景图片。

CSS Painting API使用有跟CSS Layout API固定的套路：

- CSS中引用该样式，使用`background-image:paint('xxx')；`来引用
- JS添加模块`CSS.paintWorklet.addModule('xxx.js');`
- `xxx.js`中代码套路固定，在下面注释位置写绘制代码即可；

```js
registerPaint('custom-grid', class {
    // 获取3个变量
    static get inputProperties() {
        return [
            '--color1',
            '--color2',
            '--units'
        ]
    }
    paint(context, size, properties) {
         // 依據 properties 改變顏色
        const color = properties.get('--rect-color');
        ctx.fillStyle = color.cssText;
        ctx.fillRect(0, 0, size.width, size.height);
    }
});
```

paint中的API与canvas中几乎相同，但也不尽相同，具体区别见下图（出自张老师的CSS届的绘图板）：

![PaintAPI](PaintAPI.png)

想看具体示例可以见：[用CSS Houdini画一片星空](https://juejin.im/post/5adc091b51882567105f5586)

## 其他需要了解的概念
### Box Tree API
Box tree API是为了让开发者能够取得fragments 的信息，Box tree API虽然没有出现在houidini的API中，但是它与 Parser API、Layout API 与 Paint API 有关联，因此我们应该正确的认识这个api所涉及的fragments概念，从而可以正确的使用它。

__fragments__

![fragments](fragments.png)

上面的 HTML 总共就会拆出七个 fragments：

- 最外层的 div
- 第一行的 box (包含 foo bar)
- 第二行的 box (包含 baz)
- 吃到 ::first-line 与 ::first-letter 的 f 也会被拆出來成独立的 fragments
- 只吃到 ::first-line 的 oo 只好也独立出來
- 吃到 ::first-line 与 包在 `<i>` 內的 bar 当然也是
- 在第二行底下且为 italic 的 baz

### CSS Typed OM
CSS Typed OM 就是 CSSOM 的強化版，最主要的功能在于将 CSSOM 所使用的字串值转换成具有型別意义的 JavaScript 表示形态。简单说就是给原来没有类型的CSS样式设置类型，设置接口。

```js
// CSS -> JS
const map = document.querySelector('.example').styleMap;
console.log( map.get('font-size') );
// CSSSimpleLength {value: 12, type: "px", cssText: "12px"}
// JS -> JS
console.log( new CSSUnitValue(5, "px") );
// CSSUnitValue{value:5,unit:"px",type:"length",cssText:"5px"}
// JS -> CSS
// set style "transform: translate3d(0px, -72.0588%, 0px);"
elem.outputStyleMap.set('transform',
    new CSSTransformValue([
        new CSSTranslation(
        0, new CSSSimpleLength(100 - currentPercent, '%'), 0
        )]));
```

有了型別定义，在 JavaScript 的操作上据说会有性能上的显著提升（因为浏览器知道样式的类型能够更快的解析）。CSS Typed OM 也会应用在 Parser API 与 CSS Properties and Values API 上。

## 参考文献
[CSS魔术师Houdini API介绍](https://www.w3cplus.com/css/css-houdini.html)

[Houdini目前进展](https://zhuanlan.zhihu.com/p/20939640)

[CSS背景自动配色](https://www.zhangxinxu.com/wordpress/2018/11/css-background-color-font-auto-match/)

[CSS届的绘图板](https://www.zhangxinxu.com/wordpress/2018/11/css-paint-api-canvas/)

[用CSS Houdini画一片星空](https://juejin.im/post/5adc091b51882567105f5586)