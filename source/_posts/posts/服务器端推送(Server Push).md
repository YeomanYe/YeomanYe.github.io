title: 服务器端推送(Server Push)
tags:
    - 前端
comments: true
brief: 服务器端推送(Server Push)
date: 2018-10-20
categories:
    - 前端
---
# 服务器端推送(Server Push)
广义的服务器推送指的是浏览器不需要给服务器发送请求，服务器就能将数据推送给浏览器。从广义上讲能实现服务器推送的技术有：websocket、sse、server push。

狭义的服务器推送是指HTTP/2规定的一种服务器推送技术，该技术是在进行一次http请求时，服务器除了返回请求，还能顺便推送文件。

本文主要介绍的是狭义的服务器推送server push。

<!-- more -->

## 实现原理
HTTP2传输的格式并不像HTTP1使用文本来传输，而是启用了二进制帧(Frames)格式来传输，和server push相关的帧主要分成这几种类型：

- HEADERS frame(请求返回头帧):这种帧主要携带的http请求头信息，和HTTP1的header类似。
- DATA frames(数据帧) :这种帧存放真正的数据content，用来传输。
- PUSH_PROMISE frame(推送帧):这种帧是由server端发送给client的帧，用来表示server push的帧，这种帧是实现server push的主要帧类型。
- RST_STREAM(取消推送帧):这种帧表示请求关闭帧，简单讲就是当client不想接受某些资源或者接受timeout时会向发送方发送此帧，和PUSH_PROMISE frame一起使用时表示拒绝或者关闭server push。

server push的实现过程了：

1. HTTP2中对于同一个域名的请求会使用一条tcp链接而用不同的stream ID来区分各自的请求。
2. 当client使用stream 1请求index.html时，server正常处理index.html的请求，并可以得知index.html页面还将要会请求index.css和index.js。
3. server使用stream 1发送PUSH_PROMISE frame给client告诉client我这边可以使用stream 2来推送index.js和stream 3来推送index.css资源。
4. server使用stream 1正常的发送HEADERS frame和DATA frames将index.html的内容返回给client。
5. client接收到PUSH_PROMISE frame得知stream 2和stream 3来接收推送资源。
6. server拿到index.css和index.js便会发送HEADERS frame和DATA frames将资源发送给client。
7. client拿到push的资源后会缓存起来当请求这个资源时会从直接从从缓存中读取。

## 实现方式

### nginx实现
nginx的配置只要在nginx的配置文件的server中的匹配规则上使用http2_push关键字就能实现推送。

```txt
server {
    listen 443 ssl http2;
    server_name  localhost;

    ssl                      on;
    ssl_certificate          /etc/nginx/certs/example.crt;
    ssl_certificate_key      /etc/nginx/certs/example.key;

    ssl_session_timeout  5m;

    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_protocols SSLv3 TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers   on;

    location / {
      root   /usr/share/nginx/html;
      index  index.html index.htm;
      http2_push /style.css;
      http2_push /example.png;
    }
}
```

注意Nginx 从 1.13.9 版开始支持。

### Apache
在配置文件httpd.conf或者.htaccess里面打开服务器推送
```xml
<FilesMatch "\index.html$">
    Header add Link "</styles.css>; rel=preload; as=style"
    Header add Link "</example.png>; rel=preload; as=image"
</FilesMatch>
```

### 后端代码
使用后端代码实现，比起单纯的在服务器文件中配置要方便的多，以下是nodejs的[实现](https://github.com/RisingStack/http2-push-example/blob/master/src/server.js)

```js
const http2 = require('http2')
const server = http2.createSecureServer(
  { cert, key },
  onRequest
)
const { HTTP2_HEADER_PATH } = http2.constants

function push (stream, filePath) {
  const { file, headers } = getFile(filePath)
  const pushHeaders = { [HTTP2_HEADER_PATH]: filePath }

  stream.pushStream(pushHeaders, (pushStream) => {
    pushStream.respondWithFD(file, headers)
  })
}

function onRequest (req, res) {
  // Push files with index.html
  if (reqPath === '/index.html') {
    push(res.stream, 'bundle1.js')
    push(res.stream, 'bundle2.js')
  }

  // Serve file
  res.stream.respondWithFD(file.fileDescriptor, file.headers)
}
```

如果使用了nginx作代理，那么nginx中匹配规则的设置要改为如下形式

```txt
server {
    listen 443 ssl http2;

    # ...

    root /var/www/html;

    location = / {
        proxy_pass http://upstream;
        http2_push_preload on;
    }
}
```

## 其他
服务器推送的文件的报文头与一般的并无区别，但是能够从Dev Tool的Initiator(发起者)中看出是否是服务器推送的文件。

![devTool](devTool.png)

### 兼容情况
如果服务器或者浏览器不支持 HTTP/2，那么浏览器就会按照 preload 来处理这个头信息，预加载指定的资源文件。在浏览器不支持的情况下，服务器推送与下面的标签是等价的。

```html
<link rel="preload" href="/styles.css" as="style">
<link rel="preload" href="/example.png" as="image">
```

### 缓存推送
要使推送缓存起来，可以根据cookie判断，只在进行第一次访问时进行推送，以下是nginx实现方案。

```txt
server {
    listen 443 ssl http2 default_server;

    ssl_certificate ssl/certificate.pem;
    ssl_certificate_key ssl/key.pem;

    root /var/www/html;
    http2_push_preload on;

    location = /demo.html {
        add_header Set-Cookie "session=1";
        add_header Link $resources;
    }
}


map $http_cookie $resources {
    "~*session=1" "";
    default "</style.css>; as=style; rel=preload";
}
```

## 参考文献

[阮一峰网络日志](http://www.ruanyifeng.com/blog/2018/03/http2_server_push.html)

[node-js-http2-push](https://blog.risingstack.com/node-js-http-2-push/)

[http2-server-push](http://www.alloyteam.com/2017/01/http2-server-push-research/)