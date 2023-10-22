---
title: 【論文研讀】Cascaded Pyramid Network for Multi-Person Pose Estimation
catalog: true
date: 2023-10-23
author: David Chen
categories:
- paper review
- Segmentation
- Transformer
---
# Cascaded Pyramid Network for Multi-Person Pose Estimation
* Journal reference: CVPR 2018
* Authors: Yilun Chen, Zhicheng Wang, Yuxiang Peng, Zhiqiang Zhang, Gang Yu, Jian Sun
* Github: [Cascaded Pyramid Network (CPN)](https://github.com/chenyilun95/tf-cpn)
* 論文連結: [Cascaded Pyramid Network for Multi-Person Pose Estimation](https://openaccess.thecvf.com/content_cvpr_2018/papers/Chen_Cascaded_Pyramid_Network_CVPR_2018_paper.pdf)

---

作者提出 **CPN** 來解決關鍵點被遮蔽和複雜背景中的關鍵點偵測錯誤的情況。

**關鍵點被遮蔽**和**背景複雜**無法良好定位的原因如下：
* 這些困難關節不能**僅憑外觀特徵**來簡單識別，例如軀幹點。
* 這些困難關節在訓練過程中沒有明確解決。

## Method

**CPN** 主要是由兩個子網路左組成的：
* **GlobalNet**
* **RefineNet**

下圖為 **CPN** 的整體架構。
![](https://hackmd.io/_uploads/SkoQ5hff6.png)

### GlobalNet
**GlobalNet** 為基於**ResNet Backbone** 的網路結構。

作者將不同卷積特徵 $conv2∼5$ 的最後一個殘差塊分別表示為 $C_2, C_3, ..., C_5$。

如下圖所示，$C_2$ 和$C_3$ 等淺層特徵具有**用於定位的高空間分辨率**(可以看得比較廣)，但**用於識別的語義資訊較低**。
反之，像 $C_4$ 和 $C_5$ 這樣的深層特徵層**具有更多語義訊息**，但由於跨步卷積（和池化）而導致**空間分辨率較低**(看的比較窄)。
因此通常會使用一個 **U 形結構**來在特徵層的空間分辨率和語義資訊中**取得一個平衡**。

![](https://hackmd.io/_uploads/rkkHsnMfp.png)

作者引用了FPN的**特徵金字塔結構**，但是在上採樣過程中，作者先經過了 $1 × 1$ 卷積核然後才進行逐元求和。(上圖一 **elem-sum** 的部分)

如上圖二所示，基於 **ResNet Backbone** 的 **GlobalNet** 可以有效地定位眼睛等關鍵點，但卻無法精確定位**被遮擋住的臀部**位置。

作者表示像臀部這樣的關鍵點的定位通常需要**更多的上下文資訊和處理**，而不是附近的外觀特徵，因此單靠上述的 **GlobalNet** 很難直接識別這些**困難關鍵點**，因此作者附加一個 **RefineNet** 來解決**困難關鍵點**。

### RefineNet
為了**提高訊息傳輸的效率**並**保持訊息的完整性**，我們的 **RefineNet** 跨不同層級傳輸訊息，最終**透過上取樣和串聯將不同層級的訊息**集成為 [HyperNet](https://www.cv-foundation.org/openaccess/content_cvpr_2016/papers/Kong_HyperNet_Towards_Accurate_CVPR_2016_paper.pdf)。

**RefineNet** 特點：
* 連接了**所有金字塔特徵**，不像堆疊沙漏只有簡單的使用沙漏模組末端的上採樣特徵。
* 將更多的 **bottleneck blocks** 堆疊到更深的層中，其較小的空間尺寸實現了有效性和效率之間的良好權衡。

隨著網路的訓練，網路通常會更關注那些**相對簡單**的關鍵點，而不太重視**被遮蔽**和**困難**的關鍵點，這兩類關鍵點都應該被關注！

因此在 **RefineNet** 中，作者根據訓練損失在線選擇困難關鍵點（稱為 **online hard keypoints mining** ），並僅從所選關鍵點進行反向傳播。

#### Online Hard Keypoints Mining
整個模型中有兩個階段，他們各自的損失為：
* **GlobalNet**：所有 Label 關鍵點的 L2 Loss。
* **RefineNet**：只懲罰 Loss 最高的前 N 個關鍵點損失，經過作者的實驗，在 COCO 資料集中的 17 個關鍵點中取 8 個關鍵點可以在困難關鍵點和簡單關鍵點之間達成平衡，得到最佳訓練結果。