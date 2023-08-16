---
title: 【論文研讀】STAR-Transformer - A Spatio-temporal Cross Attention Transformer for Human Action Recognition
catalog: true
date: 2023-08-15
author: Frances Kao
categories:
- paper review
- transformer
- HAR
---

[![hackmd-github-sync-badge](https://hackmd.io/i9DwNzkbR5-e2nPl5HrjoQ/badge)](https://hackmd.io/i9DwNzkbR5-e2nPl5HrjoQ)


[STAR-Transformer: A Spatio-temporal Cross Attention Transformer for Human Action Recognition](https://arxiv.org/abs/2210.07503)
* Journal reference: 2023 IEEE/CVF Winter Conference on Applications of Computer Vision (WACV)
* Author: Dasom Ahn, Sangwon Kim, Hyunsu Hong, Byoung Chul Ko*
* github: 無
---

# Introduction

![](https://hackmd.io/_uploads/SkntFtzth.png)
為了解決多模態資料之特徵整合問題，首先將**兩種模態特徵轉換為可識別的向量特徵**，作為STAR-transformer之輸入。其次，基於ViT架構設計一**交互注意力機制(cross-attention module)**．以解決原先多頭注意力機制用於時序影片之辨識上所造成的高運算量問題。

## 現今HAR技術面臨的問題
* video-based: 容易受外在環境如相機角度、目標物大小、雜亂背景等因素影響
* skeleton-based: 需要一額外的預訓練模型以取得人體骨架，且結果會受骨架辨識準確率及骨架重疊程度而影響
* cross-modal (video+skseleton): 將兩種模態之數據結合起來是個模糊的過程，需要有一單獨的子模型進行跨模態學習（即自兩種模態資料中提取並整合有用資訊的一個學習過程）。
* Vision Transformer (ViT): 該技術現已可應用於影像分類任務中，但在HAR任務中也應考慮時序關聯性，如此便會導致**運算量較高**的問題。
* 使用Transformer耦合跨模態信息的方法尚未發展。

### 本研究主要貢獻
* multi-feature representation method
    * input video -> global grid tokens;
    * skeleton sequence -> joint map tokens;
    * 以上token整合 -> multi-class tokens
* Spatio-TemporAl cRoss transformer (STAR-transformer)
    * 設計cross-attention module學習跨模態之特徵，以取代原本ViT的多頭注意力機制
    * encoder
        * FAttn (full spatio-temporal attention)
        * ZAttn (zigzag spatio-temporal attention)
    * decoder
        * FAttn (full spatio-temporal attention)
        * BAttn (binary spatio-temporal attention)
* 此研究為首創無須使用額外子模型訓練，便可直接使用空間/時序之跨模態資料作為ViT之輸入

---

# Method

![](https://hackmd.io/_uploads/HyYLbhGKh.png)
補充: [ViT](https://zhuanlan.zhihu.com/p/340149804)

## Cross-Modal Learning
跨模態的部分包含了三種資訊，即全域性、局部性、以及合併資訊，因此在類別上也會有三種。其中在特徵提取使用了預訓練模型ResNet-MC18 (mixed convolution 18)[43]，透過其不同層之特徵圖得到全域與局部的特徵再以Transformer加以提取與結合。

### Global grid token (GG-token)  $\mathbb{T}^{t}_{g}$ 
* 提取ResNet18之**最後一層**作為全域特徵，得 $h \times w$ 之特徵圖，並且將其flatten為 $hw$ (即 $P$ )之向量，即得到 $\mathbb{T}^{t}_{g}$ 中 $g^{t}_{1,...,P}$ 之各元素： $\mathbb{T}^{t}_{g} = \{ g^{t}_{1}, ..., g^{t}_{P} \}$

### Joint map token (JM-tokem)  $\mathbb{T}^{t}_{j}$ 
* 提取ResNet18之中間層作為局部特徵，以獲得較細節之特徵，當中的元素 $j^{t}_{n}$ 來自於local feature map $F$ 與第n張joint heat map $h^{t}_{n}$ 的合併(concatenate)；首先擷取local feature map $F$ 後，第n張joint heat map $h_{n}$ 即為在一暫時性特徵映射圖上的第n個joint結果，其經過高斯模糊縮放(scaled at $\sigma$)後的大小為 $h' \times w'$ ： $\mathbb{T}^{t}_{j} = \{ j^{t}_{1}, ..., j^{t}_{N} \}$, where $N$ is the number of joint heat map <br>
    ![](https://hackmd.io/_uploads/S1rvvvLc3.png)
    
### Multi-class token $Z$
Vanilla Vit主要以單一類別學習全域關聯性(下圖(a))，而此研究則加入各個模態資料的類別標記，也就是在總類別 $CLS_{total}$ 加上 $\mathbb{T}_{g}$ 和 $\mathbb{T}_{j}$ 兩者token，其中僅有$\mathbb{T}_{j}$保有位置編碼（此與一般ViT位置編碼方法有所不同處，這邊作者主張位置資訊對JM特別重要），詳細其公式如下：
> $\mathbb{T}_{g} = CLS_{global} \oplus \mathbb{T}_{g}$
> $\mathbb{T}_{j} = CLS_{joint} \oplus (\mathbb{T}_{j} + pos)$
> $Z = \mathbb{T}_{g} \oplus \mathbb{T}_{j} \oplus CLS_{total}$
![](https://hackmd.io/_uploads/r1Duw2fth.png)

## Spatio-temporal cross attention
![](https://hackmd.io/_uploads/BkTyMuIqn.png)

### FAttn (full spatical-temperal attantion)
該輸入包含了所有空間維度與時間維度的資訊，其複雜性為$T^{2}S^{2}$。而另外設計的兩個注意力機制將$T$的部分拆為兩份分別給了Q向量和KV向量，因此其複雜性僅為FAttn的四分之一倍。 <br>
$FAttn(Q, K, V) = \displaystyle\sum^{T}_{t} \displaystyle\sum^{S}_{s} Softmax{\dfrac{Q_{s,t} \cdot K_{s, t}}{\sqrt{d_{h}}}} V_{s,t}$

### ZAttn (zigzag spatical-temperal attantion)
Q與K和V套用了交叉幀資訊之解藕，即將$T$資訊分為基偶數幀，並且交互計算出$a'$和$a''$再將其合併。首先，$a'$以所有TS之基數幀作為Q向量而偶數幀則為K和V向量；而$a''$則反之，以所有TS之基數幀作為K和V向量而偶數幀則為Q向量。如此作法是希望能捕捉到特徵中的細微變動。 <br>

$a' = \displaystyle\sum^{T/2}_{t} \displaystyle\sum^{S}_{s} Softmax{\dfrac{Q'_{s,t} \cdot K'_{s, t}}{\sqrt{d_{h}}}} V'_{s,t}$ <br>
$a'' = \displaystyle\sum^{T/2}_{t} \displaystyle\sum^{S}_{s} Softmax{\dfrac{Q''_{s,t} \cdot K''_{s, t}}{\sqrt{d_{h}}}} V''_{s,t}$ <br>
$ZAttn(Q, K, V) = a' \oplus a''$ <br>

註：zigzag意指曲折的線段，指的就是在此方法上會將資訊以Z行曲折的方式拆分開來。

### BAttn (binary spatical-temperal attantion)
BAttn之注意力機制同樣將原來的TS資訊分為前後段，並分配予Q向量與K、V向量。 <br>
$BAttn(Q, K, V) = b' \oplus b''$

## Encoder & Decoder

本研究提出的Transformer encoder-decoder結構是以一般的Transformer為基礎，而非處理影像的ViT那樣僅有encoder。 <br>
$\bar{Z}_{l} = LN\{FSTA(z_{l-1})+z_{l-1}\}$ <br>
$z'_{l}, z''_{l} = Decoupling(\bar{Z}_{l})$ <br>
$\hat{Z}_{l} =LN\{(STA(z'_{l})+z'_{l}) \oplus (STA(z''_{l})+z''_{l})\}$ <br>
$z_{l} = LN\{MLP(\bar{z}_{l}) + \bar{z}_{l}\}$ <br>
如此經過STAR Transformer的多類別token便會透過平均、餵入MLP推測動作標籤，即將多類別的特徵類別融合為單一類別。

---

# Results

## Datasets
* [Penn-Action](http://dreamdragon.github.io/PennAction/)
* [NTU-RGB+D 60, NTU-RGB+D 120](https://arxiv.org/abs/1604.02808)
    * 指標說明
        * XSub: 根據不同受試者(共有40位受試者，training set和testing set各為20/20不同受試者)
        * XView: 根據不同視角(共有3個視角，training set和testing set分別為camera1/camera2&3)
        * XSet: 根據不同場景

## Implemetation details
* backbone: ResNet18 (pretrained on Kinetics-400)
* batch size: 4
* epoch: 300
* optimizer: SGD
* learning rate: 2e-4
* momentum: 0.9
* GPU/CPU: NVIDIA Tesla V100 GPU x4
* 16 fixed frames**

### Quantitative analysis: Penn-Action
* STAR-Transformery在未使用pre-training model的情況下，同時使用RGB+skeleton資料可得出較好的模型表現。
-> 但實際上結果並未高出其他SOTA方法很多
![](https://hackmd.io/_uploads/HkXrSqzKh.png)

### Quantitative analysis: NTU RGB+D
![](https://hackmd.io/_uploads/BJxC8cGKh.png)
* 結果說明
    * VPN [14]在NTU60稍高而NTU120稍低: 在分類增加或場景改變後表現下降，不多討論 (同樣配置)
    * PoseC3D [17]高出許多: 該模型使用pre-trained poseConv3D model，這導致該方法的骨架辨識與動作辨識模型並非end-to-end，即兩者並未能整合而得以在一個單獨的模型中進行訓練，以致於模型效率不如預期。
    * KA-AGTN [31]在NTU60稍低而NTU120稍高: 該模型僅使用spatial-temporal骨架資訊進行特徵提取，與本研究方法使用RGB+skeleton特徵之表現不相上下。
    * 在此實驗中可觀察到多模態資料之表現皆較單模態資料來的高。
    * 此實驗驗證STAR-Transformer的表現無受限於不同受試者、視角或場景。

### Qualitative analysis (Ablation study)
| Ablation Study | Result |
|-|-|
| multi-expression learning | ![](https://hackmd.io/_uploads/S1_DSiGtn.png) | 
| number of transformer layers | ![](https://hackmd.io/_uploads/H1LUHoMKn.png) |
| cross attention modules | ![](https://hackmd.io/_uploads/rkiMUjGKh.png) |
| spatio-temporal cross attention | ![](https://hackmd.io/_uploads/HkKo8jfth.png) |
* spatio-temporal cross attention: 此實驗計算出根據時序，各注意力機制所關注的資訊。可觀察到三種注意力機制所關注的資訊，如FAttn並不考慮全面的時序資訊，而是關注後三幀；ZAttn關注中後之資訊；BAttn則關注前中後之資訊。而這在cross attention modules的實驗中也可以看出，根據關注不同位置的注意力機制之組合也得出不同準確率，例如僅使用關注後三幀的FAttn作為encoder/decoder，可能導致資訊遺漏而使得準確率相對較低(96.1%)。
* 作者表示在進行動作辨識任務時，不能只關注某些幀，而是需要均勻地學習並考慮所有幀中的特徵。
-> 在此研究中，使用attention mechanism與不使用的差別？若均勻的關注所有幀而不使用注意力機制的實驗？

---

# Future works

* 設計更有效率的模型，例如可使用較少量的資料進行訓練
* 將模型修改為可同時進行骨架特徵與動作辨識的端到端模型

---

## 補充問題
* 三個類別分別為何?
    * 可訓練的token, 分別代表了global feature, local feature, multi-class feature，是以注意力訓練得出所能代表這段輸入的特徵，而非所謂動作類別標籤。
* 如何決定最終類別?
    * 經過transformer後，會生成多類別特徵表示(token)，透過平均這些token並且將這些特徵資訊餵入MLP而得到最終動作類別。文中沒有特別提及MLP的結構，並非此篇論文重點。
* 16 fixed frames為何? 
    * 推測為固定每個資料為固定16幀(T=16)，但文中未提及如何將資料集處理為固定幀數(例如取前取後?)這種方法的優點是可以減少STAR-transformer模型的計算量，從而提高模型的訓練速度。同時，這種方法還可以減少動作序列中的噪聲和冗余信息，從而提高模型的準確率。然而，這種方法也有一些缺點，例如可能會丟失一些重要的動作信息，因為每個時間段只提取了一個幀作為輸入。因此，在實現STAR-transformer模型時，需要根據具體的應用場景和需求來選擇合適的方法。
* 僅對joint map token做position embedding，（未說明）joint map比起global grid的位置資訊更重要的原因可能是因為我們的任務是針對人體骨架的動作。未實驗若也對global grid token加上position embedding或者皆不加，結果差異如何。