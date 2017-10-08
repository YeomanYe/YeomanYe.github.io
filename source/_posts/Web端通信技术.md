title: Web端通信技术
tags:
    - JavaScript
comments: true
brief: Web端通信技术
date: 2017-3-4
categories:
    - 通信
---
# Web端通信技术
归纳到目前为止的Web端原生通信技术，包括：Ajax、Web Sockets、SSE(服务器发送事件)。

<!-- more -->

## Ajax
AJAX即“Asynchronous Javascript And XML”（异步JavaScript和XML），是指一种创建交互式网页应用的网页开发技术。Ajax能够向服务器请求额外的数据而无须卸载(刷新)页面

### XMLHttpRequest
XHR是Ajax技术的核心，不同的浏览器获得XHR对象的方法

```js
function createXHR(){
    if(typeof XMLHttpRequest != "undefined"){
        return new XMLHttpRequest();
    }else if(typeof ActiveXObject != "undefined"){
            //适用于IE7之前的版本
            if(typeof arguments.callee.activeXSring != "string"){
            var versions = ["MSXML2.XMLHttp.6.0","MSXML2.XMLHttp.3.0","MSXML2.XMLHttp"],i,len;
            for(i=0,len=versions.length;i<len;i++){
                try{
                    new ActiveXObject(versions[i]);
                    arguments.callee.activeXString = versions[i];
                    break;
                }catch(ex){
                    //跳过
                }
            }
        }
        return new ActiveXObject(arguments.callee.activeXString);
    }else{
        throw new Error("No XHR object available.");
    }
}
```

xhr使用示例
```js
var xhr = createXHR();
xhr.onreadystatechange = function(){
    if(xhr.readyState == 4){
        if((xhr.status >= 200 && xhr.status > 300) || xhr.status == 304){
            console.log(xhr.responseText);
        }else{
            console.log("Request was unsuccessful: " + xhr.status);
        }
    }
}
xhr.open("get","example.txt",true);
xhr.send(null);
```

常见属性和事件
- responseText 作为响应主体被返回的文本
- responseXML 如果响应式的内容类型是"text/xml"或"application/xml"，这个属性包含响应数据的XML DOM文档
- status 响应的HTTP状态
- statusText HTTP状态说明
- onreadystatechange 每当readyState变化，即触发该事件
- readyState 表示请求/响应过程的当前活动阶段
    + 0:未初始化，尚未调用open方法
    + 1:启动，调用了open但是，未调用send方法
    + 2:发送，已调用send,但未收到响应
    + 3:接收，已经接收到部分响应数据
    + 4:完成。已经接收到全部响应数据

常见方法
- open(method,url,async) 打开链接，设置为post方法时需要设置请求头`Content-Type`为`application/x-www-form-urlencoded`
- setRequestHeader() 用于设置请求头信息
- abort() 取消异步请求。调用后XHR对象会停止触发事件,而且也不会再允许访问任何与响应有关的对象属性。
- send(data) 发送请求，数据的格式为格式化后的字符串形式

### XMLHttpRequest 2级
xhr 2级比起1级新增了如下功能
- 可以设置HTTP请求的时限。
- 可以使用FormData对象管理表单数据。
- 可以上传文件。
- 可以请求不同域名下的数据（跨域请求）。
- 可以获取服务器端的二进制数据。
- 可以获得数据传输的进度信息。

#### FormData
FormData对象可以添加表单数据，也可以格式化表单数据，并作为send的参数

```js
var form = document.getElementById("user-form"),
    data = new FormData(form);
data.append("extra","data-extra");
xhr.send(data);
```

#### 超时处理
使用timeout属性设置请求超时的时间间隔，并且超时后会调用ontimeout
```js
xhr.timeout = 1000;
xhr.ontimeout = function(){
    alert("Request did not return in a second.");
}
```

#### 指定响应类型
overrideMimeType()重写服务器端返回的MIME类型，必须使用在send()方法调用前

#### 上传文件
```js
var formData = new FormData();
for (var i = 0; i < files.length;i++) {
　　formData.append('files[]', files[i]);
}
xhr.send(formData);
```

#### 跨域资源共享
新版本的XMLHttpRequest对象，可以向不同域名的服务器发出HTTP请求。使用"跨域资源共享"的前提，是浏览器必须支持这个功能，而且服务器端必须同意这种"跨域"。

#### 接收二进制数据
通过改写MIME类型，将二进制数据作为文本数据接收，最后再还原为二进制数据。
```js
// 设置为用户自定义字符集
xhr.overrideMimeType("text/plain; charset=x-user-defined");
// 接收数据
var binStr = xhr.responseText;
// 还原为二进制数据
for (var i = 0, len = binStr.length; i < len; ++i) {
　　var c = binStr.charCodeAt(i);
　　var byte = c & 0xff;
}
```

