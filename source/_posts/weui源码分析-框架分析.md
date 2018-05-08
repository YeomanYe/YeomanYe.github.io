title: WeUI源码分析-框架分析
tags:
    - 源码分析
    - CSS
comments: true
date: 2018-05-05
brief: WeUI源码分析-框架分析
categories:
    - 源码分析
---
# WeUI源码分析-框架分析
上一篇已经分析过了WeUI的demo中值得学习的部分，这一偏正式分析WeUI框架。WeUI框架将组件分为基础组件、表单、操作反馈、导航、搜索这几个部分，并制定层级规范：Popout、Mask、Navigation、Content。

<!-- more -->
基础组件：Article、Badge、Flex、Footer、Gallery、Grid、Icons、Loadmore、Panel、Preview、Progress
表单：Button、Input、List、Slider、Uploader
操作反馈：Actionsheet、Dialog、Msg、Picker、Toast
导航：Navbar、Tabbar
搜索：SearchBar


层级结构以及组件划分基于版本v1.1.2，本文记录源码中让我感到精彩的部分，不能涵盖所有，如有补充欢迎交流。

## 样式
### 文本
- 过长处理
white-space: nowrap不换行,pre-wrap保留空白符，并进行断行；pre-line不保留空白符，但进行断行；pre保留空白符，不进行断行
text-overflow: ellipsis文本使用...省略；clip文本截断
hypens  告知浏览器在换行时如何使用连字符连接单词。可以完全阻止使用连字符，也可以控制浏览器什么时候使用，或者让浏览器决定什么时候使用。(none|auto|manual(当且仅当使用`&hyphen;` 或 `&shy;` 时换行))
word-wrap normal/break-word 过长单词处理方式
word-break break-all（允许单词内换行）在恰当的断字点进行换行

- 文本对齐属性
text-align 设置行与父元素的对齐方式
text-align-last justify(调整为首位对齐) 设置最后一行（唯一的一行）或被打断的行的对齐方式。

- 文本样式
font-variant: normal; //设置小型大写字母字体的样式
text-transform: uppercase | lowercase | capitalize (每个单词都以大写开头) 设置文中单词的显示
line-height:%/无单位 实际值为 设定的百分比值 x font-size获得的具体值
text-size-adjust: none (不允许放大)| auto(可能被放大) | 80%(放大80%) 调整文本大小

### 盒模型
使用box-sizing设置盒模型，值为content-box/border-box
content-box 模型 width = content
border-box 模型 width = padding + content + border

### 伪元素
伪元素before、after是在子元素的第一个前、最后一个后插入元素

a:after { content: ""; }
attr() – 调用当前元素的属性，可以方便的比如将图片的 Alt 提示文字或者链接的 Href 地址显示出来。示例：
a:after { content:"(" attr(href) ")"; }
url() / uri() – 用于引用媒体文件。示例：
h1::before { content: url(logo.png); }
counter() –  调用计数器，可以不使用列表元素实现序号功能。

### 移动相关
webkit-touch-callout：none 当你触摸并按住触摸目标时候，禁止或显示系统默认菜单。在iOS上，当你触摸并按住触摸的目标，比如一个链接，Safari浏览器将显示链接有关的系统默认菜单。这个属性可以让你禁用系统默认菜单。
-webkit-overflow-scrolling:touch 有回弹效果的滚动属性
-webkit-tap-highlight-color 触击时高亮色

### 其他
user-select 是否可选 text、none、all
-apple-system-font(font-family属性值，设置为apple系统字体)
zoom的缩放是相对于左上角的；而scale默认是居中缩放；
zoom的缩放改变了元素占据的空间大小；而scale的缩放占据的原始尺寸不变，页面布局不会发生变化；

