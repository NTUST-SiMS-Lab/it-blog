---
title: 【論文研讀】Something-Else Compositional Action Recognition with Spatial-Temporal Interaction Networks
catalog: true
date: 2023-09-30
author: Frances Kao
categories:
- paper review
- HAR
- Object-relation HAR
---

# Something-Else: Compositional Action Recognition with Spatial-Temporal Interaction Networks

Journal reference: CVPR2020
Author: Materzynska, Joanna and Xiao, Tete and Herzig, Roei and Xu, Huijuan and Wang, Xiaolong and Darrell, Trevor
Github: https://github.com/joaanna/something_else

## Introduction
以RGB-based HAR模型而言，輸入資料中的物件被模型視為非獨立物件，但事實上**它們為動作的一部分，應被視為獨立物件一同考慮**。因此作者提出方法，嘗試完整**捕捉動作與物件間的組成**。前提是現今HAR方法本是基於空間資訊再進行延伸，應更加注重空間特徵來提升動作辨識效果。

### Spatial-Temporal Interaction Network (STIN)
一動作辨識模型，其將動作中的主體(Subject)和物體(Object)之間的幾何關係納入模型考慮。STIN會追溯根據偵測與追蹤結果得來的候選稀疏圖。

輸入: 物體和主體的位置和形狀
1. 對輸入資料進行空間交互作用推理（spatial interaction reasoning）
2. 對沿著相同軌跡的框進行時間交互作用推理（temporal interaction reasoning），即針對物體的變換和主體與物體之間的關係兩者進行編碼。
3. 接著，再組合主體與物體的軌跡，以進行動作辨識。
4. 若當中無交互作用的動作（如倒水或撕紙等未有兩物體互動的動作），則僅以單純的時空場景表示方式進行辨識。（baseline）

### Something-Else task
延伸自[Something-Something V2 dataset](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&cad=rja&uact=8&ved=2ahUKEwiB2sfziNmBAxVLslYBHSHTDDMQFnoECA8QAQ&url=https%3A%2F%2Fpaperswithcode.com%2Fdataset%2Fsomething-something-v2&usg=AOvVaw0G1EXIeKID1UAip5dZ_cPj&opi=89978449)，作者再加入：
- 資料標記：Bounding Box
- 訓練－測試資料切割

### Contribution
1. 提出STIN (Spatial-Temporal Interaction Network)得以明確地理解人員與物件間的幾何變化特徵。
2. 提出兩項任務資料集，用以測試模型泛化性，其中包含影片中的標註框。
3. 模型性能優於其他appearance-based HAR模型。

## Related Work
> However, a recent study in [77] indicates that most of the current models trained with the above-mentioned datasets are not focusing on temporal reasoning but the appearance of the frames: Reversing the order of the video frames at test time will lead to almost the same classification result

> Misra et al. [45] propose a method to compose classifiers of known visual concepts and apply this model to recognize objects with unseen combinations of concepts.

> Visual Interaction Network [69], which models the physical interactions between objects in a simulated environment.

## Method
- detector and tracker >> object-graph representations (bbox)
- spatial-temporal reasoning

### Object-centric Representation
針對影片進行物件偵測（detector可偵測手及其互動物件）；所有互動物體（object）在訓練檢測器中皆被視為一個類別，也就是僅有主體（手）和物體（任何互動物體）兩個類別。偵測出Ｎ個物件後，進行多物件追蹤，以獲得多幀中物件框間的關聯性。
- Bounding box coordinates（location＆shape）: 輸入物件框資訊（x,y,h,w）至MLP，得到一d維特徵；即透過物件的位置與形狀提取物件與其移動資訊。
- Object identity embedding: 利用一可學習的d維嵌入層來表示**物體和主體的類別**：
    - subject embedding
    - object embedding
    - null embedding: 與動作無關的物件框（dummy boxes）
- 以上三個類別嵌入皆起始於多變數常態分佈（彼此獨立），並且與上述的物件框特徵合併作為模型輸入。

