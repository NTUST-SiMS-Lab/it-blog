---
title: APSNet論文介紹
catalog: true
date: 2023-08-08
author: Chao-Hung Huang
categories:
- point cloud, pointnet, action recognition
---

# [APSNet: Toward Adaptive Point Sampling for Efficient 3D Action Recognition](https://ieeexplore.ieee.org/document/9844448)(來源自IEEE)

# 自適應點採樣的高效3D動作辨識(APSNet)

### 🔹 Journal reference: 
*IEEE, Transactions on Image Processing, Volume 31, 2022, pp 5287–5302*
### 🔹 Authors: 
*Vittorio Mazzia, Simone Angarano, Francesco Salvetti, Federico Angelini, Marcello Chiaberge*

## ✅ 論文重點整理
1. 提出了一個自適應點採樣的設計架構。
2. 端到端的動作辨識模型，點雲to動作辨識結果。
3. 相較Benchmark降低點雲模型運算量，並維持一定的準確度。

## ✅ 現有3D動作辨識遇到的問題

### 1. 現有 3D 動作辨識模型提取動作信息的效率不夠好
以近期的[3DV-PointNet++ network](https://arxiv.org/abs/2005.05501) (2020年)為例，它需要花費大量時間對點雲數據進行體素化並通過時間排序池預先計算運動信息。

### 2. 希望設計一個end-to-end(端到端)的網路結構
可以直接學習來自原始點雲序列的運動表示和同時優化幾何信息，並以完全端到端的方式進行提取過程。

### 3. 點雲模型的運算量大，期望高效的網路架構
在資源有限的設備上部署這些模型的問題，例如自動駕駛汽車。

### 4. 現有的3D動作識別方法通常使用相同的分辨率進行辨識
不同的動作模式其點雲的複雜度也不同，較複雜的動作行為可以用高分辨率進行處理，而有些存在冗餘和噪聲幀靜態場景中的點雲序列，可使用較低分辨率進行處理。圖中顯示了兩點來自動作類“投擲”和“握手”的點雲序列。觀察到“投擲”的動作類通常具有更複雜的運動模式。因此，使用高分辨率幀是有利的在測試過程中做到合理分類結果。另一方面，“握手”的動作類，其點雲序列相對簡單，使用低分辨率幀就足夠進行辨識了。

![](https://hackmd.io/_uploads/rkS8_0Nih.png)

## ✅ 論文主要貢獻

1. 作者引入高效的骨幹網絡並提出**端到端的自適應點採樣**基於此主幹的網絡（APSNet）架構網絡，專為高效3D而設計的動作辨識模型。

2. 作者新提出的 APSNet 中，可以根據輸入點雲資訊自適應地決定對測試過程中**不同幀點雲視頻的最佳分辨率**（即最優點雲數目）。

3. 多個基準的綜合實驗數據集證明了作者骨幹網絡(Backbone Network) 和 APSNet 3D 動作辨識的有效性和效率。

## ✅ Backbone Network 架構介紹
* **Backbone Network的架構圖：**

    ![](https://hackmd.io/_uploads/Skj_nR4s3.png)

    1. Input: 點雲影片(三維點雲資訊)
    2. Frame sampling(得到成雙的frame pairs)
    3. 將每個frame pairs投入Backbone Network裡，可以得到Pair-level級別的特徵(geometry & motion)
    4. 整合所有frame pairs的得到的特徵
    5. 使用分類器進行動作分類(FC layers and softmax)

* **Frame sampling(幀採樣):**
    1. 投入點雲影片(三維點雲資訊)並分割成採樣幀數(2T = 8)個片段，T = 4。
    2. 隨機抽取每個片段的一個幀(8個片段各取一個幀)，組成T frame pairs。
    公式表示：![](https://hackmd.io/_uploads/rJdrCRNih.png)，t = 0 , ... , T-1
    
* **Backbone network 架構圖：**
    ![](https://hackmd.io/_uploads/S17gr1Hoh.png)
    
    1. **Data Pre-Processing Module:**
        
        投入Qc(current frame)與Qr(reference frame)經過**第一次FPS處理**後，進行點雲降維變為˜Qc與˜Qr，從原本的點雲數目變為˜N個點。再進行**S次**的Set abstraction operation(集合抽象)，它是一種幾何特徵抽取的過程：首先分別對˜Qc與˜Qr點雲再進行降維一次(**第二次FPS處理**)變為N個點，再進行Grouping與Mini-PointNet操作，最後得到的特徵表示為：
        
        ![](https://hackmd.io/_uploads/SJRS1xri3.png) 特徵表示為
        ![](https://hackmd.io/_uploads/S1dYA1rsn.png)
        
        ![](https://hackmd.io/_uploads/BkIF1gSs2.png) 特徵表示為
![](https://hackmd.io/_uploads/Hke2RJHi3.png)

        ```
        (˜N, N)是作者自己設定的分辨率(點雲數目)
        ```

        * **最遠點採樣(Farthest point sampling, FPS):**
            
            點雲在進行樣本採樣時能夠達到均勻採樣的效果，舉例來說：就像卷積在做max pooling的時候一樣，在保留圖像主要特徵信息的同時，能將圖像轉換為不同尺度。
            
            [FPS演算法流程：](https://www.bilibili.com/video/BV1oT411x7TH/?spm_id_from=333.337.search-card.all.click)
            1. 輸入點雲有N個點，從點雲中**隨機選取**一個點P0作為起始點，得到採樣點集合S={P0}。
            
            ![](https://hackmd.io/_uploads/S1wEwxHih.png)

            2. 計算所有點到P0的距離(**歐式距離**)，構成N維數組L，從中選擇最大值對應的點作為P1，更新採樣點集合S={P0，P1}。
            
            ![](https://hackmd.io/_uploads/SJ9_werj2.png)

            3. 計算所有點到P1的距離，對於每一個點Pi，其距離P1的距離如果小於L[i]，則更新L[i] = d(Pi, P1)，因此，數組L中存儲的一直是每一個點到採樣點集合S的最近距離。
            
            ![](https://hackmd.io/_uploads/ryr6DgSo3.png)

            4. 選取L中最大值對應的點作為P2，更新採樣點集合S={P0，P1，P2}。
            
            ![](https://hackmd.io/_uploads/Hy8-deSin.png)

            5. 重複2-4步，一直採樣到N'個目標採樣點為止。
        * **集合抽象([Set abstraction operation](https://www.bilibili.com/video/BV1Cu411p7Pu/?spm_id_from=333.788.recommend_more_video.1)來自[pointnet++](https://arxiv.org/abs/1706.02413) 2017年)，以BBNet3為例：**

            ![](https://hackmd.io/_uploads/rJNyjJrjh.png)
            
            進行第二次FPS降維點雲，利用pointnet++的Grouping技術擷取所有採樣點N限定範圍內的點雲，使神經網路更專注於局部的區域特徵，Grouping詳細操作過程如下圖：
            
            ![](https://hackmd.io/_uploads/SkX_Qxri3.png)
            
            將第二次FPS的採樣點，每一點利用**球狀鄰域查詢(Ball Query)** or **K近鄰算法(KNN)** 組成區域點的集合。最後經由多尺度感知器 **(MLPs)** 與 **Max pooling**，組成Pc與Pr的幾何特徵(**geometry feature**)。
            
            ![](https://hackmd.io/_uploads/HyxuXZUjn.png)

            
        * **[Mini-PointNet](https://www.bilibili.com/video/BV1bh4y1o7Ji/?spm_id_from=333.788.recommend_more_video.0)(來自[pointnet](https://arxiv.org/abs/1612.00593) 2016年):**
            
            一種為保留點雲無序性的特徵擷取方式，幾乎在每次擷取點雲特徵的過程結尾都會使用**MLPs+Max pooling**，統稱為Mini-PointNet。
            
            先將每個點雲投入MLPs中，原先3維的資訊升維成C(通道數的特徵)，利用Max pooling取得每維特徵中的最大值，因此在置換投入的點雲順序時，最後的特徵結果是不會受到影響的。
            ![](https://hackmd.io/_uploads/BJM8_grih.png)
            
            ![](https://hackmd.io/_uploads/Sk7c8xHi3.png)
            
* **Backbone Network (Core)架構圖：**
    ![](https://hackmd.io/_uploads/SJ7ETers3.png)
    
    1. **[Aggregated feature extraction](https://www.bilibili.com/video/BV1U3411j7Fg/)(來自[GeometryMotion-Net](https://ieeexplore.ieee.org/document/9503414) 2021年，其作者與本篇作者相同):**

        經由set abstraction後得到的cloud point，將Pc每一個點在Pr點雲上找出鄰近的K點(KNN)，再把Pr每一個鄰近點的三維座標減去Pc，可以得到帶有點雲偏移量的特徵(**motion feature**)。
        
        表示公式為：![](https://hackmd.io/_uploads/ry5VzZrj2.png)
        
    2. **Local feature extraction:**
    
        此過程是將Aggregated feature extraction得到的其中一個點特徵再去做Mini-pointnet。
        ![](https://hackmd.io/_uploads/SJiOHZSjh.png)進行區域性的特徵提取
 ![](https://hackmd.io/_uploads/B1orSZSs3.png)

    以下為Aggregated feature extraction+Local feature extraction的示意圖：
    ![](https://hackmd.io/_uploads/B1XbbZSih.png)
    
    3. **Global feature extraction:**
    
        每個![](https://hackmd.io/_uploads/SJiOHZSjh.png)點，i = 1 , ..., N，再做一次Mini-pointnet可以提取出帶有幾何與動作的全域pair-level特徵vector![](https://hackmd.io/_uploads/HJ_QrGBin.png)。

* **Concatenation and Classification:**

    最終結合所有的T frame pairs的幾何與動作特徵，再使用分類器來預測影片的動作。

## ✅ 作者的 APSNet 模型架構介紹
它與Backbone Network的差異在於，由下圖可知：

![](https://hackmd.io/_uploads/B1jj9zrsh.png)

在Backbone Network提取完Global feature extraction的特徵vector![](https://hackmd.io/_uploads/HJ_QrGBin.png)後，新增了Multi-resolution backbone network pre-training。BBNeti , i = {0, 1, 2, 3}，四種不同的分辨率**BBNet0, BBNet1, BBNet2 and BBNet3 as (128, 64), (256, 128), (512, 128) and (1,024, 128)**，其對應的數值就是前面在做FPS中有提到的(˜N , N)，BTW這四種模型都是需要預先訓練好的，再把訓練好的模型參數置入APSNet (Core)中。

* **APSNet (Core):**

    分為三個步驟Coarse Feature Extraction Stage、Decision Making Stage、Fine Feature Extraction Stage以下分別說明：
    
    1. **Coarse Feature Extraction Stage:**

        它就是等於Backbone Network的架構，所採用分辨率為最低的(128, 64)，也是消耗最少的運算成本，特徵表示為![](https://hackmd.io/_uploads/SkbsymBsn.png)
。
        
        ![](https://hackmd.io/_uploads/ryTzRMrj2.png)

    2. **Decision Making Stage:**

        作者使用決策模塊(DM)來生成操作決策，並確定該frame pair最佳分辨率為何(四選一)。
        
        ![](https://hackmd.io/_uploads/ByXcRzSo3.png)
        
        a. **LSTM updating:**
            
        將Coarse Feature Extraction Stage所得到的特徵![](https://hackmd.io/_uploads/SJfp1mBs2.png)當作input投入[LSTM模型](https://www.youtube.com/watch?v=xCGidAeyS4M)，模型會持續更新隱藏層ht和輸出Ot，可以表示為：![](https://hackmd.io/_uploads/HyzybXrsn.png)
        
        原先的LSTM結構，如下圖：
        ![](https://hackmd.io/_uploads/r1UUr7Boh.png)
        
        **以下為個人猜想，APSNet (Core)裡的LSTM**：
        ![](https://hackmd.io/_uploads/rJKDQXHih.png)
        (截圖源至：[LSTM模型](https://www.youtube.com/watch?v=xCGidAeyS4M) 46:07)
        
        原本的LSTM是投入ct-1跟ct，在APSNet (Core)裡，作者換成上一個LSTM記憶模塊的輸出，第一個LSTM記憶模塊投入![](https://hackmd.io/_uploads/SJfp1mBs2.png)特徵作為輸入，之後的記憶模塊則須加上上個記憶模塊的隱藏層(ht-1)與輸出(Ot-1)作為輸入，這個LSTM module源自於[AR-Net](https://arxiv.org/abs/2007.15796) 2020年。
        
        b. **Decision making:**
        
        ![](https://hackmd.io/_uploads/BJhXvvBin.png)
        
        將ht作為FC層的輸入，在經過**softmax層**即可產出最佳的分辨率，機率分布dt，表示如下
        ![](https://hackmd.io/_uploads/rylTw7Hjh.png)，再轉換為one-hot vector，將vector中最大的值變為1其他則為0，可以得到action decision 
        ![](https://hackmd.io/_uploads/BJsHOQri3.png)。
        
        但是有一個問題是argmax function沒有一個實際的可微分公式表示，所以會無法使用BP的技巧來更新權重。作者選擇[Gumbel-Max/Gumbel-Softmax trick](https://arxiv.org/abs/1611.01144)技巧讓模型可以自行訓練，基本概念是原本的dt vector加入noise形成新的 distribution vector = ![](https://hackmd.io/_uploads/H1sOnXHin.png)，定義如下：![](https://hackmd.io/_uploads/rkHi37Bon.png)

        
        ![](https://hackmd.io/_uploads/B116n7ro2.png) noise是一個標準的Gumbel distribution，![](https://hackmd.io/_uploads/rkBfpXSo2.png)
是採樣來自於uniform istribution(均勻分配) U(0, 1)，藉此作者就能夠產生新的one-hot vector如下：![](https://hackmd.io/_uploads/ByrICmri3.png)，當![](https://hackmd.io/_uploads/B1km-EBjh.png)為最大值時![](https://hackmd.io/_uploads/S10tlVBi2.png)會等於1其他為0。

        在BP的情況下，one-hot vector ![](https://hackmd.io/_uploads/S10tlVBi2.png) to 
![](https://hackmd.io/_uploads/rkdrlVrs3.png)
其公式為
![](https://hackmd.io/_uploads/BkIoAmSjh.png) 這個公式便可以使用BP的技巧進行微分與權重更新，讓模型end-to-end。

        !!!![](https://hackmd.io/_uploads/BkOH1Vrs2.png) 是 temperature parameter

        ---------------------
        補充說明：當![](https://hackmd.io/_uploads/BkOH1Vrs2.png)趨近於無限大decision vector![](https://hackmd.io/_uploads/rkdrlVrs3.png)傾向為uniform one；當![](https://hackmd.io/_uploads/BkOH1Vrs2.png)趨近於0則約等於one-hot vector ![](https://hackmd.io/_uploads/S10tlVBi2.png)。
        
        ---------------------
        
    3. **Fine Feature Extraction Stage:**

        最終得到一個action decision vector ![](https://hackmd.io/_uploads/SkaQ4Nri2.png)，以此為例的話，模型會將此frame pairs在投入BBNet1模型裡產生一個新的全域特徵 ![](https://hackmd.io/_uploads/rkGe7BSi2.png)。
        
        [1, 0, 0, 0]對應BBNet0，[0, 0, 1, 0]對應BBNet2，[0, 0, 0, 1]對應BBNet3。
        
* **Training Details:**

    這部份是要了解loss function的部分，loss function L定義如下：
    ![](https://hackmd.io/_uploads/HJhWHrBoh.png)
    
    **Lacc**是標準的cross-entropy loss(分類問題)，Ground-truth是點雲影片的動作標籤。
    
    **Leff**是APSnet的運算量複雜度，以the number of floating point operations(#FLOPs)作為表示。
    
    要先了解一個t-th frame pair的#FLOPs怎麼算：
    
    ![](https://hackmd.io/_uploads/Sk73tSHsn.png)
    
    Beta會等於每個BBNeti(i = 1~3)的運算量。
    
    ![](https://hackmd.io/_uploads/S1vWqrBsh.png)
    
    ![](https://hackmd.io/_uploads/SJ3NpHBj2.png)是decision making module的運算量，包含LSTM module跟FC。
    
    **平均所有的frame pairs的運算量**可以得到![](https://hackmd.io/_uploads/ryNV18Hs2.png)，公式如下：![](https://hackmd.io/_uploads/r12I1UHo2.png)
    
    計算出![](https://hackmd.io/_uploads/ryNV18Hs2.png)後，作者利用![](https://hackmd.io/_uploads/H15R-LBjn.png)
來控制APSNet的複雜度，公式如下：

    ![](https://hackmd.io/_uploads/Hk0wfUBoh.png)
    
    舉例來說，當FLOPpair > FLOPtarget時，作者使用較大的![](https://hackmd.io/_uploads/SkdNmLSs3.png)
來產生大的loss，促使優化器更新權重使分辨率決策往低分辨率調整；反之，則會使loss變小找到該點雲影片最佳分辨率。 

## ✅ THE DETAILED ARCHITECTURE OF MULTI-RESOLUTION BACKBONE NETWORKS
* The network structure of backbone network at the highest resolution (i.e., BBNet3)

![](https://hackmd.io/_uploads/H1O8pIBj2.png)

* The Structure of **BBNet3**:

    * farthest point sampling (FPS) = (˜N, N): (1024, 128)
    * set abstraction module: S = 2
    * MLP(**first** set abstraction module) ![](https://hackmd.io/_uploads/ByjdqLSi2.png): 64, 64, 128
    * MLP(**second** set abstraction module) ![](https://hackmd.io/_uploads/Skkn9IHs3.png): 128, 128, 256
    * MLP(local feature extraction): ![](https://hackmd.io/_uploads/H1e4iUBih.png): 128, 128, 256
    * MLP(global feature extraction): ![](https://hackmd.io/_uploads/H1_YsLBih.png): 256, 512, 1024

* The Structure of **BBNet2**:

    * farthest point sampling (FPS) = (˜N, N): (512, 128)
    * set abstraction module: S = 1
    * MLP(**one** set abstraction module) ![](https://hackmd.io/_uploads/ByjdqLSi2.png): 128, 128, 256
    * MLP(local feature extraction): ![](https://hackmd.io/_uploads/H1e4iUBih.png): 128, 128, 256
    * MLP(global feature extraction): ![](https://hackmd.io/_uploads/H1_YsLBih.png): 256, 512, 1024

* The Structure of **BBNet1**:

    * farthest point sampling (FPS) = (˜N, N): (256, 128)
    * set abstraction module: S = 1
    * MLP(**one** set abstraction module) ![](https://hackmd.io/_uploads/ByjdqLSi2.png): 96, 96, 192
    * MLP(local feature extraction): ![](https://hackmd.io/_uploads/H1e4iUBih.png): 96, 96, 192
    * MLP(global feature extraction): ![](https://hackmd.io/_uploads/H1_YsLBih.png): 192, 384, 768

* The Structure of **BBNet0**:

    * farthest point sampling (FPS) = (˜N, N): (128, 64)
    * set abstraction module: S = 1
    * MLP(**one** set abstraction module) ![](https://hackmd.io/_uploads/ByjdqLSi2.png): 64, 64, 128
    * MLP(local feature extraction): ![](https://hackmd.io/_uploads/H1e4iUBih.png): 64, 64, 128
    * MLP(global feature extraction): ![](https://hackmd.io/_uploads/H1_YsLBih.png): 128, 256, 512




## ✅ EXPERIMENTS
### 1. 資料集
> [NTU RGB+D 60](https://paperswithcode.com/paper/ntu-rgbd-a-large-scale-dataset-for-3d-human):
* 60種動作類別
* 40位受測者

> [NTU RGB+D 120](https://paperswithcode.com/paper/ntu-rgbd-120-a-large-scale-benchmark-for-3d):
* 120種動作類別
* 106位受測者

```
NTU源自於新加坡南洋理工大學 (Nanyang Technological University)
```

> [Northwestern-UCLA Multiview Action3D(N-UCLA)](https://paperswithcode.com/dataset/n-ucla):
* 10種動作類別
* 10位受測者
* 3種拍攝視角
* 將2種視角作為training data，剩餘一種作為testing data

```
西北大學洛杉磯分校多視圖動作 3D 數據集
```

> [UWA3D Multiview Activity II(UWA3DII)](https://ieee-dataport.org/documents/uwa-3d-multiview-activity-ii-dataset):
* 30種動作類別
* 10位受測者
* 4種拍攝視角
* 將2種視角作為training data，其他2種作為testing data


### 2. 資料集處理細節 
> 共同超參數：
* number of sampled frames (2T): **8** (i.e., T = 4)
* optimizer: **SGD** (with the **cosine** learning rate decay strategy)

> NTU RGB+D 60 and NTU RGB+D 120 datasets
* learning rate: **0.05**
* weight decay: **0.0005**
* batch size: **256**
* epoch: **48000**(NTU RGB+D 60)、**96000**(NTU RGB+D 120)

在訓練過程中，作者隨機沿 X 軸和 Y 軸旋轉每個點雲並比照[3DV](https://arxiv.org/abs/2005.05501)執行抖動和隨機丟失操作輸入點雲視頻。


> N-UCLA and UWA3DII datasets
* learning rate: **0.005**
* weight decay: **0.005**
* batch size: **64**
* epoch: 沒有說明

1. 首先預訓練BBNet0、BBNet1、BBNet2、BBNet3，這四個不同解析度的backbone networks。
1. 訓練決策模塊，以lr = **0.005**，batch size = **160**，optimizer = **SGD (cosine)**，temperature parameter (![](https://hackmd.io/_uploads/B18KQs1s3.png)) = **5**，每個 epoch 結束會乘上 exp(−0.045) 大約 **0.956** (我個人猜測是為了幫助收斂)，epoch = **60,000**(NTU RGB+D 60)、**20,000**(NTU RGB+D 120)。


### 3. 實驗結果 
> NTU RGB+D 60、NTU RGB+D 120 benchmark

![](https://hackmd.io/_uploads/r1FM131s3.png)

```
Backbone BBNet3 (alternative setting)是比照3DV-PointNet++的參數進行訓練
```

> N-UCLA benchmark

![](https://hackmd.io/_uploads/r1omb2ki3.png)

> UWA3DII benchmark

![](https://hackmd.io/_uploads/SJQBb2Jo3.png)

```
作者有提到APSNet是設計給大規模dataset，但投入N-UCLA、UWA3DII這兩個小規模dataset也取得很好的效果
```

> 不同解析度的backbone network比較(BBNet0~3，4種)，NTU RGB+D 60、NTU RGB+D 120 datasets
    
![](https://hackmd.io/_uploads/Bk5yB2Jsh.png)

> 不同解析度的backbone network比較(BBNet1~3，4種)，因為BBNet0的結果較差，所以僅採用1到3種進行比較
> 
> NTU RGB+D 60、NTU RGB+D 120 datasets

![](https://hackmd.io/_uploads/SJoKD2ks2.png)

![](https://hackmd.io/_uploads/rk59P2yo2.png)

> N-UCLA dataset

![](https://hackmd.io/_uploads/rJBiPhkin.png)

> 跟benchmark比較準確度、#FLOPs(平均運算量)、運算時間
> 
> 值得注意的是3DV-PointNet++雖然#FLOPs較少，但其花費的運算時間非常高

![](https://hackmd.io/_uploads/rkzush1o3.png)

### 4. 實驗設備 
> one Nvidia RTX 2080Ti GPU.
### 5. Ablation Study for Backbone Network(都以NTU PGB+D 60 CROSS-SUBJECT為測試資料集)
* **幾何與動作信息對於Backbone Network的影響：**

![](https://hackmd.io/_uploads/BkqDk6Jsn.png)

```
表示幾何與動作信息都是有效被用於Backbone Network裡，BTW w/o是without的意思
```

* **比較不同變體對於Backbone Network的影響：**
    1. ![](https://hackmd.io/_uploads/BkLJE6kj3.png)

        原本![](https://hackmd.io/_uploads/ry5VzZrj2.png)，改成![](https://hackmd.io/_uploads/HyvgbOHo3.png)多了![](https://hackmd.io/_uploads/B1WNbdBo2.png)
的維度資訊。
        * alternative: 90.5%(acc)、10.20G(FLOPs) 
        * original: **90.3%(acc)**、**9.40G(FLOPs)** 
        
    3. ![](https://hackmd.io/_uploads/HyeNVp1in.png)

        ![](https://hackmd.io/_uploads/rkq5CPrj3.png)跟![](https://hackmd.io/_uploads/BJUC0DSjh.png)
的聯集作為input(投入8個frame pairs訓練)。
        * alternative: 90.5%(acc)、12.64G(FLOPs)
        * original: 90.3%(acc)、9.40G(FLOPs)
        
    5. ![](https://hackmd.io/_uploads/B1Fv4Tyin.png)
        * alternative: 90.6%(acc)、17.60G(FLOPs)
        * original: 90.3%(acc)、9.40G(FLOPs)
        
* **比較不同採樣幀數(2T)對於Backbone Network的影響：**

![](https://hackmd.io/_uploads/BkTabdBs3.png)

### 5. Ablation Study for APSNet(都以NTU PGB+D 60 CROSS-SUBJECT為測試資料集)
* **比較不同數量的Backbone Network對於APSNet的影響：**

    * 3 BBNets (i.e., BBNet0, BBNet2, and BBNet3)
    * 5 BBNets (i.e., BBNet0, BBNet1, BBNet2, BBNet3, and BBNet4)
    

![](https://hackmd.io/_uploads/r1FkS_Hin.png)

* **比較有無LSTM Module對於APSNet的影響：**

![](https://hackmd.io/_uploads/rkJDS_Hjn.png)

* **使用最低分辨率當作粗層次的信息就足夠用於決策了嗎？**

    作者也有嘗試以BBNet1(256, 128)作為，decision making module輸入的結果，並用        BBNet0、BBNet2和BBNet3作為fine feature extraction。

    * alternative: 89.1%(acc)、7.42G(FLOPs)
    * original: 90.8%(acc)、7.21G(FLOPs)

    ```
    作者給出的想法是，在decision-making階段使用 BBNet1 提取特徵會需要更多的#FLOPs,
    which limits the #FLOPs allocated at the fine feature extraction stage 
    in this alternative method and thus degrades its performance.(我看不太懂...)
    ```

* **為了進一步展示作者的 APSNet 的有效性，比較其他 APSNet 有兩個變體：APSNet-Rand、APSNet-MultiScale**

**APSNet-Rand:** 在每個frame pair的decision making module使用隨機的方式選擇分辨率進行訓練。
**APSNet-MultiScale:** 對所有分辨率的結果進行平均，並用此產生最終預測結果。(我猜應該就不需要decision making module了)

![](https://hackmd.io/_uploads/ryrfw_Bs3.png)

```
APSNet-A和APSNet-B是由作者的APSNet用兩種不同計算複雜度，去得到準確度與#FLOPs。
沒有說明如何進行複雜度的計算方式，可以看出作者本身的模型效果還是比較好。
```

* **![](https://hackmd.io/_uploads/SkdNmLSs3.png)在公式中對於APSNet的影響：**

![](https://hackmd.io/_uploads/BJKr8OSo2.png)

### 6. Algorithm Analysis(都以NTU PGB+D 60 CROSS-SUBJECT為測試資料集)

* **每個frame pair選擇最佳分辨率的有效性 in APSNet**
* **每個frame pair的限制是FLOPtarget = 0.8G or 1.8G**

![](https://hackmd.io/_uploads/SklyPYBs3.png)

【投擲】的視覺化點雲圖，**在不同複雜度限制下**：

![](https://hackmd.io/_uploads/B1ErPKBo3.png)

【握手】的視覺化點雲圖，**在不同複雜度限制下**：

![](https://hackmd.io/_uploads/HJxoDFSs3.png)

## ✅ CONCLUSION

在這項論文中，作者研究了設計3D動作網絡結構的準確性與效率。作者引入骨幹網絡並提出自適應點採樣網絡（APSNet）3D動作識別。在給定任意的計算複雜度約束(FLOPtarget)，作者的 APSNet 也可以自適應地為每個點雲影片中的frame pairs選擇出最佳分辨率（即最佳點數）。綜合多個基準數據集的實驗證明了新提出的 APSNet 對於高效 3D 的有效性動作識別。
