---
title: 【論文研讀】Skeleton-based Action Recognition of People Handling Objects
catalog: true
date: 2023-10-19
author: Frances Kao
categories:
- paper review
- HAR
- Object-relation HAR
---

# [Skeleton-based Action Recognition of People Handling Objects](https://arxiv.org/pdf/1901.06882.pdf)

- Journal reference: WACV 2019
- Authors: Sunoh Kim, Kimin Yun, Jongyoul Park, Jin Young Choi
- Github: None
- 論文連結: [Skeleton-based Action Recognition of People Handling Objects](https://arxiv.org/pdf/1901.06882.pdf)

## Introduction
- 取RGB特徵會增加模型運算量, 因此使用骨架資訊作為模型輸入。但部份動作包含了互動物件，該物對動作的判斷有一定的重要性。因此將互動物件加入輸入資料結構中，進行動作辨識。

## Literature Review
- Graph convolutional neural networks
- Action recognition
- Skeleton-based action recognition

## Methodology
![](https://hackmd.io/_uploads/rykWg2AWa.png)
### ST-GCN
（略）
### 「人體使用物件」追蹤（Objects handled by humans）
- 過去追蹤互動物件的方法與其難點：
    - 偵測與人體重疊的物件 > 不相關的背景物並非人體實際互動的物件
    - 設計辨識模型來偵測與人互動的物件 > 互動物件種類廣泛，其大小形狀亦有所差異；且對每一幀每一動作類別皆需要一組人與物件的標記資料才可訓練模型
- 本論文方法：[ViBE algorithm(1444 cites)](https://ieeexplore.ieee.org/document/5672785) + OpenPose
    ![](https://hackmd.io/_uploads/ByVQNbVzT.png)
    (圖摘自ViBE原論文)
    > 原論文是用C++，這裡有找到一些大神用python寫的版本，雖然速度無法與C++比但也還算能即時，有興趣可以看[232525/ViBe.python](https://github.com/232525/ViBe.python/tree/master)
    - 追蹤畫面中移動物，包含人體與物件
    - 移除人體部份（heatmep），即得到該物件
    ![](https://hackmd.io/_uploads/Byhvl1Vfa.png)
### 物件關聯人體姿態辨識（Object-related human pose）
- 自OpenPose取得25個人體骨架點位，並且**將關聯物件視為第26個點位**，加入資料結構中。
    $V=\{v_{ti}\ |\ t = 1, ..., T;\ i = 1, ..., N\}$
    $E_S = \{e_{tij}\ |\ v_{ti}, v_{tj}\ are\ connected, (i, j) \in o\}$
    $E_T = \{e_{ti}\ |\ v_{ti}, v_{(t+1)i}\ are\ connected, (i, j) \in o\}$
![](https://hackmd.io/_uploads/Bka5NkVz6.png)
- 作者實驗三種資料結構: Body, Limbs, Hands
    - OHP + informative samples表現：Hands > Limbs > Body

### 2sGCNs（OHA-GCN）
- 將模型設計為Two-stream，包含human pose stream和object-related human pose stream。
- 因為物件關聯的動作並不會出現在每一場景中，若欲辨識的非物件關聯動作，則會僅使用human pose stream。
- GCN模型架構：
    - GCN layer x 9（channel =  64-64-64-128-128-256-256-256）
    - global average pooling `>> feature vector`
    - softmax `>> action prediction`
### 有效幀選取方法（Informative frame selection strategy）
- 作者使用的骨架也與傳統方法一樣出自RGB序列，因此也會有不正常、遺漏、重疊等問題。因此，提出「有效幀選取方法」，僅採樣影片中的一小段幀序列作為輸入，而這些資料提供的joint足以用來理解人體動作。
- 根據OpenPose提供的confidence score，替除掉模稜兩可的人體姿態資訊，只留下可靠度高的資訊。
- 方法：
    1. 整段影片以相同間距被均分為 $T$ 段 $\{S_1, S2, ..., S_T\}$，每一段有 $M$ 幀。
    2. 從以上 $T$ 段各取一幀，得 $Ｍ$ 個 $T$ 幀序列，為 $S$ ，即第t段 $S_t$ 包含了幀 $\{F^1_t, F^2_t, F^3_t, ..., F^M_t\}$ ，其中的 $F^m_t$ 為第t段的第m幀。
        > 因連續幀的資訊較為相像，如此作法可去除相鄰的高度重複資訊 
    3. 對每一幀 $F^m_t$ 進行姿態辨識可得每一骨架節點 $h^m_{ti}$ 的信心分數（confidence score） $c^m_{ti}$ ，其中 $i=1, ..., N$ 為骨架點位數目。
    4. 將 $S_t$ 的所有信心分數加總，並取用分數最高的 $S$ 直接作為時序資訊。
     $V=\{v_{ti}\ |\ v_{it}=h^{m*}_{ti}, m*=arg\ max \sum^N_i c^m_{ti}\}$

## Result

### Dataset
1. IRD dataset: illegal rubbish dumping (IRD) dataset，總共十分鐘的影片，包含1374影片片段（1193訓練和181驗證）。
2. ICVL-4 dataset: 包含805訓練資料和86驗證資料

### Experiments
![Screenshot from 2023-11-07 11-05-57.png](https://hackmd.io/_uploads/Sk8nF7DXp.png)
- 在互動物件與人體骨架的連接方式上（body/limbs/hands）,hands相較於其他兩者優異許多。
- 在有效幀選取策略上（informatuve samples），能獲得最多改善。
- 在有無加入互動物件上（HP/OHP/Two Stream），則僅有些為改善，甚至單用OHP時的表現會比單用HP來的差，但使用Two Stream方式可達到兩者互補。

## Conclusion
- 該方法可即時辨識動作
- 作者使用的資料集皆為自行蒐集，且僅選擇部份動作類別，較無公信力
- 加入互動物件作為human pose的node，因不包含該互動物件之表徵，若遇到相同骨架構成的動作仍無法克服。
- ViBE演算法為C++基礎，Python版本相對速度較慢。且不適用於攝影機無法確實固定（會有晃動狀況）的情境。