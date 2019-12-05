title: 前端构建工具Webpack
tags:
    - 前端
comments: true
brief: 前端构建工具Webpack
date: 2018-02-22
categories:
    - 前端
---
# 前端构建工具Webpack
webpack作用是分析你的项目结构，找到JavaScript模块以及其它的一些浏览器不能直接运行的拓展语言（Scss，TypeScript等），并将其转换和打包为合适的格式供浏览器使用。本文讲解的内容基于webpack4版本
<!-- more -->

## 基本
Webpack的工作方式是：把你的项目当做一个整体，通过一个给定的主文件（如：index.js），Webpack将从这个文件开始找到你的项目的所有依赖文件，使用loaders处理它们，最后打包为一个（或多个）浏览器可识别的JavaScript文件。

其实Webpack和Gulp/Grunt并没有太多的可比性，Gulp/Grunt是一种能够优化前端的开发流程的工具，而WebPack是一种模块化的解决方案，不过Webpack的优点使得Webpack在很多场景下可以替代Gulp/Grunt类的工具。

Grunt和Gulp的工作方式是：在一个配置文件中，指明对某些文件进行类似编译，组合，压缩等任务的具体步骤，工具之后可以自动替你完成这些任务。


对于单一入口起点，写成如下配置即可
```js
module.exports = {
  entry: './path/to/my/entry/file.js',
  output: {
    filename: 'bundle.js',
    path: '/home/proj/public/assets'
  }
};
```

对于多入口起点，需要写成如下形式，
```js
module.exports = {
    entry: {
        popup: './js/App.js',
        background: './js/bg/index.js',
        cnt: './js/cnt/index.js',
    },
    output: {
        path: path.resolve(__dirname, './build'),
        publicPath: '',
        filename: '[name].js'
    },
}
```

其中`[name]`叫作占位符，它与entry对象的键名相同。除此之外还有`[hash]`、`[chunkhash】`、`[id]`、`[query]`等，具体参考:[占位符](https://webpack.docschina.org/configuration/output#output-filename)

### devtool
配置devtool让编码后的文件与编码前的文件对应起来，便于调试。

在webpack的配置文件中配置source maps，需要配置devtool，它有许多不同的配置选项，开发中一般使用eval-source-map，生产环境中一般不进行配置（配置为false)

eval-source-map 
使用eval打包源文件模块，在同一个文件中生成干净的完整的source map。这个选项可以在不影响构建速度的前提下生成完整的sourcemap，但是对打包后输出的JS文件的执行具有性能和安全的隐患。在开发阶段这是一个非常好的选项，在生产阶段则一定不要启用这个选项；

其他配置选项可参见:[devtool api](https://webpack.docschina.org/configuration/devtool/)

### mode
用于告知 webpack 使用相应模式的内置优化。mode 的默认值是 production。

development
会将 process.env.NODE_ENV 的值设为 development。

- NamedChunksPlugin ：以名称固化 chunk id
- NamedModulesPlugin ：以名称固化 module id

production
会将 process.env.NODE_ENV 的值设为 production。

- FlagDependencyUsagePlugin (编译时标记依赖)
- FlagIncludedChunksPlugin (标记了chunks，防子chunks多次加载)
- ModuleConcatenationPlugin (作用域提升(scope hosting),预编译功能,提升或者预编译所有模块到一个闭包中，提升代码在浏览器中的执行速度)
- NoEmitOnErrorsPlugin (在输出阶段时，遇到编译错误跳过)
- OccurrenceOrderPlugin (给经常使用的ids更短的值)
- SideEffectsFlagPlugin(识别 package.json 或者 module.rules 的 sideEffects 标志（纯的 ES2015 模块)，安全地删除未用到的 export 导出)
- UglifyJsPlugin (删除未引用代码，并压缩)

### resolve
#### resolve.alias
创建 import 或 require 的别名，来确保模块引入变得更简单

