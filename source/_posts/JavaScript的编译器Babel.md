title: JavaScript的编译器Babel
tags:
    - 前端
comments: true
brief: JavaScript的编译器Babel
date: 2018-01-05
categories:
    - 前端
---
# JavaScript的编译器Babel
Babel 是一个通用的多用途 JavaScript 编译器。通过 Babel 你可以使用（并创建）下一代的 JavaScript，以及下一代的 JavaScript 工具。

Babel 把用最新标准编写的 JavaScript 代码向下编译成可以在今天随处可用的版本。 这一过程叫做“源码到源码”编译， 也被称为转换编译

<!-- more -->

## 模块
### babel-core
如其名字一样是babel核心模块，用于将js代码抽象成抽象语法树ast(abstract syntax tree)。具有一系列transform api。

```js
var babel = require('babel-core');
babel.transform("code", options) // => { code, map, ast } //抽象代码字符串
babel.transformFileSync(path.resolve(__dirname) + "/test.js", {
  presets: ['env'],
  plugins: ['transform-runtime'],
}, function(err, result) {// { code, map, ast }
    console.log(result);
});
//ast转换为code
babel.transformFromAst(ast: Object, code?: string, options?: Object)
```

### babel-cli
Babel 内置的一个 CLI，可通过命令行操作来编译文件。因为直接使用命令行来编译文件比较少，需要的时候还是查询[文档](https://www.babeljs.cn/docs/usage/cli/)吧，

```bash
babel src --out-dir lib
```

#### babel-external-helpers
babel在编译文件的时候需要使用一些帮助函数，如：toArray,jsx转化函数等。在编译成模块的时候，会放到模块的顶部。但这样会造成大量的冗余，因此babel提供了该命令将所有的babel帮助函数生成一份，引入到项目中，再引入babel-plugin-external-helpers插件，就可以避免冗余的产生。

不过已经被babel-plugin-transform-runtime给代替了

#### babel-node
babel-node用于支持在命令行上转义代码，方便开发之用。babel-node 已经内置了 polyfill，并依赖 babel-register 来编译脚本。

### babel-register
我们可以在代码中引入它 `require('babel-register')`，并通过 node 直接执行我们的代码而不需要通过转义。

原理是通过改写 node 本身的 require，添加钩子，然后在 require 其他模块的时候，就会触发 babel 编译。可以理解为babel-node 就是在内存中写入一个临时文件，在顶部引入 babel-register。

```js
// register.js 引入 babel-register，并配置。然后引入要执行代码的入口文件
require('babel-register')({ presets: ['react'] });
require('./test')
```

### babel-runtime
这个包很简单，就是引用了 core-js 和 regenerator，然后生产环境把它们编译到 dist 目录下，做了映射

需要作为dependencies引用，因为在转义中按需引入它的包下的文件。

#### core-js
core-js 是用于 JavaScript 的组合式标准化库，它包含 es5 （e.g: object.freeze）, es6的 promise，symbols, collections, iterators, typed arrays， es7+提案等等的 polyfills 实现。也就是说，它几乎包含了所有 JavaScript 最新标准的垫片。

#### regenerator
它是来自于 facebook 的一个库，链接。主要就是实现了 generator/yeild， async/await。

#### helper
babel-runtime中存在一个helpers，它相当于babel-external-helpers生成的helper，只不过是将每一个helper单独放置在一个文件中。

### babel-polyfill
它会让我们程序的执行环境，模拟成完美支持 es6+ 的环境，毕竟无论是浏览器环境还是 node 环境对 es6+ 的支持都不一样。它是以重载全局变量 （E.g: Promise）,还有原型和类上的静态方法（E.g：Array.prototype.reduce/Array.form），从而达到对 es6+ 的支持。不同于 babel-runtime 的是，babel-polyfill 是一次性引入你的项目中的，就像是 React 包一样，同项目代码一起编译到生产环境。

### babel-loader
用于配合webpack使用，在webpack的loader中使用它来转义js文件。

## .babelrc
.babelrc是babel的配置文件，一般是放置在项目的根目录下，或者被集成到package.json中包裹在babel字段下

```js
{
    "babel":{
        "presets": [],
        "plugins": []
    }
}
```

### plugins
babel 编译分为三步：
1. parser：通过 babylon 解析成 AST。
2. transform[s]：All the plugins/presets ，进一步的做语法等自定义的转译，仍然是 AST。
3. generator： 最后通过 babel-generator 生成 output string。

### babel-plugin-transform-runtime
transform-runtime 是为了方便使用 babel-runtime 的，它会分析我们的 ast 中，是否有引用 babel-rumtime 中的垫片（通过映射关系），如果有，就会在当前模块顶部插入我们需要的垫片。当然还可以配合其他的库使用，只需要在moduleName中将库名设置为其他的即可。

```json
// 默认值
{
  "plugins": [
    ["transform-runtime", {
      "helpers": true,
      "polyfill": true,
      "regenerator": true,
      "moduleName": "babel-runtime"
    }]
  ]
}
```

### presets
presets可以认为是plugins的组合，用于设定转码规则，常见的有：
- babel-preset-env 在没有任何配置选项的情况下，babel-preset-env 与 babel-preset-latest（或者babel-preset-es2015，babel-preset-es2016和babel-preset-es2017一起）的行为完全相同。可以配置项目需要的环境依赖，使得转义代码更小。（[查看详情](https://www.babeljs.cn/docs/plugins/preset-env/) ，[转义语法](https://github.com/browserslist/browserslist#queries)）
- babel-preset-es2015 es2015转码规则
- babel-preset-react react转码规则
- babel-preset-stage-0 - 稻草人: 只是一个想法，可能是 babel 插件。
- babel-preset-stage-1 - 提案: 初步尝试。
- babel-preset-stage-2 - 初稿: 完成初步规范。
- babel-preset-stage-3 - 候选: 完成规范和浏览器初步实现。

#### babel-preset-env
它能根据当前的运行环境，自动确定你需要的 plugins 和 polyfills。通过各个 es标准 feature 在不同浏览器以及 node 版本的支持情况，再去维护一个 feature 跟 plugins 之间的映射关系，最终确定需要的 plugins。

```json
{
  "presets": [
    [
      "env",
      {
        "targets": { // 配支持的环境
          "browsers": [ // 浏览器
            "last 2 versions",
            "safari >= 7"
          ],
          "node": "current"
        },
        "modules": true,  //设置ES6 模块转译的模块格式 默认是 commonjs
        "debug": true, // 开启debug后，编译结果会得到使用的 targets，plugins，polyfill 等信息
        "useBuiltIns": false, // 是否开启自动支持 polyfill
        "include": [], // 总是启用哪些 plugins
        "exclude": []  // 强制不启用哪些 plugins，用来防止某些插件被启用
      }
    ]
  ],
  plugins: [
    "transform-react-jsx" //如果是需要支持 jsx 这个东西要单独装一下。
  ]
}
```

开启了useBuiltIns选项后，仍然需要`import 'babel-polyfill'`。不过开启这个选项后，它会根据项目的需要，使用最小的polyfill。

## 参考文献

[Babel入门教程](http://www.ruanyifeng.com/blog/2016/01/babel.html#page-title)

[Babel文档](https://www.babeljs.cn/docs/plugins/)

[你真的会用babel吗?](https://juejin.im/entry/59ba1a3c5188255e723b8cae)