## 组件
### SearchBar
使用两个叠加层实现搜索栏聚焦，失焦的效果
```html
<div class="weui-search-bar" id="searchBar">
    <form class="weui-search-bar__form">
        <div class="weui-search-bar__box">
            <i class="weui-icon-search"></i>
            <input type="search" class="weui-search-bar__input" id="searchInput" placeholder="搜索" required/>
            <a href="javascript:" class="weui-icon-clear" id="searchClear"></a>
        </div>
        <!-- 覆盖在整个层上，当点击时使得input获得聚焦效果 -->
        <label class="weui-search-bar__label" id="searchText">
            <i class="weui-icon-search"></i>
            <span>搜索</span>
        </label>
    </form>
    <a href="javascript:" class="weui-search-bar__cancel-btn" id="searchCancel">取消</a>
</div>
```

干掉input[search]默认的clear button
```css
input[type="search"]::-webkit-search-decoration,
input[type="search"]::-webkit-search-cancel-button,
input[type="search"]::-webkit-search-results-button,
input[type="search"]::-webkit-search-results-decoration {
    display: none;
}
```

伪类:focues代表聚焦的情况下

### loadMore
文字覆盖在线上的效果
```less
.weui-loadmore_line{
    border-top:1px solid @weuiLineColorLight;
    margin-top:2.4em;
    .weui-loadmore__tips{
        position: relative;
        top:-.9em;
        padding:0 .55em;
        background-color: #FFFFFF;
        color:@weuiTextColorGray;
    }
}
```

### ActionSheet
通过先将元素下滑出屏幕，然后在移回到原点实现上滑效果。

```css
.someCls{
    transform: translate(0, 100%);
    transition: transform .3s;
}
.toggle{
    transform: translate(0, 0);
}
```

### footer
inline-block父元素设置 font-size为0 去掉间隙
一个高度等于容器的绝对定位元素同时设置top和bottom，意味着去掉顶部和底部，top和bottom对应的长度。

### text
多行缩略文本的设置
```less
.ellipsisLn(@line) {
    overflow: hidden;
    text-overflow: ellipsis;
    display: -webkit-box;
    /*子元素应该被垂直还是水平排列*/
    -webkit-box-orient: vertical;
    /*限制在一个块元素显示的文本的行数。*/
    -webkit-line-clamp: @line;
}
```


display:box; 与 display:flex; 的不同：

1. 与子元素 display 方式的相关性不同
    - display:box; 作用下，如果子元素是 block 的，竖着排，如果子元素是 inline、inline-block的，横着排。 
    - display:flex; 作用下，是横着排还是竖着排，只取决于 flex-direction 的值是 row 还是 column。
2. float 等属性是否受影响的情况不同
    - display:box; 作用下，float、clear、text-align、vertical-align 仍起作用。 
    - display:flex; 作用下，上述四属性失效。
3. 横向排列时，子元素之间空白字符（空格、换行等）处理不同
    - display:box; 作用下，不会被忽略。 
    - display:flex; 作用下，忽略。

### Input
去掉原先浏览器的默认样式，方便用自定义的样式填充
```css
input{
    -webkit-appearance: none;
    appearance:none;
}
```

使用伪元素:after，设置绝对定位覆盖在button上可以用于增大点击面积

自定义radio样式
label包裹input扩大点击域，将input设置为-9999移出屏幕。使用:checked伪类设置选中未选中的样式
```html
<label class="weui_cell weui_check_label" for="x11">
    <div class="weui_cell_bd weui_cell_primary">
        <p>cell standard</p>
    </div>
    <div class="weui_cell_ft">
        <input type="radio" class="weui_check" name="radio1" id="x11">
        <span class="weui_icon_checked"></span>
    </div>
</label>
```

```css
.weui-check{
    position: absolute;
    left: -9999em;
}
```

uploader
input file类型可以视为普通盒子对待  accept="image/*"设置接受的文件内容

### progress
使用两个div，外部的div表示整个条，内部的表示填充的条
使用一个图标在使用旋转动画就能产生loading效果

