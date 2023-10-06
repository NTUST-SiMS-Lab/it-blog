---
title: 【論文研讀】DiffPose - SpatioTemporal Diffusion Model for Video-Based HumanPose Estimation
catalog: true
date: 2023-10-05
author: David Chen
categories:
- paper review
- Human Pose Estimation
- Diffusion Model
---
# DiffPose: SpatioTemporal Diffusion Model for Video-Based HumanPose Estimation

[![hackmd-github-sync-badge](https://hackmd.io/wG_eWUUeTiyDWfiBTsGhyg/badge)](https://hackmd.io/wG_eWUUeTiyDWfiBTsGhyg)

* Journal reference: ICCV 2023
* Authors: Runyang Feng, Yixing Gao, Tze Ho Elden Tse, Xueqing Ma, Hyung Jin Chang
* Github: None
* 論文連結: [DiffPose: SpatioTemporal Diffusion Model for Video-Based HumanPose Estimation](https://openaccess.thecvf.com/content/ICCV2023/html/Feng_DiffPose_SpatioTemporal_Diffusion_Model_for_Video-Based_Human_Pose_Estimation_ICCV_2023_paper.html)

---

Diffusion Model 是目前影像生成任務中最火的模型，並且也在其他CV任務有不錯的成效，但是因為影片有額外的時間維度，所以沒辦法將 Diffusion Model 直接擴展到 Video-base 的人體姿勢估計任務。

而且學習 Focus 在人體關鍵點區域在人體姿勢估計任務中很重要，但是怎麼在基於擴散的方法實現這個目標還不清楚。

作者在此論文中提出一個 Diffsion 架構，把 Video-base 的人體姿勢估計看作是一個條件熱圖生成問題
![](https://hackmd.io/_uploads/rkT52Onxa.png)


**並且為了更好地利用時間信息，作者提出了 SpatioTemporal Representation Learner，它聚合跨幀的視覺證據，並使用每個去噪步驟中的結果特徵作為條件。**

提出了 **Lookup-based Multi Scale Feature Interaction** ，用於確定跨多個尺度的局部關節和全局上下文之間的相關性。

主要貢獻：
* 作者是第一個從生成建模的角度研究基於視頻的人體姿勢估計的人。
* 提出了第一個將擴散模型應用於多幀人體姿勢估計的模型，DiffPose。
* 成為 Pose Track2017、PoseTrack2018 和 PoseTrack21資料集目前的SOTA方法。

---

## Method

首先使用現成的物件偵測器來獲得每幀 $I_t$ 中的所有人體邊界框，並把每個邊界框放大 25%，以在連續幀中裁剪同一個人，$\mathcal{I} ^i_t =〈I^i_{t-δ},\, ...,\, I^i_{t},\, ...,\, I^i_{t+δ}〉$ ，$δ$ 為預先設定的時間步長，這樣就得到這個人 $i$ 以 $I_t$ 為關鍵幀的影片 $\mathcal{I} ^i_t$，我們的目標是估計 $I^i_t$ 的關鍵點熱圖。

---

### DiffPose

DiffPose 旨在調整普通擴散模型以合併時間資訊並關注關鍵點區域線索，以適應多幀人體姿勢估計的任務。
![](https://hackmd.io/_uploads/SkL_Utnxa.png)

黃色框框中，Diffusion Model 的 Ground truth 為熱圖 $x_0 = H^i_t$。

此熱圖是使用以註釋的關節位置為中心的 2D 高斯產生的。

接著作者訓練一個 **Pose-Decoder** $f_{\theta}(x_t,\, \mathbb{F}^i_t,\, t)$，透過以 **STRL** 產生的輸入序列 $\mathbb{F}^i_t$ 的時空特徵為條件，從雜訊熱圖 $x_t$ 中恢復 $x_0$。

損失函數如下：
$$ \mathcal{L}_{x_0} = \left \| f_{\theta}(x_t,\,  t) - x_0\right \| $$

---

### Spatiotemporal Representation Learner (STRL)

作者在這裡使用 **cascaded Transformer** 來捕捉視訊幀之間的時空依賴性。

將裁剪好的影片 $\mathcal{I}^i_t$ 作為輸入，作者首先用在 ImageNet 上預訓練的 Vision Transformer 作為 Backbone 來對每一幀提取空間特徵$〈F^i_{t-δ},\, ...,\, F^i_{t},\, ...,\, F^i_{t+δ}〉$。

接著每個幀特徵在空間上重新排列並輸入到 patch embedding 層，將特徵嵌入至token $〈\bar{F}^i_{t-δ},\, ...,\, \bar{F}^i_{t},\, ...,\, \bar{F}^i_{t+δ}〉$

接著 concat 所有 token，透過可學習的 position embedding $E_{POS}$ 來保留它們的空間訊息，並將它們輸入級聯的 Transformer 編碼器，其中每個編碼器由多頭自注意力層(MHSA)和前饋神經網路(FFN)組成。

最後用MLP把所有幀的 encoded 深度特徵 aggregated 起來，以產生時空特徵 $\mathbb{F}^i_t$。

上述過程可以表述為：

$$ \begin{array}{lcl}\tilde{F}^0_t = Concat(\bar{F}^i_{t-δ} \, +\, E^{t-δ}_{POS},\, ...,\, \bar{F}^i_{t+δ}\,+\,E^{t-δ}_{POS}), \\<br>
\tilde{F}^{'l}_t = \tilde{F}^{l-1}_t + MHSA(LN(\tilde{F}^{l-1}_t)), \\<br>
\tilde{F}^{l}_t = \tilde{F}^{'l}_t + FFN(LN(\tilde{F}^{'l}_t)), \\<br>
\qquad\qquad\vdots \\<br>
\mathbb{F}^i_t = MLP(LN(\tilde{F}^L_t)) \end{array}
$$

上標 $l\in [1,2,\dots,L]$ 表示第 $l$ 個 Transformer 層的輸出，$\tilde{F}^0_t$ 表示初始特徵。

LN表示LayerNorm層。

**$\star$ 每個 Transformer 層內的空間和通道尺寸保持不變。**

---

### Pose-Decoder

在得到 $i$ 先生在以第 $t$ 幀為中心採樣的影片的時空特徵 $\mathbb{F}^i_t$ 後，Pose Decoder 以 $\mathbb{F}^i_t$ 和 **sampling step** $t$ 為條件對熱圖 $x_t$ 進行去噪，並輸出預測熱圖 $\hat{x}_0 = \hat{H}^i_t$。

詳細步驟如下：
1. 將**sampling step** $t$ 映射到 embedding 中，並利用 embedding 來重新縮放初始雜訊熱圖 $x_t$，以獲得該幀的自適應版本熱圖 $\bar{x}_t$。
2. 透過Transformer 或卷積結構對 $\mathbb{F}^i_t$ 和 $\bar{x}_t$ multi scale 的全局相關性進行建模，並獲得 multi scale 特徵 $\mathcal{F}^i_t = {\mathcal{F}^{i,1}_t, \mathcal{F}^{i,2}_t, \mathcal{F}^{i,3}_t}$。
3. 最後把這些特徵整合起來並傳遞到檢測頭以預測姿勢熱圖 $\hat{H}^i_t$。

為了鼓勵 $\mathcal{F}^i_t$ 關注關鍵點位區域，作者提出了一種基於查找的多尺度特徵交互機制 (Lookup-based Multi-Scale Feature Interaction mechanism, **LMSFI**) 來歸納 $\mathbb{F}^i_t$ 和 $\bar{x}_t$ 之間的模型相關性。

LMSFI主要由兩個過程組成：
* 產生尺寸相同的成對特徵。
* 基於查找的特徵交互。

---
#### Pairwise size-matched feature generation

分別對不同空間維度的 $\mathbb{F}^i_t\in\mathbb{R}^{C\times H\times W}$ 和 $\bar{x}_t\in\mathbb{R}^{c\times 4H\times 4W}$ 進行上採樣和下採樣以產生大小相同的特徵對 $⟨\mathbb{F}^i_t, \bar{x}_t⟩$。

詳細步驟如下：
1. 使用反卷積層對 $\mathbb{F}^i_t$ 進行 $1\times$、$2\times$ 和 $4\times$上取樣，並獲得對應的特徵 $\begin{Bmatrix}\mathbb{F}^{i,1}_t, \mathbb{F}^{i,2}_t, \mathbb{F}^{i,3}_t\end{Bmatrix}$。
2. 同理，使用卷積層對 $\bar{x}_t$ 進行下取樣，以產生$\begin{Bmatrix}\bar{x}^1_t, \bar{x}^2_t, \bar{x}^3_t\end{Bmatrix}, (\bar{x}_t = \bar{x}^3_t)$ 

由以上兩個步驟，可以得到尺寸相同的 multi-scale 特徵對 $⟨\mathbb{F}^{i, J}_t, \bar{x}^J_t⟩$。
上標 $J = \begin{Bmatrix}1,2,3\end{Bmatrix}$ 代表從低到高不同的解析度。

---

#### Lookup-based feature interaction

作者在實驗中發現，直接將 $\mathbb{F}^{i, J}_t$ 和 $\bar{x}^J_t$ 整合起來的特徵 $\mathcal{F}^{i,j}_t$ 效果不好。

在實踐中，熱圖揭示了包含關節的位置的可能性，但是噪聲熱圖 $\bar{x}^J_t$ 被破壞，只能提供微乎其微的有效資訊。

所以作者決定採用歸納建模策略，首先根據熱圖 $\bar{x}^j_t$ 對時空特徵 $\mathbb{F}^{i,j}_t$ 進行查找，檢索局部聯合特徵 $\bar{\mathbb{F}}^{i,j}_t$ ，然後對局部特徵 $\bar{\mathbb{F}}^{i,j}_t$ 和普通全域上下文 $\mathbb{F}^{i,j}_t$ 之間的相關性進行建模。

以下詳解：
考慮到 self-attention 的計算複雜度隨著輸入分辨率的增加呈二次方增加，作者採用了一種複合結構，使用 Transformer 和卷積分別擷取低分辨率和高分辨率下的特徵交互。

* 對於低解析度特徵對 $⟨\mathbb{F}^{i, 1}_t, \bar{x}^1_t⟩$：
    1. 將雜訊熱圖 $\bar{x}^1_t$ 嵌入到特徵token中，然後利用 Transformer 編碼器執行自我優化以產生 $\bar{\bar{x}}^1_t$。
    2. 在 $\bar{\bar{x}}^1_t$ 上沿著深度維度取最大激活值以將全域通道資訊壓縮到單通道描述符中，然後使用 sigmoid 函數來獲得 attention mask $A^1$，用來表示可能的關鍵點位區域的。
    3. 使用 attention mask $A^1$ 來檢索對應的時空特徵 $\bar{\mathbb{F}}^{i,1}_t$。
    4. 透過級聯 Transformer 來對 $\bar{\mathbb{F}}^{i,1}_t$ 和 $\mathbb{F}^{i,1}_t$ 進行連接和處理，然後對解析度進行上採樣以輸出特徵 $\mathcal{F}^{i,1}_t$。
    上述過程可以表述為：
    $$ \begin{array}{lcl} \bar{\bar{x}}^1_t = SeRef(\bar{x}^1_t), \\<br>
    A^1 = Sigmoid(Sq(\bar{\bar{x}}^1_t)), \\<br>
    \bar{\mathbb{F}}^{i,1}_t = A^1 \odot \mathbb{F}^{i,1}_t, \\<br>
    \mathcal{F}^{i,1}_t = Up(Trans(\bar{\mathbb{F}}^{i,1}_t \oplus \mathbb{F}^{i,1}_t))
    \end{array} $$

    其中 $SeRef(\cdot)$、$Sq(\cdot)$、$\odot$、$\oplus$ 和 $Up$ 分別表示：自優化、壓縮、空間乘法、Concatenation 和 Upsampling。

* 對於高解析度特徵對 $⟨\mathbb{F}^{i, j}_t, \bar{x}^j_t⟩,\,\, \begin{Bmatrix}j = 2,3\end{Bmatrix}$，使用卷積執行類似過程，差在把自優化跟 Transformer 改成卷積層以避免計算複雜度太高，表述如下：
$$ \begin{array}{lcl} \bar{\bar{x}}^j_t = Conv(\bar{x}^j_t), \\
A^j = Sigmoid(Sq(\bar{\bar{x}}^j_t)), \\
\bar{\mathbb{F}}^{i,j}_t = A^j \odot \mathbb{F}^{i,j}_t, \\
\mathcal{F}^{i,j}_t = Up(Conv(\bar{\mathbb{F}}^{i,j}_t \oplus \mathbb{F}^{i,j}_t))
\end{array} $$
    
以下是作者對以上提出的兩個方法做的消融實驗：
![](https://hackmd.io/_uploads/r1ZNbrpx6.png)

以下為進行 **LMSFI** 的前後對比圖，Base line 為未使用 **LMSFI** 的結果：
![](https://hackmd.io/_uploads/rk63bHTlp.png)

---

#### Heatmap generation

最後透過逐元加法整合所有尺度 $\begin{Bmatrix}\mathcal{F}^{i,1}_t, \mathcal{F}^{i,2}_t, \mathcal{F}^{i,3}_t \end{Bmatrix}$ 的特徵，並使用檢測頭 ($3\times3 \;conv$) 來產生預測的熱圖 $\hat{\mathbf{H}}^i_t$。

---

### Overall Training and Inference Algorithms

以下為 DiffPose 的整體訓練過程：
![](https://hackmd.io/_uploads/H1U0UB6lp.png)

根據 $\alpha_t$ 高斯雜訊進行取樣並將它們加入Ground Truth 熱圖中以獲得雜訊樣本。
每個取樣步驟 $t$ 的參數 $\alpha_t$ 都跟 [DDPM](https://arxiv.org/abs/2006.11239) 預先定義的一樣。

作者採用標準姿態估計損失來監督模型訓練：
$$ \mathcal{L} = \left \| \mathbf{H}^i_t - \hat{\mathbf{H}}^i_t\right \|^2_2 $$ 

---

## Experiments

以下為 DiffPose 處理具有挑戰性的場景（例如相互遮蔽和快速運動）的 Demo。
![](https://hackmd.io/_uploads/BkzoiS6xp.png)

以下為 DiffPose 與當前 SOTA 的方法 b) FAMI-Pose 和 c) HRNet 的並排比較處理具有挑戰性的場景（例如相互遮蔽和快速運動）的能力。
![](https://hackmd.io/_uploads/Hy0OcSpg6.png)

