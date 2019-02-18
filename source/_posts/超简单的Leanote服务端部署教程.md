title: 超简单的Leanote服务端部署教程
tags:
    - 软件
comments: true
brief: 超简单的Leanote服务端部署教程
date: 2018-6-13
photos:
    - "https://qn-cdn.leanote.top/leanote/images/leanote-index-bg.jpg"
categories:
    - 软件
---
# 超简单的Leanote服务端部署教程

<!-- more -->

leanote又叫蚂蚁笔记是一个具有ios、android、桌面、web全端的笔记软件。而且能够将保存的笔记直接发布为博客，但是能定制的内容不多，对于追求个性化的程序员恐怕是难以胜任，但是具有多端同步还支持markdown、富文本两种书写模式，并且全部开源（貌似有些个性化的功能没有开源）。这对于爱折腾的程序员还是很有吸引力的。

废话不多说，接下来说明如何服务器端部署Leanote。

说白了超简单的Leanote服务器部署是使用docker打包部署，可以参考链接：[docker-leanote](https://github.com/jim3ma/docker-leanote)

## mongodb配置
首先按照官方教程安装mongodb并导入初始数据：

安装mongodb方法网上一抓一大把，归纳起来就是找到一个顺眼的目录(不能是tmp啊，一般人放home或usr目录)下载->解压->导入路径->使配置文件生效

```bash
# 解压缩包
tar -xzvf mongodb.tgz
# 打开配置文件
sudo vi /etc/profile
# 导入路径，路径为自己的
export PATH=$PATH:/home/mongodb-linux-x86_64-3.0.1/bin
# 使配置文件生效
source /etc/profile
```

然后就是mongodb的启动和导入初始数据。

mongodb启动
```bash
# 建一个看的顺眼的目录存放mongodb数据
mkdir /home/data
# 后台启动mongodb
nohup mongod --dbpath /home/data &
# 进入数据库，查看是否成功
mongo
show dbs
```

数据导入
```bash
# PATH_TO_LEANOTE为Leanote对应文件夹
mongorestore -h localhost -d leanote --dir PATH_TO_LEANOTE/mongodb_backup/leanote_install_data/
#进入mongodb，将使用的数据库改为leanote
mongo
use leanote
```

直接点开官方教程mongodb下载会发现比较慢，下载最新版本又怕有兼容性问题。贴心的作者把mongodb都传到百度云上了[mongodb-linux-x86_64-3.0.1](https://pan.baidu.com/s/1lwZXKo2T3K2n6iCtfduktg?errno=0&errmsg=Auth%20Login%20Sucess&&bduss=&ssnerror=0&traceid=)，大家点连接即可飞速下载。

## docker配置
然后再找一个自己看的顺眼的目录，按照如下建立结构，app.conf，docker-compose.yml在容器作者说明文档中都有[链接](https://github.com/jim3ma/docker-leanote#2-update-mongo-config-in-appconf)

```txt
├── app.conf
├── docker-compose.yml
└── leanote-data
    ├── files
    │   └── upload
    ├── mongodb_backup
    │   └── upload
    └── public
        └── upload
```

docker-compose.yml
```yaml
version: '2'
services:
  leanote:
    image: jim3ma/leanote:latest
    network_mode: "host"
    volumes:
      - ./leanote-data:/leanote/data
      - ./app.conf:/leanote/conf/app.conf
    restart: always
```

目录结构是根据容器作者要求建的，从docker-compose.yml中能看出是被映射到容器中的。需要说明下我使用的是最终版，而不是说明文档中的2.4版。

踩到的坑：
1. 忘记修改site.url为自己的ip、域名，导致图片在其他客户端无法获得同步。
2. 没有开启阿里云端口访问权限，导致外部无法访问。
3. docker登录dockerhub的使用的是用户名，而不是邮箱

一些经验，客户端同步出错。服务器端修改正确之后，客户端并不会自动同步修正。需要客户端注销再登录，就能使得同步正常。

感谢[@jim3ma](https://github.com/jim3ma)同学。没有他默默的付出就不会有这么容易的部署方案。

## 废话开始
本来我是不想部署leanote。一是网上评价太差，很多人说leanote伪开源，bug太多；二是因为官方文档的部署操作太麻烦，尤其是需要翻墙才能够让go获取需要的包。但是想着反正自己买了服务器了，想试试也不亏。于是才有了今天这篇文章。

使用docker进行部署leanote比起直接按照官网的教程简单的多，我在按照官方教程一步一步部署时，就想如果我部署成功了，一定要打个docker包来方便后来人。既然我能想到docker，那说不定早就有人这么做了。于是我去dockerhub翻找了下，果然有不少leanote的容器。按照其中star量最高最近有更新的操作果然成功了。

这件事情教会我：
1. 平时要广开言路，对各种主流技术工具不说熟练、精通，但应该也要有所了解。眼下可能没有用处，但是在未来的某一天说不定就帮上大忙了。
2. 多用不同的角度思考问题，不能只依赖百度、google。
3. 对于传言不能尽信，尤其是网络上的发言，即使在那个时间点是正确的，也有可能过时。