```js
resolve: {
    alias: {
        xyz$: path.resolve(__dirname, 'path/to/file.js') //$表示精确匹配
    }
}
import "xyz"; //路径/abs/path/to/file.js
import "xyz/file.js"; //路径 /abc/node_modules/xyz/file.js
```
具体参见:[resolve.alias](https://www.webpackjs.com/configuration/resolve/#resolve-alias)

#### resolve.extensions
自动解析确定的扩展。默认值为:
```js
extensions: [".js", ".json"]
```
常用于解析jsx,vue后缀匹配

#### resolve.mainFields
当从 npm 包中导入模块时（例如，import * as D3 from "d3"），此选项将决定在 package.json 中使用哪个字段导入模块。根据 webpack 配置中指定的 target(表示编译后的js用于什么环境) 不同，默认值也会有所不同。

当 target 属性设置为 webworker, web 或者没有指定，默认值为：

`mainFields: ["browser", "module", "main"]`
对于其他任意的 target（包括 node），默认值为：

`mainFields: ["module", "main"]`

例如，D3 的 package.json 含有这些字段：

```json
{
  ...
  main: 'build/d3.Node.js',
  browser: 'build/d3.js',
  module: 'index',
  ...
}
```

### optimization 
用于优化的一些配置项

如将公共代码抽离，加快加载速度
```js
optimization: {
    splitChunks: {
        chunks: 'all',                              //'all'|'async'|'initial'(全部|按需加载|初始加载)的chunks
        // maxAsyncRequests: 1,                     // 最大异步请求数， 默认1
        // maxInitialRequests: 1,                   // 最大初始化请求书，默认1
        cacheGroups: {
            // 抽离第三方插件
            vendor: {
                test: /node_modules/,            //指定是node_modules下的第三方包
                chunks: 'all',
                name: 'vendor',                  //打包后的文件名，任意命名
                priority: 10,                    //设置优先级，防止和自定义公共代码提取时被覆盖，不进行打包
                },
                // 抽离自己写的公共代码，utils这个名字可以随意起
            utils: {
                chunks: 'all',
                name: 'utils',
                minSize: 0,                      //只要超出0字节就生成一个新包
                minChunks: 2,                     //至少两个chucks用到
                // maxAsyncRequests: 1,             // 最大异步请求数， 默认1
                maxInitialRequests: 5,           // 最大初始化请求书，默认1
            }
        }
    },
    //提取webpack运行时的代码
    runtimeChunk: {                              
        name: 'runtime'
    }
}
```

### externals
防止将某些 import 的包(package)打包到 bundle 中，而是在运行时(runtime)再去从外部获取这些扩展依赖

index.html

```html
<script
  src="https://code.jquery.com/jquery-3.1.0.js"
  integrity="sha256-slogkvB1K3VOkzAI8QITxV3VzpOnkeNVsKvtkYLMjfk="
  crossorigin="anonymous">
</script>
```

webpack.config.js

```js
externals: {
  jquery: 'jQuery'
}
```

```js
import $ from 'jquery';

$('.my-element').animate(...);
```

### webpack-dev-server
webpack-dev-server是webpack提供的一个可选的本地开发服务器，使用该服务器能够监听你本地代码修改，自动刷新浏览器。要使用该组件，除了要单独安装依赖以外还需要配置devserver字段。

常见配置
```js
devServer: {
    contentBase: path.resolve(__dirname, '../dist'),    //服务路径，存在于缓存中
    host: 'localhost',                                  // 默认是localhost
    port: 8080,                                         // 端口
    open: true,                                         // 自动打开浏览器
    // inline: true,                                    //inline模式开启服务器(默认开启)
    // proxy: xxx                                       //接口代理配置
    // quiet: true                                      //和friendly-errors-webpack-plugin配合,但webpack自身的错误或警告在控制台不可见。
    clientLogLevel: "none",                             //阻止打印那种搞乱七八糟的控制台信息
},
```


#### 热更新
模块热替换功能会在应用程序运行过程中替换、添加或删除模块，无需重新加载整个页面。主要是通过以下几种方式，来显著加快开发速度：

- 保留在完全重新加载页面时丢失的应用程序状态。
- 只更新变更内容，以节省宝贵的开发时间。
- 调整样式更加快速 - 几乎相当于在浏览器调试器中更改样式。

```js
{
     devServer:{
        hot:true,//热加载
        hotOnly:true // 不开启的话，热更新后又会自动刷新
    },
    plugins:[
    //热更新插件
        new webpack.HotModuleReplacementPlugin()
    ]
}
```

## Loaders
通过使用不同的loader，webpack有能力调用外部的脚本或工具，实现对不同格式的文件的处理，比如说分析转换scss为css，或者把下一代的JS文件（ES6，ES7)转换为现代浏览器兼容的JS文件，对React的开发而言，合适的Loaders可以把React的中用到的JSX文件转换为JS文件。

注意loader的加载顺序是从右向左

```js
module.exports = {
    entry: {/*...*/},
    output: {/*...*/},
    module: {
        rules: [
            {
                test: /\.(scss|css)$/,
                use: ['css-loader','style-loader'],
                exclude: /node_modules/
            },
            {
                test: /\.(js|jsx)$/,
                use: {
                    loader: 'babel-loader',
                },
                exclude: /node_modules/
            },
            {
                test: /\.(png|jpg|gif|svg)$/,
                loader: 'file-loader',
                options: {
                    name: '[name].[ext]?[hash]'
                }
            }
        ]
    },
}
```

### 常见loader
file-loader
将使用import,require导入的图片，在生成文件中变成对应的路径

babel-loader
用于对代码进行转码

css-loader 
处理css文件中的url()等

style-loader 
将css插入到页面的style标签

## Plugins
插件（Plugins）是用来拓展Webpack功能的，它们会在整个构建过程中生效，执行相关的任务。
Loaders和Plugins常常被弄混，但是他们其实是完全不同的东西，可以这么来说，loaders是在打包构建过程中用来处理源文件的（JSX，Scss，Less..），一次处理一个，插件并不直接操作单个文件，它直接对整个构建过程其作用。

Webpack有很多内置插件，同时也有很多第三方插件，可以让我们完成更加丰富的功能。

```js
module.exports = {
...
    module: {
        /*...*/
    },
    plugins: [
        new webpack.BannerPlugin('版权所有，翻版必究') //给打包的代码添加版权说明信息
    ],
};
```

### 常见的Plugin

webpack.HotModuleReplacementPlugin 
配合webpack-dev-server实现热重载

copy-webpack-plugin 
拷贝文件到对应的目录下

uglifyjs-webpack-plugin
删除未使用代码并压缩

mini-css-extract-plugin
抽取文件中的css并压缩，常用于vue单文件的项目中

webpack.DefinePlugin({
    'process.env': '"production"',
  })
用于定义运行时模块内部环境变量

## 参考文献：
[入门webpack看这篇就够了](https://www.jianshu.com/p/42e11515c10f#h5o-26)
[webpack官方文档](https://webpack.docschina.org/)
[webpack4常用配置](https://juejin.im/post/5b4364d66fb9a04fac0cf686#heading-5)