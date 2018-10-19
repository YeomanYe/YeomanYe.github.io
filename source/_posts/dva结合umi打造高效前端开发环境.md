title: dva结合umi打造高效前端开发环境
tags:
    - 前端
comments: true
brief: dva结合umi打造高效前端开发环境
copyright: true
date: 2018-09-30
categories:
    - 前端
---
# dva结合umi打造高效前端开发环境
dva是一个对react业界标准框架与类库的轻量级封装。使用elm来组织model，简化了action、reducer的扁平化代码组织形式，使代码更易于编写、维护。

umi是一个可插拔的企业级应用框架，本身插件化非侵入式的设计除了可以实现一键更换为preact，一键支持ie9等，按照其umi约定方式进行项目目录结构的搭建可以简化很多不必要的代码的编写和配置。

<!-- more -->

## dva
dva整合了redux、redux-sage、react-router、react-router-redux等业界标准而成的轻量级框架。dva中的概念与接口都是从原有的东西中来的，使用该框架改进代码的架构的同时，不需要花费额外的精力来学习新东西。此外仍可以使用redux中间件，并能编写dva的插件来扩展应用。

### elm概念
elm是指通过reducers、effects（等价于saga中的effects表示从发送请求到产生action中产生副作用的部分；我的认知中它也相当于reducer，是用于和后端通信将数据传给真正reducer的）和subscriptions（一个监听器，在model第一次加载时调用）来组织model。形式如下：

```js
export default {
  namespace: 'page',
  state: {
    curPage:-1,
    perPage:10,
    total:0
  },
  reducers: {
    save(state, {payload}) {
        return {...state, ...payload};
  },
  effects: {
    * saveEff({payload},{call,put}) {
        let data = yield call(queryPage,payload);
        yield put('save',data);
        },
    },
  subscriptions: {
    //常用于设置history监听触发action
    setup({dispatch, history}) {
        history.listen(location => {
                if (location.pathname == '/queryPage') {
                    dispatch({
                        type: 'save',
                        payload: location.query
                    });
                }
            });
    },
  },
};
```

从代码中可以看出elm只是指的将reducer、effects、subscriptions和state中组织在一个文件中配以命名空间，并没有任何新内容。

### 初始化
为什么初始化没有在一开始介绍呢，理由是dva与umi结合可以省略dva的初始化步骤。示例代码如下

```js
import createDvaApp from 'dva';
import createHistory from 'history/createBrowserHistory';

// 1. Initialize
// 在1.x版本的dva中history可以直接通过dva获取
// 在最新的dva中，history需要另装history模块。
// onAction用于配置redux中间件，存在多个中间件时使用数组
const app = createDvaApp({
    history: createHistory(),
    onAction:createLogger(),
});

// 2. Plugins
// 配置dva的插件，如:dva-loading
app.use({});

// 3. Model
// 注册model，解除注册使用unmodel
app.model(home);

// 4. Router
app.router(router);

// 5. Start
// 启动app
app.start('#root');
```
dva的模板文件，可以如同react放在public目录下，也可以放在根目录下。

### dva插件
一般情况下dva的基本使用，配上redux的中间件和dva已存在的插件，基本能够解决问题大部分问题，解决不了还可以考虑通过编写redux中间件来解决。但是既然在dva框架下，了解dva插件的能力还是很有必要的。

dva插件的编写，在网上和文档中都没看到有相关的记录，因此我只能通过现有的插件来了解dva插件的能力以及编写方式。

我参考的插件是dva-loading，它能够根据发出的action是否完成来改变其标志位。

