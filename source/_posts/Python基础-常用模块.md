title: Python基础-常用模块
tags:
    - 语言
    - Python
comments: true
brief: Python基础-常用模块
date: 2017-09-06
categories:
    - Python
---
# Python基础-常用模块
这篇文章是对廖雪峰老师的python 3教程中python常用模块内容相关的笔记。廖雪峰老师的python基础教程不仅细致的讲解了python的语法、还点出了语法中的注意点、python常用的模块、python的面向对象和函数式编程以及一些周边。对廖雪峰老师的python基础教程分为四部分。一、语法；二、面向对象和函数式；三、语言机制关系密切的模块；四、常用模块。

[Python 3教程](https://www.liaoxuefeng.com/wiki/0014316089557264a6b348958f449949df42a6d3a2e542c000)

<!-- more -->

## 正则表达式
- 正则表达式,使用r前缀:r'ABC|-001'
- 使用re模块

```py
import re
#match()方法判断是否匹配，如果匹配成功，返回一个Match对象，否则返回None。
print(re.match(r'^\d{3}\-\d{3,8}$', '010-12345'))
print(re.match(r'^\d{3}\-\d{3,8}$', '010 12345'))
```

- 切分字符串

```py
re.split(r'[\s\,\;]+', 'a,b;; c  d')
#['a','b','c','d']
```

- 分组

```py
m =  re.match(r'^(\d{3})-(\d{3,8})$', '010-12345')
m.group(0)
#'010-12345'
m.group(1)
#'010'
m.groups()
#('010','12345')

#说明默认采用贪婪匹配
re.match(r'^(\d+)(0*)$', '102300').groups()
#('102300', '')

#转换为非贪婪模式匹配
re.match(r'^(\d+?)(0*)$', '102300').groups()
#('1023', '00')
```

- 预编译

```py
#预编译的正则表达式在使用时就不需要再行编译
re_telephone = re.compile(r'^(\d{3})-(\d{3,8})$')
```

## 常用模块
### datetime
- 使用示例:

```py
#获取当前时间
#第一个datetime是模块,第二个是类
from datetime import datetime
now = datetime.now()
print(now)

#指定时间和日期
dt = datetime(2014,9,12,12,12)

#转换为timestamp
dt.timestamp)()

#timestamp转换为datetime
#默认和本地时区转换
t = 1429417200.0
datetime.fromtimestamp(t)

#timestamp直接转换到UTC标准时间
datetime.utcfromtimestamp(t)

#字符串转换为datetime
datetime.strptime('2015-6-1 18:19:59', '%Y-%m-%d %H:%M:%S')

#datetime转换为字符串
now.strftime('%a, %b %d %H:%M')

#时间加减
from datetime import datetime, timedelta
now = datetime.now()
now + timedelta(hours=10)

#本地时间转换为UTC时间
from datetime import datetime, timedelta, timezone
tz_utc_8 = timezone(timedelta(hours=8)) # 创建时区UTC+8:00
now = datetime.now()
#除非时区恰好是UTC+8:00否则不能强制设置为UTC+8:00
dt = now.replace(tzinfo=tz_utc_8) # 强制设置为UTC+8:00

#时区转换,只能使用带时区的datetime进行转换
# 拿到UTC时间，并强制设置时区为UTC+0:00:
utc_dt = datetime.utcnow().replace(tzinfo=timezone.utc)
# astimezone()将转换时区为北京时间:
bj_dt = utc_dt.astimezone(timezone(timedelta(hours=8)))
```

- timestamp的值与时区毫无关系，因为timestamp一旦确定，其UTC时间就确定了，转换到任意时区的时间也是完全确定的

### collections
- namedtuple是一个函数，它用来创建一个自定义的tuple对象，并且规定了tuple元素的个数，并可以用属性而不是索引来引用tuple的某个元素。

```py
from collections import namedtuple
#Point对象是tuple的一种子类
Point = namedtuple('Point', ['x', 'y'])
p = Point(1, 2)
print(p.x)
```

- deque高效实现插入和删除的双向列表

```py
from collections import deque
q = deque(['a', 'b', 'c'])
q.append('x')
q.pop()
q.appendleft('y')
q.popleft()
print(q)
```

- defaultdict对于不存在的key返回一个默认值

```py
from collections import defaultdict
dd = defaultdict(lambda: 'N/A')
dd['key1'] = 'abc'
dd['key1'] # key1存在
#'abc'
dd['key2'] # key2不存在，返回默认值
#'N/A'
```

- OrderedDict保持Key的顺序

```py
from collections import OrderedDict
d = dict([('a', 1), ('b', 2), ('c', 3)])
d # dict的Key是无序的
#{'a': 1, 'c': 3, 'b': 2}
od = OrderedDict([('a', 1), ('b', 2), ('c', 3)])
od # OrderedDict的Key是有序的
#OrderedDict([('a', 1), ('b', 2), ('c', 3)])
od = OrderedDict()
od['z'] = 1
od['y'] = 2
od['x'] = 3
list(od.keys()) # 按照插入的Key的顺序返回
#['z', 'y', 'x']
```

- Counter是一个简单的计数器也是dict的一个子类，例如，统计字符出现的个数：

```py
from collections import Counter
c = Counter()
for ch in 'programming':
     c[ch] = c[ch] + 1
c
#Counter({'g': 2, 'm': 2, 'r': 2, 'a': 1, 'i': 1, 'o': 1, 'n': 1, 'p': 1})
```

### base64
- 将3个8bit的字节，变换为4个6bit的数,好处是将二进制中一些无法显示的字符变的能够显示
- 最后剩下一个或两个字节,Base64用\x00字节在末尾补足,再在编码的末尾加上1个或2个=号,表示补了多少个字节
- Base64字符集:['A', 'B', 'C', ... 'a', 'b', 'c', ... '0', '1', ... '+', '/']

```py
import base64
base64.b64encode(b'binary\x00string')
#b'YmluYXJ5AHN0cmluZw=='
base64.b64decode(b'YmluYXJ5AHN0cmluZw==')
#b'binary\x00string'

#将+/分别变为-_,这样就能够用于url参数传递
base64.urlsafe_b64encode(b'i\xb7\x1d\xfb\xef\xff')
#b'abcd--__'
```

### struct
- struct解决bytes和其他二进制数据类型的转换。

```py
import struct
#pack的第一个参数是处理指令，'>I'的意思是：
#>表示字节顺序是big-endian，也就是网络序，I表示4字节无符号整数。
struct.pack('>I',10240099)

#将bytes变成相应的数据类型
struct.unpack('>IH', b'\xf0\xf0\xf0\xf0\x80\x80')
#(4042322160, 32896)
```

### hashlib
- 名词解释:摘要算法又称哈希算法、散列算法。它通过一个函数，把任意长度的数据转换为一个长度固定的数据串（通常用16进制的字符串表示）。
- 常见的哈希算法有MD5,SHA1

```py
#MD5
import hashlib

md5 = hashlib.md5()
md5.update('how to use md5 in python hashlib?'.encode('utf-8'))
print(md5.hexdigest())
#d26a53750bc40b38b65a520292f69306

#SHA1
import hashlib

sha1 = hashlib.sha1()
sha1.update('how to use sha1 in '.encode('utf-8'))
sha1.update('python hashlib?'.encode('utf-8'))
print(sha1.hexdigest())
```

### itertools
- itertools提供了非常有用的用于操作迭代对象的函数
- itertools模块提供的全部是处理迭代功能的函数，它们的返回值不是list，而是Iterator，只有用for循环迭代的时候才真正计算。

```py
import itertools
#count()会创建一个无限的迭代器
natuals = itertools.count(1)
#会把传入的序列无限重复下去
cs = itertools.cycle('ABC') # 注意字符串也是序列的一种
#把一个元素重复一定的次数
ns = itertools.repeat('A', 3)
#使用takewhile()加lambda获取有限的序列
ns = itertools.takewhile(lambda x: x <= 10,natuals)
#把一组迭代对象串联起来，形成一个更大的迭代器
itertools.chain('ABC','XYZ')
#groupby()把迭代器中相邻的重复元素挑出来放在一起
for key, group in itertools.groupby('AaaBBbcCAAa', lambda c: c.upper()):
    print(key,list(group))
```

### contextlib
- 任何对象只要实现了上下文管理就能使用with语句

```py
with open('path/to/file','r') as f:
    f.read()

class Query(object):

    def __init__(self, name):
        self.name = name

    def __enter__(self):
        print('Begin')
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        if exc_type:
            print('Error')
        else:
            print('End')

    def query(self):
        print('Query info about %s...' % self.name)

with Query('Bob') as q:
    q.query()
```

- 使用@contextmanager
    1. with语句首先执行yield之前的语句
    2. yield调用会执行with语句内部的所有语句
    3. 最后执行yield之后的语句

```py
from contextlib import contextmanager

class Query(object):

    def __init__(self, name):
        self.name = name

    def query(self):
        print('Query info about %s...' % self.name)

@contextmanager
def create_query(name):
    print('Begin')
    q = Query(name)
    yield q
    print('End')

#@contextmanager这个decorator接受一个generator，用yield语句把with ... as var把变量输出出去，然后，with语句就可以正常地工作了
with create_query('Bob') as q:
    q.query()
```

- 使用closing()把一个对象变成为上下文对象

```py
from contextlib import closing
from urllib.request import urlopen

with closing(urlopen('https://www.python.org')) as page:
    for line in page:
        print(line)
```

- closing也是一个经过@contextmanager装饰的generator，这个generator编写起来其实非常简单

```py
@contextmanager
def closing(thing):
    try:
        yield thing
    finally:
        thing.close()
```

### XML
- SAX解析XML

```py
from xml.parsers.expat import ParserCreate

class DefaultSaxHandler(object):
    def start_element(self, name, attrs):
        print('sax:start_element: %s, attrs: %s' % (name, str(attrs)))

    def end_element(self, name):
        print('sax:end_element: %s' % name)

    def char_data(self, text):
        print('sax:char_data: %s' % text)

xml = r'''<?xml version="1.0"?>
<ol>
    <li><a href="/python">Python</a></li>
    <li><a href="/ruby">Ruby</a></li>
</ol>
'''

handler = DefaultSaxHandler()
parser = ParserCreate()
parser.StartElementHandler = handler.start_element
parser.EndElementHandler = handler.end_element
parser.CharacterDataHandler = handler.char_data
parser.Parse(xml)
```

- 生成XML(通过返回字符串)

```py
L = []
L.append(r'<?xml version="1.0"?>')
L.append(r'<root>')
L.append(encode('some & data'))
L.append(r'</root>')
return ''.join(L)
```

### HTMLParser
- 解析HTML

```py
from html.parser import HTMLParser
from html.entities import name2codepoint

class MyHTMLParser(HTMLParser):

    def handle_starttag(self, tag, attrs):
        print('<%s>' % tag)

    def handle_endtag(self, tag):
        print('</%s>' % tag)

    def handle_startendtag(self, tag, attrs):
        print('<%s/>' % tag)

    def handle_data(self, data):
        print(data)

    def handle_comment(self, data):
        print('<!--', data, '-->')

    def handle_entityref(self, name):
        print('&%s;' % name)

    def handle_charref(self, name):
        print('&#%s;' % name)

parser = MyHTMLParser()
#feed()方法可以多次调用，也就是不一定一次把整个HTML字符串都塞进去，可以一部分一部分塞进去
parser.feed('''<html>
<head></head>
<body>
<!-- test html parser -->
    <p>Some <a href=\"#\">html</a> HTML&nbsp;tutorial...<br>END</p>
</body></html>''')
```

### urllib
- GET

```py
from urllib import request

with request.urlopen('https://api.douban.com/v2/book/2129650') as f:
    data = f.read()
    print('Status',f.status,f.reason)
    for k,v in f.getheaders():
        print('%s: %s' % (k,v))
    print('Data:',data.decode('utf-8'))
#添加请求头
req = request.Request('http://www.douban.com/')
req.add_header('User-Agent', 'Mozilla/6.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/8.0 Mobile/10A5376e Safari/8536.25')
request.urlopen(req)
```

- POST

```py
login_data = parse.urlencode([
    ('username', email),
    ('password', passwd),
    ('entry', 'mweibo'),
    ('client_id', ''),
    ('savestate', '1'),
    ('ec', ''),
    ('pagerefer', 'https://passport.weibo.cn/signin/welcome?entry=mweibo&r=http%3A%2F%2Fm.weibo.cn%2F')
])
req = request.Request('https://passport.weibo.cn/sso/login')
#以POST方式请求url
with request.urlopen(req, data=login_data.encode('utf-8')) as f:
    print('Status:', f.status, f.reason)
    for k, v in f.getheaders():
        print('%s: %s' % (k, v))
    print('Data:', f.read().decode('utf-8'))
```

- Handler
- 通过一个Proxy访问网站，我们需要利用ProxyHandler来处理

```py
proxy_handler = urllib.request.ProxyHandler({'http': 'http://www.example.com:3128/'})
proxy_auth_handler = urllib.request.ProxyBasicAuthHandler()
proxy_auth_handler.add_password('realm', 'host', 'username', 'password')
opener = urllib.request.build_opener(proxy_handler, proxy_auth_handler)
with opener.open('http://www.example.com/login.html') as f:
    pass
```

## 常用第三方模块
### PIL
- pillow兼容PIL,且是最新版,PIL未更新好久
- 生成验证码

```py
from PIL import Image, ImageDraw, ImageFont, ImageFilter

import random

# 随机字母:
def rndChar():
    return chr(random.randint(65, 90))

# 随机颜色1:
def rndColor():
    return (random.randint(64, 255), random.randint(64, 255), random.randint(64, 255))

# 随机颜色2:
def rndColor2():
    return (random.randint(32, 127), random.randint(32, 127), random.randint(32, 127))

# 240 x 60:
width = 60 * 4
height = 60
image = Image.new('RGB', (width, height), (255, 255, 255))
# 创建Font对象:
font = ImageFont.truetype('Arial.ttf', 36)
# 创建Draw对象:
draw = ImageDraw.Draw(image)
# 填充每个像素:
for x in range(width):
    for y in range(height):
        draw.point((x, y), fill=rndColor())
# 输出文字:
for t in range(4):
    draw.text((60 * t + 10, 10), rndChar(), font=font, fill=rndColor2())
# 模糊:
image = image.filter(ImageFilter.BLUR)
image.save('code.jpg', 'jpeg')
```

- 模糊图片

```py
from PIL import Image, ImageFilter

# 打开一个jpg图像文件，注意是当前路径:
im = Image.open('Cover - 1.jpg')
# 应用模糊滤镜:
im2 = im.filter(ImageFilter.BLUR)
im2.save('Cover - 2.jpg', 'jpeg')
```

- 缩放图片

```py
from PIL import Image

# 打开一个jpg图像文件，注意是当前路径:
im = Image.open('test.jpg')
# 获得图像尺寸:
w, h = im.size
print('Original image size: %sx%s' % (w, h))
# 缩放到50%:
im.thumbnail((w//2, h//2))
print('Resize image to: %sx%s' % (w//2, h//2))
# 把缩放后的图像用jpeg格式保存:
im.save('thumbnail.jpg', 'jpeg')
```

## 图形界面
- Python支持多种图形界面的第三方库,包括:Tk、wxWidgets、Qt、GTK等
- Python自带的库是支持Tk的Tkinter,使用Tkinter,无需安装任何包，就可以直接使用。
- Tkinter分专管访问Tk的接口,Tk是一个图形库,支持多个操作系统。Tk会调用操作系统提供的本地GUI接口，完成最终的GUI。

```py
from tkinter import *
import tkinter.messagebox as messagebox

class Application(Frame):
    def __init__(self, master=None):
        Frame.__init__(self, master)
        #pack()方法把Widget加入到父容器中，并实现布局。pack()是最简单的布局，grid()可以实现更复杂的布局
        self.pack()
        self.createWidgets()

    def createWidgets(self):
        self.nameInput = Entry(self)
        self.nameInput.pack()
        #command设置事件
        self.alertButton = Button(self, text='Hello', command=self.hello)
        self.alertButton.pack()

    def hello(self):
        name = self.nameInput.get() or 'world'
        messagebox.showinfo('Message', 'Hello, %s' % name)

app = Application()
# 设置窗口标题:
app.master.title('Hello World')
# 主消息循环:
app.mainloop()
```

## 网络编程
### TCP编程
- 客户端

```py
# 导入socket库:
import socket

# 创建一个socket:
# AF_INET表示使用IPv4协议,SOCK_STREAM指定使用面向流的TCP协议
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
# 建立连接:
# 80是Web服务的标准端口
s.connect(('www.sina.com.cn', 80))
# 发送数据:
s.send(b'GET / HTTP/1.1\r\nHost: www.sina.com.cn\r\nConnection: close\r\n\r\n')
# 接收数据:
buffer = []
while True:
    # 每次最多接收1k字节:
    d = s.recv(1024)
    if d:
        buffer.append(d)
    else:
        break
data = b''.join(buffer)
# 关闭连接:
s.close()

header, html = data.split(b'\r\n\r\n', 1)
print(header.decode('utf-8'))
# 把接收的数据写入文件:
with open('sina.html', 'wb') as f:
    f.write(html)
```

- 服务器

```py
# 导入socket库:
import socket,threading,time

# 创建一个socket:
# AF_INET表示使用IPv4协议,SOCK_STREAM指定使用面向流的TCP协议
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# 监听端口:
#服务器可能有多块网卡，可以绑定到某一块网卡的IP地址上，也可以用0.0.0.0绑定到所有的网络地址，还可以用127.0.0.1绑定到本机地址。
s.bind(('127.0.0.1', 9999))

s.listen(5)
print('Waiting for connection...')

def tcplink(sock, addr):
    print('Accept new connection from %s:%s...' % addr)
    sock.send(b'Welcome!')
    while True:
        data = sock.recv(1024)
        time.sleep(1)
        if not data or data.decode('utf-8') == 'exit':
            break
        sock.send(('Hello, %s!' % data.decode('utf-8')).encode('utf-8'))
    sock.close()
    print('Connection from %s:%s closed.' % addr)

while True:
    # 接受一个新连接:
    sock, addr = s.accept()
    # 创建新线程来处理TCP连接:
    t = threading.Thread(target=tcplink, args=(sock, addr))
    t.start()
```

- 用于测试的客户端程序

```py
# 导入socket库:
import socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
# 建立连接:
s.connect(('127.0.0.1', 9999))
# 接收欢迎消息:
print(s.recv(1024).decode('utf-8'))
for data in [b'Michael', b'Tracy', b'Sarah']:
    # 发送数据:
    s.send(data)
    print(s.recv(1024).decode('utf-8'))
s.send(b'exit')
s.close()
```

### UDP编程
- 服务端

```py
import socket
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
# 绑定端口:
s.bind(('127.0.0.1', 9999))

print('Bind UDP on 9999...')
while True:
    # 接收数据:
    data, addr = s.recvfrom(1024)
    print('Received from %s:%s.' % addr)
    s.sendto(b'Hello, %s!' % data, addr)
```

- 客户端

```py
import socket
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
for data in [b'Michael', b'Tracy', b'Sarah']:
    # 发送数据:
    s.sendto(data, ('127.0.0.1', 9999))
    # 接收数据:
    print(s.recv(1024).decode('utf-8'))
s.close()
```

## 访问数据库
### 使用MySQL
- 使用mysql.connector驱动连接数据库

```py
#到如MySQL驱动
import mysql.connector
conn = mysql.connector.connect(user='root',password='password',database='test')
cursor = conn.cursor()
#创建user表
cursor.execute('create table user (id varchar(20) primary key, name varchar(20))')
#插入一行数据
cursor.execute('insert into user (id,name) values (%s,%s)',['1','Michael'])
print(cursor.rowcount)
conn.commit()
cursor.close()
#运行查询
cursor = conn.cursor()
cursor.execute('select * from user where id = %s',('1',))
values = cursor.fetchall()
print(values)
cursor.close()
conn.close()
```

## virtualenv
- virtualenv就是用来为一个应用创建一套“隔离”的Python运行环境,以防使用的包的版本冲突
- 使用命令:virtualenv --no-site-packages env_dir创建一个独立的环境,--no-site-packages意味着不复制第三方的包到环境中
- windows系统进入虚拟环境env_dir\Scripts\activate