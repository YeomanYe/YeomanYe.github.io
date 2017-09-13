title: Python基础-语法
tags:
    - 语言
    - Python
comments: true
brief: Python基础-语法
date: 2017-08-20
categories:
    - Python
---
# Python基础-语法
这篇文章是对廖雪峰老师的python 3教程中python语法的笔记。廖雪峰老师的python基础教程不仅细致的讲解了python的语法、还点出了语法中的注意点、python常用的模块、python的面向对象和函数式编程以及一些周边。对廖雪峰老师的python基础教程分为四部分。一、语法；二、面向对象和函数式；三、语言机制关系密切的模块；四、常用模块。

[Python 3教程——廖雪峰](https://www.liaoxuefeng.com/wiki/0014316089557264a6b348958f449949df42a6d3a2e542c000)

<!-- more -->

## 基本语法
- 一般使用4个空格作为缩进
- 使用#作为注释
- r''表示''内部的字符串默认不转义
- 使用'''...'''格式表示多行内容,还可以在前面加r表示不转义
- 逻辑运算and,or,not
- 空值None,空值不是0
- 变量名必须是大小写英文、数字和_的组合
- //地板除,两个整数的地板除仍然是整数;/两个整数相处时浮点数

### 字符串
- 在计算机内存中，统一使用Unicode编码，当需要保存到硬盘或者需要传输的时候，就转换为UTF-8编码。
- \uxxxx表示对应的unicode编码的字符
- 无法显示为ASCII字符的字节，用\x##显示
- 将字符串变为bytes,x = b'ABC' 等效于x = 'ABC'.encode('ascii');只能用在ascii码方位的字符
- 函数就计算字节数,如果是list则返回元素个数
- 常用函数
    + int()转换字符串为整形
    + len()函数计算的是str的字符数，如果换成bytes，len()
    + str.encode('utf-8')转换编码为utf-8类型
    + str.decode('utf-8')解码
    + ord()函数用于获取字符的整数表示,chr()函数把编码转换为对应的字符
- 在开头加上以下两行注释使Python解释器按UTF-8解析源代码
    + 第一行告诉linux/os x系统这是一个可执行程序
    + 第二行告诉python解释器,按照utf-8读取源代码

```py
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
```

- python格式化字符串(%s永远起作用，它会把任何数据类型转换为字符串,用%%来表示一个%)

```py
'Hello, %s' % 'world'
#'Hello, world'
'Hi, %s, you have $%d.' % ('Michael', 1000000)
#'Hi, Michael, you have $1000000.'
```

### list和tuple
- list
- 可以使用负数从后往前获取list的元素,超出元素的范围也会越界
- 常用函数:
    + append()追加元素到list末尾
    + insert(1,'Jack')
    + pop(i)删除i位置的元素,pop()删除最后一个元素
- tuple(不能改变的list,更加安全)

```py
#表示只有一个元素,使用,来消除歧义
t = (1,);
```

### 条件判断
- if语句

```py
if <条件判断1>:
    <执行1>
elif <条件判断2>:
    <执行2>
elif <条件判断3>:
    <执行3>
else:
    <执行4>
```

可以使用这种形式的条件判断0 <= score <= 100

### 循环
- for...in循环,把list或tuple中的每个元素迭代出来

```py
sum = 0
for x in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]:
    sum = sum + x
print(sum)
```

- range(i)生成一个0-i的整数序列
- while循环,只要条件满足,就不断循环,条件不满足时退出循环。

```py
sum = 0
n = 99
while n > 0:
    sum = sum + n
    n = n - 2
print(sum)
```

### 使用dict和set
- dict的key必须是不可变对象

```py
d = {'Michael' : 98,'Bob' : 75,'Tracy' : 85};

d['Michael'] = 90;

#判断key是否存在
 'Thomas' in d
 #删除一个key
 d.pop('Bob')
```

- set

```py
s = set([1,2,3]);
#添加一个key到set之中
s.add(5);
#删除元素
s.remove(1);
#交并集操作
{1,2} & {2,3,4} #{1}
{1,2} | {2,3,4} #{1,2,3,4}
```

### 函数
- 函数名就是指向该函数的一个变量
- 默认参数一定要用不可变对象，如果是可变对象，程序运行时会有逻辑错误！
- 定义函数

```py
def my_abs(x):
    if x >= 0:
        return x
    else:
        return -x

#默认参数注意将必选参数置于前面
def enroll(name, gender, age=6, city='Beijing'):
    print('name:', name)
    print('gender:', gender)
    print('age:', age)
    print('city:', city)
enroll('Adam', 'M', city='Tianjin')

#可变参数,内部接收到一个tuple
def calc(*numbers):
    sum = 0
    for n in numbers:
        sum = sum + n * n
    return sum
tup = (1,2,3)
#list或tuple参数可以使用*的方式传递
calc(*tup);

#关键字可变参数
def person(name, age, **kw):
    print('name:', name, 'age:', age, 'other:', kw)
person('Adam', 45, gender='M', job='Engineer')
#name: Adam age: 45 other: {'gender': 'M', 'job': 'Engineer'}
extra = {'city': 'Beijing', 'job': 'Engineer'}
person('Jack', 24, **extra)

#命名关键字参数
def person(name, age, *, city, job):
    print(name, age, city, job)
#具有可变参数时，可以省略*
def person(name, age, *args, city = 'Beijing', job):
    print(name, age, args, city, job)
person('Jack', 24, job='Engineer')
```

- 默认参数陷阱

```py
def add_end(L=[]):
    L.append('END')
    return L
'''
Python函数在定义的时候，默认参数L的值就被计算出来了，即[]，因为默认参数L也是一个变量，它指向对象[]，每次调用该函数，如果改变了L的内容，则下次调用时，默认参数的内容就变了，不再是函数定义时的[]了。
'''
add_end()
#['END']
add_end()
#['END','END']
```

- 尾递归优化
    1. 在函数返回的时候调用自身本身
    2. 并且return语句不能包含表达式

## 高级特性
### 切片操作
- 可以使用在在list,tuple或字符串上

```py
L = ['Miichael','Tony','Tom']
L[0:3];
L[:3]
#['Michael', 'Tony', 'Tom']

L[-2:]
#['Tony','Tom']
L[-2:-1]
#['Tony']

L = list(range(100))
#取前10个数，每两个取一个
L[:10:2]
#所有数每5个取一个
L[::5]
```

### 迭代
- 迭代所有可迭代的对象(包括字符串,dict)

```py
d = {'a' : 1 , 'b' : 2 , 'c' : 3};
#迭代key
for key in d:
#迭代value
for value in d.values():
#迭代key,value
for key,value in d.items():
#迭代出每一个字符
for ch in 'ABC'
#对list类型实现下标循环
for i, value in enumerate(['A', 'B', 'C']):
#同时引用两个对象
for x, y in [(1, 1), (2, 4), (3, 9)]:
```

- 判断可迭代对象的方法

```py
from collections import Iterable
isinstance('abc', Iterable) # str是否可迭代
```

### 列表生成式

```py
for x in range(1,11):
    L.append(x * x)
#等价于
[x * x for x in range(1,11)]

#if语句
[x * x for x in range(1,11) if x % 2 == 0]
#嵌套for语句
[m + n for m in 'ABC' for n in 'XYZ']
#使用两个变量生成list
d = {'x':'A','y':'B','z':'C'}
[k + '=' + v for k,v in d.items()]
```

### 生成器
- 在循环的过程中不断推算出后续的元素,这样就不必创建完整的list，从而节省大量的空间。这种一边循环一边计算的机制，称为生成器：generator
- 生成器创建

```py
#1.列表生成式改为()
g = (x * x for x in range(10))
#可以使用next()获得下一个值,可以使用迭代器
next(g)
for n in g:
    print(n)

#2.使用函数方案,包含yield关键字
#''
'''
函数是顺序执行，遇到return语句或者最后一行函数语句就返回。而变成generator的函数，在每次调用next()的时候执行，遇到yield语句返回，再次执行时从上次返回的yield语句处继续执行
'''
def fib(max):
    n, a, b = 0, 0, 1
    while n < max:
        yield b
        a, b = b, a + b
        n = n + 1
    return 'done'
f = fib(6)
'''
用for循环调用generator时，发现拿不到generator的return语句的返回值。如果想要拿到返回值，必须捕获StopIteration错误，返回值包含在StopIteration的value中
'''
 while True:
     try:
         x = next(g)
         print('g:', x)
     except StopIteration as e:
         print('Generator return value:', e.value)
         break
```

- 可以被for循环调用的被称为Iterable可迭代对象
- 可以使用next()函数调用的是Iterator对象
- 将list、dict、str等Iterable变成Iterator对象可以使用iter()函数
- Iterator对象表示的是一个数据流，Iterator对象可以被next()函数调用并不断返回下一个数据，直到没有数据时抛出StopIteration错误。可以把这个数据流看做是一个有序序列，但我们却不能提前知道序列的长度，只能不断通过next()函数实现按需计算下一个数据，所以Iterator的计算是惰性的，只有在需要返回下一个数据时它才会计算。

## 模块
- python使用包结构管理模块,每一个包中必须有一个`__init__.py`文件代表整个包模块
- 自己创建的模块名不能和Python自带的模块名起冲突

![python包示意图](resources/images/python包示意图.png)

- 文件www.py的模块名就是mycompany.web.www，两个文件utils.py的模块名分别是mycompany.utils和mycompany.web.utils。
- 使用模块

```py
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#表示模块的文档注释，任何模块代码的第一个字符串都被视为模块的文档注释；
' a test module '
#作者的名字
__author__ = 'Michael Liao'

import sys

def test():
    #argv表示命令行参数的list
    #第一个参数代表文件名
    args = sys.argv
    if len(args)==1:
            print('Hello, world!')
    elif len(args)==2:
        print('Hello, %s!' % args[1])
    else:
        print('Too many arguments!')
#当我们在命令行运行hello模块文件时，Python解释器把一个特殊变量__name__置为__main__，而如果在其他地方导入该hello模块时，if判断将失败
if __name__=='__main__':
    test()
```

- 模块搜索路径

```py
import sys
sys.path
#添加模块搜索路径,运行完成后失效
sys.path.append('/Users/michael/my_py_scripts')
```

- 设置环境变量PYTHONPATH，该环境变量的内容会被自动添加到模块搜索路径中。设置方式与设置Path环境变量类似。注意只需要添加你自己的搜索路径，Python自己本身的搜索路径不受影响。
- 通过前缀_实现变量的私有,类似`_xxx`和`__xxx`这样的函数或变量就是非公开的（private），不应该被直接引用，比如_abc，`__abc`等。这只是人为的约定，并非内部机制实现

## 错误处理
错误处理中除了本身的语法与java错误处理不同外，还多加了一个else分支，用于在错误未发生 时运行。

```py
try:
    print('try...')
    r = 10 / int('2')
    print('result:', r)
#错误也是类,所有错误继承自BaseException
except ValueError as e:
    print('ValueError:', e)
except ZeroDivisionError as e:
    print('ZeroDivisionError:', e)
#没错错误发生时,会执行else语句
else:
    print('no error!')
finally:
    print('finally...')
print('END')
```

抛出错误，使用raise

```py
# err_raise.py
class FooError(ValueError):
    pass

def foo(s):
    n = int(s)
    if n==0:
        #抛出异常类的实例
        raise FooError('invalid value: %s' % s)
    return 10 / n

foo('0')
```