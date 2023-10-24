---
title: 【論文研讀】Prompt-Guided Zero-Shot Anomaly Action Recognition using Pretrained Deep Skeleton Features
catalog: true
date: 2023-10-24
author: Frank Liou # 填上你的姓名
categories:
- Paper Review
- Anomaly Action Recognition
# 這邊擺放標籤
---

<style>
.text-center {
  text-align: center; //文字置中
}
</style>

# Prompt-Guided Zero-Shot Anomaly Action Recognition using Pretrained Deep Skeleton Features


* 論文出處:arXiv/CVPR 2023
* 作者:Fumiaki Sato, Ryo Hachiuma, Taiki Sekii,Konica Minolta,Inc
* [原文連結:https://arxiv.org/abs/2303.15167](https://arxiv.org/abs/2303.15167)
* github:無

**摘要:**
本論文提出了一種基於骨架序列與使者文本提示的無監督異常檢測方法，該方法可以在零樣本學習(Zero-Shot)的情況下辨識異常動作
本研究使用兩個假設:
1. 用戶可以定義異常動作的類別(如圖中的'violence')
2. 觀察到的訓練樣本由正常動作組成

未觀察到的訓練動作被稱為OoD(Out-of-distribution)，例如圖中的'handshake','pushing'和'punching a person'。當在訓練階段**沒有觀察到足夠多的正常樣本**時，OoD動作包括未被觀察到的正常動作'handshake'，由於沒有出現在正常樣本中而被錯誤地辨識為異常動作。僅從正常樣本中學習的決策邊界（黑色虛線）向嵌入的使用者提示'violence'（紅線）的方向移動，通過使用者定義的文字提示，可以正確地將握手樣本辨識為正常，同時將行走樣本辨識為正常

![](https://hackmd.io/_uploads/Skj1_7WGT.png)

模型包括三個部分：骨架的特徵提取器、Text encoder和異常檢測器。
* 骨架特徵提取器( $F$ ):使用預先訓練的深度學習模型從骨架序列中提取特徵，後續不再更新權重
* Text encoder:將用戶提示轉換為向量，並用其他MLP將其與骨架特徵對齊在共同空間中
* 異常檢測器:使用一個基於點雲的深度學習架構來檢測異常動作，能在關節間稀疏的傳遞特徵

該方法通過使用預訓練的深度學習模型和點雲深度學習，提高了異常動作辨識的準確性和魯棒性。實驗結果表明，該方法在多個數據集上取得了優異的異常檢測效果。

### 1.介紹
本論文欲克服問題
* **目標領域相關的DNN訓練:** 使用模型前需要重新訓練DNN，浪費時間&資源成本
* **缺乏可定義的正常樣本:** 在實際應用中，無法獲得各種正常動作來訓練DNN。在這種情況下有些正常動作將被錯誤的視為異常，因此若使用者能夠定義要辨識的目標異常或正常動作，將有助於降低此種誤判
* **骨架效果的穩健性:** 如果特徵提取器辨識錯誤或失敗，或環境發生光源變化或遮擋問題，則連帶影響異常辨識精度會降低

為了克服這些限制，作者提出了一種具有文字提示的zero-shot框架，基於骨架的異常動作辨識，且不需要觀察異常行為來訓練DNN。

針對第一個訓練限制，作者利用skeleton feature extractor $F$ 對骨架特徵進行提取，再去計算正常動作的分配，而F已經在Kinetics-400和NTU-RGB+120上預訓練，**後續用其他資料集訓練模型時不會更新權重，因此獨立於目標域**，也不需要重新訓練

針對第二個正常樣本限制，作者利用使用者提供的**異常動作提示**來間接補充正常動作的信息，目的是希望減少將正常動作辨識為異常的誤判。
透過對比學習的方式，將Text encoder和feature extractor $F$ 產生的特徵向量間的餘弦相似性$Cos()$納入異常分數(OoD)計算公式當中，使模型能透過文字了解動作，反之亦然

最後，基於PointNet，作者引入了一種更簡單的DNN，將骨架關鍵點進行特徵提取，以此提高穩健性，此種架構消除了資料集對輸入骨架的約束，例如輸入關節大小和順序。
且其能夠將凍結在不同數據集上的預訓練特徵提取器轉移至其他資料集，而不需
fine-tuning，並能對正常樣本的分配和數據集上的'骨架-文本嵌入空間'進行建模

主要貢獻如下：
1. 透過實驗證明，透過使用大規模動作辨識資料集預訓練的骨架特徵表示來消除使用正常樣本的 DNN 訓練
2. 處理公共空間中的骨架特徵和文字嵌入的Zero-Shot學習範式可以有效地對正常和異常動作的分佈進行建模。 它由全新的統一框架支持，該框架將用戶引導的文本嵌入納入異常分數的計算中
3. 透過實驗證明，排列不變架構在關節之間稀疏地傳播特徵，可以作為骨架特徵提取器，對正常樣本上的'骨架-文本嵌入空間'進行建模，並增強針對骨架錯誤的穩健性


### 2.文獻回顧
* 影片異常檢測
可以在較短的時間間隔內(逐幀)辨識異常動作
  * RGB based-圖元變化的直方圖或光流，用於提取外觀特徵
  * DL based-3D CNN用於提取時空特徵
  * skeleton based-迴圈神經網路或GNN，用於對人體骨架特徵進行建模
* 異常動作辨識
可以辨識相對較長時間間隔內的間歇或週期性動作組成的異常動作，對目標的異常行為限制較少
* Zero-Shot動作辨識
視覺和語言領域一直在積極研究Zero-Shot視覺識別任務，透過描述目標的文本提示來識別視覺數據中未知的目標，例如，Zero-Shot圖像分類任務採用一對圖像及其文本提示來識別訓練期間未見過的類別
![](https://hackmd.io/_uploads/rJIdakHGT.png)

視覺問答任務(visual question answering,VQA)通過文本輸入一對圖像及其相應的問題。透過在圖像特徵和從提示中提取的文本嵌入之間引入對比學習，此類任務的性能得到顯著增強
![](https://hackmd.io/_uploads/ByXeJgSGp.png)

對比學習(contrastive learning)也被使用到動作辨識中，其利用未知動作的文本提示，透過在訓練時，對齊影片中提取的外觀或骨架特徵與文本提示，以Zero-Shot方式辨識
本論文將Zero-Shot方法引入到異常動作辨識的任務中，以增強異常動作分布的建模

* 基於骨架的動作辨識
先前已有許多人使用skeleton based的GNN方法來研究時間序列關節之間的關係
較特別的是，[SPIL(Skeleton Points Interaction Learning)](https://arxiv.org/abs/2308.13866)將人體骨骼序列視為輸入3D點雲，透過注意力機制來模擬關節之間的密集關係，可以稀疏地傳播關節之間的特徵來提高針對輸入錯誤(例如FP和FN關節或姿勢跟蹤錯誤)的穩健性，並且是一種僅在架構概念上與所提出的方法競爭的技術

### 3.方法
模型架構包括三個部分(下圖不包含Pretrain):
1. Pretrain : $F$ 在沒有正常樣本的動作辨識數據集上進行預訓練
2. 計算正常樣本分配 : 僅計算正常樣本的統計值，而不改變 $F$ 權重
3. 計算異常分數 : 使用模型沒有看過的的分佈和動作文字來計算異常分數

首先，在資料集上使用多人骨架偵測器來推論骨架，對Feature extractor $F$進行預訓練，在後續訓練和推理階段凍結權重
在訓練階段，利用 $F$ 從正常動作的骨架提取特徵，並計算正常特徵向量的平均值與協方差
在推論階段，計算OoD分數與提示分數，兩者聯合成為異常分數(計算異常分數後如何判斷異常則沒有詳細解釋)
![](https://hackmd.io/_uploads/r1bMXjMz6.png)


#### 3.1 Pretraining
作者使用大型動作辨識數據集Kinetics-400和NTU RGB+D 120提出的預訓練DNN，在預訓練階段中，使用從骨架提取的特徵x和從動作名稱中提取的特徵y之間的對比學習。
在一批N個影片中的總損失 ${L}$ 定義如下，其中包含動作分類損失 ${L}_{cls}$ 和對比損失  ${L}_{cont}$ 組成的


$$\mathcal {L} = \alpha \sum _{i=1}^{N} \mathcal {L}_{\text {cls},i} + (1 - \alpha ) \mathcal {L}_\text {cont}$$

* ${L}_{\text {cls},i}$指的是動作分類ground-truth( $h_i$ )與predict( $l_i$ )間的cross-entropy，$C$為動作類別，

$$\mathcal {L}_\text{cls} = -\sum _{i=1}^{C}h_i\log\frac {\exp (l_i)}{\sum _{j=1}^{C}{\exp (l_j)}}$$

* $\mathcal {L}_\text {cont}$是基於[CLIP（Contrastive Language-Image Pre-training）](https://zhuanlan.zhihu.com/p/486857682)模型提出的對比損失(contrastive loss)，目的是為了學習到圖片與文字的對應關係
* $\mathcal{L}_{\rm{t2s}}$是batch中骨架特徵與文本特徵的對比損失，$\mathcal{L}_{\rm{s2t}}$與其相反，是文本特徵與骨架特徵的對比(監督對象不一樣)

$$\mathcal {L}_\text {s2t} = - \sum _{i=1}^{N} \log \frac {\exp (\mathrm {Cos}(f(\mathbf {x}_i), \mathbf {y}_i)/\tau )}{\sum _{j=1}^{N}\exp (\mathrm {Cos}(f(\mathbf {x}_i), \mathbf {y}_j)/\tau )}$$


$$\mathcal {L}_\text {t2s} = - \sum _{i=1}^{N} \log \frac {\exp (\mathrm {Cos}(f(\mathbf {x}_i)), \mathbf {y}_i)/\tau )}{\sum _{j=1}^{N}\exp (\mathrm {Cos}(f(\mathbf {x}_j), \mathbf {y}_i)/\tau)}$$
其中，$x_i$ 與對應的動作 $y_i$ 是從影片$i$學習到的


#### 3.2 骨架特徵提取器
作者基於PointNet設計了骨架特徵提取器。首先自影像提取骨架後，每一幀會得到J個關鍵點，每個關鍵點可以轉換為$v$，包含7個維度 : 二維關節座標、時間、置信度、關節index和二維質心座標，把$v_1...v_J$當作MLP的輸入，作者單純的使用3層MLP加上Residual後，得到S維度的骨架特徵向量，最後再取MaxPooling，得到特徵向量$x$大小為$1×J$
![](https://hackmd.io/_uploads/HkkYJ37Ma.png)

#### 3.3 異常分數定義
異常分數定義為 : $x$不是正常樣本的機率$p(O|x)$(OoD分數)和 $x$包含使用者指定異常行為的機率$p(T|x)$兩者的聯和機率，$p(O|x)$的參數會對訓練樣本中$x$的分佈進行建模。$p(T|x)$的參數是與$x$相對的文本嵌入:

$p(O,T|\mathbf {x})=p(O|\mathbf {x})p(T|\mathbf {x})$

其中，作者用[馬式距離](https://zhuanlan.zhihu.com/p/46626607#%E9%A9%AC%E6%B0%8F%E8%B7%9D%E7%A6%BB%E7%9A%84%E5%87%A0%E4%BD%95%E6%84%8F%E4%B9%89)公式來近似OoD分數，其中$( w 1 , w 2 )$是歸一化常數和溫度參數。${\mu}和{\Sigma}$分別是訓練樣本分配的平均值與協方差矩陣。
$p(O|\mathbf {x})\sim \mathrm {min} \left (1.0, w_1\sqrt {( {x}- {\mu})^\intercal  {\Sigma }^{-1}( {x}- {\mu })}^{\frac {1}{w_2}} \right)$


用餘弦相似度來近似$p ( T ∣ x )$ ，其中$f$表示用於對齊$x$和$y$維度的預訓練MLP，作者並未提及使用了什麼 Text encoder與如何對齊
$p(T|\mathbf {x})\sim \mathrm {min} \left (1.0, w_1\mathrm {PromptScore}(\mathbf {x}|\mathcal {Y})^{\frac {1}{w_2}}\right )$
其中，${PromptScore}({x}|\mathcal{Y})={max}({Cos}(f({x}),{y}_1),...,{Cos}(f({x}), {y_P}))$

![](https://hackmd.io/_uploads/Syzhgy7fT.png)


### 4.實驗
#### 4.1數據集
* [RWF-2000](https://github.com/mchengny/RWF2000-Video-Database-for-Violence-Detection) : 是從YouTube收集的暴力辨識數據集，包含暴力或非暴力的兩種動作，以30fps拍攝的5秒影片。有1.6K訓練和0.4K測試，每個影片都標註了兩類標籤
![](https://github.com/mchengny/RWF2000-Video-Database-for-Violence-Detection/raw/master/Images/result_1.gif)
在本論文中，非暴力和暴力行為分別被定義為正常和異常，使用非暴力樣本來訓練DNN並凍結，以Zero-Shot辯識暴力行為，使用五種不同的文字提示來表達暴力行為
![](https://hackmd.io/_uploads/rJgN3fNfa.png)

* Kinetics-250 : 是Kinetics-400數據集的子集，由具有250個動作類別的影片組成。由於Kinetics-400數據集中包含專注於頭部和手臂的影片，模型準確性會受到這些影片的顯著影響。因此[Markovitz等人](https://arxiv.org/pdf/1912.11850.pdf)選擇了具有 250 個動作類別的影片進行評估，這些影片在動作分類準確性方面表現最好，並且可以準確檢測骨骼。
作者使用使用「少」與「多」來區分，選擇三到五個操作類定義為正常，其餘操作類定義為異常，並分為'隨機分組'和'有意義分組'進行評估，有意義選取按照原論文內主觀選擇，根據動作的物理或環境的一些約束邏輯來分組

#### 4.2骨架偵測器
* PPN：在RWF-2000資料集的實驗中，作者在準確度與多個異常動作辨識的baselines(PointNet++和DGCNN)相似的的條件下，選擇使用低效能的Pose Proposal Networks(PPN)，因為沒有公開的骨架資料(???)，PPN以Bottom-Up的方式從RGB影像中偵測人體骨架，由Pelee backbone組成，並在COCO資料集上訓練。
> 原文 : In the experiments on the RWF-2000 dataset, we use the low-performance 'Pose Proposal Networks, PPN' detector [30] under conditions of similar anomaly action recognition accuracy against several baselines (PointNet++ and DGCNN) because there are no publicly available skeleton data. 

* HRNet以Top-Down偵測人體骨架，但人體偵測器(Faster R-CNN)在內的計算成本較高。
在Kinetics-250資料集的實驗中，作者採用了由Haodong等人提供的公開HRNet。
![](https://hackmd.io/_uploads/SyuznzEf6.png)

#### 4.3與SoTA方法比較
表2與表3比較了SoTA與本篇論文提出的方法在RWF-2000、Kinetics-250資料集上的準確率，分別僅使用OoD分數/提示分數，及使用異常分數來比較。
![](https://hackmd.io/_uploads/HyHZ3fNfT.png)
> *：使用HRNet骨架作為輸入
> †：採用[StructPool](https://arxiv.org/abs/2303.15270)作為網路架構

在RWF-2000上，本篇方法在準確性方面優於以前的幾種監督方法，包括PointNet++、DGCNN和ST-GCN。在本方法中，使用了較不準確的骨架偵測器(PPN)，但其準確度也僅比SPIL低7%
(PPN在COCO驗證集上的準確度率36.4%，baselines使用了較高準確率的RMPE，準確率為
72.3%)

![](https://hackmd.io/_uploads/SkHx2zVfa.png)

在Kinetics-250上，本方法的準確率優於SoTA非監督方法。先前的方法需要花費一些時間來訓練 DNN，但本方法的結果是在目標域中無需進行任何 DNN 訓練的情況下實現的。
only OoD與本方法皆優於先前的無監督方法，由此可知，即使不提供文字提示，所提出的方法在訓練期間凍結DNN權重，也可以以無監督的方式辨識異常動作
此外，透過使用文字提示，提高了方法的準確性。表示本方法可以透過文字提示來補充異常或正常動作的資訊，減少了將正常動作辨識為異常的誤檢測。

![](https://hackmd.io/_uploads/BkIT2MVMa.png)
上圖描繪了RWF-2000資料集上異常樣本和正常樣本之間移動的決策邊界。
相比only prompt與本方法，only prompt在兩個資料集準確率皆下降，但Kinetics-250更明顯(下降17%)，這是因為本方法僅在Kinetics-250資料集上定義了一些正常動作，而沒有直接使用文字提示作為異常動作。因此，即使使用者僅定義正常操作，本方法也可以偵測異常行為

#### 4.4 消融實驗
* 針對骨架偵測和追蹤誤差的穩健性比較:
作者綜合了三種不同類型的骨架檢測誤差：FP、FN 和跟蹤誤差
FP誤差 : 透過將從正態分佈採樣的雜訊添加到二維關節座標而產生
FN誤差: 透過將關節置信度得分和關節座標按特定比例替換為0
例如，如果骨架偵測誤差率為20%，對20%的輸入關節綜合生成FP和FN誤差，並在150幀影片中隨機切換它們的跟蹤索引60幀以生成跟蹤誤差，即使骨架錯誤率上升，本方法的精度也不會降低
![](https://hackmd.io/_uploads/r1Od-BNMa.png)
* 針對場景轉移的穩健性比較
將RWF-2000訓練數據分為五個子集作為不同的場景，並將每個子集用作單獨的評估
![](https://hackmd.io/_uploads/ByaFWBNfT.png)
* 比較準確性與文本提示的變化
使用五種不同的文本提示，具有不同的異常分數
在表2中，本方法準確率(82.5%)高於only OoD(71.8%)，表示使用合理的文本提示可以減少對訓練階段未觀察到的正常動作的誤判
而在這五個文本提示中，透過加入Ood分數，也可以提高準確率，因此，文本提示辨識異常行為，與從正常數據中收集的資訊相輔相成
![](https://hackmd.io/_uploads/rJgN3fNfa.png)

#### 討論

Kinetics-250用了什麼提示文本
到底用什麼模型辨識異常動作，或是計算出異常分數後設定的筏值
StructPool是作者提出的另一種架構，沒有詳細介紹
只使用骨架資料而沒有文字預訓練Feature extractor $F$ 有點怪，作者沒有詳細說明Kinetics-400和NTU RGB+D 120中，文字的部分(直接使用label或有其他方式)