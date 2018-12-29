title: SVG入门
tags:
    - 前端
comments: true
brief: SVG入门
date: 2018-12-28
categories:
    - 前端
---
# SVG入门
svg是一种用于描述二维矢量图形的一种图形格式。它由xml声明头，文档类型定义头，svg根标签组成。加上svg下的绘制内容组成，其中svg标签可以认为是绘制的画布，基本代码如下：

```svg
<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg width="100%" height="100%" version="1.1" xmlns="http://www.w3.org/2000/svg">
    <circle cx="100" cy="50" r="40" stroke="black"stroke-width="2" fill="red"/>
</svg>
```

<!-- more -->

## 形状

### circle
circle标签代表圆形。

```svg
<svg width="300" height="180">
  <circle cx="30"  cy="50" r="25" />
  <circle cx="90"  cy="50" r="25" class="red" />
  <circle cx="150" cy="50" r="25" class="fancy" />
</svg>
```

通用的绘制属性：

```css
.red {
  fill: red;
}

.fancy {
  fill: none;
  stroke: black;
  stroke-width: 3pt;
}
```

### line
用来绘制直线

```svg
<svg width="300" height="180">
  <line x1="0" y1="0" x2="200" y2="0" style="stroke:rgb(0,0,0);stroke-width:5" />
</svg>
```

### polyline
用于绘制一根折线。

```svg
<polyline points="3,3 30,28 3,53" fill="none" stroke="black" />
```

points用于指定每个端点坐标

### rect
用于绘制矩形。

```svg
<rect x="0" y="0" height="100" width="200" style="stroke: #70d5dd; fill: #dd524b" />
```

### ellipse
用于绘制椭圆。

```svg
<ellipse cx="60" cy="60" ry="40" rx="20" stroke="black" stroke-width="5" fill="silver"/>
```

### polygon
用于绘制多边形。

```svg
<polygon fill="green" stroke="orange" stroke-width="1" points="0,0 100,0 100,100 0,100 0,0"/>
```

### path
用于制路径。

```svg
<path d="
  M 18,3
  L 46,3
  L 46,40
  L 61,40
  L 32,68
  L 3,40
  L 18,40
  Z
"></path>
```

path的d属性表示绘制顺序，它的值是一个长字符串，每个字母表示一个绘制动作，后面跟着坐标。

- M：移动到（moveto）
- L：画直线到（lineto）
- Z：闭合路径

## 文字和图片

### text
用于绘制文本。

```svg
<text  font-family="Microsoft Yahei" font-size="60" font-weight="900" x="50" y="25">Hello World</text>
```

x属性和y属性，表示文本区块基线（baseline）起点的横坐标和纵坐标。文字的样式可以用class或style属性指定。

### image
用于插入图片文件。

```svg
<image xlink:href="path/to/image.jpg"
    width="50%" height="50%"/>
```

xlink:href属性表示图像的来源。

## 渐变
渐变只可用于填充，包括文字填充、图形的填充。不可用于描边。

### linearGradient
linearGradient用于定义线性渐变

- stop-color/stop-opacity：该位置表现的颜色和透明度
- offset：偏移量，位置
- stop标签，表示结束点

```svg
<svg height="150" width="400">
  <defs>
    <linearGradient id="grad3" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" style="stop-color:rgb(255,255,0);stop-opacity:1" />
      <stop offset="100%" style="stop-color:rgb(255,0,0);stop-opacity:1" />
    </linearGradient>
  </defs>
  <ellipse cx="200" cy="70" rx="85" ry="55" fill="url(#grad3)" />
  <text fill="#ffffff" font-size="45" font-family="Verdana" x="150" y="86">
  SVG</text>
</svg>
```

### radialGradient
radialGradient用于定义径向渐变

属性值基本与linearGradient相同，没什么好说的

```svg
<svg height="150" width="500">
  <defs>
    <radialGradient id="grad1" cx="50%" cy="50%" r="50%" fx="50%" fy="50%">
      <stop offset="0%" style="stop-color:rgb(255,255,255);
      stop-opacity:0" />
      <stop offset="100%" style="stop-color:rgb(0,0,255);stop-opacity:1" />
    </radialGradient>
  </defs>
  <ellipse cx="200" cy="70" rx="85" ry="55" fill="url(#grad1)" />
</svg>
```

## 滤镜

