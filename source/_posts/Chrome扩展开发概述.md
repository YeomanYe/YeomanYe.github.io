title: Chrome扩展开发概述
tags:
    - Chrome
    - 浏览器
    - 软件
comments: true
date: 2017-08-06
brief: Chrome扩展开发
categories:
    - 软件
---
# Chrome扩展开发概述
chrome扩展是指一种能够增强浏览器功能的小程序，它由html、css、js和一个描述文件manifest.json组成。浏览器的地址栏边上显示扩展图标。

<!-- more -->

![图标](resources/images/地址栏图标.png)

chrome扩展结构是由内容脚本(content script)、弹出页(popup)、选项页(option)、后台脚本页(background)组成。除了内容脚本只是嵌入到网页中的脚本外，后台脚本页可以是含script标签的html也可以仅仅只是js脚本。弹出页、选项页与普通的网页几乎无二，只是可以使用chrome扩展特有的API罢了。了解一个扩展的结构，应该要先读manifest.json文件。

![结构](resources/images/arch.gif)

## manifest

典型的manifest文件如下:

```js
{
    //配置后台页
   "background": {
      "page": "JieCao.html"
   },
   //配置扩展图标、弹出页、扩展标题
   "browser_action": {
      "default_icon": "images/icon/icon19.png",
      "default_popup": "gateway.html?mod=popup",
      "default_title": "__MSG_ext_name__"
   },
   //配置内容脚本、匹配的域名（可以使用通配符）以及何时运行该脚本
   "content_scripts": [ {
      "js": [ "js/chrome.js", "js/loader.js" ],
      "matches": [ "http://*/*", "https://*/*" ],
      "run_at": "document_start"
   } ],
   //配置默认的国际化语言
   "default_locale": "zh_CN",
    //配置扩展的描述，在扩展管理中可以看到
   "description": "__MSG_ext_description__",
   //配置扩展主页：右击扩展图标，点击扩展名后跳转的页面
   "homepage_url": "http://www.nicaia.com/",
   //不同分辨率的图标
   "icons": {
      "128": "images/icon/icon128.png",
      "16": "images/icon/icon16.png",
      "19": "images/icon/icon19.png",
      "32": "images/icon/icon19.png",
      "48": "images/icon/icon48.png"
   },
   //版本
   "manifest_version": 2,
   //最低支持的chrome版本
   "minimum_chrome_version": "21",
   //扩展名
   "name": "__MSG_ext_name__",
   //选项页，右击图标和选项
   "options_page": "gateway.html?mod=options",
    //需要权限的地址以及权限
   "permissions": [ "http://*/*", "https://*/*", "notifications", "tabs", "activeTab", "storage", "webRequest", "webRequestBlocking", "webNavigation", "unlimitedStorage", "cookies", "downloads" ],
   //简短名
   "short_name": "__MSG_ext_short_name__",
   //版本号
   "version": "3.4",
   //扩展需要使用的资源相对地址
   "web_accessible_resources": [ "remote/*", "lib/jquery.js", "test/js/test.js", "manifest.json", "images/*", "_locales/*" ]
}
```

