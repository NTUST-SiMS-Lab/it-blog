---
title: 【論文研讀】3D Interacting Hand Pose Estimation by Hand De-occlusion and Removal
catalog: true
date: 2023-09-24
author: David Chen
categories:
- 3D Interacting Hand Pose Estimation
- De-occlusion
- Removal
---
# 3D Interacting Hand Pose Estimation by Hand De-occlusion and Removal

[![hackmd-github-sync-badge](https://hackmd.io/Uy6hxfpOS3KL6O0LHhiT-A/badge)](https://hackmd.io/Uy6hxfpOS3KL6O0LHhiT-A)


* Journal reference: ECCV 2022
* Authors: Hao Meng, Sheng Jin, Wentao Liu, Chen Qian, Mengxiang Lin, Wanli Ouyang, Ping Luo 
* Github: [HDR](https://github.com/MengHao666/HDR)
* 論文連結: [3D Interacting Hand Pose Estimation by Hand De-occlusion and Removal](https://arxiv.org/abs/2207.11061)
---
## Introduction
此篇論文建議分解具有挑戰性的互動手部姿勢估計任務，並分別預測左手和右手的姿勢。

近距離雙手互動情況下的單手姿勢估計有兩大主要挑戰：
- 嚴重的手部遮擋：在雙手進行密切交互時，遮擋模式是複雜的，因此目標手的許多區域可能被遮擋，這使得推斷不可見部分的姿勢變得困難。
- 手的同質和相似的外觀：手部姿勢估計器可能會被另一隻外觀相似的手所誤導。

提出了一個**Hand De-occlusion and Removal**(HDR)框架，其中包含三個主要階段：
* **Hand Amodal Segmentation Module** (HASM)
* **Hand De-occlusion and Removal Module** (HDRM)
* **Single Hand Pose Estimator** (SHPE)

作者提出的 HDR 框架，可以將具有挑戰性的雙手互動場景轉換為常見的單手場景，讓我們可以透過現成的 SHPE 輕鬆處理。
![](https://hackmd.io/_uploads/S1pn0W0Ja.png)

作者有提到因為此篇論文的目標是提出一個框架來解決 3D 互動手勢估計的挑戰，因此他們沒有與先前的amodal segmentation, de-occlusion, SHPE模型進行完整的比較。

---
### AIH dataset
因為目前尚未有包含互動式手部的Amodal Segmentation和ground-truths的資料集，因此作者團隊製作了一個大規模的Amodal InterHand資料集，即AIH資料集。

資料集包含超過300萬互動式手部的圖片，並帶有amodal and modal segmentation, de-occlusion and removal ground-truths。

資料集包含 **AIH 同步**和 **AIH 渲染**兩個部分：
* AIH 同步：
    * 透過簡單的複製和貼上獲得。
    * 保留了詳細且真實的外觀資訊。
    * 可能產生違反人體力學的奇怪手勢。
* AIH 渲染：
    * 透過將帶有紋理的 3D 交互手網格渲染到影像平面來產生。
    * 充分考慮兩隻手之間的相互依賴性，所以不會有奇怪的手勢出現。
    * 因為渲染的紋理是合成的，因此可能會出現外觀差距。
![](https://hackmd.io/_uploads/SyWkmZgx6.png)

---
## Method

### Overview
作者提出的HDR框架包含以下三個階段：
1. **Hand Amodal Segmentation Module** (HASM)：將兩隻手的可見部分與完整部分分割出來，此模型產生的結果還包含了兩隻手的大致位置並為 HDRM 的後續去遮擋和去除過程提供線索。
* **Amodal Segmentation** 技術主要步驟如下：
    * 鄰近物體的順序恢復：得知圖片中是誰被誰遮擋住了
    * Amodal completion：恢復被遮擋物體的完整輪廓(Amodal mask)。
    **Modal mask**：僅物體可見部分的mask
    **Amodal mask**：物體完整的mask
    * Content completion：得到Amodal completion後，填充物體的不可見部分，將被遮擋物體完整的恢復出來。
2. **Hand De-occlusion and Removal Module** (HDRM)：
    * De-occlusion(去遮擋)：預測被遮蔽部分的內容。
    * Removal(移除)：去除影像中分散注意力的部分(另一隻手)。
3. **Single Hand Pose Estimator** (SHPE)：分別預測每隻手的 3D 姿勢。
![](https://hackmd.io/_uploads/rJnu-ARka.png)

---
### Hand Amodal Segmentation Module (HASM)
作者在這個步驟採用現成的[SegFormer](https://paperswithcode.com/paper/segformer-simple-and-efficient-design-for)來進行 Amodal Segmentation，並將解碼頭的數量從1個增加到4個，以預測四種分割 mask：
* Right hand amodal mask ($M_{ra}$)
* Right hand visible mask ($M_{rv}$)
* Left hand amodal mask ($M_{la}$)
* Left hand visible mask ($M_{lv}$)

作者使用二元交叉熵損失 $L_{HAS}$ 來監督模型，最後的損失函數如下：$$ L_{HAS} = L_{BCE}(M_{ra}, M_{ra}^*) + L_{BCE}(M_{rv}, M_{rv}^*) + \\
\hspace{1cm} L_{BCE}(M_{la}, M_{la}^*) + L_{BCE}(M_{lv}, M_{lv}^*)$$

$M_{ra}$, $M_{rv}$, $M_{la}$, $M_{lv}$ 為預測的segmentation masks，
$M_{ra}^*$, $M_{rv}^*$, $M_{la}^*$, $M_{lv}^*$ 為對應的ground-truth masks。

---
### Hand De-occlusion and Removal Module (HDRM)
此模組旨在將手部互動案例轉變為常見的單手案例。
給定由HASM輸出的amodal和modal mask，De-occlusion負責重新覆蓋**被遮蔽區域**的外觀內容或RGB值，而Removal的負責去除影像中的分散注意力的區域。

在下面的釋例中，我們專注於右手，並將左手視為干擾物。

如上圖所示，作者先使用amodal mask $M_{ra}$ 來定位右手，並以右手中心為基準裁剪圖片及mask。

新裁剪的圖片和mask分別表示為 $I_s^{crop}$, $M_{ra}^{crop}$, $M_{rv}^{crop}$, $M_{la}^{crop}$, $M_{lv}^{crop}$

**以下為了公式整潔，將省略crop上標。**

* $M_D$用來表示目標手被另一隻手遮住的區域。
* $M_R$用來表示分散注意力的手所佔據的區域。

$$M_D = M_{ra} \cdot (1 - M_{rv}) \\
  M_R = (1-M_{ra}) \cdot M_{lv}$$
   
* $I_D$ 與 $I_R$ 是原始圖片$I_s$分別被遮罩$M_D$和$M_R$擦除的結果，主要用於告知 HDRNet 將焦點放在哪裡以及如何透過部分卷積修復這兩個區域。
* $M_{bv}$ 用來表示除了手以外的背景部分。

$$I_D = I_s \cdot (1 - M_D) \\
  I_R = I_s \cdot (1 - M_R) \\
  M_{bv} = (1 - M_{ra}) \cdot (1 - M_{la}) $$

把 $I_D$, $M_{rv}$, $I_R$, $M_{bv}$ 連結在一起作為輸入，如下圖所示。
![](https://hackmd.io/_uploads/Hk3wPMkxa.png)

HDRNet會使用這些資料來恢復被遮蔽部分的內容，並將干擾手的部分進行修復以跟背景相符，
對於模型架構 ，作者採用[Image Inpainting for Irregular Holes Using Partial Convolutions](https://openaccess.thecvf.com/content_ECCV_2018/html/Guilin_Liu_Image_Inpainting_for_ECCV_2018_paper.html)的網路，並添加一些transformer blocks以增強特徵擷取效果。

最後HDRNet會輸出一個修復完成的圖片$I_o$ 並使用影像鑑別器 $D$ 透過對抗性訓練來提高影像恢復品質。

損失函數如下所示：

$$ L_{HDR} = \lambda_1(\mathbb{E}_{I_o}[log(1-D(I_o))] + \mathbb{E}_{I_o^*}[log(D(I_o^*))]) +\\ \lambda_2L_{l1}(I_o, I_o^*) + \lambda_3L_{prec}(I_o, I_o^*) + \lambda_4L_{style}(I_o, I_o^*) $$

其中前兩項是由[Image-to-Image Translation with Conditional Adversarial Networks](https://)中的 $$ L_{cGAN}(G, D) = \mathbb{E}_{x, y}[logD(x, y)] + \mathbb{E}_{x, z}[log(1-D(x, G(x, z)))] $$

$$ L_{L1}(G) = \mathbb{E}_{x, y, z}[‖y - G(x, z)‖_1] $$

演變而來。

而$L_{prec}$ 表示感知損失，$L_{style}$ 表示風格損失。

$$ \lambda_1、\lambda_2、 \lambda_3、\lambda_4 是平衡損失的超參數。$$

---
### 3D Single Hand Pose Estimation (SHPE)
作者提到此篇論文的框架可以應用於任何現成的姿勢估計器。

在此項工作，作者選擇 MinimalHand 的 DetNet 作為Base line。

MinimalHand 包含兩個模組：
* DetNet 負責預測 2D 和 3D 手關節位置。
* IKNet 負責將預測的 3D 手關節位置映射到關節角度。

在此研究中，作者丟棄 IKNet 並在 InterHand2.6M 資料集上重新訓練 DetNet。

SHPE 的損失函數如下：
$$ L_{SHPE} = L_{heat} + L_{loc} + L_{delta} + L_{reg} $$

* $L_{heat}$ 為 2D heatmap loss
* $L_{loc}$ 為 location map loss
* $L_{delta}$ 為 delta map loss
* $L_{reg}$ 為一個 $l_2$ 權重正規化器，用於避免過度擬合。

---
##  Experiments
作者在 InterHand2.6M 和 Tzionas 資料集上進行實驗。
由於Tzionas資料集沒有提供訓練集，故使用在 InterHand2.6M 資料集上訓練的模型來進行測試，主要是為了評估泛化能力。

---
從下表的實驗結果來看，作者提出的方法優於所有當時的 SOTA SHPE 方法，且在更具挑戰性的「IH26M-Inter」中，此方法屌打其他現有單手姿勢估計方法，獲得了約 47% 的準確率提升。
這表明現有的單手姿勢估計器不能處理嚴重的手部遮擋，而且很容易被另一隻手混淆。

![](https://hackmd.io/_uploads/SylXGS-ggT.png)

以下三種為單手姿勢估計器方法：
* Boukhayma et al.
* Pose2Mesh 
* BiHand
以下三種為雙手姿勢估計器方法：
* Rong et al.
* DIGIT
* InterNet

---
如下圖所示，作者對 InterHand2.6M 和 Tzionas 資料集進行定性分析，以說明 HDR 如何幫助處理嚴重的手部遮擋和手部的均勻外觀。

![](https://hackmd.io/_uploads/BkqV5-gep.png)

---
## Conclusion
此框架可以在手部被遮擋住的情況下很好的辨識出個別的單手骨架，在圓展的應用上，因為圓展的輸入輸出皆是影片格式，未來我會嘗試將此方法增加時間與光流維度以使修復後的影片不會有跳幀的情形產生。