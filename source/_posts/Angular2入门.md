title: Angular2入门
tags:
    - Angular
    - 前端框架
comments: true
brief: Angular入门概览
date: 2017-06-24
categories:
    - 前端
---
# Angular2入门
Angular 是一个用 HTML 和 JavaScript 或者一个可以编译成 JavaScript 的语言（例如 Dart 或者 TypeScript ），来构建客户端应用的框架。

本文介绍Angular的相关概念，使用方式。使读者对Angular有一个大致的了解，以便能够快速上手Angular。

<!-- more -->

编写Angular应用：用 Angular 扩展语法编写 HTML 模板(模板表达式、指令)， 用组件类管理这些模板，用服务添加应用逻辑，用路由跳转视图，用模块打包发布组件与服务。

![架构概览](overview.png)

## 模块
Angular 模块（无论是根模块还是特性模块）都是一个带有@NgModule装饰器的类。(@NgModule是元数据)

NgModule是一个装饰器函数，它接收一个用来描述模块属性的元数据对象。其中最重要的属性是：
- declarations - 声明本模块中拥有的视图类。Angular 有三种视图类：组件、指令和管道。
- exports - declarations 的子集，可用于其它模块的组件模板。
- imports - 本模块声明的组件模板需要的类所在的其它模块。
- providers - 服务的创建者，并加入到全局服务列表中，可用于应用任何部分。
- bootstrap - 指定应用的主视图（称为根组件），它是所有其它视图的宿主。只有根模块才能设置bootstrap属性。

## 组件
组件负责控制屏幕上的一小块称之为视图的区域

```ts
import { Component,OnInit } from '@angular/core';

import { Hero } from './hero';
import { HeroService } from './hero.service';

@Component({
    selector:'my-dashboard',
    // template:'<h3>My Dashboard</h3>',
    templateUrl:'./dashboard.component.html',
    styleUrls:['./dashboard.component.css'],
    providers:[HeroService]

})
export class DashboardComponent implements OnInit{
    heroes:Hero[] = [];
    constructor(private heroService:HeroService){}
    ngOnInit():void{
        this.heroService.getHeroes().then(heroes => this.heroes = heroes.slice(1,5));
    }
}
```

生命周期钩子OnInit挂钩组件初始化

## 模板
通过组件的自带的模板来定义组件视图。模板以 HTML 形式存在，告诉 Angular 如何渲染组件。

模板除了可以使用标准的html语法外，还可以使用angular特有的模板语法。

```html
<h2>Hero List</h2>
<p><i>Pick a hero from the list</i></p>
<ul>
  <li *ngFor="let hero of heroes" (click)="selectHero(hero)">
    {{hero.name}}
  </li>
</ul>
<hero-detail *ngIf="selectedHero" [hero]="selectedHero"></hero-detail>
```

&#123;&#123;...&#125;&#125;代表插值表达式，内部的值会被展开运算，不能使用会起副作用的运算符(如：+=、++），具有新的运算符(|、?、!)。上下文为组件上下文。

## 数据绑定
![数据绑定](databinding.png)

前三种为单向，最后一种为双向。

```html
<li>{{hero.name}}</li>
<hero-detail [hero]="selectedHero"></hero-detail>
<li (click)="selectHero(hero)"></li>
<input [(ngModel)]="hero.name">
```

## 指令
Angular 模板是动态的。当 Angular 渲染它们时，它会根据指令提供的操作对 DOM 进行转换。

指令分为结构型和属性形两类。

```html
<!-- 结构型 -->
<li *ngFor="let hero of heroes"></li>
<hero-detail *ngIf="selectedHero"></hero-detail>
<!-- 属性型 -->
<input [(ngModel)]="hero.name">
```

除此之外还有像ngSwitch、ngClass、ngStyle等指令，用户也可以自定义指令。

## 服务
服务是一个类，具有专注的、明确的用途。它应该做一件特定的事情，并把它做好。

```ts
// 声明为可注入的函数
@Injectable()
export class HeroService {
  private heroes: Hero[] = [];

// 注入服务
  constructor(
    private backend: BackendService,
    private logger: Logger) { }

  getHeroes() {
    this.backend.getAll(Hero).then( (heroes: Hero[]) => {
      this.logger.log(`Fetched ${heroes.length} heroes.`);
      this.heroes.push(...heroes); // fill cache
    });
    return this.heroes;
  }
}
```

要想使用依赖注入还需要使用providers将它注册在组件上或者根模块上。

## 路由器
大多数带路由的应用都要在index.html的`<head>`标签下先添加一个`<base>`元素，来告诉路由器该如何合成导航用的URL。

### 路由配置
每个带路由的Angular应用都有一个Router（路由器）服务的单例对象。 当浏览器的URL变化时，路由器会查找对应的Route（路由），并据此决定该显示哪个组件。

```ts
const appRoutes: Routes = [
  { path: 'crisis-center', component: CrisisListComponent },
  { path: 'hero/:id',      component: HeroDetailComponent },
  {
    path: 'heroes',
    component: HeroListComponent,
    data: { title: 'Heroes List' }
  },
  { path: '',
    redirectTo: '/heroes',
    pathMatch: 'full'
  },
  { path: '**', component: PageNotFoundComponent }
];

@NgModule({
  imports: [
    RouterModule.forRoot(
      appRoutes,
      { enableTracing: true } // <-- debugging purposes only
    )
    // other imports here
  ],
  ...
})
export class AppModule { }
```

### 路由出口
当应用在浏览器中的URL变为/heroes时，路由器就会匹配到path为heroes的Route，并在宿主视图中的RouterOutlet之后显示HeroListComponent组件。

```html
<router-outlet></router-outlet>
<!-- Routed views go here -->
```

### 路由器链接
配置在组件上，点击时跳转到对应的路由。
```ts
template: `
  <h1>Angular Router</h1>
  <nav>
    <a routerLink="/crisis-center" routerLinkActive="active">Crisis Center</a>
    <a routerLink="/heroes" routerLinkActive="active">Heroes</a>
  </nav>
  <router-outlet></router-outlet>
`
```

参考文献：
[Angular官方文档](https://www.angular.cn/)
