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
常见的排序算法有：冒泡排序、选择排序、插入排序、归并排序、快速排序、希尔排序、堆排序。下面我们使用js来一一实现它们。

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

原理图
![冒泡排序](冒泡排序流程图.png)

```js
var arr = randIntArr(15);
console.log('before',arr);
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
bubbleSort(arr,true);
console.log('reverse',arr);
```

## 选择排序
首先在未排序序列中找到最小（大）元素，存放到排序序列的起始位置，然后，再从剩余未排序元素中继续寻找最小（大）元素，然后放到已排序序列的末尾。以此类推，直到所有元素均排序完毕。

原理图
![选择排序](选择排序.gif)

```js
var arr = randIntArr(15);
console.log('before',arr);
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
selectionSort(arr,true);
console.log('reverse',arr);
```

## 插入排序
插入排序工作原理是通过构建有序序列，对于未排序数据，在已排序序列中从后向前扫描，找到相应位置并插入。

原理图
![插入排序](插入排序.jpg)

```js
var arr = randIntArr(15);
console.log('before',arr);
function insertionSort(arr,reverse) {
    for(let i=0,len=arr.length;i<len;i++){
        for(let j=i+1;j>0;j--){
            if((!reverse && arr[j] < arr[j-1]) || (reverse && arr[j] > arr[j - 1])){
                exch(arr,j,j-1);
            }else break; //说明已经在有序的列表中已经交换完成
        }
    }
}
insertionSort(arr);
console.log('after',arr);
insertionSort(arr,true);
console.log('reverse',arr);
```

## 归并排序
对一个数组的排序，我们可以将他分成两个数组来处理，再对这两个数组同样的道理来处理，将他们分别分成两个数组来处理…… 直到数组无法再细分下去（即数组的长度为1，只有一个元素的数组肯定是有序的），分为之后的数组进行合并操作，向上整合整个数组（注意整合这部，因为两个数组都是有序的只要遍历一个，不断的往后插入即可），最后到达得到一个有序的数组的目的。

原理图
![归并排序](归并排序.jpg)

```js
var arr = randIntArr(15);
console.log('before',arr);
function mergeSort(arr,reverse) {
    let sort = (arr,reverse) => {
        if(arr.length === 1) return arr;
        let partition = Math.floor(arr.length / 2),
            leftArr = arr.slice(0,partition),
            rightArr = arr.slice(partition,arr.length);
        leftArr = sort(leftArr,reverse);
        rightArr = sort(rightArr,reverse);
        return mergeArray(leftArr,rightArr,reverse);
    };
    let newArr = sort(arr,reverse);
    arr.splice(0,arr.length,...newArr);
}
function mergeArray(leftArr,rightArr,reverse) {
    let i = 0,j = 0,retArr = [],len=leftArr.length,len2=rightArr.length;
    for(;i<len;i++){
        let leftVal = leftArr[i];
        for(;j<len2;j++){
            let rightVal = rightArr[j];
            if(!reverse){
                if(leftVal > rightVal) retArr.push(rightVal);
                else{
                    retArr.push(leftVal);
                    break;
                }
            }else{
                if(leftVal < rightVal) retArr.push(rightVal);
                else{
                    retArr.push(leftVal);
                    break;
                }
            }
        }
        if(j === len2) {
            retArr = retArr.concat(leftArr.slice(i,len));
            break;
        }
    }
    if(j !== len2) retArr = retArr.concat(rightArr.slice(j,len2));

    return retArr;
}
mergeSort(arr);
console.log('after',arr);
mergeSort(arr,true);
console.log('reverse',arr);
```

## 快速排序
快速排序的基本思想：通过一趟排序将待排记录分隔成独立的两部分，其中一部分记录的关键字均比另一部分的关键字小，则可分别对这两部分记录继续进行排序，以达到整个序列有序。

原理图
![快速排序](快速排序.png)

