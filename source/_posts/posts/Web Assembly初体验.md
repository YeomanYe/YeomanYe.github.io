title: Web Assembly初体验
tags:
    - 前端
comments: true
brief: Web Assembly初体验
copyright: true
date: 2018-10-27
categories:
    - 前端
---
# Web Assembly初体验
WebAssembly是一种运行在现代网络浏览器中的新型代码并且提供新的性能特性和效果。它设计的目的不是为了手写代码而是为诸如C、C++和Rust等低级源语言提供一个高效的编译目标。你可以在不知道如何编写WebAssembly代码的情况下就可以使用它。WebAssembly的模块可以被导入的到一个网络app（或Node.js）中，并且暴露出供JavaScript使用的WebAssembly函数。

简单来说Web Assembly是一个将原生编译型语言（如：c/c++、rust）经过特殊方式编译（Emscripten）后得到的文件（.wasm），让js环境直接能够运行的规范。当然除了简单的运行外，还能够将js注入到编译型语言中供c/c++等环境调用；以及得到原生环境的内存区，进行内存级的操作。

<!-- more -->

![emscripten-diagram](emscripten-diagram.png)

这里提一嘴Asm.js。Asm.js是一个JavaScript的一个严格的子集，可以被用来作为一个底层的、高效的编译器目标语言。具体来说，就是通过VM（如Emscripten）把一些本地代码（如C语言）生成的VM字节码（bytecode）翻译成前述严格子集的JS代码得以在Web上运行，并通过浏览器的支持，得到性能优化。asm.js是在WebAssembly出现之前，将编译型语言集成到浏览器上的一个尝试。asm.js的编译也是使用的Emscripten。

