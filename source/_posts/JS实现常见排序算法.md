title: JS实现常见排序算法
tags:
    - JavaScript
    - 前端框架
comments: true
brief: JS实现常见排序算法
date: 2018-08-05
categories:
    - 前端框架
---
# JS实现常见排序算法
常见的排序算法有：冒泡排序、选择排序、插入排序、归并排序、快速排序、堆排序。下面我们使用js来一一实现它们。

<!-- more -->

randIntArr,用于生成1到100之间的n个随机数
```js
function randIntArr(n){
    let retArr = [];
    for(let i=0;i<n;i++){
        retArr.push(parseInt(Math.random() * 100 ));
    }
    return retArr;
}
```

exch,用于交换数组中的两个元素。
```js
function exch(arr,i,j) {
    let tmp = arr[i];
    arr[i] = arr[j];
    arr[j] = tmp;
}
```

以下排序方式默认都是升序排序。

## 冒泡排序
冒泡排序是一种简单的排序算法。它重复地走访过要排序的数列，一次比较两个元素，如果它们的顺序错误就把它们交换过来。走访数列的工作是重复地进行直到没有再需要交换，也就是说该数列已经排序完成。这个算法的名字由来是因为越小的元素会经由交换慢慢“浮”到数列的顶端。

```js
var arr = randIntArr(15);
console.log('before',arr);
//[9, 37, 26, 4, 16, 86, 4, 6, 44, 42, 52, 60, 92, 89, 72]
function bubbleSort(arr,reverse) {
    //判断是否经过交换，一次交换也没有，代表排序成功。
    let isExch = false; 
    for(let i=0,len = arr.length;i<len - 1;i++){
        for(let j=len - 1;j>i;j--){
            if((!reverse && arr[j]<arr[j-1]) || (reverse && arr[j] > arr[j-1])){
                exch(arr,j,j-1);
                isExch = true;
            }
        }
        if(!isExch) return;
    }
}
bubbleSort(arr);
console.log('after',arr);
//[4, 4, 6, 9, 16, 26, 37, 42, 44, 52, 60, 72, 86, 89, 92]
bubbleSort(arr,true);
console.log('reverse',arr);
//[92, 89, 86, 72, 60, 52, 44, 42, 37, 26, 16, 9, 6, 4, 4]
```

## 选择排序
首先在未排序序列中找到最小（大）元素，存放到排序序列的起始位置，然后，再从剩余未排序元素中继续寻找最小（大）元素，然后放到已排序序列的末尾。以此类推，直到所有元素均排序完毕。

```js
var arr = randIntArr(15);
console.log('before',arr);
//[54, 79, 31, 13, 18, 38, 35, 73, 25, 58, 71, 30, 90, 98, 88]
function selectionSort(arr,reverse) {
    for(let i=0,len=arr.length;i<len;i++){
        let extremum = arr[i]; //最小或最大值
        for(let j=i+1;j<len;j++){
            if((!reverse && extremum > arr[j]) || (reverse && extremum < arr[j])){
                let tmp = arr[j];
                arr[j] = extremum;
                extremum = tmp;
            }
        }
        arr[i] = extremum;
    }
}
selectionSort(arr);
console.log('after',arr);
//[13, 18, 25, 30, 31, 35, 38, 54, 58, 71, 73, 79, 88, 90, 98]
selectionSort(arr,true);
console.log('reverse',arr);
//[98, 90, 88, 79, 73, 71, 58, 54, 38, 35, 31, 30, 25, 18, 13]
```

