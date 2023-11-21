---
title: 【論文研讀】SlowFast Networks for Video Recognition
catalog: true
date: 2023-11-14
author: Frances Kao
categories:
- paper review
- RGB-based HAR
- video recognition

---

# [SlowFast Networks for Video Recognition](https://arxiv.org/pdf/1812.03982.pdf)
- Journal reference: 2019 IEEE/CVF International Conference on Computer Vision (ICCV)
- Author: Christoph Feichtenhofer, Haoqi Fan, Jitendra Malik, Kaiming He (Facebook AI Research, FAIR)
- Github: https://github.com/facebookresearch/SlowFast
- 論文連結：[SlowFast Networks for Video Recognition](https://arxiv.org/pdf/1812.03982.pdf)

## Introduction
- 作者設計了雙通道的架構，分別於低幀率下提取空間資訊，以及於高幀率下捕捉時序動態特徵。
- 其模型設計來自於生物學研究的啟發，模仿人類的視覺系統，即 ~80% 的小細胞(P-cells)和 ~15-20% 的大細胞(M-cells)所構成。以此為基礎，將模型設計為slow和fast之雙通道。大細胞負責處理快速的時序動態資訊，但對於空間上的細節與色彩不敏銳；而小細胞則是負責精細的空間特徵，但對動態資訊的反應較慢。

## Related Works
- 時空序列特徵過濾
- [44]的two-stream架構採用光流作為影片辨識之另一個輸入，作者以此為雙通道模型的啟發。 

## Methodology
| architecture | instantiation |
|--|--|
|![圖片](https://hackmd.io/_uploads/rkMMYseEa.png)|![image](https://hackmd.io/_uploads/rJ_bNxKN6.png)|
　

- Slow pathway: 採大的時序步伐，每隔 $\tau$ 取一幀，總共取 $T \times \tau$ 幀作為slow pathway之輸入。作者預設為 $\tau = 16$ 。
- Fast pathway: 採較小的時序步伐，每隔 $\tau / \alpha$ 取一幀，總共取 $\alpha T$ 幀作為fast pathway之輸入。作者預設為 $\alpha = 8$ 。此外，整個fast pathway皆不使用downsampling layer，而僅有分類前的global pooling layer，因此時序特徵形狀會保持在 $\alpha T$ 幀。
- Fast pathway與Slow pathway同樣為捲積網路，但僅有 $\beta$ 比例的通道大小，因此就算取較多幀資料作為輸入，作者預設為 $\beta=1/8$ 。其運算量也不大，甚至運算效率較slow pathway高，同時代表其較弱的空間特徵提取能力。作者對此做過實驗，例如減少輸入之空間特徵（resolution）或移除色彩資訊，實驗結果顯示皆能夠獲得好的結果。
- 僅於res4和res5使用**non-degenerate temporal convolution**，因為於模型前層即使用temporal convolution會降低準確率。*
- 橫向連接(Lateral connections)[35]: 
    1. 在每一階段皆對二通道先進行 **資料維度轉換** ；
        > 二通道之時序維度不同，需進行轉換再連接。
    3. 在每一階段皆對二通道間進行橫向連接，將fast pathway資料透過 **單向連接** 融合至slow pathway；
    4. 二通道之各別輸出進行 **global average pooling** ；
    5. 將二通道之輸出進行 **加總(summation)** 或 **合併(concatenation)** ;
    6. 經過pooling之二通道之特徵向量再餵入 **全連階層進行分類** 。
    - Feature shape
        - Slow pathway: ${T, S^2, C}$
        - Fast pathway: ${\alpha T, S^2, \beta C}$
    - Data transformation：作者提出三種資料為度轉換的方式，結果如[Results](#Results)
        1. Time-to-channel：將時間維度轉換為通道維度，使Fast pathway與Slow pathway的輸出在通道維度上具有相同的維度，方便兩者進行融合。
            >  $transform \ \{\alpha T, S^2, \beta C\} \ into\  \{T, S^2, \alpha \beta C\}$
        1. Time-strided sampling：僅選擇其中一個 $\alpha$ 時間步，以降低時間維度的資訊量，同時保留空間維度和通道維度的資訊。
            >  $transform \ \{\alpha T, S^2, \beta C\} \ into\  \{T, S^2, \beta C\}$
        1. Time-strided convolution：對Fast pathway的輸出進行3D卷積，並將輸出與 Slow pathway 進行融合。
            >  $kernel =5 \times 1^{2},\ output\ channels= 2 \beta C,\ stride= \alpha$
        - 以上 Time-strided sampling 和 Time-strided convolution 都是對時間維度資訊進行壓縮和提取，以便於模型學習到更有用的時間特徵。

## Experiments
### Settings
- Dataset: Kinect400 (~240k training & 20k validation)
- mini batch size = 8 clips pre GPU x 128
### Results
- slowfast fusion: 作者實驗三種不同的資料轉換和融合方式進行橫向連接(Lateral connections)，皆優於僅使用slow pathway的方法。
- channel capacity ratio ( $\beta$ ): 作者實驗不同 $\beta$ 值得最適值為 $\beta=1/8$
- weaker spatio input to fast pathway: 作者嘗試弱化Fast pathway之空間感知能力，例如將RGB資訊減半、使用灰階、時間差、光流等方式減少空間資訊，其準確率仍與一般使用RGB時無大差異，而計算量最多可減少約 2 GFLOPs。
- train from scratch: 在不使用pretrained model的情況下，可以獲得優異的表現。
- 與SOTA之比較
    | 與Kinect400之SOTA | 與Kinect600/Charades之SOTA |
    |-|-|
    |![image](https://hackmd.io/_uploads/H1I1-6FNa.png)|![image](https://hackmd.io/_uploads/r1yZWTtVp.png)|
- Ablation Study
![image](https://hackmd.io/_uploads/SkQebpYEp.png)
![image](https://hackmd.io/_uploads/ByZUgTKEa.png)
