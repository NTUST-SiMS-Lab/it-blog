---
title: 【論文研讀】2D Human Pose Estimation - A Survey
catalog: true
date: 2023-10-20
author: David Chen
categories:
- paper review
- Human Pose Estimation
- Survey
---
# 2D Human Pose Estimation: A Survey

[![hackmd-github-sync-badge](https://hackmd.io/Z1dLQGWvQFaNxoCxZf4btg/badge)](https://hackmd.io/Z1dLQGWvQFaNxoCxZf4btg)

* Journal reference: Multimedia Systems, 2022 
* Authors: Haoming Chen, Runyang Feng, Sifan Wu, Hao Xu, Fengcheng Zhou, Zhenguang Liu 
* Github: None
* 論文連結: [2D Human Pose Estimation: A Survey](https://arxiv.org/pdf/2204.07370.pdf)

---

## Network Architecture Design Method
2D HPE 通常分為兩個通用框架：
* **top-down** framework：使用 **two-step** procedure：
    1. 偵測人體邊界框(BBox)
    2. 分別對各個 BBox 進行 Single Person Pose Estimation (SPPE)

    $\Diamond$ **top-down** framework 可以隨著物體檢測器和姿勢偵測器的進步而不斷改進。
    
    **top-down** 可細分為以下幾個類別：
    * **Regression-Based**
    * **Heatmap-Based**
    * **Video-Based**
    * **Model Compressing-Based**

![](https://hackmd.io/_uploads/SyvuKT3WT.png)

* **bottom-up** framework：與 **top-down** 相比，**bottom-up** 透過**不依賴人類檢測，直接執行關鍵點估計**，以達成減少計算量的目的，但就有需要**判斷關節點屬於誰**的問題。

    **bottom-up** 可細分為以下幾個類別：
    * **Human Center Regression-Based**
    * **Associate Embedding-Based**
    * **Part Field-Based**

---

### Top-Down Framework
#### Regression-Based Methods
**Regression-Based** 很有效，但是他只有輸出每個關節的座標而已，完全不考慮身體部位的面積。
為了解決這個問題，發展出了 **heatmap-based** 的方法。

以下為幾個代表性的 **Regression-Based** 方法：
* **CNN**：DeepPose 透過級聯 CNN 提取影像特徵，然後透過全連接層回歸關節座標。
* **self-correcting model**：[Human Pose Estimation with Iterative Error Feedback](https://openaccess.thecvf.com/content_cvpr_2016/papers/Carreira_Human_Pose_Estimation_CVPR_2016_paper.pdf) 基於 GoogleNet 提出了一種**自校正**模型，逐步改變初始關節座標估計。
* **Re-parameterization**：[Compositional Human Pose Regression](https://openaccess.thecvf.com/content_ICCV_2017/papers/Sun_Compositional_Human_Pose_ICCV_2017_paper.pdf) 提出了一種結構感知回歸方法，該方法利用**結構重參數化**的骨骼姿勢表示，並因為建構在ResNet50之上，模型能夠捕捉更多的人體結構訊息，例如關節連接之類的。
* **GCN**：透過合併相鄰節點的特徵來增強節點的特徵，[Peeking into occluded joints: A novel framework for crowd pose estimation](https://arxiv.org/pdf/2003.10506.pdf) 將人體視為圖形結構，其中節點代表關節，邊緣代表骨骼，並建議使用**影像引導漸進式 GCN 模組**來估計不可見的關節。
* **Transformer**：[Pose Recognition With Cascade Transformers](https://openaccess.thecvf.com/content/CVPR2021/papers/Li_Pose_Recognition_With_Cascade_Transformers_CVPR_2021_paper.pdf) 提出了一個**級聯 Transformer**，執行人體和關鍵點檢測的 end-to-end 回歸，首先檢測所有人的邊界框，然後分別回歸每個人的所有關節座標。
$\Diamond$ 如果想做 end-to-end 感覺可以看一下這篇。

---

#### Heatmap-Based Methods
熱圖 $H_i$ 通過以第 $i$ 個關節位置$(x_i, y_i)$為中心的 **2D 高斯**產生，編碼該位置是第 i 個關節的機率。
訓練目標是預測總共 $N$ 個關節的 $N$ 個熱圖 $\begin {Bmatrix}H_1,H_2,..,H_N\end{Bmatrix}$。

**Heatmap-Based** 的準確率會比 **Regression-Based** 來的**高**，但是相對的**需要較多的計算資源**，以及有著不可避免的**量化誤差**。

以下為幾個代表性的 **Heatmap-Based** 方法：
* **Iterative Architecture (迭代架構)**：[Convolutional Pose Machines](https://openaccess.thecvf.com/content_cvpr_2016/papers/Wei_Convolutional_Pose_Machines_CVPR_2016_paper.pdf) 建構了一個**順序預測框架**，該框架採用 **sequential CNN** 來隱式模擬人體部位之間的遠程空間依賴性，並且提出了**中間監督**來緩解迭代架構中梯度消失的固有問題，後來因為 [ResNet](https://openaccess.thecvf.com/content_cvpr_2016/papers/He_Deep_Residual_Learning_CVPR_2016_paper.pdf) 出現，把梯度消失/爆炸的問題完美解決了，因此很多大模型就出現了。

    下圖為迭代架構的示意圖，( a )為 **Convolutional Pose Machine** 的架構，( b )為使用 LSTM 對 **Convolutional Pose Machine** 進行延伸的 **LSTM Pose Machines**。

![](https://hackmd.io/_uploads/B1FeHw6-T.png)

* **Symmetric Architecture (對稱架構)**：

    [Stacked Hourglass Networks for Human Pose Estimation](https://islab.ulsan.ac.kr/files/announcement/614/Stacked%20Hourglass%20Networks%20for%20Human%20Pose%20Estimation.pdf) 提出了一種基於**池化**和**上採樣**的連續步驟的新穎的**堆疊沙漏架構**，它結合了**所有尺度**的特徵來捕捉關節之間的各種空間關係。

    **堆疊沙漏架**構如下圖( a )所示。

    以下為基於這種**堆疊沙漏架構**的成功變體，這些變體模型都保留了**從高到低和從低到高卷積**之間的對稱結構：
    * [Multi-Context Attention for Human Pose Estimation](https://arxiv.org/pdf/1702.07432v1.pdf) 進化成**帶有側分支**的沙漏殘差單元，包括具有更大感受野的濾波器，這大大**增加了網絡的感受野**並**自動學習不同尺度的特徵**。
    * [Learning Feature Pyramids for Human Pose Estimation](https://arxiv.org/pdf/1708.01101v1.pdf) 以**金字塔殘差模組**取代了堆疊沙漏中的殘差塊，增強了網路的尺度不變性。
    * [Multi-Scale Structure-Aware Network for Human Pose Estimation](https://arxiv.org/pdf/1803.09894v3.pdf) 提出了一種**多尺度監督**，結合了所有尺度的關鍵點熱圖，從而獲得豐富的上下文特徵並提高了堆疊沙漏網路的性能。
    * [Learning Delicate Local Representations for Multi-Person Pose Estimation](https://arxiv.org/pdf/2003.04030.pdf) 設計了一個堆疊的沙漏狀網絡，即**殘差步驟網絡**，它聚合具有相同空間大小的特徵以產生**精緻的局部描述**。
    * [Does Learning Specific Features for Related Parts Help Human Pose Estimation?](https://openaccess.thecvf.com/content_CVPR_2019/papers/Tang_Does_Learning_Specific_Features_for_Related_Parts_Help_Human_Pose_CVPR_2019_paper.pdf) 採用沙漏網路作為主幹，並提出了一種**基於部分的分支網路來學習特定於不同部分組的表示**。
* **Asymmetric Architecture (非對稱架構)** ：
    與對稱架構一樣是高到低和低到高的卷積架構，但是非對稱架構**偏重於由高到低**的過程，因此存在**特徵編碼和解碼不平衡**的問題，可能會影響模型表現。
    
    以下模型採用經典分類網路（[VGGNet](https://arxiv.org/pdf/1409.1556.pdf) 和 [ResNet](https://openaccess.thecvf.com/content_cvpr_2016/papers/He_Deep_Residual_Learning_CVPR_2016_paper.pdf)）的子網路進行**從高到低**的卷積，並採用簡單網路進行**從低到高**的卷積：
    * [Simple Baselines for Human Pose Estimation and Tracking](https://openaccess.thecvf.com/content_ECCV_2018/papers/Bin_Xiao_Simple_Baselines_for_ECCV_2018_paper.pdf) 透過添加一些**反卷積層**而不是特徵圖插值來擴展 [ResNet](https://openaccess.thecvf.com/content_cvpr_2016/papers/He_Deep_Residual_Learning_CVPR_2016_paper.pdf)，如下圖( b )所示。
    * [Cascaded Pyramid Network for Multi-Person Pose Estimation](https://openaccess.thecvf.com/content_cvpr_2018/papers/Chen_Cascaded_Pyramid_Network_CVPR_2018_paper.pdf) 提出了一個**級聯金字塔網路**，它用 **GlobalNet** 偵測簡單的關鍵點，並用由多個常規卷積組成的 **RefineNet** 整合了 **GlobalNet** 的所有層級的特徵表示以處理困難的關鍵點，如下圖( c )所示。
* **High Resolution Architecture (高解析度架構)**：
    高解析度架構能夠在整個過程中**保持高解析度表示**，[HRNet](https://openaccess.thecvf.com/content_CVPR_2019/papers/Sun_Deep_High-Resolution_Representation_Learning_for_Human_Pose_Estimation_CVPR_2019_paper.pdf) 在多個視覺任務上實現最先進的結果，足以證明高解析度表示在人體姿勢估計方面的優越性。
    
    其中[Pay Attention Selectively and Comprehensively: Pyramid Gating Network for Human Pose Estimation without Pre-training](https://dl.acm.org/doi/abs/10.1145/3394171.3414041) 以 [HRNet](https://openaccess.thecvf.com/content_CVPR_2019/papers/Sun_Deep_High-Resolution_Representation_Learning_for_Human_Pose_Estimation_CVPR_2019_paper.pdf) 為骨幹網絡，進一步結合**門控機制**和**特徵注意模組**來選擇和融合**判別性和注意力感知特徵**。
    
    ![](https://hackmd.io/_uploads/ryx1hF6bp.png)
    $reg. conv.$ = 常規卷積層，$strided \  conv.$ = 用於可學習下採樣的跨步卷積層，
    $trans.conv.$ = 用於可學習上採樣的轉置卷積層，$ele. sum$ = 逐元求和

* **Composed Human Proposal Detection (組合人類提案檢測)**：
    上述模型專注於對從整個圖像中裁剪出的 **Human Proposal** 進行姿勢估計，並簡單地採用現成的 **Human Proposal Detecter** 進行 **Proposal Detection**，且 **Human Proposal 的品質(人類位置和冗餘檢測)會影響姿勢估計器的結果**。
    因此有以下兩派人馬從不同的角度去解決這個問題：
    * 改善 **Human Proposal** 派：
        * [Towards Accurate Multi-Person Pose Estimation in the Wild](https://openaccess.thecvf.com/content_cvpr_2017/papers/Papandreou_Towards_Accurate_Multi-Person_CVPR_2017_paper.pdf) 提出了一種**多人姿勢估計方法**，該方法採用 [Faster R-CNN](https://arxiv.org/abs/1506.01497) 作為人物檢測器，使用 [ResNet-101](https://openaccess.thecvf.com/content_cvpr_2016/papers/He_Deep_Residual_Learning_CVPR_2016_paper.pdf) 作為姿勢檢測器，並另外提出了一種新的關鍵點NonMaximum-Suppression ( NMS）策略來**解決姿勢冗餘問題**。
        * [RMPE](https://openaccess.thecvf.com/content_ICCV_2017/papers/Fang_RMPE_Regional_Multi-Person_ICCV_2017_paper.pdf) 利用 [SSD-512](https://arxiv.org/pdf/1512.02325.pdf) 作為人體偵測器，使用堆疊沙漏作為單人姿勢偵測器，並進一步提出一種可以**從不準確的邊界框中提取高品質的單人邊界框**的**對稱空間變換網路**以促進人體姿勢估計。
        * [CrowdPose](https://openaccess.thecvf.com/content_CVPR_2019/papers/Li_CrowdPose_Efficient_Crowded_Scenes_Pose_Estimation_and_a_New_Benchmark_CVPR_2019_paper.pdf) 利用**聯合候選姿勢偵測器**來預測**具有多個峰值的熱圖**，並使用**圖網路**來執行**全域關節關聯**以解決**單人邊界框包含多人**的問題。
    * 一起處理 **Human Proposal** 和 **pose detection** 派：
        * [Mixture Dense Regression for Object Detection and Human Pose Estimation](https://openaccess.thecvf.com/content_CVPR_2020/papers/Varamesh_Mixture_Dense_Regression_for_Object_Detection_and_Human_Pose_Estimation_CVPR_2020_paper.pdf) 提出了一個以**密集迴歸**方式**同時推斷**人體邊界框和關鍵點位置的混合模型。
        * [Point-Set Anchors](https://arxiv.org/pdf/2007.02846.pdf) 引入了一種**模板偏移模型**，該模型首先為人體邊界框和姿勢**提供良好的初始化**，然後**回歸初始化和相應標籤之間的偏移**。
        * [MultiPoseNet](https://openaccess.thecvf.com/content_ECCV_2018/papers/Muhammed_Kocabas_MultiPoseNet_Fast_Multi-Person_ECCV_2018_paper.pdf) **分別檢測關鍵點和 Human Proposal**，然後採用由殘差多層感知器實現的**姿勢殘差網路**將偵測到的關鍵點**分配給不同的邊界框**。
        * [FCPose](https://openaccess.thecvf.com/content/CVPR2021/papers/Mao_FCPose_Fully_Convolutional_Multi-Person_Pose_Estimation_With_Dynamic_Instance-Aware_Convolutions_CVPR_2021_paper.pdf) 是一個結合了**動態實例感知卷積**並**消除邊界框裁切和關鍵點分組過程**的框架。

---

#### Video-Based Methods

使用 **Video-Based Method** 的優缺點如下：
* 優點：存在豐富的**時間**線索，如時間依賴性和幾何一致性。
* 缺點：影片有可能會因為攝影機移位、快速物體移動和散焦而造成 **frame 品質不良**。

根據時間資訊的利用方式，**Video-Based** 方法大致可分為：
* **Optical Flow(光流)**：
    基於**光流**的表示可以在像素層級對運動線索進行建模，這有**利於捕捉有用的時間資訊**，但是**在擷取人體運動資訊之類的有用特徵的同時也將背景的變化也一起蒐集起來了**，因此光流只能提取不純的特徵，並且**對雜訊相當敏感**：
    * [Flowing ConvNets for Human Pose Estimation in Videos](https://openaccess.thecvf.com/content_iccv_2015/papers/Pfister_Flowing_ConvNets_for_ICCV_2015_paper.pdf) **將卷積網路和光流結合到一個統一的框架中**框架**利用流場來對齊多個幀之間的特徵速度**，並利用對齊的特徵來改進各個幀中的姿態檢測。
    * [Thin-Slicing Networks](https://openaccess.thecvf.com/content_cvpr_2017/papers/Song_Thin-Slicing_Network_A_CVPR_2017_paper.pdf) 提出了一種**薄切片網絡**，它**計算每兩個幀之間的密集光流**，以**隨時間傳播關節位置的初始估計**，並**使用基於流的扭曲機制來對齊關節熱圖**，以進行後續的時空推理。
    * [Towards Accurate Human Pose Estimation in Videos of Crowded Scenes](https://arxiv.org/pdf/2010.10008.pdf) 專注於**擁擠場景中的人體姿態估計**，它結合了前向姿態傳播和後向姿態傳播來**改進當前幀的姿態**。
    * [PoseFlow](https://openaccess.thecvf.com/content_cvpr_2018/papers/Zhang_PoseFlow_A_Deep_CVPR_2018_paper.pdf) 能夠**揭示影片中的人體運動**，同時抑制一些雜訊，例如背景和運動模糊。
    
* **RNN(循環神經網路)**：
    **RNN** **可捕獲視訊幀之間的時間上下文**以改進姿勢估計，因此**可以有效地從單人圖像序列中估計人體姿勢**，但截至論文發表為止，**RNN** **尚未應用於多人影片**，作者**推測**可能 **RNN** 在提取每個人的時間上下文時會受到其他人的影響：
    * [Chained Predictions Using Convolutional Neural Networks](https://arxiv.org/pdf/1605.02346.pdf)提出了一種**Seq2Seq模型**，它採用 **Chained Convolutional Networks** 來處理輸入影像，並**結合歷史隱藏狀態和當前影像來預測當前關鍵點熱圖**。
    * [LSTM Pose Machines](https://openaccess.thecvf.com/content_cvpr_2018/papers/Luo_LSTM_Pose_Machines_CVPR_2018_paper.pdf)透過使用**卷積LSTM**擴展了卷積姿勢機(Heatmap-Based-Iterative Architecture 有提到)，它**能夠對空間和時間上下文進行建模**以進行姿勢預測。
* **Pose Tracking(姿態追蹤)**：
    **Pose Tracking method** 會為視訊幀中的每個人**建立一個軌跡**，以**過濾不相關資訊的干擾**，並且**在多人場景中表現出強烈的適應性**，但是這些模型需要計算特徵相似性或姿勢相似性來創建軌跡，**計算資源++**：
    * [3D Mask R-CNN](https://openaccess.thecvf.com/content_cvpr_2018/papers/Girdhar_Detect-and-Track_Efficient_Pose_CVPR_2018_paper.pdf) 為 [Mask R-CNN](https://openaccess.thecvf.com/content_ICCV_2017/papers/He_Mask_R-CNN_ICCV_2017_paper.pdf) 的擴展，先產生單人小片段，接著**利用小片段內的時間資訊**來產生更準確的預測。
    * [Temporal Keypoint Matching and Refinement Network for Pose Estimation and Tracking](https://link.springer.com/chapter/10.1007/978-3-030-58542-6_41) 提出了一種姿態估計框架，由根據**關鍵點相似度**給出可靠的單人姿勢序列的**時間關鍵點匹配模組**和藉由**聚合序列內的姿勢**以糾正原始姿勢的**時間關鍵點細化模組**組成。
    * [Combining detection and tracking for human pose estimation in videos](https://openaccess.thecvf.com/content_CVPR_2020/papers/Wang_Combining_Detection_and_Tracking_for_Human_Pose_Estimation_in_Videos_CVPR_2020_paper.pdf) 設計了**剪輯追蹤網路**和**視訊追蹤管道**來為每個人**建立軌跡**，並將 [HRNet](https://openaccess.thecvf.com/content_CVPR_2019/papers/Sun_Deep_High-Resolution_Representation_Learning_for_Human_Pose_Estimation_CVPR_2019_paper.pdf) 擴展到3D-HRNet以對所有軌跡執行**時間姿態估計**。
    * [Learning Dynamics via Graph Neural Networks for Human Pose Estimation and Tracking](https://openaccess.thecvf.com/content/CVPR2021/papers/Yang_Learning_Dynamics_via_Graph_Neural_Networks_for_Human_Pose_Estimation_CVPR_2021_paper.pdf) **採用圖神經網路從歷史姿勢序列中學習姿勢動態**，並將姿勢動態**合併到目前影格的姿勢偵測**。

* **Key Frame Optimization(關鍵影格優化)**：
    **Key Frame Optimization** 的特點在於模型會**選擇一些關鍵影格來改善目前影格的姿態估計**：
    * [Personalizing Human Video Pose Estimation](https://openaccess.thecvf.com/content_cvpr_2016/papers/Charles_Personalizing_Human_Video_CVPR_2016_paper.pdf) 提出了一種個人化視訊姿勢估計框架，它**利用一些具有高精度姿勢估計的關鍵影格來微調模型**。
    * [PoseWarper](https://arxiv.org/pdf/1906.04016.pdf) 是一種姿勢扭曲網絡，它**先將標記幀的姿勢扭曲到未標記的（當前）幀，然後聚合所有扭曲的姿勢**以預測當前幀的姿勢熱圖。
    * [K-FPN](https://arxiv.org/pdf/2007.15217.pdf) 提出了一個**關鍵幀提議網絡**來選擇有效關鍵幀，並提出了一個**可學習的字典來從所選關鍵幀重建整個姿勢序列**。
    * [DCPose](https://openaccess.thecvf.com/content/CVPR2021/papers/Liu_Deep_Dual_Consecutive_Network_for_Human_Pose_Estimation_CVPR_2021_paper.pdf) 為一個能夠充分**利用相鄰幀的時間信息的雙連續幀工作視訊姿勢估計框架**，包含以下三個模組化組件：(跟這篇 Survey 是同一批作者，灌水機率偏高)
        * 姿勢時間合併器會對關鍵點時空上下文進行編碼以**產生有效的搜尋範圍**。
        * 姿勢殘差融合模組則**計算雙向加權姿勢殘差**。
        * 姿勢校正網路用於**重新處理以上兩個模組的輸出**，以改善姿勢估計。

---

#### Model Compression-Based Methods
上述的方法雖然有效但是模型都偏大，為了可以在手機等輕量設備上實際應用，需要將模型壓縮以達到即時計算：
* [FastPose](https://arxiv.org/pdf/1908.05593.pdf) 是一個基於**教師-學生網絡**的快速**姿勢蒸餾模型**，教師網絡採用**8階段沙漏模型**，而學生網絡則採用**緊湊型對應模型（4階段沙漏）**。

* [LSTM Pose Machines](https://openaccess.thecvf.com/content_cvpr_2018/papers/Luo_LSTM_Pose_Machines_CVPR_2018_paper.pdf) 提出了一種輕量級的 LSTM 架構來執行視訊姿態估計。

* [Lite-HRNet](https://openaccess.thecvf.com/content/CVPR2021/papers/Yu_Lite-HRNet_A_Lightweight_High-Resolution_Network_CVPR_2021_paper.pdf) 提出了兩種減少HRNet參數的方案：
    * 簡單地應用 [Shuffle-Block](https://openaccess.thecvf.com/content_cvpr_2018/papers/Zhang_ShuffleNet_An_Extremely_CVPR_2018_paper.pdf) 來**取代**普通 [HRNet](https://openaccess.thecvf.com/content_CVPR_2019/papers/Sun_Deep_High-Resolution_Representation_Learning_for_Human_Pose_Estimation_CVPR_2019_paper.pdf) 中的基本區塊。
    * 設計一個**條件通道加權模組**，它可以**學習多種解析度的權重**，以取代昂貴的逐點 (1 × 1) 卷積。

---

### Bottom-Up Framework

#### Human Center Regression-Based Methods

**Human Center Regression-Based Method** 利用人體中心點來表示人物實例：
* [Single-Stage Multi-Person Pose Machines](https://openaccess.thecvf.com/content_ICCV_2019/papers/Nie_Single-Stage_Multi-Person_Pose_Machines_ICCV_2019_paper.pdf) **引入根關節（中心偏移點）來表示人物實例**，並且**將身體關節位置編碼到它們的位移中**，**統一了人類實例和身體關節位置表示**。
* [DisEntangled Keypoint Regression](https://openaccess.thecvf.com/content/CVPR2021/papers/Geng_Bottom-Up_Human_Pose_Estimation_via_Disentangled_Keypoint_Regression_CVPR_2021_paper.pdf) 預測人物實例的**人體中心圖**，並**密集地估計中心圖中每個像素** $q$ 可能的姿勢。

**Associate Embedding-Based Method** **為每個關鍵點分配一個關聯嵌入**以區分不同人的實例表示：
* [Associative Embedding: End-to-End Learning for Joint Detection and Grouping](https://arxiv.org/pdf/1611.05424.pdf) 開創了嵌入表示，其中**每個預測的關鍵點都有一個額外的嵌入向量**，用作**識別其人類實例分配的標籤**。
* [Multi-person Articulated Tracking with Spatial and Temporal Embeddings](https://openaccess.thecvf.com/content_CVPR_2019/papers/Jin_Multi-Person_Articulated_Tracking_With_Spatial_and_Temporal_Embeddings_CVPR_2019_paper.pdf) 提出了 SpatialNet 來**偵測身體部位熱圖**並預測**輸入影像透過關鍵點嵌入來參數化的部位層級資料關聯性**。
* [HigherHRNet](https://openaccess.thecvf.com/content_CVPR_2020/papers/Cheng_HigherHRNet_Scale-Aware_Representation_Learning_for_Bottom-Up_Human_Pose_Estimation_CVPR_2020_paper.pdf) 遵循[Associative Embedding: End-to-End Learning for Joint Detection and Grouping](https://arxiv.org/pdf/1611.05424.pdf) 中的關鍵點分組，並進一步提出了一個**更高解析度網路來學習高解析度特徵金字塔**，改進了**較小人物的姿態估計**。
* [Rethinking the Heatmap Regression for Bottom-up Human Pose Estimation](https://openaccess.thecvf.com/content/CVPR2021/papers/Luo_Rethinking_the_Heatmap_Regression_for_Bottom-Up_Human_Pose_Estimation_CVPR_2021_paper.pdf) 針對人類**尺度差異大**和**標籤模糊**的問題提出了**尺度自適應熱圖回歸模型**，能夠**自適應調整每個關鍵點的真實高斯核的標準差**，並實現**對不同人體尺度和標籤歧義的高容忍度**。
 
**Part Field-Based Method** 先偵測關鍵點及其之間的連接，然後根據關鍵點連接進行關鍵點分組：
* 代表性工作 [Realtime Multi-Person 2D Pose Estimation using Part Affinity Fields](https://openaccess.thecvf.com/content_cvpr_2017/papers/Cao_Realtime_Multi-Person_2D_CVPR_2017_paper.pdf) 提出了**兩分支多層次CNN架構**，其中一支預測**置信圖**以表示關鍵點的位置，另一支預測**部分親和力場**以指示關鍵點之間的連接強度，然後**根據關節之間的連接強度**，用**貪婪演算法**來組裝同一個人的不同關節。
* [PifPaf](https://openaccess.thecvf.com/content_CVPR_2019/papers/Kreiss_PifPaf_Composite_Fields_for_Human_Pose_Estimation_CVPR_2019_paper.pdf) 利用**部位強度場**來定位身體部位，並利用**部位關聯場**將身體部位彼此關聯。
* [Simple Pose](https://arxiv.org/pdf/1911.10529.pdf) 提出了一種基於**部位親和力場**的身體部位熱圖的新穎**關鍵點關聯表示**，以實現**有效的關鍵點分組**。
* [Multi-Person Pose Estimation via Multi-Layer Fractal Network and Joints Kinship Pattern](https://ieeexplore.ieee.org/abstract/document/8444436) 提出了一種**多層分形網絡**，它**對關鍵點位置熱圖進行回歸並推斷相鄰關節之間的親緣關係**以確定最佳匹配的關節對。
* [Differentiable Hierarchical Graph Grouping](https://arxiv.org/pdf/2007.11864.pdf) **將關鍵點分組轉換為圖分組問題**，並且**可以與關鍵點檢測網絡進行端到端訓練**。

---

## Network Training Refinement

### Data Augmentation Techniques
常見的資料增強技術包括**隨機旋轉**、**隨機縮放**、**隨機截斷**、**水平翻轉**、**隨機資訊丟棄**和**光照變化**。
* [Adversarial Data Augmentation](https://openaccess.thecvf.com/content_cvpr_2018/papers/Peng_Jointly_Optimize_Data_CVPR_2018_paper.pdf) 可以**產生困難的姿勢樣本**來與姿勢估計器競爭。
* [Does Learning Specific Features for Related Parts Help Human Pose Estimation?](https://openaccess.thecvf.com/content_CVPR_2019/papers/Tang_Does_Learning_Specific_Features_for_Related_Parts_Help_Human_Pose_CVPR_2019_paper.pdf) 指出**最先進的人體姿勢估計方法具有類似的誤差分佈**。
* [PoseFix](https://openaccess.thecvf.com/content_CVPR_2019/papers/Moon_PoseFix_Model-Agnostic_General_Human_Pose_Refinement_Network_CVPR_2019_paper.pdf) 根據 [Does Learning Specific Features for Related Parts Help Human Pose Estimation?](https://openaccess.thecvf.com/content_CVPR_2019/papers/Tang_Does_Learning_Specific_Features_for_Related_Parts_Help_Human_Pose_CVPR_2019_paper.pdf) 中的誤差統計**生成合成姿勢**，並使用合成姿勢來訓練人體姿勢估計網絡。
* [Adversarial Semantic Data Augmentation](https://islab.ulsan.ac.kr/files/announcement/804/2008.00697.pdf) 使用 [GAN](https://arxiv.org/pdf/1406.2661.pdf) 的**對抗語義資料增強**，它**透過貼上具有不同語義粒度的分段身體部位**來增強原始影像。
* [When Human Pose Estimation Meets Robustness: Adversarial Algorithms and Benchmarks](https://openaccess.thecvf.com/content/CVPR2021/papers/Wang_When_Human_Pose_Estimation_Meets_Robustness_Adversarial_Algorithms_and_Benchmarks_CVPR_2021_paper.pdf) 引入了AdvMix演算法，其中生成器網路**透過混合各種損壞的圖像**來混淆姿勢估計器，並且**知識蒸餾網路將乾淨的姿勢結構知識傳輸到目標姿勢偵測器**。

---

### Multi-Task Training Strategies(有料)
多任務學習旨在**透過在相關視覺任務之間共享表示來捕獲資訊特徵**。

**人體解析**是與人體姿勢估計密切相關的任務，其目標是將人體分割成頭部、手臂和腿等語意部分。

$\Diamond$ **人體解析**資訊**可提升**人體姿勢估計的效能。

- [ ] [Joint Multi-Person Pose Estimation and Semantic Part Segmentation](https://openaccess.thecvf.com/content_cvpr_2017/papers/Xia_Joint_Multi-Person_Pose_CVPR_2017_paper.pdf) 共同解決了人體解析和姿態估計兩個任務，並**利用部分級片段來指導關鍵點定位**。
* [Human Pose Estimation with Parsing Induced Learner](https://openaccess.thecvf.com/content_cvpr_2018/papers/Nie_Human_Pose_Estimation_CVPR_2018_paper.pdf) 提出了一個**解析編碼器**和一個**姿勢模型參數適配器**，它們一起學習預測姿勢模型的參數，以提取用於人體姿勢估計的**互補特徵**。
### Loss Function Constraints
* 最常見的損失函數是L2距離。
L2距離公式：$$L = \frac{1}{N}\sum_{j=1}^N v_j \times \lVert G(j) - P(j)\lVert^2$$
$G(j), P(j), v(j), N$ 分別代表 Ground Truth 熱圖, Prediction 熱圖, 關節 $j$ 的可見性, 關節的數量。
* [Multi-Scale Structure-Aware Network for Human Pose Estimation](https://arxiv.org/pdf/1803.09894.pdf) 提出了一種多尺度的人體結構感知損失，它捕捉人體的結構資訊。
第 $i$ 個特徵尺度的結構感知損失可以表示如下：$$ L^i = \frac{1}{N}\sum_{j=1}^N \lVert P_j^i - G_j^i\lVert_2 \ + \ \alpha \sum_{i=1}^N \lVert P_{S_j}^i - G_{S_j}^i\lVert_2$$
$P_j, G_j, P_{S_j}, G_{S_j}$ 分別代表關節 $j$ 的Prediction 熱圖, Ground Truth 熱圖, 關節 $j$ 和他的鄰居的熱圖組。
* [Cascaded Pyramid Network for Multi-Person Pose Estimation](https://openaccess.thecvf.com/content_cvpr_2018/papers/Chen_Cascaded_Pyramid_Network_CVPR_2018_paper.pdf) 提出了一種**線上困難關鍵點探勘**，它首先計算所有關鍵點的常規 L2 損失，然後**對前 M 個困難的關鍵點加強懲罰**。
* [Combined Distillation Pose](https://dl.acm.org/doi/abs/10.1145/3394171.3416278) 提出了適用於 HR Net 的**組合蒸餾損失**，其中包括**強制網路在早期階段學習人體結構以對抗姿勢遮擋**的結構損失（STLoss）、**緩解了類似關節分類錯誤**的成對抑制損失（PairLoss）和**指導最終熱圖分佈學習**的機率分佈損失（PDLoss）。
### Domain Adaption Methods
在實際應用中，預先訓練的姿態估計模型**通常需要適應沒有標籤或稀疏標籤的新領域**。
下列領域適應方法**利用有標籤的來源領域來學習一個模型**，使其在無標籤或標籤稀疏的目標領域上表現良好：
* [Alleviating Human-level Shift : A Robust Domain Adaptation Method for Multi-person Pose Estimation](https://arxiv.org/pdf/2008.05717.pdf) 提出了一種**既實現了人體級拓撲結構對齊，又實現了不同資料集中的細粒度特徵對齊**的 2D HPE的領域自適應方法。
* [Multi-Domain Pose Network](https://openaccess.thecvf.com/content_ECCVW_2018/papers/11130/Guo_Multi-Domain_Pose_Network_for_Multi-Person_Pose_Estimation_and_Tracking_ECCVW_2018_paper.pdf) 能夠**同時在多個資料集上訓練模型**，從而以多域學習方式獲得更好的姿態表示。
* [From Synthetic to Real: Unsupervised Domain Adaptation for Animal Pose Estimation](https://openaccess.thecvf.com/content/CVPR2021/papers/Li_From_Synthetic_to_Real_Unsupervised_Domain_Adaptation_for_Animal_Pose_CVPR_2021_paper.pdf) 提出了一種能夠軟化標籤雜訊的**在線從粗到精的偽標籤更新策略**，以**減少合成數據與真實數據之間的差距**，這在動物姿態估計方面表現出了強大的泛化能力。

---

## Post Processing Approaches
**Post Processing Approaches** 不會立即預測最終關鍵點位置，而是先估計初始姿勢，然後透過一些**後處理操作**進行最佳化。

作者將這些方法分為兩大類：
* **Quantization Error**
* **Pose Resampling**

### Quantization Error
heatmap based 的模型需要從估計的關鍵點熱圖解碼關節的 2D 座標 (x, y)，且通常會將預測熱圖中**最大活化值**的位置作為關鍵點座標，但是預測的高斯熱圖並**不總是符合標準高斯分佈**，並且可能**包含多個峰值**，這**降低了座標計算的準確性**。
- [ ] [Distribution-Aware Coordinate Representation for Human Pose Estimation](https://openaccess.thecvf.com/content_CVPR_2020/papers/Zhang_Distribution-Aware_Coordinate_Representation_for_Human_Pose_Estimation_CVPR_2020_paper.pdf) 提出了一種**分佈感知架構**，首先執行**熱圖分佈調變**來調整預測熱圖的形狀，然後採用**新的座標解碼方法**來準確地獲得最終的關鍵點位置。
* [The Devil is in the Details: Delving into Unbiased Data Processing for Human Pose Estimation](https://openaccess.thecvf.com/content_CVPR_2020/papers/Huang_The_Devil_Is_in_the_Details_Delving_Into_Unbiased_Data_CVPR_2020_paper.pdf) **定量分析了2D HPE上常見的偏移數據處理**，並進一步**基於單位長度而不是像素**來處理數據，在推理中**進行翻轉時獲得對齊的姿態結果**，並引入了一種理論上可以將熱圖和座標之間的關鍵點位置**完美轉換的編碼解碼方法**。

解碼過程中，最大運算的**不可微性質**也會產生**量化誤差**，因此以下研究嘗試設計**可微分演算法**：
* [Human Pose Regression by Combining Indirect Part Detection and Contextual Information](https://arxiv.org/pdf/1710.02322.pdf) 提出了一種**完全可微且端對端可訓練的迴歸方法**，該方法利用新穎的 Soft argmax 函數**將特徵圖直接轉換為關鍵點座標**。
* [Integral human pose regression](https://openaccess.thecvf.com/content_ECCV_2018/papers/Xiao_Sun_Integral_Human_Pose_ECCV_2018_paper.pdf) 提出了一種**積分方法**來解決熱圖到座標的不可微分問題。

### Pose Resampling
很多姿態估計器會直接將模型輸出作為最終估計，以下方法將這些估計值透過與模型無關的 **Pose Resampling** 技術進一步改進。

* 針對靜態影像設計的 **Pose Resampling**：
    * [PoseFix]([PoseFix](https://openaccess.thecvf.com/content_CVPR_2019/papers/Moon_PoseFix_Model-Agnostic_General_Human_Pose_Refinement_Network_CVPR_2019_paper.pdf)) **根據輸入圖像和輸入姿勢的元組估計精細姿勢**，其中輸入姿勢是從現有方法的估計中導出的。
    * [Peeking into occluded joints: A novel framework for crowd pose estimation](https://arxiv.org/pdf/2003.10506.pdf) 提出先透過現有的姿勢估計器根據視覺資訊定位可見關節，**透過結合影像上下文**和**姿勢結構線索**的**影像引導漸進式 GCN 模組**估計不可見關節。
    * [Graph-PCNN](https://arxiv.org/pdf/2007.10599.pdf) 是一個兩階段且與模型無關的框架，**先利用現有的姿態估計器進行粗略關鍵點定位**，再用他們提出的**圖姿態細化模組**以產生更準確定位結果。

* 針對動態影片設計的 **Pose Resampling**：
    以下方法透過**執行姿勢聚合來整合當前幀的多個估計姿勢**以改善估計結果：
    * [Combining detection and tracking for human pose estimation in videos](https://openaccess.thecvf.com/content_CVPR_2020/papers/Wang_Combining_Detection_and_Tracking_for_Human_Pose_Estimation_in_Videos_CVPR_2020_paper.pdf) 引入了**Dijkstra演算法**來解決最佳關鍵點位置問題，該演算法首先採用**均值平移演算法**將所有姿態假設**分組到各個族群**中，然後**選擇與關鍵點距離最近的關鍵點聚類中心**作為最優結果。
    * [Temporal Keypoint Matching and Refinement Network for Pose Estimation and Tracking](https://link.springer.com/chapter/10.1007/978-3-030-58542-6_41) 利用**相鄰幀和當前幀之間的姿勢相似性**來進行**有偏差的聚合特徵**，然後採用卷積神經網路從聚合特徵中解碼當前熱圖。

---

## Evaluation Metrics

### Percentage of Correctly Estimated Body Parts (PCP) 
PCP 指標反映了局部身體部位的準確性。

如果估計的部位的端點位於閾值內，則認為該部位是正確的，該閾值可以是其註釋位置處的地面實況片段長度的一小部分[31]。

除了所有身體部位的平均 PCP 之外，通常還會報告軀幹、大腿和頭部等單獨的身體肢體 PCP。

與 PCP 指標類似，PCPm 在整個測試中利用平均真實片段長度的 50% 作為匹配閾值。

### Percentage of Correct Keypoints (PCK)
PCK 用於測量局部身體關鍵點的準確性，如果候選關節位於匹配閾值內，則認為它是正確的

關鍵點位置與地面實況相符的閾值可以定義為人體邊界框大小的一部分（表示為 PCK）和頭部片段長度的 50%（表示為 PCKh）。

### Average Precision (AP)
AP 度量是基於物件關鍵點相似度（OKS）[93] 來定義的，它評估預測關鍵點和真實關鍵點之間的相似性。

不同 OKS 閾值 N 下的平均精度得分表示為 AP@N。

對於基於影像的人體姿勢估計，平均精確度 (mAP) 是所有 OKS 閾值下 AP 分數的平均值。

在基於影片的人體姿態估計中，mAP 每個關節的平均 AP 分數。