以下是其源码：
```js
const SHOW = '@@DVA_LOADING/SHOW';
const HIDE = '@@DVA_LOADING/HIDE';
const NAMESPACE = 'loading';

function createLoading(opts = {}) {
    const namespace = opts.namespace || NAMESPACE;
  
      const { only = [], except = [] } = opts;
      if (only.length > 0 && except.length > 0) {
        throw Error('It is ambiguous to configurate `only` and `except` items at the same time.');
      }

      const initialState = {
        global: false,
        models: {},
        effects: {},
      };

    //只是普通的reducer
    //如名字一般是额外产生的reducer
    const extraReducers = {
    [namespace](state = initialState, { type, payload }) {
      const { namespace, actionType } = payload || {};
      let ret;
      switch (type) {
        case SHOW:
          ret = {
            ...state,
            global: true,
            models: { ...state.models, [namespace]: true },
            effects: { ...state.effects, [actionType]: true },
          };
          break;
        case HIDE: // eslint-disable-line
          const effects = { ...state.effects, [actionType]: false };
          const models = {
            ...state.models,
            [namespace]: Object.keys(effects).some((actionType) => {
              const _namespace = actionType.split('/')[0];
              if (_namespace !== namespace) return false;
              return effects[actionType];
            }),
          };
          const global = Object.keys(models).some((namespace) => {
            return models[namespace];
          });
          ret = {
            ...state,
            global,
            models,
            effects,
          };
          break;
        default:
          ret = state;
          break;
      }
      return ret;
    },
  };
  //从名字以及代码中可以看出它能够拦截effect做出一些额外的动作
  //namespace是定义model时的namespace
  function onEffect(effect, { put }, model, actionType) {
    const { namespace } = model;
    if (
        (only.length === 0 && except.length === 0)
        || (only.length > 0 && only.indexOf(actionType) !== -1)
        || (except.length > 0 && except.indexOf(actionType) === -1)
    ) {
        return function*(...args) {
            yield put({ type: SHOW, payload: { namespace, actionType } });
            yield effect(...args);
            yield put({ type: HIDE, payload: { namespace, actionType } });
        };
    } else {
        return effect;
    }
  }

  return {
    extraReducers,
    onEffect,
  };
}
```
由此可推出dva插件拦截effect，可以在其执行前后进行一系列的操作，并能自定义额外的reducer(我觉得应该是只有一个reducer的model吧，因为使用dva-loading时有一个loading的model被自动的注册到dva app中)。

## umi
### umi约定式目录
上面也提到根据umi约定的结构来搭建项目能够简化代码的编写与配置，具体的目录结构如下。

```txt
.
├── dist/                          // 默认的 build 输出目录
├── mock/                          // mock 文件所在目录，基于 express
├── layouts/                       //该目录下导出的为全局的文件文件，如果只想作为一些页面的布局可以在pages下建页面的目录，_layout.js会作为该页面的布局文件
├── config/
    ├── config.js                  // umi 配置，同 .umirc.js，二选一
└── src/                           // 源码目录，可选
    ├── layouts/index.js           // 全局布局
    ├── pages/                     // 页面目录，里面的文件即路由
        ├── .umi/                  // dev 临时目录，需添加到 .gitignore
        ├── .umi-production/       // build 临时目录，会自动删除
        ├── document.ejs           // HTML 模板
        ├── 404.js                 // 404 页面
        ├── page1.js               // 页面 1，任意命名，导出 react 组件
        ├── page1.test.js          // 用例文件，umi test 会匹配所有 .test.js 和 .e2e.js 结尾的文件
        └── page2.js               // 页面 2，任意命名
    ├── global.css                 // 约定的全局样式文件，自动引入，也可以用 global.less
    ├── global.js                  // 可以在这里加入 polyfill
├── .umirc.js                      // umi 配置，同 config/config.js，二选一
├── .env                           // 环境变量
└── package.json
```

### 路由简化
对于约定式路由简化主要通过几个方面来实现：

- pages目录下的组件会被作为对应的地址的页面，pages下面的组件如果有多个目录进行嵌套，则会按照目录结构生成对应地址的路由(如：目录结构pages -> page1 -> page2)，生成的路由结构就是`/page1/page2`

- 动态路由在路由名（即文件名前加$）`$page`;可选动态前后加$，如：`$page$`

```txt
+ pages/
  + $post/
    - index.js
    - comments.js
  + users/
    $id$.js
  - index.js
```

生成的路由如下：

```json
[
  { path: '/', component: './pages/index.js' },
  { path: '/users/:id?', component: './pages/users/$id.js' },
  { path: '/:post/', component: './pages/$post/index.js' },
  { path: '/:post/comments', component: './pages/$post/comments.js' },
]
```

