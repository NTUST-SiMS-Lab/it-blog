---
title: 【論文研讀】Revisiting Skeleton-based Action Recognition(PoseC3D)
catalog: true
date: 2023-08-16
author: Frank Liou
categories:
- paper review
- HAR
---


# Revisiting Skeleton-based Action Recognition(PoseC3D)


論文出處:2022 IEEE/CVF Conference on Computer Vision and Pattern Recognition (CVPR)

作者:Haodong Duan, Yue Zhao, Kai Chen; Dahua Lin; Bo Dai
* [原文連結](
https://arxiv.org/pdf/2104.13586.pdf)
* [papers with code](https://paperswithcode.com/paper/revisiting-skeleton-based-action-recognition)
* [github](https://github.com/kennymckormick/pyskl)
* [youtube](https://www.youtube.com/watch?v=Zk_sqJHiSjk)

## 代補:
* 自己的心得
* 精簡內文
* 3DCNN詳細介紹


# Introduction
在現有的研究中，發表了多種video-based的辨識方式，如RGB、光流(optical
flows)、[聲波](https://arxiv.org/abs/2001.08740)(audio waves)(蠻新的之前沒聽過)和人體骨架。skeleton-based的動作辨識因為其穩健性近年來受到越來越多的關注。骨架通常表示為關節坐標與骨骼，由於只包含骨架信息，較不受背景變化和光照變化等環境干擾。而在skeleton-based中的方法又以GCN占多數，但GCN會出現以下的問題:
1. 穩健性(Robustness):雖然GCN可直接處理人體關節坐標，**但其識別能力會受到坐標偏移或消失的嚴重影響**，而在使用不同的骨架推論模型獲取坐標時，坐標分佈偏移往往會發生。坐標的擾動會導致完全不同的預測結果
2. 互通性(Interoperability):RGB、光流和骨架等不同模態的特徵是互補的。因此將這些模態**有效的**結合起來，往往能提高動作辯識的性能。然而，GCN是在骨架的非歐幾里得幾何圖形上運行的，因此很難與通常在歐幾里得幾何網格上表示的其他模態融合
3. 擴展性(Scalability):由於GCN將每個關節視為一個節點，因此**GCN的複雜度與人數成線性關係**，這限制了它在涉及多人的場景(如群體活動識別)中的適用性。

對比GCN-based的方法，PoseConv3D主要有以下優勢：
1. 使用3D Heatmap Volumes**對上游的骨架推論更具穩健性**，實驗發現PoseConv3D在通過不同方法獲得的輸入骨架上具有良好的通用性
2. PoseConv3D依賴於skeleton heatmap，並具有CNN架構的特性，更容易與其他模態集成到多通道CNN中，這特性為進一步提高辨識性能開闢了很大的設計空間。
3. PoseConv3D可以處理不同數量的人，而不會增加計算量，因為3D Heatmap Volumes的複雜性與人數無關(作者有分析不同方法，最後發現直接疊加多人的3D Heatmap Volumes最為有效)

* PoseConv3D與GCN的差異
![](https://hackmd.io/_uploads/HJZpBiIo2.png =80%x)

# Related Work 
1. GCN-based:ST-GCN是著名baseline，但會有上述提到的問題 (穩健性、互通性、擴展性)
2. CNN-based:不管是2D-CNN或3D-CNN(直接整合成3D或以偽影像堆疊的方式)都會有訊息丟失的問題，導致效果較差，如[PoTion](https://openaccess.thecvf.com/content_cvpr_2018/html/Choutas_PoTion_Pose_MoTion_CVPR_2018_paper.html)將骨架點序列以color coding 的方式繪製在一張圖上，並用2D-CNN進行處理，而在這時序壓縮過程中導致信息丟失
![](https://hackmd.io/_uploads/SJmuxe3jh.png =70%x)

# frame work
![](https://hackmd.io/_uploads/ByQjcuIjn.png)
模型主要有兩個模塊，分別為**骨架模塊(PoseConv3D)** 以及 **骨架+RGB模塊(RGB PoseConv3D)**，強調模型的互通性(interoperability)
首先使用兩階段骨架推論器(**Faster-RCNN偵測+HRNet_w32推論**)來進行2D人體骨架估計，然後沿著時間維度堆疊關鍵點或骨架的熱圖,並對生成的3D Heatmap Volumes進行預處理，最後使用MMAction2提供的[3D ConvNets](https://github.com/open-mmlab/mmaction2)對3D Heatmap Volumes進行動作分類
>在某些情況下，即使骨架估計的質量很差，只要其中包含與目標動作相關的模式，那也足以用來進行動作辨識。如HRNet在Fine GYM數據集上的辨識效果實際不佳，但依賴於其所估計的關鍵點，依然能在動作辨識任務上取得出色的效果

## 3.1 input
![](https://hackmd.io/_uploads/ryTr1MEj2.png =80%x)

PoseConv3D使用2D骨架(不具深度資訊)作為輸入，因為通常2D骨架辨識比3D來得好，**2D骨架是由骨架關節的熱圖表示，而不是整張圖的座標點**，會先使用uniform sampling選出隨機T幀，每一幀都會生成K×H×W的3D Heatmap Volumes。
使用帶有ResNet50的[Faster-RCNN](https://proceedings.neurips.cc/paper_files/paper/2015/file/14bfa6bb14875e45bba028a21ed38046-Paper.pdf)進行人體檢測，再使用COCO pre-trained過的[HRNet_w32](https://openaccess.thecvf.com/content_CVPR_2019/papers/Sun_Deep_High-Resolution_Representation_Learning_for_Human_Pose_Estimation_CVPR_2019_paper.pdf)進行人體骨架推論。最後PoseConv3D在3D Heatmap Volumes的基礎下採用3D-CNN來辨識動作。

* 驗證2D與3D模型在資料集準確度 [未標出處](https://zhuanlan.zhihu.com/p/395588459)

![](https://hackmd.io/_uploads/ry-cocUi2.png =80%x)


## 3.2 Pose Extraction
採用**2D自上而下的骨架推論器**，並使用(x,y,c)的方式儲存關鍵點。(x,y)為關鍵點座標，c為對應的熱圖分數，2D Heatmap的大小為K×H×W(關節數×高×寬)
如果只有骨架推論器的座標與置信度，則可以設第k個關鍵點座標為(Xk，yk)，置信度為Ck，依公式生成關鍵點熱圖數值，並以σ控制標準差，J值藉於0-1間
![](https://hackmd.io/_uploads/Bk7ZSZns3.png =60%x)
介於ak、bk兩點間的骨架熱圖依下列公式生成，D代表該點(i,j)與線段ak,bk的垂直距離，L介於0-1間
![](https://hackmd.io/_uploads/BkelHZhjn.png =80%x)

>雖然上述過程假設每一幀都是一個人,但PoseConv3D可以將其擴展到多人的情況，在這種情況下直接累加所有人的第k個高斯圖，而無需放大熱圖或增加K值，最後,通過沿時間維度堆積所有熱圖可得到3D Heatmap Volumes，大小為K × T × H × W 
K:關結數(17)
T:幀數(32)
H,W:高,寬(56,56)

## 3.3 3D-CNN for Action Recognition
為了證明3D-CNN在動作辨識的有效性，但在這方面較少研究，因此設計了兩個模塊
* **PoseConv3D**
  專注於人體骨架資訊上，以3D Heatmap Volumes作為input，使3D-CNN適應skeleton-based動作辨識需要進行兩點修改，基於以下兩點，分別對三種3D-CNN進行了調整：[C3D](https://openaccess.thecvf.com/content_iccv_2015/papers/Tran_Learning_Spatiotemporal_Features_ICCV_2015_paper.pdf)、[SlowOnly](https://openaccess.thecvf.com/content_ICCV_2019/papers/Feichtenhofer_SlowFast_Networks_for_Video_Recognition_ICCV_2019_paper.pdf)和[X3D](https://openaccess.thecvf.com/content_CVPR_2020/papers/Feichtenhofer_X3D_Expanding_Architectures_for_Efficient_Video_Recognition_CVPR_2020_paper.pdf)
  此外，採用輕量級的3D-CNN可以顯著降低[FLOPs](https://www.wikiwand.com/zh-tw/FLOPS)與參數量，但性能些微下降(差距小於0.3%)，而因為SlowOnly的簡單性(直接從ResNet生成)和良好的性能，使用SlowOnly作為默認網路，且與其他RGB-based的動作辯識模型之間的互性使人體骨架更容易使用於多模態融合
   1. 因為3D Heatmap Volumes的[空間分辨率](https://www.anymp4.com/zh-TW/photo-editing/images-resolution.html)不需要像RGB那麼大(比RGB小4倍)，因此移除3D-CNN的下採樣階段
   2. 較淺(較少layers)和較薄(較少channels)的網路足以用於動作辨識，因為3D Heatmap Volumes已經是經過預處理的中級特徵

* PoseConv3D優點:
  1. 相比RGM輕很多
  2. input需要較小的空間尺寸和較長的時間長度
  3. 所需網路更薄且更輕

![](https://hackmd.io/_uploads/ryPBcFTs2.jpg)

![](https://hackmd.io/_uploads/Syj72wpi2.png =70%x)
 

>s 表示淺層(層數較少)
HR 表示高分辨率(雙倍高度和寬度)
wd 表示更寬的網絡，雙通道尺寸 


* **RGB Pose-Conv3D**
  為了展示PoseConv3D的互通性，提出RGBPose-Conv3D，用於人體骨架和RGB的融合，這是一個雙流3D-CNN，有兩條路徑分別處理 RGB和骨架
   1. 由於兩種模態的特性不同，因此兩條路徑是不對稱的，與RGB路徑相比，骨架路徑的通道寬度較少、網路深度較淺，inpute空間分辨率也較小
   2) 受到SlowFast的啟發，兩條路徑之間增加了雙向橫向連接(Time stride convolutions)，以促進兩種模態之間的早期特徵融合

  為了避免過擬合，RGBPose-Conv3D在訓練時對每條通路分別採用了兩個單獨的交叉熵損失，實驗發現通過橫向連接實現的早期特徵融合與僅通過後期融合實現的特徵融合相比，具有一致的改進效果
![](https://hackmd.io/_uploads/BkWq9K6ih.jpg)

# Experiments
## 4.1 使用的數據集
{%youtube oS7fX9Eg2ws %}
共使用六個數據集:Fine GYM、NTURGB+D(#1/RGB+Pose)、Kinetics 400、UCF101、HMDB51、Volleyball(#1/Pose Only)
除了Fine-GYM數據集外，所有數據集的骨架都是RGB輸入自上而下的骨架推論器來獲得。並報告了Fine GYM的平均Top-1精度和其他數據集的Top-1精度。在實驗中採用了在MMAction2中實現的3D ConvNets。

* [**FineGYM**](https://paperswithcode.com/dataset/finegym) 是一個細粒度([fine-grained](https://baubimedi.medium.com/%E9%80%9F%E8%A8%98ai%E8%AA%B2%E7%A8%8B-convolutional-neural-networks-for-computer-vision-applications-%E4%BA%8C-d5fbb995ffd7))動作辨識數據集，包含99個細粒度體操動作類別，2.9萬個影片。在姿勢提取過程中，有三種不同的人物邊界框：
  1. 檢測器預測的人物邊界框(Detection)
  2. 第一幀中運動員的GT邊界框，其餘幀的跟踪框(Tracking)
  3. 所有幀中運動員的GT邊界框(GT)，**在實驗中使用第三種邊界框提取的人體姿勢**
* **NTU-60** 包含60個動作的5.7萬個影片，而NTU-120包含120個動作的11.4萬個影片
  數據集以三種方式分割:跨主體(X-Sub)、跨視角(X-View/NTU-60)、跨設置(X-Set/NTU-120)，其中動作主體、攝像機視角、攝像機設置在訓練和驗證集中是不同的，**在實驗中使用NTU-60和NTU-120的X-sub**
* **Kinetics 400** 是一個大型視頻數據集，包含400個動作類別的30萬個視頻
* [**UCF101**](https://paperswithcode.com/dataset/ucf101)和 [**HMDB51**](https://paperswithcode.com/dataset/hmdb51)的規模較小，分別包含101個類別的1.3萬個視頻和51個類別的6700個視頻
* [**Volleyball**](https://arxiv.org/pdf/1511.06040v2.pdf)是一個多人動作辨識數據集，包含8個多人動作類別的4830個視頻。每幀約12人，而只有中心幀有GT人物框lable，使用跟踪框進行骨架提取
## 4.2 PoseConv3D與[MS-G3D](https://paperswithcode.com/paper/disentangling-and-unifying-graph-convolutions)比較


MS-G3D是GCN-based的多維模型，兩個模型採用完全相同的輸入(GCN採用三維坐標(x,y,c)，PoseConv3D採用由坐標生成的熱圖)，input的尺寸為**48×56×56(很怪的數字，不曉得為什麼)**，並使用1&10 clip testing
> clip testing是指將一個長視頻分成多個短視頻片段(稱為clip)，然後對每個clip進行單獨的測試。這樣做的目的是為了更好地評估模型的性能，因為它可以測試模型對不同動作片段的辨識能力，1-clip testing是從每個影片中隨機選擇一個片段進行測試，而10-clip testing則是從每個影片中選擇10個片段進行測試。
>此外，clip testing還可以幫助減少過擬合現象，因為模型需要在不同的clip上進行測試，而不是在整個長視頻上進行測試。使用 uniform sampling的1-clip testing在某些情況下可以達到比使用fixed stride sampling的10-clip testing更好的結果
>![](https://hackmd.io/_uploads/BJrVKwRsn.png =80%x)

>
* **性能與效率(Performance&Efficiency)**
在多數資料集上，PoseConv3D在表現優於MS-G3D，參數量和FLOPs方面都比MS-G3D輕，因為PoseConv3D能利用多視角測試的優勢，它能對每個inpute的整個heatmap volumes進行Pooling，且只有PoseConv3D可以受益於多clip testing，因其採樣一個子集而非全部幀以構成輸入。
![](https://hackmd.io/_uploads/S1gzvE0i2.png)
>PoseConv3D在不同數據集上使用相同的架構和超參數，而GCN則需要在不同數據集上對架構和超參數進行調整(但MS-G3D在[Assembly101](https://paperswithcode.com/dataset/assembly101)排名#1，或許可以參考)

* **穩健性(Robustness)**
為了測試兩種模型的穩健性，在輸入骨架中放棄一部分的關鍵點，以此觀察擾動會對準確度產生什麼影響，關鍵點包括左右的bow(肩膀??)、手腕、膝蓋、腳踝，由於這些關鍵點對體操來說比軀幹或臉部關鍵點更為重要，通過在每一幀中以機率p隨機刪除一個關鍵點來測試這兩個模型
可以看到PoseConv3D對這種擾動具有很高的穩健性，Mean-Top1的適度下降0.9%，而GCN下降14.3%。可以用噪聲輸入來訓練GCN，如加入dropout layer 。然而，在p=1的情況下，GCN的Mean-Top1準確率仍然下降了 1.4%，以此表明PoseConv3D在動作辯識的穩健性明顯優於GCN
![](https://hackmd.io/_uploads/S1zHiB0s2.png =80%x)

* **通用性(Generalization)**
  為了比較GCN和3D-CNN的泛化效果，在Fine GYM上設計了一個交叉驗證方式，使用兩個模型，分別為HRNet(Higher Quality，簡稱HQ)和Mobile Net(Lower Quality，LQ)進行骨架推論，並分別在頂部訓練兩個PoseConv3D。
  **在訓練/ 測試時分別使用不同方式提取的人體骨架**。例如，在訓練時使用HRNet(HQ)模型提取出的人體骨骼，而在測試時使用MobileNet(LQ)模型提取出的人體骨骼，將LQ的結果輸入到使用HQ訓練的模型中，反之亦然。在這種設定下，PoseConv3D的表現一致好於GCN，使用PoseConv3D進行訓練和測試時，使用低質量姿勢時，精確度下降較少。**也可以改變人員框的來源**，使用GT框(HQ)或Track(LQ)進行訓練和測試，PoseConov3D的性能下降也比GCN小得多。
![](https://hackmd.io/_uploads/S176NyJh2.png)

* **擴展性(Scalability)**
  GCN的計算量隨影片中人數的增加而線性遞增，因此在多人動作辨識方面效率較低。排球數據集中的每段視頻包含13個人和20個幀，對於GCN來說，相應的輸入形狀將是13×20×17×3，比一個人的輸入大13倍。在這種配置下，GCN的參數數和FLOPs分別為2.8M和7.2G。
  對於 PoseConv3D，可以使用一個形狀為17×12×56×56的3D Heatmap Volumes來表示所有13人。Pose-SlowOnly的基本通道寬度設置為16，因此只需0.52M參數和1.6GFLOPs。儘管參數和 FLOPs少，PoseConv3D在排球驗證中的Top-1準確率仍達到 91.3%，比GCN-based的方法高出2.1%。

>在實驗中發現，在使用Pose Conv3D進行群體動作辨識時，用單一3D Heatmap Volumes表示所有人是最佳做法。在排球數據集上，還探索了分別處理不同人物熱圖的三種替代方案：
A.對於每個關節為N個人分配N個通道。這樣，PoseConv3D輸入就有N×K個通道
B.為每個人生成三維熱圖卷(K×T×H×W)，並使用PoseConv3D(N人共享權重)分別提取骨架特徵。使用平均池法將N個人的特徵匯總為一個特徵向量
C.在B的基礎上，在平均池化之前插入幾個(1到3個)編碼器層(從頭開始或通過B預訓練)，以進行人與人之間的建模。
![](https://hackmd.io/_uploads/H1wzCSCo2.png)
對於A方案，高維的輸入會導致嚴重的過擬合，Top-1的準確率僅為75.3%。對於B、C方案，儘管消耗了大量計算量，但辨識性能並不令高，Top-1準確率分別為85.7%和87.9%，仍然遠遠低於累加熱圖(91.3%)。累加熱圖是一種簡單而相對較好的解決方案，可以在復雜性和有效性之間取得平衡。更複雜的設計可能會帶來進一步的改進，這有待於今後的工作。

## 4.3 使用RGB PoseConv3D多模態融合
PoseConv3D的3D-CNN架構使其能夠更靈活地通過一些融合方式，將骨架與其他模態融合，在RGB Pose-Conv3D中，Time stride convolutions(文章沒有細講)被用於RGB和骨架的channel的雙向橫向連接中(bi-directional lateral connections)，目的是多模態的特徵融合，而由於RGB幀是低級特徵，因此路徑的幀率較小，channel寬度較大。相反，骨架路徑的幀率較大，channel寬度較小
首先會先分別對RGB和骨架模型進行預訓練當作初始化，再繼續對SlowOnly網路進行finetune，以訓練橫向連接，最終的預測結果將通過後期融合兩條路徑的預測得分來實現，RGBPose-Conv3D 可以通過早期+晚期融合獲得更好的效果。
在訓練時，每條路徑分別使用了兩個單獨的損失，因為從兩種模態聯合學習的單一損失會導致嚴重的過擬合
![](https://hackmd.io/_uploads/BkWq9K6ih.jpg)
>看不懂這張表QQ
>>
![](https://hackmd.io/_uploads/SJG2-wAo2.png =80%x)
>在FineGYM中，骨架模式比RGB更為重要，而在NTU-60中則相反。然而，通過早期+後期融合，這兩種模式的性能都有所提高
![](https://hackmd.io/_uploads/ByCW9P0oh.png =80%x)
實驗發現雙向特徵融合比單向特徵融合效果更好，且**1-clip testing的早期+晚期融合效果優於10-clip testing的晚期融合效果**
>![](https://hackmd.io/_uploads/BJVqzDRi3.png =80%x)

## 4.4 與其他SOTA模型比較
![](https://hackmd.io/_uploads/r1sDLqCi2.png)

* **Skeleton-based Action Recognition**
將PoseConv3D與之前skeleton-based的動作辨識技術進行了比較。先前的模型(表上半部)在NTURGB+D中使用Kinect採集的3D骨架，在Kinetics中使用OpenPose提取的2D骨架(Fine GYM骨架數據尚不清楚)。PoseConv3D採用的是第3.1節中介紹的所提取的2D骨架(Faster-RCNN偵測+HRNet_w32)。將形狀為48×56×56的3D Heatmap Volumes作為輸入，使用PoseConv3D與SlowOnly辨識，並使用10-clip testing獲得的準確率。
為了進行公平比較，還使用二維人體骨架(MS-G3D++)對最先進的MS-G3D進行了評估﹑MS-G3D++ 直接將提取的坐標三元組(x,y,c)作為輸入，而PoseConv3D則將從坐標三元組生成的熱圖作為輸入。在使用高質量二維人體骨架的情況下，MS-G3D++ 和PoseConv3D的性能都遠遠優於之前的先進技術，這表明了基於骨骼的動作辨識中姿勢提取方法的重要性。當兩者都將高質量的二維姿勢作為輸入時，PoseConv3D在6個基準測試中的5個測試中都優於最先進的MS-G3D，顯示了其強大的時空特徵學習能力。
在4項NTURGB+D基準測試中，PoseConv3D有3項取得了迄今為止最好的成積。在Kinetics基准上，PoseConv3D明顯超越了MS-G3D++ ，顯著優於之前的所有方法。除了文獻中報告的基線外，之前沒有任何研究以FineGYM上基於骨骼的動作辨識為目標，研究首次將性能提高到了一個不錯的水平。

* **多模態融合(Multi-modality Fusion)**


  與多模態動作辨識SOTA模型相比，多模態融合技術在多個基準測試中取得了優異的識別性能

  作為一種強大的表示方法，骨架本身也是其他模態(如RGB外觀)的補充。通過多模態融合(RGBPose-Conv3D或LateFusion)，我們在8個不同的視頻識別基準中取得了最先進的結果。
我們將提議的RGBPose-Conv3D應用於FineGYM和4個NTURGB+D基準，使用R50作為骨幹；16、48作為RGB/Pose-Pathway的時間長度。表9a顯示，我們的早期+晚期融合在各種基準測試中都取得了優異的性能。
我們還嘗試用LateFusion將PoseConv3D的預測結果直接與其他模態融合。表9b顯示，與Pose模式的後期融合可以將識別精度提高到一個新水平。我們在三個動作識別基准上達到了新的水平：Kinetics400,UCF101和HMDB51。在具有挑戰性的Kinetics400基准上，與PoseConv3D預測融合後，識別精度比最新水平提高了0.6%，這有力地證明了Pose模式的互補性。
![](https://hackmd.io/_uploads/HJIsy2Rjh.png)
![](https://hackmd.io/_uploads/HyV3Jh0i3.png)
>R、F、P表示RGB、Flow、Pose

## 4.5熱圖預處理的消融(ablation)
1. Subject centered cropping:
   由於數據集中人物的體型和位置可能會有很大差異，希望能在H×W的input內盡可能聚焦於行動主體。此方法是逐幀找到所有2D骨架的最小bounding box，然後根據找到的bounding box取得**最小外接框**來裁剪所有幀，並將裁剪後的熱圖重新縮放至特定大小。
   在輸入大小為32×56×56的Fine GYM數據集上進行了兩次實驗，分別使用或不使用此方式，以主體為中心的裁剪有助於數據預處理，可將平均值Top1從91.7%提升至92.7%，NTU-60則是從92.2%提升至93.2%
   
![](https://hackmd.io/_uploads/HyFzPK6sn.jpg )
2. Uniform sampling:
   使用temporal window時，較小temporal window的輸入可能無法捕捉到人類的全部動作，希望模型能更加專注於整體動作並降低過擬和。此方法是需要採N幀時，先將整個視頻均分為長度相同的N段，並在每段中隨機選取一幀，此方式對骨架動作辨識尤其適用
   在FineGYM和NTU-60上進行了實驗
   * 固定步長採樣(fixed stride sampling)是從一個固定大小為32幀的temporal window採樣，設採樣步長為2、3、4，從中取得對應幀數
   * 均勻採樣(uniform sampling)是從整個片段中均勻採樣32個幀

   均勻採樣始終優於固定步長採樣結果，在均勻採樣的情況下，1-clip testing 結果甚至比固定步長採樣10-clip testing結果更好。
   
   
   ![](https://hackmd.io/_uploads/SyZi5Who2.png )
   >除了Uni-32[1c]使用1-clip testing外，其他皆使用10-clip testing (固定步長採樣怎麼用??)
   
   值得注意的是，NTU-60和Fine GYM中的視頻長度變化很大，通過分析發現，均勻採樣主要提高了數據集中**長視頻**的識別性能。此外，在這兩個數據集上，均勻採樣在RGB-based的識別上也優於固定步長採樣
   
   ![](https://hackmd.io/_uploads/rJBe3hAs2.png)
   >在NTU-60和GYM上將均勻採樣應用於RGB-based的動作辨識，使用 SlowOnly-R50作為骨幹，並將輸入長度設為16幀。
   在兩個數據集上RGB-based的辯識中，均勻採樣也優於固定步長採樣，在1-clip testing中，均勻採樣的準確率優於10-clip testing中固定步長採樣的準確率。
   均勻採樣的優勢主要歸因於這兩個數據集的視頻長度變化很大。相反，在 Kinetics4008上應用均勻採樣時，準確率略有下降，對於輸入長度為8幀的 SlowOnly-R50，Top-1的準確率從75.6%下降到75.2%。

* **Joints和Limbs的偽熱圖(Pseudo Heatmaps)**
  用於skeleton-based的動作識別的GCN方法通常將多個流(關節、骨骼等)的結果集合在一起以獲得更好的識別性能。這種做法對於PoseConv3D也是可行的。根據坐標(x,y,c)可以生成Joints和Limbs的偽熱圖。一般來說，Joints Heatmaps和Limbs Heatmaps都是3D-CNN的良好輸入。
  將Joints-PoseConv3D和Limbs-PoseConv3D(即PoseConv3D(J+L))的結果組合在一起，可以顯著且持續提高性能。

* **3D Heatmap Volumes v.s 2D Heatmap Aggregations.**
3D Heatmap Volumes 是一種更加**無損(lossless)** 的2D骨架表示法，而2D偽影像則是將熱圖與著色或時間卷積聚合在一起，[PoTion](https://openaccess.thecvf.com/content_cvpr_2018/html/Choutas_PoTion_Pose_MoTion_CVPR_2018_paper.html)和[PA3D](https://openaccess.thecvf.com/content_CVPR_2019/papers/Yan_PA3D_Pose-Action_3D_Machine_for_Video_Recognition_CVPR_2019_paper.pdf)沒有在skeleton-based的動作辯識的流行基准上進行評估，也沒有公開的實施方案，在初步研究中，PoTion的準確率(85%)遠低於GCN或PoseConv3D(均為 90%)。並在UCF101、HMDB51和NTURGB+D上對它們進行了評估，PoseConv3D 使用3D Heatmap Volumes實現的辯識結果比使用2D heatmap aggregations作為輸入的2D-CNN好得多。在使用輕量級X3D時，PoseConv3D 的表現明顯優於2D-CNNs，其FLOP值與2D-CNNs相當，而參數卻少得多
![](https://hackmd.io/_uploads/BkwzzC0j3.png)

   * PA3D的2D heatmap aggregations
 ![](https://hackmd.io/_uploads/HyamkA0sh.png =70%x)

其他值得改善的地方
1. 相對GCN，所需計算量還是較多：使用基於R50的3D網絡，其算力消耗僅能做到與GCN中的較heavy方法MS-G3D相當，多於其他一些更輕量的GCN方法
2. 如輸入為3D點的情況下，目前只能將其先投影到2D，存在信息損失
3. 目前還不能realtime辨識

問題:
1. 關於3D的第三維度是T還是K?:第三個維度是K，T幀的辨識與前後幀無關
2. 3D-CNN的詳細內容，ResNet
3. 什麼是GT框?
4. Time stride convolutions