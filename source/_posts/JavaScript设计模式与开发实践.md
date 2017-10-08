title: JavaScript设计模式与开发实践
tags:
    - JavaScript
    - 设计模式
comments: true
brief: JavaScript设计模式与开发实践
date: 2017-10-7
categories:
    - 书评
---
# [评]JavaScript设计模式与开发实践
这本书介绍了14种常见的设计模式的js实现，并且都配备了代码的实现。适合所有想深入了解前端、js写一手好代码的人员。

<!-- more -->
![JavaScript设计模式与开发实践](resources/images/JavaScript设计模式与开发实践.png)

该书循序渐进的从设计模式需要使用的基础JS知识讲解起，然后介绍具体常用的14种设计模式，最后介绍设计模式遵循的一般准则。使读者循序渐进的提高代码的编写能力和组织技巧。书中还附有许多的实战例子，使读者能够更深入的认识设计模式的用途。

## 第一部分 基础知识
使用Object.create(null)可以创建一个没有原型的对象。

使用字面量的方式创建的原型是Object

构造器不显式地返回任何数据，或者是返回一个非对象类型的数据则返回的对象为this

高阶函数是指至少满足下列条件之一的函数。
- 函数可以作为参数被传递；
- 函数可以作为返回值输出。

函数节流，用于经常性调用的函数中，减少调用的次数
```js
var throttle = function(fn, interval) {
    var __self = fn, // 保存需要被延迟执行的函数引用
    timer, // 定时器
    firstTime = true;
    // 是否是第一次调用
    return function() {
        var args = arguments
          , __me = this;
        if (firstTime) {
            // 如果是第一次调用，不需延迟执行
            __self.apply(__me, args);
            return firstTime = false;
        }
        if (timer) {
            // 如果定时器还在，说明前一次延迟执行还没有完成
            return false;
        }
        timer = setTimeout(function() {
            // 延迟一段时间执行
            clearTimeout(timer);
            timer = null;
            __self.apply(__me, args);
        }, interval || 500);
    };
};
window.onresize = throttle(function() {
    console.log(1);
}, 500);
```

分时函数，一次性渲染大批量的数据造成浏览器卡死，应该使用延时函数分批量进行渲染。
```js
var timeChunk = function(ary, fn, count) {
    var obj, t;
    var len = ary.length;
    var start = function() {
        for (var i = 0; i < Math.min(count || 1, ary.length); i++) {
            var obj = ary.shift();
            fn(obj);
        }
    };
    return function() {
        t = setInterval(function() {
            if (ary.length === 0) {
                // 如果全部节点都已经被创建好
                return clearInterval(t);
            }
            start();
        }, 200);
        // 分批执行的时间间隔，也可以用参数的形式传入
    };
};

var ary = [];
for (var i = 1; i <= 1000; i++) {
    ary.push(i);
};
var renderFriendList = timeChunk(ary, function(n) {
    var div = document.createElement('div');
    div.innerHTML = n;
    document.body.appendChild(div);
}, 8);
renderFriendList();
```

惰性函数，第一次进入函数后改变函数的结构（解决如果不使用函数就没必要执行一遍逻辑）
```js
var addEvent = function(elem, type, handler) {
    if (window.addEventListener) {
        addEvent = function(elem, type, handler) {
            elem.addEventListener(type, handler, false);
        }
    } else if (window.attachEvent) {
        addEvent = function(elem, type, handler) {
            elem.attachEvent('on' + type, handler);
        }
    }
    addEvent(elem, type, handler);
};
```

## 第二部分 设计模式
### 单例模式
保证一个类仅有一个实例，并提供一个访问它的全局访问点。

当内层函数对象为null时调用函数生成对象，内层函数存在对象则返回对象
```js
var getSingle = function(fn) {
    var result;
    return function() {
        return result || (result = fn.apply(this, arguments));
    }
};

var createLoginLayer = function() {
    var div = document.createElement('div');
    div.innerHTML = '我是登录浮窗';
    div.style.display = 'none';
    document.body.appendChild(div);
    return div;
};

var createSingleLoginLayer = getSingle(createLoginLayer);
```