## 运行准备
### 环境搭建
使用WebAssembly自然是少不了环境(Emscripten)的安装，各个平台的安装方法可以参考[文档](http://kripken.github.io/emscripten-site/docs/getting_started/downloads.html)

除了本地安装环境编译以外，还可以通过使用在线的平台运行查看。在线的平台有:[WasmFiddle](https://wasdk.github.io/WasmFiddle/?j1noa)、[WasmExplorer](http://mbebenita.github.io/WasmExplorer/)

个人比较推荐WasmFiddle，虽然WasmFiddle界面简陋，但是它不仅能够查看编译结果，还能够加入js代码，以及查看运行结果。而WasmExplorer虽然界面华丽但不能看到运行结果，只能查看编译结果。

### 代码编写
写个简单的c代码用于运行测试，如：

```c
#include <stdio.h>
#include <emscripten/emscripten.h>

int main(int argc, char ** argv){
    printf("Hello World\n");
}

#ifdef __cplusplus
extern "C" {
#endif

int EMSCRIPTEN_KEEPALIVE myFunction(int argc, char ** argv) {
  printf("我的函数已被调用\n");
}

#ifdef __cplusplus
}
#endif
```

默认情况下，Emscripten 生成的代码只会调用 main() 函数，其它的函数将被视为无用代码。在一个函数名之前添加 EMSCRIPTEN_KEEPALIVE 能够防止这样的事情发生。你需要导入 emscripten.h 库来使用 EMSCRIPTEN_KEEPALIVE。

以上是mdn的解释，然而我在测试的时候发现，不加EMSCRIPTEN_KEEPALIVE宏也不会有问题，不知道是不是Emscripten已经做了处理。

加入`#ifdef`是为了保证在c++下能被识别为c代码，使其正常工作。

### 编译

```sh
emcc test.c -s WASM=1 -o test.html
```

-s WASM=1 — 指定我们想要的wasm输出形式。如果我们不指定这个选项，Emscripten默认将只会生成asm.js。
-o hello.html — 指定这个选项将会生成HTML页面来运行我们的代码，并且会生成wasm模块以及编译和实例化wasm模块所需要的“胶水”js代码，这样我们就可以直接在web环境中使用了。


## 载入wasm
载入wasm到web端，可以使用标签`<script src="abc.wasm" type="module"/>`，然而浏览器对该标签的支持并不好。因此要想载入wasm就只能通过请求来载入wasm。比如下面这种方式：

```js
function fetchAndInstantiateWasm(url, imports) {
    return fetch(url) // url could be your .wasm file
        .then(res => {
            if (res.ok)
                return res.arrayBuffer();
            throw new Error(`Unable to fetch Web Assembly file ${url}.`);
        })
        .then(bytes => WebAssembly.compile(bytes))
        .then(module => WebAssembly.instantiate(module, imports || {}))
        .then(instance => instance.exports);
}
```

通过fetch取得二进制字节流后，将其转为ArrayBuffer，利用WebAssembly.compile来产生WebAssembly模块，接着通过WebAssembly.instantiate来产生模块实例，最后的instance.exports就是我们在wasm中导出出来的物件或函数。

instantiate具有两种重载
```js
//直接使用二进制代码
Promise<ResultObject> WebAssembly.instantiate(bufferSource, importObject);
//使用模块对象
Promise<WebAssembly.Instance> WebAssembly.instantiate(module, importObject);
```

默认情况下我们应该用使用模块对象作为参数的第二个重载，因为模块对象可以通过Web Worker进行传递，还能存储在IndexedDB中，避免日后多次编译。

如果打开了WasmFiddle的还会发现，里面的加载方式是这样写的
```js
var wasmModule = new WebAssembly.Module(wasmCode);
var wasmInstance = new WebAssembly.Instance(wasmModule, wasmImports);
log(wasmInstance.exports.main());
```

其实这只是wasm加载的同步实现，`WebAssembly.Module`是`WebAssembly.compile`的同步版，`WebAssembly.Instance`是`WebAssembly.instantiate`的同步版


使用方式
```js
fetchAndInstantiateWasm('add.wasm', {})
    .then(m => {
        console.log(m.add(5, 10)); // 15
    });
```

## 在WebAssembley中使用js
也就是在为编译过的C中申明对应的js方法，然后在实例化wasm这一步(即调用该函数`WebAssembly.instantiate`)，通过第二个参数对象的env属性进行js的连接。具体为：
```c
#include <math.h>

void jsLog(int num);
int add(int num1, int num2) {
    int r = num1 + num2;
    jsLog(r);
    return r;
}
```
函数连接
```js
fetchAndInstantiateWasm('./add.wasm'， {
    env: {
        jsLog： num => console.log(num + 1)
    }
})
.then(m => {
    m.add(5,3) // 打开console.log看到输出9
})
```

## 操作内存
### 读取内存
读取内存通过Types Array api来获取内存缓冲区的内容，并利用TextDecoder来对文本解码
```js
fetchAndInstantiateWasm('./program.wasm')
.then(wasmModule => {
    const memory = wasmModule.memory;
    const strBuf = new Uint8Array(memory.buffer, wasmModule.getStrOffset(), 11);
    const str = new TextDecoder().decode(strBuf);
    console.log(str);
})
```

### 写入内存
写入内存则是反过来，使用TextEncoder对文本进行编码后，再使用Types Array将内存缓冲区映射为数组，最后将内容赋给该数组即可。

```js
fetchAndInstantiateWasm('./program.wasm')
    .then(wasmModule => {
        const strBuf = new TextEncoder().encode("Hello Web Assembly");
        const outBuf = new Uint8Array(wasmModule.memory.buffer,  wasmModule.getInStrOffset(), strBuf.length);
        for (let i = 0; i < strBuf.length; i++) {
            outBuf[i] = strBuf[i];
        }
    })
```

## 参考文献

[WebAssembly的基础用法](https://blog.csdn.net/sinat_34070003/article/details/80291178)

[wasm-intro](https://github.com/guybedford/wasm-intro/blob/master/5-writing-wasm-memory/test.html)

[MDN](https://developer.mozilla.org/zh-CN/docs/WebAssembly/Concepts)

[asm.js 和 Emscripten 入门教程](http://www.ruanyifeng.com/blog/2017/09/asmjs_emscripten.html#h5o-16)