使用responseType,设置为blob
```js
var xhr = new XMLHttpRequest();
xhr.open('GET', '/path/to/image.png');
// 设置为blob类型，默认为TEXT
xhr.responseType = 'blob';
// 使用的是response而不是responseText
var blob = new Blob([xhr.response], {type: 'image/png'});
```

使用responseType,设置为arraybuffer
```js
// 将二进制数据放入一个数组中，然后接收数据遍历数组
var xhr = new XMLHttpRequest();
xhr.open('GET', '/path/to/image.png');
xhr.responseType = "arraybuffer";

var arrayBuffer = xhr.response;
if (arrayBuffer) {
　　var byteArray = new Uint8Array(arrayBuffer);
　　for (var i = 0; i < byteArray.byteLength; i++) {
　　　　// do something
　　}
}
```

#### 进度信息
新版本的XMLHttpRequest对象，传送数据的时候，有一个progress事件，用来返回进度信息。

它分成上传和下载两种情况。下载的progress事件属于XMLHttpRequest对象，上传的progress事件属于XMLHttpRequest.upload对象。

```js
xhr.onprogress = updateProgress;
xhr.upload.onprogress = updateProgress;

function updateProgress(event) {
　　if (event.lengthComputable) {
　　　　var percentComplete = event.loaded / event.total;
　　}
}
```

其他生命周期相关事件：
- load事件：传输成功完成。
- abort事件：传输被用户取消。
- error事件：传输中出现错误。
- loadstart事件：传输开始。
- loadEnd事件：传输结束，但是不知道成功还是失败。

## Web Sockets
Web Sockets的目标是在一个单独的持久连接上提供全双工、双向通信。在JavaScript中创建了Web Socket之后。会有一个HTTP请求发送到浏览器以发起连接。在取得服务器响应后，建立的连接会从HTTP升级为Web Socket协议(ws、wss)。

Web Sockets API
- send(data) 发送数据
- close() 关闭连接
- onopen 事件，成功建立连接时触发
- onerror 事件，发生错误时触发，连接不能持续
- onclose 事件，关闭连接时触发
- onmessage 事件，接收到远程服务器的数据时触发
- readyState表示当前的状态
    + WebSocket.OPENING(0) 正在建立连接
    + WebSocket.OPEN(1) 已经建立连接
    + WebSocket.CLOSING(2) 正在关闭连接
    + WebSocket.CLOSE(3) 以及关闭连接

示例
```js
// 不需要同源
var webSocket = new WebSocket("ws://localhost:3000");
webSocket.onopen = function(){
    webSocket.send("WebSocket发送的消息")
}
webSocket.onmessage = function(event){
    // 接收消息
    console.log(event.data);
}
```

## SSE
SSE(Server-Sent-Events,服务器发送事件) API 用于创建到服务器的单向连接，服务器通过这个连接可以发送任意数量的数据。服务器响应的MIME类型必须是text/event-stream，而且是浏览器中的JavaScript API能解析格式输出。SSE支持短轮询、长轮询和HTTP流，而且能断开连接时自动确定何时重新连接。

```js
var source = new EventSource("myevents.action")
```

EventSource API
- onmessage 事件，接收到新消息时
- onopen 事件，建立连接时
- onerror 事件，无法建立连接时
- close() 关闭连接
- url 代表源头的URL,只读
- readyState 代表连接状态
    + CONNECTING(0) 正在建立连接
    + OPEN(1) 连接已打开
    + CLOSED(2) 连接已关闭

```txt
:this is a comment
event:foo
data:foo

data:bar
id:1
retry:1000

data:foo
data:bar
```

- 类型为空白，表示该行是注释，会在处理时被忽略。
- 类型为 data，表示该行包含的是数据。以 data 开头的行可以出现多次。所有这些行都是该事件的数据。
- 类型为 event，表示该行用来声明事件的类型。浏览器在收到数据时，会产生对应类型的事件。
- 类型为 id，表示该行用来声明事件的标识符。
- 类型为 retry，表示该行用来声明浏览器在连接断开之后进行再次连接之前的等待时间。

通过给data设置id，EventSource会跟踪上一次触发的事件。如果连接断开，会向服务器发送一个包含名为Last-Event-ID的特殊HTTP头部请求，以便知道下一次触发哪个事件。

## 参考文献
JS高程(第三版)
疯狂 HTML5/CSS3/JavaScript 讲义
[XMLHttpRequest Level 2 使用指南](http://www.ruanyifeng.com/blog/2012/09/xmlhttprequest_level_2.html)
[SSE：服务器发送事件,使用长链接进行通讯](http://www.cnblogs.com/goody9807/p/4257192.html)