### 策略模式
定义一系列的算法，把它们一个个封装起来，并且使它们可以相互替换。

需要的数据类型一致，但获取数据的方式不一致时，可以使用该模式。如：
- 排序函数，返回值都为数值，但排序算法可以指定。
- 表单验证，验证的逻辑和内容可以不同，但是验证的结果都是返回布尔值用于判断是否满足条件

### 代理模式
代理模式是为一个对象提供一个代用品或占位符，以便控制对它的访问。强调控制对象的行为，添加附加操作。

- 虚拟代理：把一些开销很大的对象，延迟到真正需要它的时候才去创建。对于实时性不是很高的系统，可以将多个ajax合并一起发送。
- 缓存代理:可以为一些开销大的运算结果提供暂时的存储，在下次运算时，如果传递进来的参数跟之前一致，则可以直接返回前面存储的运算结果。

### 迭代器模式
迭代器模式是指提供一种方法顺序访问一个聚合对象中的各个元素，而又不需要暴露该对象的内部表示。

内部迭代器：内部迭代器已经完全定义好了迭代规则，完全接手整个迭代过程。each函数
外部迭代器：外部迭代器必须显式地请求迭代下一个元素。Iterator接口

迭代器模式只是规定循环访问一个聚合对象中的每个元素，但它没有规定顺序，因此实现迭代器可以有顺序、倒序、循环、终止(根据条件退出迭代)等等方式。

### 发布-订阅模式
发布—订阅模式又叫观察者模式，它定义对象间的一种一对多的依赖关系，当一个对象的状态发生改变时，所有依赖于它的对象都将得到通知。

JS中DOM事件就是发布-订阅模式

发布-订阅模式适合用于多个模块依据一个数据的状态的情况。例如：根据用户是否登录，改变各模块状态。
```js
$.ajax('http:// xxx.com?login', function(data) {
    // 登录成功
    login.trigger('loginSucc', data);
    // 发布登录成功的消息
});
var header = (function() {
    // header 模块
    login.listen('loginSucc', function(data) {
        header.setAvatar(data.avatar);
    });
    return {
        setAvatar: function(data) {
            console.log('设置 header 模块的头像');
        }
    }
})();
var nav = (function() {
    // nav 模块
    login.listen('loginSucc', function(data) {
        nav.setAvatar(data.avatar);
    });
    return {
        setAvatar: function(avatar) {
            console.log('设置 nav 模块的头像');
        }
    }
})();
```

### 命令模式
命令模式最常见的应用场景是:在请求的发起者有很多种可能，请求的接收者有很多种可能，请求有多种可能时。使用命令模式构成一个松耦合的关系。

如点击按钮触发菜单刷新就可以使用命令模式
```js
var RefreshMenuBarCommand = function(receiver) {
    return {
        execute: function() {
            receiver.refresh();
        }
    }
};
var setCommand = function(button, command) {
    button.onclick = function() {
        command.execute();
    }
};
var refreshMenuBarCommand = RefreshMenuBarCommand(MenuBar);
setCommand(button1, refreshMenuBarCommand);
```

### 组合模式
组合模式将对象组合成树形结构，以表示“部分整体”的层次结构。组合后的整体对象一般具有调用部分的方案。除了用来表示树形结构之外，组合模式的另一个好处是通过对象的多态性表现，使得用户对单个对象和组合对象的使用具有一致性

树形菜单中使用组合模式将直接子节点，放入父节点下构成一个整体以便共同操作。
```js
var TreeNode = function(name) {
    this.name = name;
    this.children = [];
};
TreeNode.prototype.add = function(node) {
    this.children.push(node);
};
TreeNode.prototype.scan = function() {
    console.log('显示节点名: ' + this.name);
    for (var i = 0, node, children = this.children; node = children[i++]; ) {
        node.scan();
    }
};
```