### Spatial-temporal interaction reasoning
假設影片共有 $T$ 幀且每幀 $N$ 個物件， $x^t_n$ 即代表第 $t$ 幀中的物件 $n$ 的特徵：
$\begin{gather*} X = (x^1_1, ..., x^1_N, x^2_1, ..., x^2_N, x^T_1, ..., x^T_N) \end{gather*}$
![](https://hackmd.io/_uploads/HytdYsIgT.png)

#### Spatial interaction module
$f(x^t_n) = ReLU(W^T_f)[x^t_n, \dfrac{1}{N-1} \displaystyle\sum_{j!=n}x^t_j ]$
- $[,]$ 表示 $x^t_n$ 與其他 $N-1$ 個物件之特徵合併
- $W^T_f$ 為一可學習權重
![](https://hackmd.io/_uploads/SyrIKiIga.png)

#### Temporal interaction module
$p(X) = W^T_p h(\{g(x^1_n, ..., x^T_n)\}^N_{n=1})$
- 一時間軌跡內各物件的特徵資訊為 $g(x^1_n, ..., x^T_n)$
- $h$ 為合併時間軌跡內資訊的函式
    - a simple averaging function
    - [non-local block [67]](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&cad=rja&uact=8&ved=2ahUKEwjyqIu2kNmBAxUI_mEKHR7PC50QFnoECAgQAQ&url=https%3A%2F%2Fopenaccess.thecvf.com%2Fcontent_cvpr_2018%2Fpapers%2FWang_Non-Local_Neural_Networks_CVPR_2018_paper.pdf&usg=AOvVaw3lpouVx5j7REXCf-OFWmzS&opi=89978449)：對兩兩一組的軌跡特徵進行編碼，再將其平均
- $W_p$ 最終的分類器（CE） 
#### Combining video appearance representation
- 投入 $T$ 幀至3D ConvNet（[ResNet-50 I3D [68]](https://arxiv.org/abs/1806.01810)），提取時空特徵表示
- 對上述所提取之時空特徵表示進行average pooling，得一d維特徵
- 上述得之video appearance representation便可與object representation $h(\{g(x^1_n, ..., x^T_n)\}^N_{n=1})$ 結合，再餵入分類器中
> Given a long clip of video (around 5 seconds), we sample 32 video frames from it with the same temporal duration between every two frames. [68]

## The Something-Else Task
- 源自Something-Something V2 dataset [20]：174組人與物體互動的動作類別，以動作（動詞）與隨意物件（名詞）的互動做組合
- 其資料切分方式未考慮到，相同人員或相同動作組合在訓練與測試資料同時可能出現，導致資料偏頗，使得於此資料集表現優異的模型缺乏泛用性。
- 作者加上**物件框標記**與**訓練資料集分割**，Something-Else 任務需要辨識「針對看不見的物件執行操作時的動作」，即在訓練時不會與該操作一起出現的物件。因此，方法是針對「某物」進行訓練的，但測試其泛化為「其他東西」的能力。該資料集中的每個動作類別都被描述為由相同動詞和不同名詞組成的短語。作者重新組織了組合動作識別的資料集，並對每個動作隨時間變化的物件間幾何配置的動態進行建模。
![](https://hackmd.io/_uploads/ry5h5pIlp.png)

## Experiments
### Implementation Details
- Detector
    - 為偵測影片中的主體與互動物體
    - 使用模型：
        - Faster R-CNN [50, 71] with Feature Pyramid Network (FPN) [42] and ResNet-101 [24] backbone, pre-trained with the COCO [43]dataset
        - 使用作者的Something-Else(加入物件框標記)再進行finetune
    - finetune過程僅使用手與其互動物件兩個類別進行訊練; 互動物件的數量至多為4
- Tracker（multi-object tracking）
    - 為提取不同幀中物體之間的對應關係
    - 方法：
        - [**卡爾曼濾波器（Kalman Filter）**[34]](https://zh.wikipedia.org/zh-tw/%E5%8D%A1%E5%B0%94%E6%9B%BC%E6%BB%A4%E6%B3%A2) 基於先前的追蹤結果去預測當前幀中的物件可能位置，藉以捕捉物體的移動軌跡
        - [**匈牙利算法（Kuhn-Munkres algorithm）**[39]](https://zh.wikipedia.org/zh-tw/%E5%8C%88%E7%89%99%E5%88%A9%E7%AE%97%E6%B3%95) 將上述預測與單幀檢測結果進行匹配，即確認哪些物體在不同幀之間是相同的。

### Setup
- training setting
    - 2層MLP (隱藏層d=512)
    - 50 epoch
    - lr=0.01
    - optim=SGD (weight dacay=0.0001, momentum=0.9, lr dacay=0.1 at 35e & 45e)
- Visulization
![](https://hackmd.io/_uploads/B1w3elPxa.png)

### Experiments
1. 原始資料集分割（Original Something-Something Split）: 原始的 Something-Something 資料集上評估模型，該資料集包含174種常見的人與物體互動類別。這裡使用資料集提供的標準訓練-測試分割方式。
2. 組織性資料分割（Compositional Action Recognition）: 針對Something-Something 資料集進行新的訓練-測試組合分割，其中任務著重於辨識出「使用未見過的物體執行的動作」。
3. 少樣本訓練（Few-shot Compositional Action Recognition）: 僅使用少樣本訓練資料進行模型訓練。
    > 由#2和#3的結果可得知，即便是使用detector所生成的bbox作為下游模型的輸入資料，其準確率也能夠維持。
4. 泛化能力－單一物體之資料訓練（One-object training）: 為分析模型對不同物體類別的泛化能力，設定實驗為僅使用「與物體類別 "box" 互動的影片」訓練模型，並於其它剩餘影片上評估模型性能。
5. 個別類別之辨識效果（Category analysis）: 針對表現最好與表現最差的前五個類別，檢視其模型效能。作者發現，在那些有直接移動物體的動作上，模型表現較好（例如take sth, push sth, ...）；而在物體本身變化的動作上，表現較差（例如poking, tearing）。

|#1|#2|#3|#5|
| -- | -- | -- | -- |
|![](https://hackmd.io/_uploads/rypkimYg6.png)|![](https://hackmd.io/_uploads/SygS3QKea.png)|![](https://hackmd.io/_uploads/ry2I3XYxp.png)|![](https://hackmd.io/_uploads/SJscnmtxa.png)|

## Conclusion
- 因物件偵測追蹤的不準確而導致下游任務表現不佳。
- 雖考慮時空間之交互關係，但完全為考慮物件之外觀，可能限制模型於不同場景之泛化能力。
- 因需要大量標記資料來進行訓練，缺乏實際應用之可延展性。
- 非end to end模型，無法作到即時辨識。![](https://hackmd.io/_uploads/ByD527Fg6.png)
