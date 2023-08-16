---
title: 【論文研讀】AcT - Action Transformer
catalog: true
date: 2023-08-16
author: Kevin Huang
categories:
- paper review
- transformer
---

[![hackmd-github-sync-badge](https://hackmd.io/OmkcmbXoRxS6KPY6ll3k2w/badge)](https://hackmd.io/OmkcmbXoRxS6KPY6ll3k2w)

# [Action Transformer: A Self-Attention Model for Short-Time Pose-Based Human Action Recognition](https://arxiv.org/abs/2107.00606)(arXiv)

### Journal reference: 
*Pattern Recognition, Volume 124, **April 2022**, 108487*

### Authors: 
*Vittorio Mazzia, Simone Angarano, Francesco Salvetti, Federico Angelini, Marcello Chiaberge*

[MPOSE2021 github](https://github.com/PIC4SeR/MPOSE2021_Dataset)

[AcT github](https://github.com/PIC4SeR/AcT)

## 論文重點整理
1. 作者引入了 AcT 網絡，它具有簡單且完全自註意力的架構，其性能顯著優於常用的 HAR 模型。
2. 在之前的 HAR 和姿態估計研究的基礎上，所提出的方法利用短時間序列的 2D 骨架作為特徵，為實時應用提供準確且低延遲。特別是在有限制的計算與設備情況下，AcT 的卓越效率可用於邊緣 AI，即使在計算能力有限的設備上也能實現良好的性能。
3. 作者引入了 MPOSE2021，這是一個用於短時人類動作識別的大型開源數據集，試圖為該主題的未來研究建立正式的基準。



## 論文主要貢獻

1. 作者研究了 Transformer encoder 在基於 2D 人體姿態辨識應用，並提出了新穎的 AcT 模型，證明完全自注意力架構可以優於其他 HAR 現有的卷積和循環模型。

2. 作者引入了 MPOSE2021 資料集，一個實時短時 HAR 數據集，適用於基於姿勢和RGB的方法。它包含 15429 個樣本，100 名受試者分別執行 20 種動作，擁有不同的場景，每個場景的幀數有限（20 到 30 之間）。與其他公開可用的數據集相比，在幀數的有限性下，刺激了以低延遲和高吞吐量執行 HAR 的實時方法的開發。

## Related works
### 1. 作者專注於視頻(2D)的分析方式優點
在視頻分析的方面，可通過 OpenPose 和 PoseNet 等姿勢檢測身體關節作為 2D 坐標，其方法廣泛應用於簡單的 RGB 相機。相反，3D 骨架數據需要特定的傳感器來獲取，例如 Kinect 或其他立體相機。這帶來了很大的限制，例如可用性、成本、有限的工作範圍（Kinect 的情況下可達 5-6 m）以及室外環境中的性能下降。

### 2. 專門為短時 HAR 設計的架構與數據集
相比於先前的方法，作者提出了一種完全基於 Transformer encoder的 HAR 架構，沒有任何卷積層或循環層。MPOSE2021 數據集包括時間持續時間最多為 30 幀的樣本，使其成為更合適測試短時 HAR 模型和低延遲性的基準。

## The MPOSE2021 dataset
* 從先前流行的 HAR 數據集收集數據：
`Weizmann, i3DPost, IXMAS, KTH, UTKinetic-Action3D (RGB only), UTD-MHAD (RGB only), ISLD, and ISLD-Additional-Sequences(共8個)。`~~要再去了解部分資料集的內容~~

![](https://hackmd.io/_uploads/HJc4Z043n.png)

* 由於不同數據集的操作存在異質性，標籤被重新映射到 20 個常見類別的列表，無法相應地重新映射的操作將被丟棄。可以被映射的動作，視頻就被分為每個30幀的非重疊樣本（剪輯），並保留超過20幀的尾部樣本。

## Action Transformer 架構介紹
* **Overview of the Action Transformer architecture:**

    ![](https://hackmd.io/_uploads/HkM6P-rn3.png)
    
    1. Input: RBG 影片(T frames of dimension H × W)。
    2. 使用預訓練好的 OpenPose 或 PoseNet 模型，逐幀找出 2D pose 的關節點。
    3. Linear Projection of Pose Features，將每幀所有骨架點特徵 (骨架點數量乘上每個骨架特徵共4個) 轉換成 1D 的 token (有幾個 T 就有幾個 token)。
    4. 承第三個步驟得到的陣列，加上 positional information 的 token，position 的數量對應為 n+1 (n 為 input 影片幀數)，【*】為起始資訊的 token，position 為 0。
    5. 所有 token 投入 Transformer Encoder 裡，再經過 MLP 與 Softmax 輸出動作分類結果。

* **Transformer encoder layer architecture (left) and schematic overview of a multi-head self-attention block (right):**

    ![](https://hackmd.io/_uploads/Sk9NObH33.png)

    Transformer Encoder(左圖) x **L層**:
    1. Input: 每幀關節點轉換成的 token，以及*起始資訊的token。
    2. Multi-Head Self-Attention
    3. Dropout
    4. 先做residual connections([殘差連接](https://kknews.cc/zh-tw/code/ejn4omn.html)), 再做[Layernorm](https://zhuanlan.zhihu.com/p/395855181)
    5. Feed Forward: 
        * 第一層擴增維度從Dmodel 到 Dmlp(4 · Dmodel)。(MLP + [GeLu non-linearity](https://medium.com/@shauryagoel/gelu-gaussian-error-linear-unit-4ec59fb2e47c)(激活函數))
        * 第二層進行降維從Dmlp to Dmodel。(還原成原本的維度)
    6. Dropout
    7. 先做residual connections([殘差連接](https://kknews.cc/zh-tw/code/ejn4omn.html)), 再做[Layernorm](https://zhuanlan.zhihu.com/p/395855181)

    Multi-Head Self-Attention(右圖):
    1. Input: 每幀關節點轉換成的 token，以及*起始資訊的token。
    2. Split: 將 token 額外乘上 H x W 個權重(Q、K、V都一樣)
    
    ![](https://hackmd.io/_uploads/BkeLWAr3n.png)
    
* Action Transformer 四種不同版本的參數調整：

    ![](https://hackmd.io/_uploads/HyMANkUnn.png)


## EXPERIMENTS
### 1. MPOSE2021資料集
T = 20~30 and P = 52(OpenPose) or 68(PoseNet) features
* OpenPose: 13 個關節點，4個參數 (position x, y and velocities Vx , Vy )
-->velocities Vx , Vy沒有說明是如何取得的。
* PoseNet: 17 個關節點，4個參數 (position x, y and velocities Vx , Vy )
-->velocities Vx , Vy沒有說明是如何取得的。

訓練模型的超參數設置：![](https://hackmd.io/_uploads/B1SlGT8hn.png)

* 實驗設備：on a PC with **32-GB RAM**, an **Intel i7-9700K CPU**, and an **Nvidia 2080 Super GP-GPU**.

### 2. 短時 HAR 不同 Benchmark 比較(Openpose)

> OpenPose vs PoseNet:
> 
> **PoseNet** 專為在瀏覽器或移動設備等輕量級設備上運行而構建([Edge AI](https://wiseocean.tech/edge-ai-semi-opportunities/))，而 **OpenPose** 更加準確，並且旨在在 GPU 驅動的系統上運行。

![](https://hackmd.io/_uploads/S11MNaUh3.png)
![](https://hackmd.io/_uploads/BkkfraUn3.png)

> Split: Split 1、Split 2、Split 3

隨機抽取21位受測者作為testing，其餘的人作為training
![](https://hackmd.io/_uploads/BJWw7ALhh.png)

> Balanced %: 

![](https://hackmd.io/_uploads/HynvfC83n.png)

### 3. 短時 HAR 不同 Benchmark 比較(PoseNet)

![](https://hackmd.io/_uploads/BkkrE082h.png)

### 4. Latency measurements

> 使用[TFLite Benchmark tool](https://www.tensorflow.org/lite/performance/measurement)進行延遲評測
>
>基準測試：使用 8 個線程執行 10 次預熱運行，然後執行 100 次連續前向傳遞。
>
> 2種CPUS: Intel i7-9700K(PC) & ARM-based HiSilicon Kirin 970(mobile phone)

![](https://hackmd.io/_uploads/By-dD0L22.png)

此圖測試了 Intel CPU 和 ARM CPU 的延遲。基於 Transformer 的架構的巨大計算效率，而卷積網絡和循環網絡會導致 CPU 使用率更高。

## Conclusion and future work
以下是作者提供的優缺點以及未來研究：

優點：
1. 作者引入了 AcT 網絡，它具有簡單且完全自註意力的架構，其性能顯著優於常用的 HAR 模型。
2. 在之前的 HAR 和姿態估計研究的基礎上，所提出的方法利用短時間序列的 2D 骨架作為特徵，為實時應用提供準確且低延遲。特別是在有限制的計算與設備情況下，AcT 的卓越效率可用於邊緣 AI，即使在計算能力有限的設備上也能實現良好的性能。
3. 作者引入了 MPOSE2021，這是一個用於短時人類動作識別的大型開源數據集，試圖為該主題的未來研究建立正式的基準。

缺點：
1. 沒有利用關節點之間的關係信息(不像GCN會考量點與點之間連結性)。

未來研究：
1. 具有 3D 骨架(點雲)和長序列輸入的 AcT 架構
2. 嘗試將骨架圖作為預先知識納入positional embedding中，並不影響延遲。

以下是我自己的想法跟疑問：

缺點：
1. 作者沒有呈現出實時部份的實驗結果。(在 github 上有一個動圖，但也沒有表明是否為 Act 網路的實測演示)

未來研究：
1. 可以嘗試其他較細微的關節點作為特徵投入，如：手部or臉部資訊。

疑問：
1. 作者有提到每個關節點都會有4個特徵(position x, y and velocities Vx , Vy)，作者沒有說明 Vx 跟 Vy 是怎麼取得的。 
2. 作者也有提到Benchmark裡有些模型會使用，[集成架構(Ensemble Models)](https://ithelp.ithome.com.tw/articles/10247936)的方式來減少模型[方差](https://jason-chen-1992.weebly.com/home/-bias-variance-tradeoff)，因此作者也分別創建三個集成版本，分別具有 2、5 和 10 個 AcT-μ 實例，但我不知道作者是用什麼方法如何建立集成架構。