### 模板方法模式
模板方法模式由两部分结构组成，第一部分是抽象父类，第二部分是具体的实现子类。通常在抽象父类中封装了子类的算法框架，包括实现一些公共方法以及封装子类中所有方法的执行顺序。子类通过继承这个抽象类，也继承了整个算法结构，并且可以选择重写父类的方法。

为了保证重写未实现的模板方法，可以使用：1.类型检查，2.默认使用抛出异常的方式实现需要重写的方法

放置钩子是隔离变化的一种常见手段。我们在父类中容易变化的地方放置钩子

```js
var Beverage = function(param) {
    var boilWater = function() {
        console.log('把水煮沸');
    };
    var brew = param.brew || function() {
        throw new Error('必须传递 brew 方法');
    };
    var pourInCup = param.pourInCup || function() {
        throw new Error('必须传递 pourInCup 方法');
    };
    var addCondiments = param.addCondiments || function() {
        throw new Error('必须传递 addCondiments 方法');
    };
    var F = function() {};
    F.prototype.init = function() {
        boilWater();
        brew();
        pourInCup();
        if ( this.customerWantsCondiments() ){ // 如果挂钩返回 true，则需要调料
            this.addCondiments();
        }
    };
    return F;
};
var Coffee = Beverage({
    brew: function() {
        console.log('用沸水冲泡咖啡');
    },
    pourInCup: function() {
        console.log('把咖啡倒进杯子');
    },
    addCondiments: function() {
        console.log('加糖和牛奶');
    },
    customerWantsCondiments: function(){
        return window.confirm("请问需要加糖吗？");
    }
});
var coffee = new Coffee();
coffee.init();
```

当我们用模板方法模式编写一个程序时，就意味着子类放弃了对自己的控制权，而是改为父类通知子类，哪些方法应该在什么时候被调用,相当于好莱坞原则。

### 享元模式
享元模式要求将对象的属性划分为内部状态与外部状态（状态在这里通常指属性）。享元模式的目标是尽量减少共享对象的数量

- 内部状态存储于对象内部。
- 内部状态可以被一些对象共享。
- 内部状态独立于具体的场景，通常不会改变。
- 外部状态取决于具体的场景，并根据场景而变化，外部状态不能被共享。

使用对象池，减少创建对象的开销
```js
// 通用对象池创建工厂
var objectPoolFactory = function(createObjFn) {
    var objectPool = [];
    return {
        create: function() {
            var obj = objectPool.length === 0 ? createObjFn.apply(this, arguments) : objectPool.shift();
            return obj;
        },
        recover: function(obj) {
            objectPool.push(obj);
        }
    }
};
// iframe对象池
var iframeFactory = objectPoolFactory(function() {
    var iframe = document.createElement('iframe');
    document.body.appendChild(iframe);
    iframe.onload = function() {
        iframe.onload = null;
        // 防止 iframe 重复加载的 bug
        iframeFactory.recover(iframe);
        // iframe 加载完成之后回收节点
    }
    return iframe;
});
var iframe1 = iframeFactory.create();
iframe1.src = 'http:// baidu.com';
var iframe2 = iframeFactory.create();
iframe2.src = 'http:// QQ.com';
setTimeout(function() {
    var iframe3 = iframeFactory.create();
    iframe3.src = 'http:// 163.com';
}, 3000);
```

### 职责链模式
职责链模式的定义是：使多个对象都有机会处理请求，从而避免请求的发送者和接收者之间的耦合关系，将这些对象连成一条链，并沿着这条链传递该请求，直到有一个对象处理它为止。

请求发送者只需要知道链中的第一个节点，从而弱化了发送者和一组接收者之间的强联系。