参数通过`this.props.match.params`来获取，顺便说一下查询查询参数（即get请求的参数）通过`this.props.location.query`来获取。

- 全局布局文件从layouts下得到，如果只想应用于一些指定的页面，只需要在对应页面的目录下加`_layout.js`即可。
- 路由动效可以使用react-transition-group在对应的布局文件的页面结构切换处设置组件来实现。

```js
import withRouter from 'umi/withRouter';
import { TransitionGroup, CSSTransition } from "react-transition-group";

export default withRouter(
  ({ location }) =>
    <TransitionGroup>
      <CSSTransition key={location.pathname} classNames="fade" timeout={300}>
        { children }
      </CSSTransition>
    </TransitionGroup>
)
```

- 路由鉴权通常是在通用的布局组件中进行（即layouts中）。也可以单独抽离一个布局组件用于鉴权，如果单独抽离一个组件进行鉴权。那么需要鉴权的页面就需要被这个布局组件加载，对于约定式路由只需要添加如下类似于yml的注释即可。

```js
/**
 * Routes:
 *   - ./routes/AuthRoutes.js
 *   - ./routes/PrivateRoute.js
 */
import router from 'umi/router';

export default () =>
  <div>
    <h1>/list</h1>
    <button onClick={() => {
      router.push('/list');
    }}>test push to self</button>
  </div>
```

装载顺序先从Routes定义的布局组件 -> 全局布局组件 -> 对应页面布局组件

## mock测试
umi将拦截ajax的mock测试简化成配置语义化对象，编写返回内容即可的简单程度。如果需要与服务器端进行联调只需要配置代理到对应服务器的地址即可。

```js
export default {
  // 支持值为 Object 和 Array
  'GET /api/users': { users: [1, 2] },

  // GET POST 可省略
  '/api/users/1': { id: 1 },

  // 支持自定义函数，API 参考 express@4
  'POST /api/users/create': (req, res) => { res.end('OK'); },
};
```

简单说明下，各种请求的参数获取方式：
- GET: `req.query`
- POST、PUT: `req.body`
- 动态路由参数，如:`DELETE /api/delHero/:id`: `req.params`

## dva与umi的整合
- umi整合dva

搭建umi的环境，然后再使用umi插件集成dva，使用脚手架的步骤如下：
1. `yarn create umi` 根据提示选择需要的插件
2. 然后到工程目录下手动安装依赖`yarn install`

详情见:[通过脚手架创建项目](https://umijs.org/zh/guide/create-umi-app.html)

- dva整合umi
使用最新版的dva进行项目构建，会自动的集成umi
1. `npm install dva-cli@next -g` 安装最新dva
2. `dva new myapp` 创建项目

详情见:[通过dva-cli创建项目](https://dvajs.com/knowledgemap/#%E9%80%9A%E8%BF%87-dva-cli-%E5%88%9B%E5%BB%BA%E9%A1%B9%E7%9B%AE)

其实两种方式都是在umi工程的基础上配以开启dva支持的插件`umi-plugin-react`或`umi-plugin-dva`

集成dva的插件中默认带有`dva-loading`和`dva-immer`如果还需要其他插件，可以通过在`src/app.js`中编写配置，编写的配置会被合与默认配置进行合并。示例如下:

```js
export const dva = {
  config: {
    onError(e) {
      e.preventDefault();
      console.error(e.message);
    },
  },
  plugins: [
    require('dva-logger'),
  ],
};
```

## 示例代码
工程上的事情，单凭文章的讲解，未免太抽象了，大家可以通过以下示例学习
- [Hero Editor](https://github.com/YeomanYe/heroeditor-example) 个人编写的简单例子
- [Antd Admin](https://github.com/zuiidea/antd-admin) 完整的项目
- [umi-examples](https://github.com/umijs/umi-examples) umi路由例子

## 参考文献

[dva文档](https://dvajs.com/guide/#%E7%89%B9%E6%80%A7)

[umi文档](https://umijs.org/zh/guide/)

[dva介绍](https://github.com/dvajs/dva/issues/1)

[umi + dva，完成用户管理的 CURD 应用](https://github.com/sorrycc/blog/issues/62)