### picker
使用双背景遮罩可以实现picker
```html
<div>
    <div class="weui-mask weui-animate-fade-in"></div>
    <div class="weui-picker weui-animate-slide-up">
        <div class="weui-picker__hd"> <a href="javascript:;" data-action="cancel" class="weui-picker__action">取消</a> <a href="javascript:;" data-action="select" class="weui-picker__action" id="weui-picker-confirm">确定</a> </div>
        <div class="weui-picker__bd">
            <div class="weui-picker__group">
                <div class="weui-picker__mask"></div>
                <div class="weui-picker__indicator"></div>
                <div class="weui-picker__content" style="transform: translate3d(0px, 34px, 0px);">
                    <div class="weui-picker__item">飞机票</div>
                    <div class="weui-picker__item">火车票</div>
                    <div class="weui-picker__item">的士票</div>
                    <div class="weui-picker__item weui-picker__item_disabled">公交票 (disabled)</div>
                    <div class="weui-picker__item">其他</div>
                </div>
            </div>
        </div>
    </div>
</div>
```

重点是遮罩部分样式的实现，通过设置双层渐变背景实现中间部分不遮罩，两边遮罩的效果
```less
.weui-picker__mask {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    margin: 0 auto;
    z-index: 3;
    background: linear-gradient(180deg, hsla(0, 0%, 100%, .95), hsla(0, 0%, 100%, .6)), linear-gradient(0deg, hsla(0, 0%, 100%, .95), hsla(0, 0%, 100%, .6));
    background-position: top, bottom;
    background-size: 100% 102px;
    background-repeat: no-repeat;
    transform: translateZ(0);
}
```

### tabbar
tabbar分为两部分(内容部分、导航部分)，便于解耦制作不同的类型，框架中实现了两种导航navbar、tabbar

顶部的navbar
```html
<div class="weui-tab">
    <div class="weui-navbar">
        <div class="weui-navbar__item weui-bar__item_on">
            选项一
        </div>
        <div class="weui-navbar__item">
            选项二
        </div>
        <div class="weui-navbar__item">
            选项三
        </div>
    </div>
    <div class="weui-tab__panel">
        <div class="weui-navbar__content"></div>
    </div>
</div>
```

底部的tabbar
```html
<div class="weui-tab">
    <div class="weui-tab__panel">
        <div class="weui-navbar__content"></div>
    </div>
    <div class="weui-tabbar">
        <a href="javascript:;" class="weui-tabbar__item weui-bar__item_on">
            <span style="display: inline-block;position: relative;">
                <img src="./images/icon_tabbar.png" alt="" class="weui-tabbar__icon">
                <span class="weui-badge" style="position: absolute;top: -2px;right: -13px;">8</span>
            </span>
            <p class="weui-tabbar__label">微信</p>
        </a>
        <a href="javascript:;" class="weui-tabbar__item">
            <img src="./images/icon_tabbar.png" alt="" class="weui-tabbar__icon">
            <p class="weui-tabbar__label">通讯录</p>
        </a>
    </div>
</div>
```

## 其他
### 命名规则
结构:weui-cell__hd、bd、ft
组件类型：weui-cell_access、check、weui-cells_radio
样式：default、primary、warn、success
功能类型：clear、delete、msg
外观：circle、square
元素类型：inline
size：mini

组合：
- 外观+样式+功能
- 结构+组件类型 
- 外观+组件类型+size

gap 间隙
topLine 顶部分割线
hyphens 连字符
arrow 箭头
ellipsis 省略号


### 重置样式
重置a的下划线，body行高，html的text-size-adjust
```css
html {
    -ms-text-size-adjust: 100%;
    -webkit-text-size-adjust: 100%;
}

body {
    line-height: 1.6;
    font-family: @weuiFontDefault;
}

* {
    margin: 0;
    padding: 0;
}

a img {
    border: 0;
}

a {
    text-decoration: none;
    .setTapColor();
}
```


### 奇淫巧技
- 使用border + 45度旋转 生成 > 箭头
- :active 点击效果
- button&：less语法,虽然&和button连在一起但表示的仍然是嵌套的元素
- &.classSel加重权值
- \e+字体16进制码 用于表示对应的字体图标
- i斜体字标签，常用于字体图标
- ::before ::after实现居中+标识