[chrome开发文档Manifest](https://developer.chrome.com/extensions/manifest/web_accessible_resources)

## 内容脚本(content scripts)
内容脚本是嵌入到匹配的网页中的脚本，但是又与页面中的脚本隔离开。虽然可以操纵页面上的DOM元素，但却不能够使用页面脚本的API。也就是运行环境与页面的脚本是隔离开的。

不能够使用除了以下的chrome扩展API：

```
extension ( getURL , inIncognitoContext , lastError , onRequest , sendRequest )
i18n
runtime ( connect , getManifest , getURL , id , onConnect , onMessage , sendMessage )
storage
```

除了可以在manifest中配置需要注入的页面以外，还可以动态的注入到页面中

```js
//直接注入代码
chrome.browserAction.onClicked.addListener(function(tab) {
  chrome.tabs.executeScript({
    code: 'document.body.style.backgroundColor="red"'
  });
});
//注入脚本文件
chrome.tabs.executeScript(null, {file: "content_script.js"});
```

需要的权限:

```
"permissions": [
  "activeTab"
],
```

[Content Script](https://developer.chrome.com/extensions/content_scripts)

## 事件页(Event Page)
事件页就是后台脚本页，相比于后台脚本页它并不常驻后台，在不需要的时候就会被卸载。开发文档中建议使用事件页来代替后台脚本页，以减少资源的开销。

### 配置

```js
  "background": {
    "scripts": ["eventPage.js"],
    "persistent": false
  },
```

### 加载与卸载
加载:
- app或扩展第一次安装或更新
- 事件页监听一个事件，这个事件被发送时
- 内容脚本或其他扩展发送一个消息时
- 其他视图（如：弹出页）调用`runtime.getBackgroundPage`时

直到所有的视图页和消息端口被关闭前，事件页不会被卸载。打开视图页不会使得事件页被加载，只能防止事件页被卸载。

原文:` the event page will not unload until all visible views (for example, popup windows) are closed and all message ports are closed. Note that opening a view does not cause the event page to load, but only prevents it from closing once loaded.`

因为监听器只存在与事件页的上下文中，所以每次加载事件页时都应该重新设置监听器`addListener`，仅仅在插件安装时`runtime.onInstalled`设置是不够的

原文:`Because the listeners themselves only exist in the context of the event page, you must use addListener each time the event page loads; only doing so at runtime.onInstalled by itself is insufficient`

## 调试
前提：调试扩展需要在扩展管理页(chrome://extensions)开启开发者模式

调试弹出页(popup),右击扩展图标->审查弹出内容即可弹出开发者面板，这个面板与网页调试面板一模一样，操作方式也是相同的。值得一提的是第一次弹出面板，会错过弹出页，初始化的脚本，可以通过在对应的面板上按F5然它重新加载进入断点

调试选项页(option),右击扩展图标->选项,在选项页按F12打开调试面板

调试后台页(background),点击检查视图后的超链接，就会弹出后台页相关的调试面板。

调试内容脚本(content script)，在内容脚本注入的网页打开开发者面板->source->Content scripts(左侧面板)

![内容脚本页调试面板](resources/images/content_scripts调试.png)

值得一提的是，在格式化的代码上添加断点，按F5重新加载后能保留格式化并且能够进入断点。

如果加载了没有经过打包的扩展程序，每一次打开chrome浏览器chrome都会提示停用扩展，按照官方的说法是设置注册表后可以解决这个问题，但是我在注册表中没有找到对应的项。如果是windows用户的话可以下载这个批处理脚本运行后也能解决问题:[解决扩展警告批处理脚本](http://pan.baidu.com/s/1c13JBDu)

[扩展警告官方处理方法](http://dev.chromium.org/administrators/policy-list-3#ExtensionInstallForcelist)

## 常用的JS API
所有的Chrome API都是以chrome对象开头，如：chrome.alarms
- bookmarks 操纵书签的API
- browserAction 获取扩展图标、标题、文字、弹出页等
- browsingData 控制浏览器的浏览数据，从本地文件
- commands 给扩展添加快捷键
- contextMenus 添加选项到右键弹出菜单
- cookies 控制cookies
- desktopCapture 捕获屏幕、个人窗口或标签内容
- downloads 下载控制
- events 事件相关API
- extension 获取扩展的各部分，也能与各部分交换信息
- extensionTypes 扩展的类型声明
- gcm 启用google云消息服务，收发消息
- history 历史记录控制
- i18n 多语言国际化支持
- idle 取得机器闲置状态
- management 管理扩展与应用
- notifications 通知控制
- pageAction 具体的页面下控制扩展图标、标题、文字、弹出页等相关内容
- permissions 获取拥有的权限
- power 请求系统常亮
- runtime 获取运行时相关信息，包括后台页、manifest等等
- sessions 查询或恢复浏览会话
- storage 存储相关
- tabs 与标签页交互
- vpnProvider 实现vpn客户端需要使用的东西
- webRequest 拦截、修改、阻塞请求
- windows 创建、修改、重排窗口


最后附上扩展的API地址：
[JavaScript APIs](https://developer.chrome.com/extensions/api_index)