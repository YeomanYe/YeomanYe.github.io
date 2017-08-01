title: 响应式Web设计
tags:
    - 书评
    - HTML
    - 前端
    - CSS
comments: true
date: 2017-08-01
brief: 响应式Web设计
categories:
    - 前端
---
《响应式Web设计:HTML5和CSS3实战》讲述了大部分HTML5和CSS3的特性，并且代领读者使用HTML5和CSS3等现代技术实现一个响应式的网站。

这本书不仅适合想要学习响应式设计和移动端网站建设的人员，也适合想要学习HTML5和CSS3特性的人员与想解决浏览器兼容问题的人员。

<!-- more -->

![响应式Web设计](resources/images/响应式Web设计.jpg)

《响应式Web设计:HTML5和CSS3实战》这本书首先介绍了响应式的重要性，然后开始一步一步搭建影评网站，并逐步的将响应式设计的技巧用在这个网站中。并且还兼顾了WAI-ARIA实现无障碍的设计以及浏览器的兼容性。该书还将CSS3的令人惊叹的特性，动画、形变、表单等等用在了网站设计中，实现了令人惊叹的效果，对于老版本的浏览器则实现了优雅降级。

该书语言诙谐幽默，例子实用并且简练，还给读者推荐了许多好用的开发工具。是难得一见的好书。

以下是自己根据书做的练习，每一章都有对应的标签
[响应式Web设计练习](https://github.com/YeomanYe/responsive-web-demo)

## 精彩部分
将三种已有的开发技巧（弹性网格布局、弹性图片、媒体和媒体查询）整合起来，并命名为响应式网页设计。

我们应该首先针对小屏幕进行设计，然后逐步增强针对大屏幕的设计和内容。但是实际开发中往往无法达到这个要求。

现代浏览器虽然可以智能地忽略与自身不匹配的样式文件，但它却不一定不下载这些文件。

使用 CSS 的 @import 指令在当前样式表中按条件引入其他样式表，但是使用css的@import方式会增加HTTP请求

```css
@import url("phone.css") screen and (max-width:360px);
```

user-scalable ＝ no 即是禁止缩放
```html
<!-- device-width设置宽度为设备的实际宽度 -->
<meta name="viewport" content="device-width, user-scalable=no">
```

目标元素宽度 ÷ 上下文元素宽度＝百分比宽度

em 作为一个测量单位，指的是特定字母的宽度和高度相对于特定字体磅值的比例。
```html
<style>
    #content h1{
        text-transform: uppercase;
        font-size: 4.312em;  /*69 / 16 默认文字大小为16px*/
    }
    #content h1 span {
        display: block;
        line-height: 1.0526em; /*40 / 38 高度相对于本身文字大小*/
        font-size: .5507em; /* 38 / 69 文字大小相对于父类*/ 
    }
</style>
<div id="content"><h1><span>This is a test</span></h1></div>
```

媒体查询约束流动布局(float)的变动范围，而流动布局则简化了从一组媒体查询样式过渡到另一组的改变过程。

遵循WAI-ARIA实现无障碍站点，追加一个地标角色属性 role 即可
```html
<div role="navigation">
    <ul>
        <li>Why?</li>
        <li>What?</li>
        <li>Where?</li>
    </ul>
</div>
```

高兼容性的视频媒体设置
```html
<video src="controls autoplay preload=auto loop poster=VideoPoster.jpg">
    <source src="video/Video.mp4" type="video/mp4"></source>
    <source src="video/Video.ogv" type="video/ogg"></source>
    <object data="FlashVideo.swf" type="application/x-shockwave-flash" width="640" height="480"><param name="movie" value="FlashVideo.swf"><param name="flashvars" value="controlbar=over&amp;image=VideoPoster.jpg&amp;file=video/Video.mp4"><img src="VideoPoster.jpg" alt="_TITLE_" width="640" height="480" title=""></object>
    <p>
        <b>Download Video:</b>
        MP4 Format:
        <a href="Video.mp4">MP4</a>
        Ogg Format:
        <a href="Video.ogv">Ogg</a>
    </p>
</video>
```

对于iframe嵌入的视频的响应问题，可以使用一个插件fitvids来解决
```html
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js">
</script>
<script src="js/fitvids.js"></script>
<script>
    $(document).ready(function(){
        $("#content").fitVids();
    })
</script>
```

离线 Web 应用的运行机制是每个需要离线使用的网页都指定一个后缀名为 .manifest 的文本文件。这个文本文件罗列了该网页离线使用时所需的所有资源文件（ HTML 、图片 JavaScript 等等）。
```html
<html manifest="/offline.manifest" >
```

在支持 HTML5 的浏览器中，在 input 元素中追加布尔类型的属性 required,一个等价的 WAI-ARIA 属性： aria-required ＝ "true"

可以使用pattern属性通过正则表达式来定义表单域的数据格式
```html
<div>
    <label for="name"></label>
    <input type="text" id="name" pattern="([a-zA-Z]{3,30}s*)+[a-zA-Z]{3,30}">
</div>
```

优雅降级指的是为现代浏览器制作网站，然后保证为某些老版本浏览器提供基本可用的体验。新特性在老版本浏览器中会降级，且一般会有一个分界点，声明不支持那些老掉牙的浏览器。

渐进增强与优雅降级恰好相反。渐进增强以恪守 Web 标准的标签为基础，意味着它在所有浏览器中均可用。然后通过 CSS 样式和必要的 JavaScript 来为更先进的浏览器提供渐进式的增强体验。

## 实用工具

[响应式影评网站](http://www.andthewinnerisnt.com/redemption.html)

[浏览器响应式兼容性脚本modernizr](https://modernizr.com/)

[快速、健壮、适应性强的HTML5模板](https://html5boilerplate.com/)

[浏览器兼容性查看](http://caniuse.com/#)

[自动添加浏览器前缀的脚本-prefix-free](http://leaverou.github.io/prefixfree/)

[渐变可视化生成工具](http://www.colorzilla.com/gradient-editor/)

[渐变生成的纹理](http://lea.verou.me/css3patterns/)

[字体图标库](http://fico.lensco.be/)

[贝塞尔曲线查看](http://cubic-bezier.com/#.57,.22,.66,1.26)

[轻量级浏览器能力判断库yepnope](http://yepnopejs.com/)

[响应式兼容库Respond](https://github.com/scottjehl/Respond)

[响应式菜单Respondive-Menu](https://github.com/mattkersley/Responsive-Menu)



