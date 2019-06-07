title: react-native-root-siblings源码解读
tags:
    - 前端
comments: true
brief: react-native-root-siblings源码解读
copyright: true
date: 2019-02-17
top: 10
categories:
    - 前端
---
react-native-root-siblings是magicismight编写的react-native的工具库，它能够使用函数将组件作为兄弟节点插入到根组件中，如:

```js
//插入
let sibling = new RootSiblings(<View
    style={{top: 0,right: 0,bottom: 0,left: 0,backgroundColor: 'red'}}
/>);
//更新
sibling.update(<View
    style={{top: 10,right: 10,bottom: 10,left: 10,backgroundColor: 'blue'}}
/>);
//删除
sibling.destroy();
```

<!-- more -->

使用该组件可以实现通过函数直接显示UI，而不需要将UI写入组件中，通过设置状态来改变显隐。鄙人认为使用这种方式来显示一些会话框能够很好的组织与维护代码。因此我对这个类库产生了浓厚的兴趣，并开始解析其写法。从github上下载源码并使用SourceTree回溯日志后，可以发现该项目经过了三次比较大的改动。分别对应于1.x版本 2.x版本 3.x版本。

## 1.x
1.x版本适用于0.46以下的react native版本
核心思路

使用一个自定义注册方法，代替原有组件注册方法，然后使用`<StaticContainer/>`作为原有组件的容器(这个组件只接收一个孩子节点，并且只有显式的设置属性shouldUpdate为true时才会更新组件)。很明显StaticContainer的使用是为了提高性能。

该库使用事件的方式，通知有组件发生了变化应该进行更新，此库使用forceUpdate 而不是使用状态进行更新。我猜测也许是为了让根组件的状态更透明而使用forceUpdate。

```js
const originRegister = AppRegistry.registerComponent;
AppRegistry.registerComponent = function (appKey, getAppComponent) {
    const siblings = new Map();
    const updates = new Set();

    return originRegister(appKey, function () {
        const OriginAppComponent = getAppComponent();
        /**/
        return class extends Component {
            componentWillMount() {
                    this._update = this._update.bind(this);
                    emitter.addListener('siblings.update', this._update);
                };

                _update(id, element, callback) {
                    if (siblings.has(id) && !element) {
                        siblings.delete(id);
                    } else {
                        siblings.set(id, element);
                    }
                    updates.add(id);
                    //触发更新
                    this.forceUpdate(callback);
                };

            render(){
                return(
                    <View style={styles.container}>
                        <StaticContainer shouldUpdate={false}>
                            <OriginAppComponent {...this.props} />
                        </StaticContainer>
                        {siblings.map((element, id) =>(
                        <StaticContainer
                            key={`root-sibling-${id}`}
                            shouldUpdate={updates.has(id)}>
                            {element}
                        </StaticContainer>))}
                    </View>
                )
            }
        }
    };
}
```

1.x版本中核心的逻辑就是这些，其他逻辑相对简单就不过多的介绍了。

## 2.x
2.x版本中主要的变化有：

1. 使用`AppRegistry.setWrapperComponentProvider` API代替了原来替换`registerComponent`的方案
2. 不再使用事件和forceUpdate来更新UI的机制，转而使用state进行UI的更新，我估计是`AppRegistry.setWrapperComponentProvider`本身已经有很好的隐藏状态的能力。

```js
AppRegistry.setWrapperComponentProvider(function () {
  return class extends Component {
    static displayName = 'RootSiblingsWrapper';

    constructor(props) {
      super(props);
      this.state = {
        siblings: {}
      }
    }
    render(){
        const { siblings } = this.state;
        Object.keys(siblings).forEach((key) => {
        const element = siblings[key];
        element && elements.push(
          <StaticContainer
            key={`root-sibling-${key}`}
            shouldUpdate={!!this._updatedSiblings[key]}
          >
            {element}
          </StaticContainer>
        );
      });
      this._updatedSiblings = {};
        return (
        <View style={styles.container}>
          <StaticContainer shouldUpdate={false}>
            {this.props.children}
          </StaticContainer>
          {elements}
        </View>
      );
    }
}
})
```

## 3.x
3.x版本加入了redux的支持，简言之就是可以将store传入到组件中

```js
_update = (id, element, callback, store) => {
      const siblings = { ...this._siblings };
      const stores = { ...this._stores };
      if (siblings[id] && !element) {
        delete siblings[id];
        delete stores[id];
      } else if (element) {
        siblings[id] = element;
        stores[id] = store;
      }

      this._updatedSiblings[id] = true;
      this._siblings = siblings;
      this._stores = stores;
      this.forceUpdate(callback);
    };
```

这引起了一个问题就是对于没有使用redux的人，会造成多余的依赖，而且由于作者没有引入redux包，对于没有使用redux的人会产生redux不存在的报错。对于这个问题可以使用这位老哥的[pr](https://github.com/magicismight/react-native-root-siblings/pull/37)

简言之，使用redux的可以用户使用最新版本，没有使用的就是用2.3版本

## 参考文献:
[AppRegistry.setWrapperComponentProvider is not a function](https://github.com/magicismight/react-native-root-toast/issues/53)

[react-native-root-sibling](https://github.com/magicismight/react-native-root-siblings)