- filter定义滤镜名
- 具体滤镜效果，使用具体滤镜标签。
- stdDeviation 定义模糊的具体数值
- in用于定义滤镜作用的范围，属于具体滤镜公有属性(SourceGraphic | SourceAlpha | BackgroundImage | BackgroundAlpha | FillPaint | StrokePaint）
- 在具体图形中使用filter属性进行连接

失焦效果

```svg
<svg height="110" width="110">
  <defs>
    <filter id="f1" x="0" y="0">
      <feGaussianBlur in="SourceGraphic" stdDeviation="15" />
    </filter>
  </defs>
  <rect width="90" height="90" stroke="green" stroke-width="3"
  fill="yellow" filter="url(#f1)" />
</svg>
```

### 滤镜大全

- feBlend 混合模式。可以混合图片实现[纹理效果](https://www.zhangxinxu.com/wordpress/2018/02/css-svg-canvas-text-pattern-overlay/)
- feColorMatrix  [将图像颜色进行矩阵变换](https://developer.mozilla.org/en-US/docs/Web/SVG/Element/feColorMatrix)
- feComponentTransfer 用于对某个区间段的颜色，alpha值进行过滤，[具体可看](https://www.oxxostudio.tw/articles/201407/svg-15-filter-feComponentTransfer.html)
- feComposite 混合两张图像，常用于遮蔽或者剪裁。
- feConvolveMatrix 定义一个会根据其相邻像素的值变化的像素栅格，从而实现自己的滤镜效果
- feDisplacementMap 位置替换滤镜，就是改变元素和图形的像素位置的。[具体参考](https://www.zhangxinxu.com/study/201712/feDisplacementMap.html)
- feFlood 创建一个着色区
- feGaussianBlur  高斯模糊。模糊滤镜
- feImage 做滤镜图片素材之用
- feMerge 将两种滤镜的输出混合在一起
- feMorphology 将输入加厚后者变薄
- feOffset 将输入进行偏移
- feTile 输入图像是平铺的，结果用来填充目标
- feTurbulence 使用Perlin turbulence function的滤镜，常用于实现水流、大理石文理、云朵等效果。[水流1](http://wow.techbrood.com/fiddle/30865)、[水流2](http://wow.techbrood.com/fiddle/31650)
- feDiffuseLight 漫反射光照滤镜，使用光源类型和光源颜色来生成的滤镜。
    - feDistantLight 平行光
    - fePointLight 点光源
    - feSpotLight 聚光灯
- feSpecularLighting 镜面反射关照滤镜，与漫反射关照滤镜类似


## 动画

### animate
用于产生动画效果。

```svg
<svg width="500px" height="500px">
  <rect x="0" y="0" width="100" height="100" fill="#feac5e">
    <animate attributeName="x" from="0" to="500" dur="2s" repeatCount="indefinite" />
    <animate attributeName="width" to="500" dur="2s" repeatCount="indefinite" />
  </rect>
</svg>
```

- attributeName：发生动画效果的属性名。
- from：单次动画的初始值。
- to：单次动画的结束值。
- dur：单次动画的持续时间。
- repeatCount：动画的循环模式。

### animateTransform
animate标签对 CSS 的transform属性不起作用，如果需要变形，就要使用animateTransform标签。

```svg
<svg width="500px" height="500px">
  <rect x="250" y="250" width="50" height="50" fill="#4bc0c8">
    <animateTransform attributeName="transform" type="rotate" begin="0s" dur="10s" from="0 200 200" to="360 400 400" repeatCount="indefinite" />
  </rect>
</svg>
```

效果为旋转（rotate），这时from和to属性值有三个数字，第一个数字是角度值，第二个值和第三个值是旋转中心的坐标。from="0 200 200"表示开始时，角度为0，围绕(200, 200)开始旋转；to="360 400 400"表示结束时，角度为360，围绕(400, 400)旋转。

## 其他
### svg

svg的width属性和height属性，指定了 SVG 图像在 HTML 元素中所占据的宽度和高度。除了相对单位，也可以采用绝对单位（单位：像素）。如果不指定这两个属性，SVG 图像默认大小是300像素（宽） x 150像素（高）。viewport属性的值有四个数字，分别是左上角的横坐标和纵坐标、视口的宽度和高度。

```svg
<svg width="100" height="100" viewBox="50 50 50 50">
  <circle id="mycircle" cx="50" cy="50" r="50" />
</svg>
```

### use
用于复制一个形状

```svg
<svg viewBox="0 0 30 10" xmlns="http://www.w3.org/2000/svg">
  <circle id="myCircle" cx="5" cy="5" r="4"/>

  <use href="#myCircle" x="10" y="0" fill="blue" />
  <use href="#myCircle" x="20" y="0" fill="white" stroke="blue" />
</svg>
```

href属性指定所要复制的节点，x属性和y属性是use左上角的坐标。另外，还可以指定width和height坐标。

### g
用于将多个形状组成一个组（group），方便复用。

```svg
<svg width="300" height="100">
  <g id="myCircle">
    <text x="25" y="20">圆形</text>
    <circle cx="50" cy="50" r="20"/>
  </g>

  <use href="#myCircle" x="100" y="0" fill="blue" />
  <use href="#myCircle" x="200" y="0" fill="white" stroke="blue" />
</svg>
```

### defs
用于自定义形状，它内部的代码不会显示，仅供引用。

```svg
<svg width="300" height="100">
  <defs>
    <g id="myCircle">
      <text x="25" y="20">圆形</text>
      <circle cx="50" cy="50" r="20"/>
    </g>
  </defs>

  <use href="#myCircle" x="0" y="0" />
  <use href="#myCircle" x="100" y="0" fill="blue" />
  <use href="#myCircle" x="200" y="0" fill="white" stroke="blue" />
</svg>
```

### pattern
用于自定义一个形状，该形状可以被引用来平铺一个区域。

```svg
<svg width="500" height="500">
  <defs>
    <pattern id="dots" x="0" y="0" width="100" height="100" patternUnits="userSpaceOnUse">
      <circle fill="#bee9e8" cx="50" cy="50" r="35" />
    </pattern>
  </defs>
  <rect x="0" y="0" width="100%" height="100%" fill="url(#dots)" />
</svg>
```

pattern标签将一个圆形定义为dots模式。patternUnits="userSpaceOnUse"表示pattern的宽度和长度是实际的像素值。然后，指定这个模式去填充下面的矩形。

## 参考

[svg图像入门](http://www.ruanyifeng.com/blog/2018/08/svg.html#h5o-4)

[feComponentTransfer](https://www.oxxostudio.tw/articles/201407/svg-15-filter-feComponentTransfer.html)

[SVG滤镜的艺术](https://www.w3cplus.com/svg/why-the-svg-filter-is-awesome.html)

[MDN文档](https://developer.mozilla.org/zh-CN/docs/Web/SVG)