```js
Function.prototype.after = function(fn) {
    var self = this;
    return function() {
        var ret = self.apply(this, arguments);
        if (ret === 'nextSuccessor') {
            return fn.apply(this, arguments);
        }
        return ret;
    }
};

var getActiveUploadObj = function() {
    try {
        // IE 上传控件
        return new ActiveXObject("TXFTNActiveX.FTNUpload");
    } catch (e) {
        return 'nextSuccessor';
    }
};
var getFlashUploadObj = function() {
    if (supportFlash()) {
        // Flash上传控件
        var str = '<object type="application/x-shockwave-flash"></object>';
        return $(str).appendTo($('body'));
    }
    return 'nextSuccessor';
};
var getFormUpladObj = function() {
    // 表单上传
    return $('<form><input name="file" type="file"/></form>').appendTo($('body'));
};
var getUploadObj = getActiveUploadObj.after(getFlashUploadObj).after(getFormUpladObj);
console.log(getUploadObj());
```

责任链模式不仅适用于顺序判断的结构，而且适合于多个对象处理一个对象的结构（组合处理对象构成责任链）

### 中介者模式
中介者模式的作用就是解除对象与对象之间的紧耦合关系。增加一个中介者对象后，所有的相关对象都通过中介者对象来通信，而不是互相引用，所以当一个对象发生改变时，只需要通知中介者对象即可。中介者使各对象之间耦合松散，而且可以独立地改变它们之间的交互。中介者模式使网状的多对多关系变成了相对简单的一对多关系。

中介者模式与发布-订阅模式相似都是对象与对象之间状态相关联的模型。发布-订阅模式是一个发送者多个接收者，关联逻辑接收者各自维护；中介者模式是多个发送者一个或多个接收者，需要管理关联逻辑。

货物购买示例：
```js
var goods = {
    // 手机库存
    "red|32G": 3,
    "red|16G": 0,
    "blue|32G": 1,
    "blue|16G": 6
};
var mediator = (function() {
    var colorSelect = document.getElementById('colorSelect'),
        memorySelect = document.getElementById('memorySelect'),
        numberInput = document.getElementById('numberInput'),
        colorInfo = document.getElementById('colorInfo'),
        memoryInfo = document.getElementById('memoryInfo'),
        numberInfo = document.getElementById('numberInfo'),
        nextBtn = document.getElementById('nextBtn');
    return {
        changed: function(obj) {
            var color = colorSelect.value, // 颜色
            memory = memorySelect.value, // 内存
            number = numberInput.value, // 数量
            stock = goods[color + '|' + memory];
            // 颜色和内存对应的手机库存数量
            if (obj === colorSelect) {
                // 如果改变的是选择颜色下拉框
                colorInfo.innerHTML = color;
            } else if (obj === memorySelect) {
                memoryInfo.innerHTML = memory;
            } else if (obj === numberInput) {
                numberInfo.innerHTML = number;
            }
            if (!color) {
                nextBtn.disabled = true;
                nextBtn.innerHTML = '请选择手机颜色';
                return;
            }
            if (!memory) {
                nextBtn.disabled = true;
                nextBtn.innerHTML = '请选择内存大小';
                return;
            }
            if (((number - 0) | 0) !== number - 0) {
                // 输入购买数量是否为正整数
                nextBtn.disabled = true;
                nextBtn.innerHTML = '请输入正确的购买数量';
                return;
            }
            nextBtn.disabled = false;
            nextBtn.innerHTML = '放入购物车';
        }
    }
})();
// 事件函数：
colorSelect.onchange = function() {
    mediator.changed(this);
};
memorySelect.onchange = function() {
    mediator.changed(this);
};
numberInput.oninput = function() {
    mediator.changed(this);
};
```

### 装饰者模式
装饰者模式可以动态地给某个对象添加一些额外的职责，而不会影响从这个类中派生的其他对象。

装饰者(decorator)能很好地描述这个模式，但从结构上看，包装器(wrapper)的说法更加贴切。装饰者模式将一个对象嵌入另一个对象之中，实际上相当于这个对象被另一个对象包装起来，形成一条包装链。

使用中间变量实现装饰模式存在两个问题：1.中间变量维护；2.this指向

