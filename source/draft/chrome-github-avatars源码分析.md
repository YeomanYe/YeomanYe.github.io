title: chrome-github-avatars源码分析
tags:
    - chrome-extension
    - 源码分析
comments: true
date: 2017-07-22
brief: chrome-github-avatars源码分析
categories:
    - 源码分析
---
# chrome-github-avatars源码分析

chrome-github-avatars是一款chrome的插件，用途是显示github用户的头像。分析的版本号是`43a54cb00a77bec8adac10ab0896f9587e197e0e`

[Chrome JS API](https://developer.chrome.com/extensions/api_index)
[chrome-github-avatars项目地址](https://github.com/anasnakawa/chrome-github-avatars)
[chrome插件编写](https://developer.chrome.com/extensions/overview)

<!-- more -->

## 功能
插件的图标为：

![图标](resources/images/icon.png)

使用前效果图：

![使用前](resources/images/github-noavaters.png)

使用后效果图：

![使用后](resources/images/github-avaters.png)

## 实现方案
这个插件的效果很简单，只是给每一项加上图标而已。实现方式也比较简单首先获取每一项中，这一项用户的ID然后使用github提供的API获取用户的头像，再创建img节点将图片url添加进去即可。

## 程序结构
流程图：

![流程图](resources/images/流程图.png)

程序首先将获取用户信息的与加载图片的函数进行了分离，当用户信息加载完成后执行插入头像的方法。

```js
getAvatarsForUsers( function( data ) { 
    printImages( data.items ); 
});
```

然后将获取用户信息的方法又分成了，得到用户名，生成获取头像对应的url

```js
getAvatarsForUsers = function( callback ) {
    $.get( generateUrl( prepareNewUsersOnPage(), 31 ), callback );
}
```

值得一提的是这里的获取用户名`prepareNewUsersOnPage`函数，使用数组值转化为对象属性，再将对象属性转化为数组值。因为对象的键值是唯一的，所以能够达到去重的效果。

```js
unique = function( array ) {
    var temp = {};
    for( var i in array ) {
        temp[ array[i] ] = null;
    }
    return Object.keys( temp );
}
```

## 评价
这个插件功能简单、结构清晰易懂，作为初学者作为学习资料来阅读源码是个不错的选择。但是却不是个具有代表性的chrome扩展，因为chrome插件的页面结构、交互、API都没有体现出来（使用了一个在页面更新时控制图标亮暗的方法chrome.pageAction.show(tabId)），这样的扩展其实可以用脚本来代替。

对于我个人而言，在这个插件中我学到了使用bower进行包管理。数组去重的方式。以及控制亮灭的API。

不明白的地方是，不知道为什么该插件在头部插入了一个隐藏的元素（难道是为了解决兼容性？）

```js
var $first = $('.news .alert').eq(0)
    , $clone;
$first.clone().insertBefore($first);
$clone = $first.prev();
$first.css('border', 'none');
$clone.css({
      height: 0
    , padding: 0
});
```