---
title: 【論文研讀】Learning Structure-Guided Diffusion Model for 2D Human Pose Estimation
catalog: true
date: 2023-10-27
author: David Chen
categories:
- paper review
- Human Pose Estimation
- Diffusion Model
---
# Learning Structure-Guided Diffusion Model for 2D Human Pose Estimation

[![hackmd-github-sync-badge](https://hackmd.io/BX18gfwdQ9iS0NT7iMvc0Q/badge)](https://hackmd.io/BX18gfwdQ9iS0NT7iMvc0Q)

* Journal reference: arXiv: 2306.17074
* Authors: Zhongwei Qiu, Qiansheng Yang, Jian Wang, Xiyu Wang, Chang Xu, Dongmei Fu, Kun Yao, Junyu Han, Errui Ding, Jingdong Wang
* Github: None
* 論文連結: [Learning Structure-Guided Diffusion Model for 2D Human Pose Estimation](https://arxiv.org/pdf/2306.17074.pdf)

---

本文提出 **DiffusionPose** 將 2D HPE 模擬為**從雜訊熱圖產生關鍵點熱圖**的問題。

## Method
下圖為 **DiffusionPose** 的架構圖，共有三種過程：
* 前向擴散過程 Forward Diffusion Process, FDP (藍色流程線)
* 模型前向過程 Model Forward Process, MFP (黑色流程線)
* 反向擴散過程 Reverse Diffusion Process, RDP (紅色流程線)

**Training PiPe Line：**
1. FDP 透過添加高斯雜訊將真實人類關鍵點 $y_0$ 擴散到雜訊關鍵點 $y_t$。
2. 將 $y_t$ 進一步用於產生特徵掩模 $y^{mask}_t$。
3. MFP以特徵掩模 $y^{mask}_t$ 從輸入影像 $x$ 中提取擴散模型的特徵條件 $x^c$。
4. DiffusionPose 的解碼器學著利用特徵條件 $x^c$ 來把雜訊熱圖 $y^{hm}_t$ 恢復成 Ground Truth 熱圖 $y^{hm}_0$。

**Inference Pipe Line：**
1. RDP 透過擴散解碼器從雜訊熱圖 $y^{hm}_t$ 以漸進式去噪的方式恢復熱圖 $y^{hm}_0$。
2. 從估計出來的熱圖 $y^{hm}_0$ 中解碼關鍵點座標 $y_0$。

![](https://hackmd.io/_uploads/BJoDCGVMp.png)

### Forward Diffusion Process (FDP)(重點是特徵掩模)

給定以下資訊：
* **GT 關鍵點** $y_0 \in \mathbb{R}^{J\times2}$
* **time step** $t \in [1,T]$

**FDP** 會生成：
* 雜訊熱圖 $y^{hm}_t \in \mathbb{R}^{J\times H\times W}$
* 特徵掩模 $y^{mask}_t$

公式如下：$$\begin{align}
y_t& = q(y_t | y_0, \zeta) \\
& = \sqrt{\gamma_t}(\zeta\  \cdot\ y_0)\  + \ \sqrt{1-\gamma_t}\epsilon,\epsilon \sim \mathcal{N}(0,I) \\
\end{align}$$
以上是DDPM裡的原公式，不要推導，會死得很難看，$\zeta$ 為控制訊號與雜訊比例的尺度參數。

生成雜訊熱圖 $y^{hm}_t$ 與特徵掩模 $y^{mask}_t$ 的公式：$$	
\begin{array} \\
y^{hm}_t = \phi(y_t,\sigma), \\
y^{mask}_t = \begin{Bmatrix} M^{kps},M^{ske} \end{Bmatrix} = {\varphi}(y_t,\delta_{kps},\delta_{ske})
\end{array}$$
$\phi (\cdot)$ 為透過關鍵點 $y_t$ 的中心和參數 $\sigma$ (引用自 [Simple Baselines for Human Pose Estimation and Tracking](https://openaccess.thecvf.com/content_ECCV_2018/papers/Bin_Xiao_Simple_Baselines_for_ECCV_2018_paper.pdf)) 來生成 2D 高斯熱圖的公式。
$\varphi(\cdot)$ 為根據關鍵點 $y_t$ 來生成 2D 關鍵點掩模 $M^{kps}$ 和 骨架掩模 $M^{ske}$，$\delta_{kps}$ 和 $\delta_{ske}$ 則用來控制掩模的寬度

### Model Forward Process (MFP)
Diffsion Model $f_{\theta}$ 包括**編碼器** $E(\cdot)$、**空間通道交叉注意(SC-CA)模組** $A(\cdot)$、**解碼器** $D(\cdot)$。

給定以下資訊：
* 大小為 $H_x \times W_x$ 的圖像 $x$
* 雜訊熱圖 $y^{hm}_t$
* 特徵遮罩 $M^{kps}$ 和骨架遮罩 $M^{ske}$

首先先用在 ImageNet 上預訓練的 HRNet Backbone 提取特徵 $x^{fea}$。

然後透過掩蔽提取關鍵點特徵和骨架特徵，如下所示：$$x^{kps} = x^{fea} \otimes M^{kps}, x^{ske} = x^{fea} \otimes M^{ske}$$

其中 $\otimes$ 為逐元素乘法。

接下來，把 $x^{kps}$ 和 $x^{ske}$ 用 SC-CA 模組來捕獲結構訊息 $x^c$：$$ x^c = C(x^{kps} \oplus A(x^{kps}, x^{ske}, x^{ske}), x^{fea}) $$
其中 $C(\cdot), \oplus , A(\cdot)$ 分別代表連結特徵、加總、SC-CA 模組。

獲得 $x^c$ 後，擴散解碼器 $D(\cdot)$ 將關鍵點熱圖 $\tilde{y}^{hm}_{t-1}$ 估計為：$$\tilde{y}^{hm}_{t-1} = D(y^{hm}_{t}, x^c)$$

作者改進了生成任務中的擴散模型，並提出了結構引導擴散解碼器（SGDD），跟他的加強版：高解析度SGDD。

#### Spatial-Channel Cross-Attention (SC-CA) Module
SC-CA模組旨在計算關鍵點特徵和骨架特徵之間的關係，其中包括空間注意力和通道注意力：$$ A(Q, K, V ) = A_c(Q, K, V ) + A_s(Q, K, V ) $$

$A_c, A_s$ 分別代表 [DaViT](https://arxiv.org/pdf/2204.03645.pdf) 提出的通道注意力和空間視窗多頭注意力：
* $A_s$ 的目的是提高定位的準確性，因為特徵條件 $x^c$ 包含雜訊。
* $A_c$ 旨在增強特徵條件 $x^c$ 的語意資訊。

#### Structure-Guided Diffusion Decoder (SGDD)
跟 DDPM 一樣都包含一個具有 U-Net 架構的神經網絡，SGDD的工作就是把前向擴散過程產生的噪音熱圖恢復成真實熱圖。

如下圖所示，給定雜訊熱圖$y^{hm}_{t} \in \mathbb{R}^{J×H×W}$ 與條件$x^c \in \mathbb{R}^{C_x×H×W}$ ，SGDD 輸出估計熱圖$y^{hm}_0 \in \mathbb{R}^{J×H×W}$，其中$C_x、J 、H × W$ 分別表示 $x^c$ 的通道數、關節數、熱圖的大小。

在SGDD中，輸入特徵和熱圖以漸進的方式 Downsample 到 $2C × \frac{H}{8} × \frac{W}{8}$的大小，並通過殘差連接上採樣到 $H × W$ 的原始大小，其中 $C ∈ \begin{Bmatrix}64， 128, 256 \end{Bmatrix}$ 是解碼器中特徵的通道數。

![](https://hackmd.io/_uploads/H1T1lzFza.png)

在SGDD的每個尺度中，多個Res-Blocks被堆疊起來以提取特徵並恢復熱圖，以下為SGDD的架構參數：
![](https://hackmd.io/_uploads/H1U0EzKMa.png)

SGDD 也可以產生高解析度熱圖，在SGDD中，$H = H_x/s, W = W_x/s$，其中 $H_x × W_x$ 是輸入影像 $x$ 的原始尺寸，$s ∈ \begin{Bmatrix}1 , 2, 4, 8\end{Bmatrix}$ 則是熱圖的比例。

因此，SGDD可以選擇不同的尺度來運作，高解析度熱圖的擴散解碼過程可以減輕量化誤差並提高熱圖品質。

###  Reverse Diffusion Process (RDP)
**RDP** 包括了採樣初始化和反向擴散推理。

在推理過程中，DiffusionPose 採用了 [DDIM](https://arxiv.org/pdf/2010.02502.pdf) 的跳步採樣策略，不需要跟訓練一樣那麼多步驟。

#### Sampling Initialization
好的取樣初始化可以減少推理步驟，在 DiffusionPose 中，給定 time step $T$，並將雜訊熱圖 $y_T$ 初始化為：$$\tilde{y}^{hm}_t = conv(x^{fea})$$

因為 $\tilde{y}^{hm}_t$ 是在 GT 熱圖監督下進行訓練的，所以它可以提供更好的初始化。

#### Reverse Diffusion Inference
初始化雜訊熱圖後，DiffusionPose 透過 SGDD 估計 GT 熱圖。
過程如以下演算法所示：
![](https://hackmd.io/_uploads/SJxgbVYz6.png)
其中特徵掩模 $y^{mask}$ 是根據 $\tilde{y}^{hm}_T$ 生成的，它進一步用於生成特徵條件 $x^c$(在MFP有提到)。

然後 SGDD 以 $\tilde{y}^{hm}_t$ 和 $x^c$ 作為輸入以估計 $\tilde{y}^{hm}_{t-1}$ (在MFP有提到)。

然後，DiffusionPose 透過重複上述步驟迭代來估計 $\tilde{y}^{hm}_0$。

最後再用 argmax 函數從 $\tilde{y}^{hm}_0$ 解碼出關鍵點 $\tilde{y}_0$。

### Loss Function
DiffusionPose 的 Loss 就是把解碼器 使用 **L2 損失**作為損失函數。

為了加速推理過程，DiffusionPose 透過卷積層 $conv$ 從 $x^{fea}$ 學習粗略熱圖，該卷積層在推理過程中用於初始化熱圖。
$\Diamond$ 講白了就是先用卷積快速算一個大概的熱圖，再把這個熱圖當 Diffusion Model 的初始熱圖讓他用特徵條件去生成最終的熱圖。

DiffusionPose 的 Loss 就是把 SGDD 的 Loss 跟上述 $conv$ 的 Loss 加起來：$$ L = \lVert D(y^{hm}_t, x^c) - y^{hm}_0 \rVert_2 + \lVert conv(x^{fea}) - y^{hm}_0 \rVert_2 $$