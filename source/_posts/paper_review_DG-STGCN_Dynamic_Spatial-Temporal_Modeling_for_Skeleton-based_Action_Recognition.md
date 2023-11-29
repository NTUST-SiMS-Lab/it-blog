---
title: 【論文研讀】DG-STGCN:Dynamic Spatial-Temporal Modeling for Skeleton-based Action Recognition 
catalog: true
date: 2023-11-29
author: Kevin Huang
categories:
- paper review
- HAR
- Action Recognition
- GCN
- Skeleton-based
---
# [DG-STGCN: Dynamic Spatial-Temporal Modeling for Skeleton-based Action Recognition](https://arxiv.org/abs/2210.05895v1)(arXiv)

### :small_blue_diamond: Reference: 
*Computer Vision and Pattern Recognition*

*arXiv preprint arXiv:2210.05895, 2022.*

### :small_blue_diamond: Authors: 
*Haodong Duan, Jiaqi Wang, Kai Chen, Dahua Lin*

### :small_blue_diamond: Github:
[pyskl](https://github.com/kennymckormick/pyskl) -> [DG-STGCN](https://github.com/kennymckormick/pyskl/blob/main/configs/dgstgcn/README.md)

## :white_check_mark: 論文主要解決的問題
* 歷代的STGCN演進

![image](https://hackmd.io/_uploads/HkqyxJ0Ea.png)

1. 依賴手動定義的骨架拓撲，需要針對不同資料集的精心自訂。更重要的是，由於執行動作時關節間的內在配合，完全可學習係數矩陣，而不是規定的圖形結構，更合適建模複雜的聯合相關性。
2. 基於 GCN 的方法主要利用固定感受野的時間來模擬一定時間範圍內的關節級運動，而忽略了在動態時間感受野內模擬多層次（即關節級 + 骨架級）運動模式的好處。

## :white_check_mark: 論文主要貢獻
1. DG-STGCN純粹基於可學習係數矩陣進行空間建模，消除了手動定義骨架拓撲的繁瑣過程。

2. 動態分組設計使得動態時空使用多樣化的圖卷積組對骨架運動進行建模和時間卷積，提高表示能力和彈性。

3. DG-STGCN在多個基準上取得顯著改進同時保持模型效率。

## :white_check_mark: Related works
### 1. 圖神經網路(Graph Neural Networks)

圖神經網路(GNN)被廣泛採用進行了廣泛的探索。GNN通常可以分為譜GNN和空間GNN。譜GNN在譜域上應用卷積。他們假設所有樣本之間存在固定的鄰接關係，從而限制了普遍性到看不見的圖形結構。相較之下，空間GNN執行透過局部特徵融合和活化對每個節點進行逐層特徵更新。

大多數基於骨架的動作辨識的GCN方法都遵循空間GNN的精神：他們根據骨架建立了時空圖數據，應用卷積進行鄰域中的特徵聚合，並執行逐層特徵更新。


### 2. 基於骨架的動作辨識(Skeleton-based Action Recognition)

早期方法設計手工製作的特徵來捕捉關節運動模式並將它們直接送入下游分類器。隨著繁榮在深度學習中，以下方法將骨架資料視為時間序列並使用循環神經網路和時間來處理它們卷積網。

GCN在基於骨架的動作辨識上的早期應用是STGCN。ST-GCN使用堆疊的GCN區塊來處理骨架數據，而每個區塊由一個空間模組和一個時間模組組成，並作為一個簡單的基線。

在時間建模中，使用先進的多尺度TCN來代替簡單的實現，能夠對具有多個持續時間的操作進行建模。

Shift-GCN採用圖升降技術進行連接間特徵融合。特徵融合，而SGN則根據輸入的序列，透過輕量級注意模組來估計係數矩陣。而SGN則根據輸入序列和輕量級注意力模組來估計係數矩陣。

另一個工作流程採用了卷積神經網絡（CNN）用於基於骨架的動作識別。基於2D-CNN轉換的方法將骨架序列轉換為偽影像並使用2D CNN 對其進行處理。

PoseC3D擁有沿時間維度的一張熱圖，並使用3D-CNN進行重建處理。雖然PoseC3D的性能令人印象深刻，但其計算量更大，不能直接評估三維模型。計算量增大，無法直接無損地評估3D
骨架。

## :white_check_mark: DG-STGCN
* **DG-STGCN的改進主要體現在兩個方面：**

    1. 作者設計動態組 GCN (DG-GCN) 和動態組時態 ConvNet (DG-TCN)，促進高度靈活和數據驅動的時空建模的骨架數據。
    2. 開發了強大的時態資料增強策略，它普遍適用於不同的骨幹網，並且特別有益到高動態 DG-STGCN。

* **ST-GCN回顧**

    ![image](https://hackmd.io/_uploads/BkvQWQfB6.png)


    1. inputs: $X ∈ R^{T×V ×C}$（每個人的T×V×C張量X），T表示時間長度，V表示骨架關節的數量，C表示通道數（2或3，XY座標或XY座標加D深度）。![image](https://hackmd.io/_uploads/BJZFbJGra.png)
    
    2. 用於空間建模的係數矩陣 $A∈R^{K×V×V}$，K表示矩陣數（作者也稱為組數）。
    
    3. 用$F$表示GCN區塊，$G$、$T$分別表示空間模組和時間模組。
    
    4. ST-GCN利用擁有的N個GCN塊（N = 10）來處理座標張量。![image](https://hackmd.io/_uploads/rkgnIkfrp.png)
    
    5. GCN塊F包含兩個組件：一個空間模塊G和一個時間模塊T。給定一個骨架特徵$X ∈ R^{T×V×C}$，G首先執行通道膨脹和重塑以獲得4D張量$X' ∈ R^{T×K×V×C}$，然後使用一組係數矩陣A進行關節間的空間建模： ![image](https://hackmd.io/_uploads/Sk24MQMBp.png)
    
    6. G的輸出進一步由T進行處理以學習時間特徵。F的計算可以總結為：![image](https://hackmd.io/_uploads/rJGqzXzSa.png)

* **DG-GCN：從零開始的動態空間建模**

    在本研究中，作者保持整體架構不變，提議使用動態群組GCN和動態群組TCN來增強其能力。
    
    在先前的工作中，一種常見的做法是首先將A設置為一系列手動定義的稀疏矩陣（從關節的鄰接矩陣導出），並在模型訓練期間學習細化ΔA。ΔA可以是靜態的，作為可訓練的參數，也可以是動態的，根據輸入樣本由模型生成。儘管直觀，作者認為這種範式在靈活性上存在限制，可能導致比純數據驅動方法更差的識別性能。
    
    **係數矩陣A設置為完全可學習的**。在DG-GCN中，$A ∈ R^{K×V×V}$是一個可學習的參數，而不是一組手動定義的矩陣。在初始化時，作者直接使用**常態分佈初始化A**，而不是求解鄰接矩陣的導出。通過隨機初始化，K可以設置為任意值，從而實現DG-GCN中的新型多組設計。
    
    * **DG-GCN架構：**![**image](https://hackmd.io/_uploads/B1y1nmGST.png)
        1. 在DG-GCN中，係數矩陣A包含K個不同的組件（在實驗中K = 8）。
        2. 輸入（帶有C個通道）首先通過1×1卷積進行處理，以生成K個特徵組（每個組具有⌊ C/K ⌋個通道）。
        3. 對每個特徵組使用相應的A~i~進行獨立的空間建模。
        4. K個特徵組在通道維度上連接(concat)，然後通過另一個1×1卷積進行處理以生成輸出。
    
    * **係數矩陣A~i~：** 每個係數矩陣Ai包含三個可學習的組件。
    
        1. 通過整個訓練過程學習的數據集參數PA~i~（靜態項）。
        2. DA~i~和CA~i~，分別作為動態項。
        3. 給定輸入特徵X，首先使用時間池化消除維度T。然後，分別對$\overline{X}$應用兩個獨立的1×1卷積以獲得X~a~和X~b~。
        4. DA~i~：![image](https://hackmd.io/_uploads/SyPlENGrT.png)CA~i~：$CA_i ∈ R^{C×V×V}$，通過將Tanh激活應用於X~a~和X~b~之間的兩兩差異來獲得CA~i~。
        5. 係數矩陣使用三個組件的加權和：![image](https://hackmd.io/_uploads/BJ2TwNMr6.png)
        6. $α$，$β$是兩個可學習的參數。

* **DG-TCN：具有動態接頭的多組TCN融合**

    作者還在時間建模中採用了動態分組設計。首先用一個多組TCN替換了普通的時間模塊。
    
    ![image](https://hackmd.io/_uploads/ByvpWBGSa.png)
    
    多組TCN由多個**具有不同感受野**的分支組成。每個分支獨立對一個特徵組進行時間建模（具有六個分支：4個帶有膨脹[1, 2, 3, 4]的卷積核為3的1D卷積分支，一個卷積核為3的最大池化分支，以及一個1 × 1卷積分支）。與ST-GCN中T的普通實現相比，多組設計不僅**節省了大量計算**，還大幅**提高了時間建模的能力**。
    
    作者提出在**關節級和骨架級同時進行時間的D-JSF建模**，用於明確建模並動態融合關節級和骨架級特徵。
    
    * D-JSF模塊：
    
        1. 首先對V個關節級特徵X~1~到X~V~，$X_i ∈ R^{C×T}$執行平均池化，以獲得骨架級特徵S。
        2. 多組TCN同時處理骨架特徵S和V個關節特徵X~i~以獲得S', X'~i~。然後應用動態關節-骨架融合將S'合併到每個X'~i~。
        3. 具體而言，每個DG-TCN實例包含一個學習的參數$γ ∈ R^V$。
        4. 在自適應的關節-骨架融合後，關節i的特徵為X'~i~ + γ~i~S'，並進一步使用1×1卷積進行處理。

* **作為時態資料增強的均勻取樣**

    由於DG-STGCN中廣泛使用了動態分組模塊，模型容量得到了大幅提升。同時，改進的靈活性也提高了過擬合的風險，使得強大的數據增強變得極為重要。
    
    採用隨機裁剪作為時間增強的策略：從原始序列中裁剪一個子字符串，並使用[雙線性插值](https://zhuanlan.zhihu.com/p/110754637)將其調整為目標長度。
    
    ![image](https://hackmd.io/_uploads/S1RtdHfrT.png)

## :white_check_mark: EXPERIMENTS
### 1. 資料集

* NTU-60 & NTU-120：

    NTU-60，包含60個人類動作的57K視頻。NTU-120，包含120個人類動作的114K視頻。數據集以三種方式劃分：跨主題（X-Sub），跨視圖（X-View，適用於NTU-60），跨設置（X-Set，適用於NTU-120），在這三種方式中，培訓和驗證中的動作主題，攝像機視圖，攝像機設置是不同的。

* [BABEL](https://babel.is.tue.mpg.de/)：是一個用於具有語義的人體運動的大規模數據集。它使用[AMASS](https://amass.is.tue.mpg.de/)中∼43.5小時的mocap進行標註。BABEL從[SMPL-H](https://smpl.is.tue.mpg.de/)網格的頂點中預測用於NTURGB+D的25個關節骨架，並將其用於基於骨架的動作識別。BABEL有兩個版本，分別包含60（BABEL60）和120（BABEL120）個動作類別。

*  [Toyota SmartHome](https://project.inria.fr/toyotasmarthome/)：是一個聚焦於人類日常活動的視頻數據集。該數據集包含16K視頻和31種不同的日常生活動作。視頻來自7個不同的攝像機視圖。數據集以兩種方式劃分：跨主題（CS）或跨視圖（CV1：一個視圖進行培訓；CV2：五個視圖進行培訓）。我們僅在其Pose V1.2標註中使用3D關節進行訓練，並報告CS和CV1拆分的結果。

### 2. Implementation Details
DG-STGCN遵循ST-GCN的基本設置。

* 10個GCN塊：每個GCN塊包含一個DG-GCN和一個DG-TCN。
* 基本通道寬度設置為64，在第5個和第8個GCN塊中，我們執行時間池化以將時間長度減半，同時將通道寬度加倍。
* 帶有動量(momentum)0.9和權重衰減(weight decay)5e−4的SGD進行訓練。
* 批量大小(Batchsize)：128
* 初始學習率(lr)：0.1
* epoch：使用[CosineAnnealing](https://paperswithcode.com/method/cosine-annealing)學習率調度程序訓練模型100個epoch。
*  使用**均勻抽樣**來從骨架數據中抽樣子序列以形成訓練樣本。
* 在消融研究(ablation study)中，我們將輸入長度設置為64。與最先進技術(state-of-the-arts)的比較中，我們將輸入長度設置為100。



### 3. Ablation study
作者在兩個大規模基準測試上訓練DG-STGCN：NTU120-XSub和NTU120-XSet。我們以關節模態為輸入，並按照[[Channel-wise topology
refinement graph convolution for skeleton-based action recognition]](https://arxiv.org/abs/2107.12213)中的預處理進行操作。我們的基準使用GCN進行空間建模，其係數矩陣（3個組件）進行了隨機初始化，並使用多分支TCN（具有六個分支：4個帶有膨脹[1, 2, 3, 4]的卷積核為3的1D卷積分支，一個卷積核為3的最大池化分支，以及一個1 × 1卷積分支）進行時間建模。

> * **Is a pre-defined topology
indispensable?**
>找出預定義的圖形結構對空間建模的重要性。我們考慮了三種替代方案：
>1）預先定義的固定拓撲(Pre-defined + fix)，
>2）帶有靜態可學習改進(Pre-defined + refine)，
>3）從頭開始隨機初始化的可學習拓撲(From scratch)
>    ![image](https://hackmd.io/_uploads/SynIOaMra.png)
    
> * **Dynamic Group GCN (DG-GCN)**
>    ![image](https://hackmd.io/_uploads/ryMKR6MS6.png)

> * **How much data does DG-GCN require? & Dynamic Group TCN (DG-TCN).**
    ![image](https://hackmd.io/_uploads/BkijAafBa.png)
    
> * **Uniform Sampling as Temporal Data Augmentation**
    ![image](https://hackmd.io/_uploads/B1z6RpfBT.png)

### 3. Comparisons with the State-of-the-Art
> * **NTURGB+D & Kinetics-400**
![image](https://hackmd.io/_uploads/H1DG1CGHp.png)

> * **BABEL & Toyota SmartHome**
![image](https://hackmd.io/_uploads/BJXLkCfSa.png)

## :white_check_mark: Conclusion
1. 提出了一個高度動態的框架DG-STGCN，用於骨架數據的時空建模。
2. DG-STGCN包括兩個具有動態多組設計的新模塊，即**DG-GCN**和**DG-TCN**。對於空間建模，DG-GCN將關節級特徵與從頭學習的係數矩陣融合，不依賴預定義的圖形結構。同時，DG-TCN採用組內時間卷積，具有多樣化的感受野，並使用動態的關節-骨架特徵模塊進行多層次的時序建模。