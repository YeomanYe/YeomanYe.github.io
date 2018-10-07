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


## .babelrc
.babelrc是babel的配置文件，一般是放置在项目的根目录下，或者被集成到package.json中包裹在babel字段下

```json
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

### presets
presets可以认为是plugins的组合，用于设定转码规则，常见的有：
- babel-preset-env 在没有任何配置选项的情况下，babel-preset-env 与 babel-preset-latest（或者babel-preset-es2015，babel-preset-es2016和babel-preset-es2017一起）的行为完全相同。可以配置项目需要的环境依赖，使得转义代码更小。（[查看详情](https://www.babeljs.cn/docs/plugins/preset-env/) ，[转义语法](https://github.com/browserslist/browserslist#queries)）
- babel-preset-es2015 es2015转码规则
- babel-preset-react react转码规则
- babel-preset-stage-0 - 稻草人: 只是一个想法，可能是 babel 插件。
- babel-preset-stage-1 - 提案: 初步尝试。
- babel-preset-stage-2 - 初稿: 完成初步规范。
- babel-preset-stage-3 - 候选: 完成规范和浏览器初步实现。

## 参考文献

[Babel入门教程](http://www.ruanyifeng.com/blog/2016/01/babel.html#page-title)

[Babel文档](https://www.babeljs.cn/docs/plugins/)

[你真的会用babel吗?](https://juejin.im/entry/59ba1a3c5188255e723b8cae)