AOP方式实现装饰器模式，原函数中的属性将会丢失
```js
Function.prototype.after = function(afterfn) {
    var __self = this;
    return function() {
        var ret = __self.apply(this, arguments);
        afterfn.apply(this, arguments);
        return ret;
    }
};

Function.prototype.before = function(beforefn) {
    var __self = this;
    return function() {
        beforefn.apply(this, arguments);
        return __self.apply(this, arguments);
    }
};
```

装饰器模式强调的是给装饰的对象添加新功能，代理模式强调的是控制对象的操作。

### 状态模式
状态模式的定义：允许一个对象在其内部状态改变时改变它的行为，对象看起来似乎修改了它的类。

toggle函数常用状态模式，在函数外部封装切换状态包含的逻辑，函数内部根据当前的状态调用对应的切换函数
```js
var Light = function() {
    this.currState = FSM.off;
    // 设置当前状态
    this.button = null;
};
Light.prototype.init = function() {
    var button = document.createElement('button')
      , self = this;
    button.innerHTML = '已关灯';
    this.button = document.body.appendChild(button);
    this.button.onclick = function() {
        self.currState.buttonWasPressed.call(self);
        // 把请求委托给 FSM 状态机
    }
};
var FSM = {
    off: {
        buttonWasPressed: function() {
            console.log('关灯');
            this.button.innerHTML = '下一次按我是开灯';
            this.currState = FSM.on;
        }
    },
    on: {
        buttonWasPressed: function() {
            console.log('开灯');
            this.button.innerHTML = '下一次按我是关灯';
            this.currState = FSM.off;
        }
    }
};
var light = new Light();
light.init();
```

### 适配器模式
适配器又称为包装器(wrapper)，适配器模式的作用是解决两个软件实体间的接口不兼容的问题。使用适配器模式之后，原本由于接口不兼容而不能工作的两个软件实体可以一起工作。

如果现有的接口已经能够正常工作，那我们就永远不会用上适配器模式。适配器模式是一种“亡羊补牢”的模式，没有人会在程序的设计之初就使用它。

## 第三部分 设计原则和编程技巧
### 单一职责原则
单一职责原则（SRP）的职责被定义为“引起变化的原因”。如果我们有两个动机去改写一个方法，那么这个方法就具有两个职责。每个职责都是变化的一个轴线，如果一个方法承担了过多的职责，那么在需求的变迁过程中，需要改写这个方法的可能性就越大。

在设计模式中体现该原则的模式有：代理模式、迭代器模式、单例模式(分离开单例创建和管理)和装饰器模式

### 最少知识原则
最少知识原则（LKP）说的是一个软件实体应当尽可能少地与其他实体发生相互作用。这里的软件实体是一个广义的概念，不仅包括对象，还包括系统、类、模块、函数、变量等。

使用最少知识原则的模式有：中介者模式、外观模式。

### 开放-封闭原则
开放-封闭原则的思想：当需要改变一个程序的功能或者给这个程序增加新功能的时候，可以使用增加代码的方式，但是不允许改动程序的源代码。

实现开放-封闭原则的方式：

- 对象的动态特性(鸭子函数)
- 放置挂钩(hook)，将判断封装一个函数，根据函数结果来判断是否执行条件。
- 回调函数，可以认为是一种特殊的挂钩。

设计模式就是给做的好的设计取个名字。几乎所有的设计模式都是遵守开放-封闭原则的，我们见到的好设计，通常都经得起开放封闭原则的考验。不管是具体的各种设计-模式，还是更抽象的面向对象设计原则，比如单一职责原则、最少知识原则、依赖倒置原则等，都是为了让程序遵守开放-封闭原则而出现的。

### 接口和面向接口编程
面向接口编程”其实是“面向超类型编程”。当对象的具体类型被隐藏在超类型身后时，这些对象就可以相互替换使用，我们的关注点才能从对象的类型上转移到对象的行为上。

### 代码重构
提炼函数，一个函数不应该过长
合并重复代码片段
将分支语句提炼成函数
多重try...catch提炼成循环
提前让函数退出
传递对象参数代替过长的参数列表
使用return退出内层循环，将剩余的代码提炼为函数