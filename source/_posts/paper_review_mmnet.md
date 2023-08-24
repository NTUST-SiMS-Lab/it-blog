---
title: 【論文研讀】MMNet - A Model-Based Multimodal Networkfor Human Action Recognition in RGB-D Videos
catalog: true
date: 2023-08-22
author: Frances Kao
categories:
- paper review
- HAR
---

# [MMNet: A Model-Based Multimodal Network for Human Action Recognition in RGB-D Videos](https://ieeexplore.ieee.org/abstract/document/9782511?casa_token=ZGe_P3bVP_8AAAAA:TRqz91pF4uPIwDLzFCz0pgQgennYjUJe67ml7-Nb5qTOeDT3ee4O4WDKw07YnBK6CB9Xqcs)

[![hackmd-github-sync-badge](https://hackmd.io/NsbTaEWHQH-UJm-heBaFkg/badge)](https://hackmd.io/NsbTaEWHQH-UJm-heBaFkg)

* Journal reference: IEEE Transactions on Pattern Analysis and Machine Intelligence (VOL.45, NO.3, MARCH 2023)
* Authors: Bruce X.B. Yu, Yan Liu, Xiang Zhang, Sheng-hua Zhong, and Keith C.C. Chan
* Github: https://github.com/bruceyo/MMNet

---

## Introduction

本研究建構一RGB模態資料，其假設為「當有一定時序內提供足夠的空間和外觀特徵時，人類即可輕鬆識別動作。」以此前提，使機器模擬人類識別動作的方式。人類在識別動作時，也會同時關注與人互動的物件。也就是說，我們會關注人體動作的移動，以及物件的外觀特徵，並將其連結以得知該動作類別。因此，作者構建一時空感知區域 (spatiotemporal region of interest, ST-ROI) 之特徵圖，透過關注RGB影像中**有變化的**外觀特徵，以減少處理影片資料時的高運算量問題。<br>
然而，直接將直接將ST-ROI餵入這些VGG或ResNet等深度學習模型時，容易造成過擬合，而未能達到令人滿意的結果。因此，作者提出了一方法，透過骨架模態的知識轉移（Knowledge transferring），以提升RGB模態的動作辨識能力。具體而言，MMNet透過注意力遮罩的設計，針對可提供互補特徵的ST-ROI區域進行關注。

### Contributions
1. 提出了一種多模態深度學習架構，該架構在模型級別融合了不同的數據模態，並使用骨骼骨頭流(skeleton bone stream)和注意力機制，以提升RGB-D影片中的動作辨識。
1. 在三個基準數據集（NTU RGB + D 120 [10]，PKU-MMD [23]和Northwestern-UCLA Multiview [24]）上展示了該方法的優異性能，大大提高了現有技術的水平。
1. 通過分析所提出的MMNet的兩個關鍵參數，進一步驗證了該方法的有效性。

### 現有技術遇到的困難
1. 僅透過單模態資料作為人體動作辨識之輸入的結果過於狹隘，例如RGB-based方法欠缺3D結構資訊，易受到背景或角度影響；而skeleton-based則欠缺紋理和色彩資訊，使骨架動向相像的動作會難以辨別。如下圖，相似動作的骨架構成相同，僅透過骨架進行辨識將會忽略動作間的細微差異。
![](https://hackmd.io/_uploads/HkaYxg9h2.png)
1. 多項研究指出，使用多模態資料確實提升了HAR結果。然而，要如何有效地結合多模態資料以提升HAR之準確度，仍是個值得探討的議題。

---

## Related Works

### Unimodal HAR
1. Skeleton-based HAR: 欠缺紋理和色彩資訊，因此骨架動向相像的動作會難以辨別。
2. RGB Video-based HAR: 欠缺3D結構資訊

### Multimodal HAR
其他多模態方法如: 結合骨架點位與其連接(joint & bone)、不同感測器資料之結合

1. Fusion-Based Multimodal HAR (data fusion[14])
* 可依據融合的資料分為以下三種：
    * data-level fusion: 在資料層次進行融合，將不同模態的資料進行結合，形成一個新的資料集。這種方法通常用於資料模態相同或相似的情況下，例如將RGB和HSV的圖像資料合併。
    * feature-level fusion: 在特徵層次進行融合，將不同模態的特徵進行結合，形成一個新的特徵集。這種方法通常用於資料模態不同但有相似特徵的情況下，例如將RGB圖像和深度圖像的特徵進行結合。常見方法為在全連接層進行特徵融合。
    * decision-level fusion: 在決策層次進行融合，將不同模態的決策結果進行結合，形成一個新的決策結果。這種方法通常用於資料模態不同且沒有相似特徵的情況下。常見方法為將softmax層得結果整合，例如將RGB影像與聲音資料的決策結果進行結合。
* 亦可依據其表示方式分為以下兩種[18]：
    * joint representations：在特徵空間中將不同模態的特徵進行連接。
    * coordinated representations：將不同模態之間的表示進行對齊後，在進行連接。例如，將不同模態的特徵映射到同一個空間中，或者進行相關性分析。

> Our multimodal setting is distinct from that in [48], where not all data modalities were available in the testing phase. Instead, we focus on a case where all data modalities were available for the training and testing phases, leading to a multimodal learning setting called multimodal fusion [50].

2. Model-Based Multimodal HAR
* 透過專注於對骨架模態帶來互補特徵的身體區域，從RGB模態中學習其表示(symbol)。即先提取不同模態之特徵表示後，再將其加以融合。
* 概念上像co-learning[18]，將不同模態之間的資訊互補或相互學習、融合，以提高模型的準確性。
> Barsoum et al. [37] developed a sequence-to-sequence model for probabilistic human motion prediction, which predicts multiple plausible future human poses from the same input. However, it is not yet clear whether the generated data can be used to enhance HAR models’ generalization abilities or accuracy.

---

## Method
![](https://hackmd.io/_uploads/ryAsVWqnn.png)
### MODEL-BASED MULTIMODAL NETWORK
* 模型輸入: 
    * skeleton joint: 人體3D點位由深度相機(kinect)提供
    * skeleton bone: 由skeleton joint轉換而來
    * RGB video: 後續將對影像針對人體部位進行ROI裁切，但此處的人體骨架點位是另外由pose estimation model取得而非kinect
* 模型輸出: 
$\hat{y} = G_J(O_J, J) + G_B(O_B, B) + G_V(O_V, V)$

#### ST-ROI (Construct ST-ROI From RGB Modality)
* 透過OpenPose取得人體骨架點位，再藉由transformation function $g$ 將點位轉換成ROI。其公式中的 $f^{(i)}_{t}$ 為影片 $V^i$ 的第 $i$ 幀，而 $o^{(i)}_{tj}$ 則是在第 $i$ 幀時OpenPose的第 $j$ 個點位。其中， $j$ 的數量不會超過OpenPose全部點位數量，僅取 $M'$ 個我們感興趣的點位： $R^{(i)}_{tj} = g(f^{(i)}_{t}, o^{(i)}_{tj})$
* 以時序採樣的方式，選取 $L$ 個代表幀，再將其垂直合併為 $R^{(i)_{t}}$ ；同樣地，於不同幀地不同骨架點位轉換為一正方形的ROI $R^{(i)}_{tj}$ 後，也會被水平地合併為 $R^{(i)_{j}}$ 。這兩組資料合併後即構成一幀方形的ST-ROI，其每一行代表一幀資訊（垂直），每一列代表一骨架資訊（水平）。因此，最後會以 $R^{i}$ 作為 $V^{(i)}$ 的代表，其中每一幀皆由 $M' \times L$ 大小的 子ST-ROI $R^{(i)}_{tj}$ 作為代表。
![](https://hackmd.io/_uploads/BkGVrz5hn.png)

#### Joint Weights (Learn Joint Weights From Skeleton Modality)
* 骨架的輸入如fig. 4所示，基本上與GCN模型相同，透過Graph Convolution整合了鄰近骨架點位的資訊（joint vertices），以計算特徵表示。這裡所得到的權重會根據joint vertice間的距離與joint vertice在圖中的級別位置而定。
![](https://hackmd.io/_uploads/rJyj2rQp2.png)
$\hat{J^{(i)}} = \sum \Lambda^{-1/2} A \Lambda ^{-1/2}f_{in}(J^{(i)}) W_k \odot M_{k}$　
<br> 
其中 $M_k$ 為attention map，用以表示每一vertex的重要性。而 $\hat{J}^{(i)}$ 為一形狀 $(c, t, M)$　的tensor（其維度分別輸出channel數、時序長度、vertice數量），用來推論動作類別；以外，也會被轉換為joint weight，提供RGB模態關注資訊，公式如下，即為一個代表Ｍ個不同骨架點位的權重矩陣：
$w^{(i)} = \dfrac{1}{ct} \sum^{c}_{1} \sum^{t}_{1} \sqrt{(\hat{J}_{ct}^{(i)})^2}$

* 透過GCN模型進行骨架模態的關節權重(Joint Weights)學習，其設定同ST-GCN `[1][2]`。
    > ST-GCN模型中，每個vertex都有一個特徵向量，以表示該關節(joint)在動作辨識任務中的重要性。因此，可透過分析節點，從而進行關節權重的學習。

#### Model-Based Fusion
* 作者提出一基於空間權重機制的RGB幀融合方法，使機器更好地關注有提供重要訊息的RGB特徵。
* 其他研究通常基於注意力機制的方法，從RGB模態本身計算出關注權重。而本研究作者則是使用從骨架模態得到的關節權重，與ST-ROI（自RGB模態取得）相乘後，再得到正規過後的RGB模態資訊。
![](https://hackmd.io/_uploads/SkxKa3Qq3h.png)

#### Objective Function
根據skeleton joint, skeleton bone, 和RGB video input個別的預測結果，設計目標函數為三者的cross-entropy加總: $L = L_J(\hat{y}^J, y) + L_B(\hat{y}^B, y) + L_V(\hat{y}^V, y)$
- skeleton joint
$\hat{y}^{j^{(i)}} = \sigma(G_J(O_J, J^{(i)}))$
其中， $G_J$ 為GCN； $O_J$ 為此GCN模型的可學習參數; $J^{(i)}$ 為骨架點位輸入的資料。
- skeleton bone
即skeleton joint資料的一種變形，會將兩個joint vector連接起來。
$\hat{y}^{B^{(i)}} = \sigma(G_B(O_B, B^{(i)}))$
其中， $G_B$ 為GCN； $O_B$ 為此GCN模型的可學習參數; $B^{(i)}$ 為skeleton bone input的資料。
    > 假設有兩個joint vector， $\upsilon_{t1} = (x_1, y_1, z_1)$ 和 $\upsilon_{t2} = (x_2, y_2, z_2)$ ，則bone vector為 $B_{t1} = \varepsilon_{t1} = \upsilon_{t1} - \upsilon_{t2} = (x_1 - x_2, y_1 - y_2, z_1 - z_3)$。
- RGB video input
透過ResNet對ST-ROI提取特徵。
$\hat{y}^{V^{(i)}} = \sigma(G_V(R'^{(i)}, O_V) + R'^{(i)})$
其中，$G_V(R'^{(i)}, O_V)$ 為需要學習的殘差映射(residual mapping)，利用殘差連接的方式關注差異處，可減少運算量； $O_V$ 為ResNet層的可學習參數。

以上的 $\sigma$ 表示一線性層，用來將模型的輸出形狀轉換為one hot表示。

#### Training and Optimization
- 透過joint weight的原方法(從RGB獲取權重)與本研究提出的方法(從skeleton獲取權重)，以驗證MMNet的有效性。
- skeleton joint子模塊 $G_J$
    - $O_J$ 可先自行訓練並固定權重(pretrained and then fixed)，再進行 RGB vedio子模塊 $G_V$ 的訓練( $O_V$ )；
    - 亦可 $O_J$ 和 $O_V$ 兩者同時訓練。
- skeleton bone子模塊 $G_B$ 則是完全分開訓練。
- MMNet的優化流程如下圖表示:
    1. 輸入skeleton joint $J$ 訓練子模型 $G_J$ , 並且獲得joint weights $w$
    2. 透過RGB video $V$ 建構 $M' \times L$ 大小的ST-ROI $R$
    3. 透過 $w$ 和 $R$ 建構skeleton-focused ST-ROI $R'$
    4. 輸入 $R'$ 訓練子模型 $G_V$
    5. 輸入 skeleton bone $B$ 訓練子模型 $G_B$
    6. 將三個子模型的預測結果合併
![](https://hackmd.io/_uploads/HyEEw9g6h.png)

> Several other loss terms could be adopted for joint weights to pursue high recognition accuracy. For instance, according to the findings in [44], both the loss that encourages joint weights to maintain diversity and the loss that leads to joint weights with temporal variance can elicit slight recognition improvements.

---

## Results

### Datasets
* NTU RGB+D 60 (96 pixels)
* NTU RGB+D 120 (96 pixels)
* PKU-MMD (96 pixels)
* Northwestern-UCLA (48 pixels)
* Toyota Smarthome (48 pixels)

### Implemetation Details
* ST-ROI: $M' \times L$ 的 ST-ROI會先resize為225x225並且正歸化後，才會餵入ResNet18。而Northwestern-UCLA 和 Toyota Smarthome資料相對較小，因此會另外執行隨機翻轉的處理。
* $G_J$ : 1) 使用了GCN模型計算空間權重(spatial weight) [1]; 2) 為了減輕時間位置(mean values of temporal positions)對於關節權重的影響，作者選擇了前15個權重值最大的時間位置來計算關節權重
* optimizer: SGD (learning rate=0.1; 10th epoch=0.01; 50th epoch=0.001)
* early stop: 80th epoch
* minibatch size: 64
* GPU: 4 GTX 1080 Ti GPUs

### Experiments
#### RGB+D 60
* 針對RGB Video融合上，做了權重更新的ablation study如下：
    * without joint weight：不使用skeleton modality學習來的權重，也就是在 $G_V$ 中沒有學習骨架資訊
    * dynamic joint weight：骨架子模組 $G_J$ 和RGB子模塊 $G_V$ (ResNet18)同時訓練，即$O_J$ 和 $O_V$ 會一起變動
    * fixed joint weight：訓練骨架子模組 $G_J$ 後固定權重( $O_J$ )(pretrained "GCN-Joints")，再進行RGB子模塊 $G_V$ (ResNet18)的訓練( $O_V$ )
* 除了以ResNet作為ST-ROI特徵提取，作者也嘗試Inception-v3和EfficientNet等backbone，並且取得更優異的表現。
* 相較於VPN++，雖然MMNet在此資料集的表現較為遜色，但在其他大型資料集如RGB+D 120或Northwestern-UCLA Multiview都超過其表現。
![](https://hackmd.io/_uploads/SyiOccepn.png)
![](https://hackmd.io/_uploads/S1EdLsla3.png)
![](https://hackmd.io/_uploads/BySR8sl6h.png)
![](https://hackmd.io/_uploads/BkStUjean.png)

#### RGB+D 120
![](https://hackmd.io/_uploads/SyRq8ixT3.png)
* 比較了MS-G3D加入ST-ROI(fixed weights)的表現
![](https://hackmd.io/_uploads/H1-9IjgT2.png)
* 特別與VPN進行比較，可以明顯看出在運行時間與資源占用上，MMNet是較為出色的。
![](https://hackmd.io/_uploads/r1ssIiga2.png)
![](https://hackmd.io/_uploads/Skivb3e63.png)

> 其他資料集的實驗結果大同小異，這邊不加以探討

#### Analysis of Joint Weights
* $G_J$ 可學習到骨架點位於特定時間點的重要性，顯現出一動作區間中骨架資訊會隨時間改變。若我們利用[joint weights公式](#Joint-Weights-(Learn-Joint-Weights-From-Skeleton-Modality))將所有時序位置資訊直接取平均值來獲取權重，便會失去特定重要時序上的特徵。
* 因此作者打算取前N個最重要的時序位置來計算joint weights，但作者發現在同個時序位置上的RGB資訊和骨架資訊並非同等重要，導致直接從兩模態融合的資訊來取前N個重要時序位置的資訊，效果並不好。
* 作者決定改以在每一人體部位( $J^{(i)}_{tj}$ )都取前15個最重要的時序位置，(即神經元激活值(neuron activation values)最大的前15個時序位置，他們代表了動作辨識中資訊的重要程度，用來計算其所對應身體部位的joint weights)。

![](https://hackmd.io/_uploads/HkO143x63.png)
![](https://hackmd.io/_uploads/Sk_e43l6h.png)

#### Analysis of Skeleton-Focused Representation
![](https://hackmd.io/_uploads/BycW4ngpn.png)
![](https://hackmd.io/_uploads/SkGPwng62.png)

---

## Conclusion
### Future Works
* 其他模態之研究: depth, optical flow
* outdoor action: 考慮背景資訊, 以符合真實場景應用

---

## Discussion
* 因RGB模態的模型需要待skeleton joint模態的模型訓練後得到joint weight參數才可繼續訓練，若要應用在即時且實際場景的辨識上將是一挑戰。
* 在RGB模態中，須額外使用姿態辨識模型推論骨架，而不是直接使用kinect所提供的骨架資訊，使方法複雜化。
* 若將skeleton input的資訊3D改為2D，是否會有明顯差異？若能調整為僅使用2D相機並且透過姿態辨識模型推論骨架，亦可較好將模型進行整合。
* 在此方法中，三種模態的資料需要各自進行模型訓練，再以essemble方式輸出辨識結果，可能相當耗時。是否為每種動作皆需要三種模態資料進行辨識, 可再加以探討。