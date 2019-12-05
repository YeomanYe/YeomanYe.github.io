title: Python基础-面向对象和函数式
tags:
    - 语言
    - Python
comments: true
brief: Python基础-面向对象和函数式
date: 2017-08-24
categories:
    - Python
---
# Python基础-面向对象和函数式
这篇文章是对廖雪峰老师的python 3教程中python面向对象和函数相关章节的笔记。廖雪峰老师的python基础教程不仅细致的讲解了python的语法、还点出了语法中的注意点、python常用的模块、python的面向对象和函数式编程以及一些周边。对廖雪峰老师的python基础教程分为四部分。一、语法；二、面向对象和函数式；三、语言机制关系密切的模块；四、常用模块。

[Python 3教程](https://www.liaoxuefeng.com/wiki/0014316089557264a6b348958f449949df42a6d3a2e542c000)

<!-- more -->

## 面向对象
### 类和实例
python类的定义，使用了`__init__`函数就不能使用默认的构造函数了，构造函数的多态可以使用默认值的方式来模拟。

```py
#类定义
#(object)表示继承的类
class Student(object):
    #类属性
    #相同名字的实例属性将覆盖类属性
    name = 'Student'
    #self表示创建的实例本身
    #和普通的函数相比，在类中定义的函数只有一点不同，就是第一个参数永远是实例变量self。
    #并且，调用时，不用传递该参数。除此之外，类的方法和普通函数没有什么区别，所以，你仍然可以用默认参数、可变参数、关键字参数和命名关键字参数。
    def __init__(self, name, score):
        self.name = name
        self.score = score
#声明对象,创建了__init__就不能使用Student()创建对象
stu1 = Student('Tom',98)
#给对象加属性
stu1.age = 18
```

让内部属性不被外部访问，可以把属性的名称前加上两个下划线`__`，在Python中，实例的变量名如果以`__`开头，就变成了一个私有变量（private），只有内部可以访问，外部不能访问(语言机制实现的:通过将变量重命名为`_ClassName__name`)

### 获取对象类型
使用type和isinstance获取类型

```py
#type()返回对象对应的类型
type('abc') == str
#判断是否为函数
type(fn)==types.FunctionType
type(abs)==types.BuiltinFunctionType
type(lambda x: x)==types.LambdaType
type((x for x in range(10)))==types.GeneratorType

#使用isinstance()
isinstance(d,Dog)
#基本类型判断
isinstance(b'a', bytes)
isinstance(123, int)
isinstance('a', str)
#判断是否是list或tuple
isinstance((1, 2, 3), (list, tuple))
```

- 获取所有属性和方法
- 在len()函数内部，它自动去调用该对象的`__len__`()方法，所以

```py
dir('ABC')
#['__add__', '__class__', '__contains__', '__delattr__', '__dir__', '__doc__', '__eq__', '__format__', '__ge__', '__getattribute__', '__getitem__', '__getnewargs__', '__gt__', '__hash__', '__init__', '__iter__', '__le__', '__len__', '__lt__', '__mod__', '__mul__', '__ne__', '__new__', '__reduce__', '__reduce_ex__', '__repr__', '__rmod__', '__rmul__', '__setattr__', '__sizeof__', '__str__', '__subclasshook__', 'capitalize', 'casefold', 'center', 'count', 'encode', 'endswith', 'expandtabs', 'find', 'format', 'format_map', 'index', 'isalnum', 'isalpha', 'isdecimal', 'isdigit', 'isidentifier', 'islower', 'isnumeric', 'isprintable', 'isspace', 'istitle', 'isupper', 'join', 'ljust', 'lower', 'lstrip', 'maketrans', 'partition', 'replace', 'rfind', 'rindex', 'rjust', 'rpartition', 'rsplit', 'rstrip', 'split', 'splitlines', 'startswith', 'strip', 'swapcase', 'title', 'translate', 'upper', 'zfill']
```

- 使用getattr()、setattr()以及hasattr()，我们可以直接操作一个对象的状态

```py
hasattr(obj, 'y') # 有属性'y'吗？
setattr(obj, 'y', 19) # 设置一个属性'y'
#试图获取不存在的属性会报错
getattr(obj, 'y') # 获取属性'y'
getattr(obj, 'z', 404) # 获取属性'z'，如果不存在，返回默认值404
```

## 面向对象高级编程
### 使用`__slots__`
- Python允许在定义class的时候，定义一个特殊的`__slots__`变量，来限制该class实例能添加的属性

```py
class Student(object):
    #仅对当前类起作用对继承的子类不起作用
    __slots__ = ('name','age') # 用tuple定义允许绑定的属性名称
```

### 使用@property
- Python内置的@property装饰器就是负责把一个方法变成属性调用的

```py
class Student(object):

    @property
    def score(self):
        return self._score
    #@property创建了一个@score.setter用于把setter方法变成属性赋值
    #自定义getter(在getter上加@property)而不定义setter就是只读属性
    @score.setter
    def score(self, value):
        if not isinstance(value, int):
            raise ValueError('score must be an integer!')
        if value < 0 or value > 100:
            raise ValueError('score must between 0 ~ 100!')
        self._score = value
```

### 多重继承
- 需要"混入"(MixIn)额外的功能，通过多重继承就可以实现

```py
#多重继承实现的混入
class Dog(Mammal, RunnableMixIn, CarnivorousMixIn):
    pass
```

### 定制类
- 看到类似`__slots__`这种形如`__xxx__`的变量或者函数名就要注意，这些在Python中是有特殊用途的。
- `__len__()`方法我们也知道是为了能让class作用于len()函数。
- `__str__()`返回用户看到的字符串,使用print()打印时调用的函数
- `__repr__()`返回开发者看到的字符串,使用直接在打印对象时显示

```py
class Student(object):
    def __init__(self, name):
        self.name = name
    def __str__(self):
        return 'Student object (name=%s)' % self.name
    __repr__ = __str__
```

- `__iter__()`方法,使该类可以被用于for...in循环
- `__next__()`方法,Python的for循环就会不断调用该迭代对象的`__next__()`方法拿到循环的下一个值，直到遇到StopIteration错误时退出循环。

```py
class Fib(object):
    def __init__(self):
        self.a, self.b = 0, 1 # 初始化两个计数器a，b

    def __iter__(self):
        return self # 实例本身就是迭代对象，故返回自己

    def __next__(self):
        self.a, self.b = self.b, self.a + self.b # 计算下一个值
        if self.a > 100000: # 退出循环的条件
            raise StopIteration();
        return self.a # 返回下一个值
```

- `__getitem__()`方法,表现得像list那样按照下标取出元素(如果把对象看成dict，`__getitem__()`的参数也可能是一个可以作key的object，例如str);与之对应的还有`__setitem__()`方法,用于像list那样设置某个元素,`__delitem__()`方法,用于删除某个元素

```py
class Fib(object):
    def __getitem__(self, n):
        if isinstance(n, int): # n是索引
            a, b = 1, 1
            for x in range(n):
                a, b = b, a + b
            return a
        #还没有对step参数做处理
        if isinstance(n, slice): # n是切片
            start = n.start
            stop = n.stop
            if start is None:
                start = 0
            a, b = 1, 1
            L = []
            for x in range(stop):
                if x >= start:
                    L.append(a)
                a, b = b, a + b
            return L
f[0:5]
```

- `__getattr__()`方法,用于动态返回一个不存在的属性(只有没有的属性才会调用)

```py
class Student(object):

    def __init__(self):
        self.name = 'Michael'

    def __getattr__(self, attr):
        if attr=='score':
            return 99
        if attr=='age':
            return lambda: 25
        raise AttributeError('\'Student\' object has no attribute \'%s\'' % attr)
s.score
s.age()
```

- `__call__()`在实例本身调用方法(把实例当作一个方法)

```py
class Student(object):
    def __init__(self, name):
        self.name = name

    def __call__(self):
        print('My name is %s.' % self.name)
s = Student('Michael')
s()
#判断一个对象是否能被调用
callable(s)#true
```

### 使用枚举类
- 枚举常量

```py
from enum import Enum

Month = Enum('Month', ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'))

for name, member in Month.__members__.items():
    #value属性则是自动赋给成员的int常量，默认从1开始计数
    print(name, '=>', member, ',', member.value)
#Jan => Month.Jan , 1
#Feb => Month.Feb , 2
#...
```

- 派生枚举类

```py
from enum import Enum, unique
#@unique装饰器可以帮助我们检查没有重复的值
@unique
class Weekday(Enum):
    Sun = 0 # Sun的value被设定为0
    Mon = 1
    Tue = 2
    Wed = 3
    Thu = 4
    Fri = 5
    Sat = 6
#访问枚举类型的方法
day1 = Weekday.Mon
day2 = Weekday['Mon']
day7 = Weekday(7)
print(day1)#Weekday.Mon
print(day1 == Weekday.Mon)#True
```

### 使用元类
- 类的类型是type
- class的定义是运行时动态创建的，而创建class的方法就是使用type()函数
- 使用type创建类型

```py
def fn(self,name = 'world'):
    print('Hello, %s' % name)
'''
1.对象名称
2.继承的父类,tuple写法
3.class的方法名称与函数绑定，这里我们把函数fn绑定到方法名hello上。
'''
Hello = type('Hello', (object,), dict(hello=fn)) # 创建Hello class
```

- 通过type()函数创建的类和直接写class是完全一样的，因为Python解释器遇到class定义时，仅仅是扫描一下class定义的语法，然后调用type()函数创建出class。

使用metaclass创建类

```py
# metaclass是类的模板，所以必须从`type`类型派生：
class ListMetaclass(type):
    '''
    cls:当前准备创建的类对象
    name:类的名称
    bases:类继承的父类集合
    attrs:类的方法集合
    '''
    def __new__(cls, name, bases, attrs):
        attrs['add'] = lambda self, value: self.append(value)
        return type.__new__(cls, name, bases, attrs)
#当我们传入关键字参数metaclass时，魔术就生效了，
#它指示Python解释器在创建MyList时，要通过ListMetaclass.__new__()来创建
class MyList(list, metaclass=ListMetaclass):
    pass
```

## 函数式编程
### 高阶函数
高阶函数，接收另一个函数作为参数的函数或返回一个函数的函数。

map()函数接收两个参数，一个是函数，一个是Iterable，map将传入的函数依次作用到序列的每个元素，并把结果作为新的Iterator返回

```py
#list()将Iterator变为list
list(map(str, [1, 2, 3, 4, 5, 6, 7, 8, 9]))
#['1', '2', '3', '4', '5', '6', '7', '8', '9']
```

reduce把一个函数作用在一个序列[x1, x2, x3, ...]上，这个函数必须接收两个参数，reduce把结果继续和序列的下一个元素做累积计算

```py
def fn(x,y):
    return x + y
reduce(fn,[1,3,5,7,9])
#25
```

应用，字符串转化为数字函数

```py
from functools import reduce

def str2int(s):
    def fn(x, y):
        return x * 10 + y
    def char2num(s):
        return {'0': 0, '1': 1, '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7, '8': 8, '9': 9}[s]
    return reduce(fn, map(char2num, s))
```

- filter()把传入的函数依次作用于每个元素，然后根据返回值是True还是False决定保留还是丢弃该元素,返回的也是一个Iterator

```py
#判断是否回文数,如:989,121这样
def is_palindrome(n):
    return int(str(n)[::-1]) == n
# 测试:
output = filter(is_palindrome, range(1, 1000))
print(list(output))
```

sorted()默认从小到大排序,它还可以接收一个key函数来实现自定义的排序,第三个参数可以反转排序

```py
sorted(['bob', 'about', 'Zoo', 'Credit'],cmp=None, key=str.lower, reverse=True)
#['Zoo', 'Credit', 'bob', 'about']

#字母顺序排序
L = [('Bob', 75), ('Adam', 92), ('Bart', 66), ('Lisa', 88)]

def by_name(t):
    return t[0]

L2 = sorted(L, key=by_name)
print(L2)
```

### 闭包
与js相似的闭包概念

```py
#不使用f嵌套g,最后的结果都是9
#返回的函数引用了变量i,但它并非立刻执行。等到3个函数都返回时，它们所引用的变量i已经变成了3，因此最终结果为9。
def count():
    def f(j):
        def g():
            return j*j
        return g
    fs = []
    for i in range(1, 4):
        fs.append(f(i)) # f(i)立刻被执行，因此i的当前值被传入f()
    return fs
f1, f2, f3 = count()
```

### 匿名函数
使用lambda表达式(函数体只能有一个表达式,返回值就是该表达式的结果)

```py
list(map(lambda x: x * x, [1, 2, 3, 4, 5, 6, 7, 8, 9]))
#[1, 4, 9, 16, 25, 36, 49, 64, 81]

#lambda表达式就是一个函数对象
f = lambda x: x * x
```

### 装饰器
函数对象有一个`__name__`属性可以拿到函数的名字
python的@语法，类似于面向切面编程

```py
import functools

def log(text):
    def decorator(func):
        #用于将函数的签名如__name__属性复制到wraps中
        @functools.wraps(func)
        def wrapper(*args, **kw):
            print('%s %s():' % (text, func.__name__))
            return func(*args, **kw)
        return wrapper
    return decorator
#把@log放到now()函数的定义处，相当于执行了语句now = log('execute')(now)
@log('execute')
def now():
    print('2015-3-25')
#execute now():
#2015-3-25
```

- 可选参数的装饰器

```py
# -*-coding:utf-8-*-
import functools

def log(set_in=None):
                                    #装饰器参数为：可选
                                    #默认结构为：  带输出信息的三层装饰器结构
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args,**kw):
            #判断set_in是否为函数
            if callable(set_in):
                print('call: %s' % func.__name__)
            else:
                print('call(\'%s\'): %s' %(set_in,func.__name__))
            return func(*args,**kw)
        return wrapper
    if callable(set_in):            #如果传入的set_in是函数
        return decorator(set_in)    #把函数作为参数传给decorator，逻辑上减少一层级
    else:
        return decorator            #如果传入的set_in非函数，decorator默认参数会自动获得函数

@log
def test1():
    print('func 1 inside')

@log('another test:')
def test2():
    print('func 2 inside')

test1()
test2()
```

### 偏函数
偏函数，把一个函数的某些参数给固定住，使得函数的使用更加简单

```py
def int2(x,base = 2):
    return int(x,base)
#等价于
import functools
#functools.partial的作用就是，把一个函数的某些参数给固定住（也就是设置默认值），返回一个新的函数，调用这个新函数会更简单。
int2 = functools.partial(int,base = 2)

#实际上会把10作为*args的一部分自动加到左边
max2 = functools.partial(max, 10)
max2(5, 6, 7)
#相当于
args = (10, 5, 6, 7)
max(*args)
```