```js
var arr = randIntArr(15);
console.log('before',arr);
function quickSort(arr,reverse) {
    let sort = (arr,reverse) => {
        if(arr.length === 1) return arr;
        let randIndex = Math.floor(Math.random() * arr.length);
        let comparison = arr[randIndex],leftArr = [],rightArr = [];
        arr.splice(randIndex,1); //去掉当前这个数，便于迭代
        for(let val of arr){
            if((!reverse && val > comparison) || (reverse && val < comparison)) rightArr.push(val);
            else leftArr.push(val);
        }
        if(leftArr.length > 0) leftArr = sort(leftArr,reverse);
        if(rightArr.length > 0) rightArr = sort(rightArr,reverse);
        return leftArr.concat(comparison,rightArr);
    };
    let newArr = sort(arr,reverse);
    arr.splice(0,arr.length,...newArr);
}
quickSort(arr);
console.log('after',arr);
quickSort(arr,true);
console.log('reverse',arr);
```

## 希尔排序
先将整个待排序记录序列分割成若干个子序列，在序列内分别进行直接插入排序，待整个序列基本有序时，再对全体记录进行一次直接插入排序。

原理图
![希尔排序](希尔排序.jpg)

```js
var arr = randIntArr(15);
console.log('before',arr);
function shellSort(arr,reverse) {
    let len = arr.length,
        gap = Math.floor(len / 2);
    while(gap>0){
        for(let i=gap;i < len;i++){
            let j = i - gap,tmp = arr[i];
            while((!reverse && j>=0 && tmp < arr[j]) || (reverse && j>=0 && tmp > arr[j])){
                arr[j + gap] = arr[j];
                j -= gap;
              }
            arr[j + gap] = tmp;
        }
        gap = Math.floor(gap / 2);
    }
}
shellSort(arr);
console.log('after',arr);
shellSort(arr,true);
console.log('reverse',arr);
```

## 堆排序
堆排序是利用堆这种数据结构而设计的一种排序算法，堆排序是一种选择排序。

堆是具有以下性质的完全二叉树：每个结点的值都大于或等于其左右孩子结点的值，称为大顶堆；或者每个结点的值都小于或等于其左右孩子结点的值，称为小顶堆。

![堆](堆.png)

数组表示：

![堆数组](堆数组.png)

大顶堆：arr[i] >= arr[2i+1] && arr[i] >= arr[2i+2]  
小顶堆：arr[i] <= arr[2i+1] && arr[i] <= arr[2i+2] 

堆排序，是将已经已经形成堆结构的数组取出堆顶，然后在调整数组剩下的元素形成新的堆，再取出新的堆的堆顶，如此反复知道取完全部的元素即可完成排序。

![堆排序流程](堆排序流程.png)

```js
var arr = randIntArr(15);
console.log('before',arr);
function heapSort(array,reverse) {

  function heapify(array, index, heapSize){
    var iExtremum, iLeft, iRight;
    while (true) {
      iExtremum = index;
      iLeft = 2 * index + 1;
      iRight = 2 * (index + 1);

      if ((iLeft < heapSize) && ((!reverse && array[index] < array[iLeft]) || (reverse && array[index] > array[iLeft]))) {
        iExtremum = iLeft;
      }

      if ((iRight < heapSize) && ((!reverse && array[iExtremum] < array[iRight]) || (reverse && array[iExtremum] > array[iRight]))) {
        iExtremum = iRight;
      }
      //递归向下调整
      if (iExtremum != index) {
        exch(array, iExtremum, index);
        index = iExtremum;
      } else {
        break;
      }
    }
  }

  function buildHeap(array) {
    //从倒二层开始调节
    var i, layer = Math.floor(array.length / 2) - 1;

    for (i = layer; i >= 0; i--) {
      heapify(array, i, array.length);
    }
  }

  function sort(array) {
    buildHeap(array);

    for (var i = array.length - 1; i > 0; i--) {
      exch(array, 0, i);
      heapify(array, 0, i);
    }
    return array;
  }

  return sort(array);
}
heapSort(arr);
console.log('after',arr);
heapSort(arr,true);
console.log('reverse',arr);
```

## 参考文献
[图解排序算法之堆排序](https://www.cnblogs.com/chengxiao/p/6129630.html)
[排序图解](https://www.cnblogs.com/wteam-xq/p/4752610.html#h5o-9)