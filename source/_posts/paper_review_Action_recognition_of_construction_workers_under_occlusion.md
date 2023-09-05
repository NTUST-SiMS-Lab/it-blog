---
title: 【論文研讀】Action recognition of construction workers under occlusion 
catalog: true
date: 2023-09-05
author: David Chen
categories:
- paper review
- HAR
- Data imputation
- GAN
- Feature matrix
- occlusion
---
# Action recognition of construction workers under occlusion

* Journal reference: Journal of Building Engineering (VOL.45, January 2022)
* Authors: Ziqi Li, Dongsheng Li
* Github: None
* 論文連結: [Action recognition of construction workers under occlusion](https://www.sciencedirect.com/science/article/abs/pii/S2352710221012109)
---
## Introduction
當前大多數動作識別模型在出現遮擋問題時往往會失去其有效性。
為了解決這個問題，本文提出了一種基於骨架的動作識別方法。
本文的目標在於準確的辨識被遮擋的工人，若可以將此研究的抗遮擋成果移植到手部動作辨識模型上，可以提升模型在實際場域的準確率。
該方法主要包含三個部分。
- 矩陣編碼技術的骨架，它利用更高判別性的幾何特徵進行數據轉換。
- 基於GAN的數據插補模型，它使用LSTM作為生成器來更好地推算



的矩陣信息，並添加注意力機制使模型更加關注缺失的部分。
- Resnet分類模型，用於對推算矩陣進行分類。
![Flowchart of the proposed action recognition method](https://hackmd.io/_uploads/H1BRKAzAh.png)

---

## Methodology

### Process
1. 將建築工人的視頻準備為數據集。
2. 提取工人關節坐標並構建特徵矩陣。
3. 補全缺失數據。
4. 建立Resnet分類模型並用估算數據對其進行訓練。
5. 根據訓練好的模型預測建築工人的動作。

---
### Skeleton to matrix encoding technique
- 使用OpenPose來獲取2D骨架資訊
- 當身體被遮擋時，CNN會因特徵缺失而無法計算骨架坐標。
- 將缺失坐標替換為0。
- 提出一種可以將骨架數據轉化為特徵矩陣的編碼方法。

![](https://hackmd.io/_uploads/H1aKSH703.png)

---
該方法主要利用四種特徵：

- 骨架長度$γ_i^t$，表示相鄰兩個關節的長度；
- 骨架餘弦$λ_i^t$，表示骨架與水平方向夾角的餘弦；
- 頭部到各關節點向量的長度$ς_i^t$，表示頭部到各關節點的距離；
- 頭部到各關節向量的餘弦$κ_i^t$，表示頭部到各關節點的連線與水平方向夾角的餘弦。
![](https://hackmd.io/_uploads/ByrFKr7C3.png)

這四種特徵的變換公式如下：
骨架長度：
$$γ_i^t=‖(x_i^t, y_i^t) - (x_j^t, y_j^t)‖$$

- 骨架長度特徵向量為：
$$F_γ^t=[γ_1^t, γ_2^t,..., γ_n^t]$$

- 為了防止$γ_i^t=0$時，$λ_i^t=0$無法計算的情況，骨架角度特徵如下：
$$λ_i^t=\frac{|x_i^t-x_j^t|}{γ_i^t}$$

- 角度特徵向量為：
$$F_λ^t=[λ_1^t, λ_2^t,..., λ_n^t]$$

- 頭部節點到身體節點的長度特徵為：
$$ς_i^t=‖(x_i^t, y_i^t) - (x_0^t, y_0^t)‖$$

- 頭部節點到身體節點的長度特徵向量為：
$$F_ς^t=[ς_1^t, ς_2^t,..., ς_n^t]$$

- 為了防止$ς_i^t=0$時，$κ_i^t=0$無法計算的情況，頭部節點與身體節點的角度特徵如下：(未定義解釋 $e^\beta$ )
$$κ_i^t=\frac{x_i^t-x_0^t}{ς_i^t+e^\beta}$$

- 頭部節點與身體節點的角度特徵向量為：
$$F_κ^t=\begin{bmatrix}κ_1^t, κ_2^t,..., κ_n^t\end{bmatrix}$$

- 最終特徵矩陣為：
$$F=
\begin{bmatrix}
F^1 \\
F^2 \\
\vdots \\
F^t
\end{bmatrix}$$

- 以上特徵分別會生成四個特徵矩陣，分別是$F_λ、F_γ、F_ς、F_κ$，為了得到兩幀之間的骨骼信息等級，將四個特徵矩陣分別與Sobel算子相乘，得到特徵矩陣的梯度矩陣，下列為Sobel算子：
$$G_y=\begin{bmatrix}
1&2&1 \\
0&0&0 \\
-1&-2&-1 \\
\end{bmatrix}$$

- 最後將特徵矩陣與其之梯度矩陣結合起來生成一個可用於分類的特徵矩陣

$$\widehat{F}=\begin{bmatrix}
F_λF_γF_ςF_κG_λG_γG_ςG_κ
\end{bmatrix}$$

---
### GAN-based data imputation model
現有的缺失值處理方法：
- 跳過缺失值直接計算(Xgboost 和 LightGBM)
- 使用平均值、中位數和復數來代替缺失值(統計評估方法)
- 使用 K-NN，基於特徵相似性對缺失數據進行計算

---
由於施工人員**遮擋面積較大，有的會超過50%**，那些不處理缺失或簡單填充的方法無法完全恢復數據的原始特徵，因此作者提出此數據差補模型。

模型包含三部分：
* 生成器：用於觀察真實數據的每一個細節，然後根據觀察結果對缺失數據進行插補，插補後輸出插補矩陣。
    * 由LSTM網路組成
    * 添加注意力模組，模組包含：
        * 空間注意力部分
        * 時間注意力部分
* 鑑別器：用來區分真正觀察到的數據部分和插補的部分
    * imput：生成器輸出的插補矩陣與提示矩陣
* 提示矩陣：
    * 提供了原始數據缺失部分的一些信息，使鑑別器能夠更加關注該部分，並迫使生成器生成更接近真實數據的數據以進行插補。
    * 如下圖中 Hint Matrix 所示，0值的位置代表缺失值對應的位置，1值的位置代表真實值對應的位置

![](https://hackmd.io/_uploads/SkHxrE402.png)

透過輸入第i幀到第t-1幀的特徵來獲得第t幀的插補矩陣，作者通過最小化第t幀插補矩陣與缺失矩陣的MSE來訓練生成器

在時間注意力模型中，$\begin{bmatrix}q_1,..., q_m\end{bmatrix}$是一個m維隨機向量，m是數據維度，向量qm是輸入數據的權重，由訓練得到。

---
### Classification network
作者採用用單通道Resnet-50網絡進行訓練，訓練前將特徵矩陣標準化為0到255。

---
## Experiments
此研究進行了三組實驗：
1. 使用NTU RGB + D來測試所提出的方法在常見情況下的動作識別能力。
2. 重點研究不同動作識別方法在本文數據集上的表現，並以PB-GCN動作識別網絡作為基準。
3. 實驗關注不同遮擋區域對所提方法識別效果的影響。

作者的私有數據集是從大連的一個建築工地收集的。

該數據集總共包含 254 分鐘，每個剪輯有一到兩個工作人員，**每個剪輯僅包含一類動作**。

它包含8個不同的動作，相應的代碼如下表所示
![](https://hackmd.io/_uploads/Sk_UG8ECn.png)

每種動作分為兩種情況，遮擋情況和非遮擋情況。

下圖說明每個動作的遮擋的示例圖片。

![](https://hackmd.io/_uploads/rk5CM8VCn.png)

訓練過程使用NVIDIA RTX 2080Ti和AMD Ryzen 2700 × 3.7 GHz
所以有機會可以在普通家機上實現，是否能在邊緣設備運算尚須確認。

---
##  Experimental results and analysis

### Experimental results of NTU RGB + D

根據下表的內容，所提出的方法在NTU RGB + D數據集中達到了中等水平，並且在面對遮擋時達到了state-of-the-art。

![](https://hackmd.io/_uploads/HyzqEI403.png)

---
### Different methods of action recognition
為了證明該方法估算骨骼信息的能力，作者將所提出的方法與基於骨骼的動作識別方法PB-GCN進行了比較。

數據集分成遮擋情況和非遮擋情況。
每個部份又分成訓練集、驗證集和測試集，比例為 0.7 : 0.1 : 0.2

訓練時應確保每個樣本大於16幀，最終得到遮擋和無遮擋情況下的混淆矩陣。

本文提出的方法在作者的數據集上的可視化結果如下圖所示

![](https://hackmd.io/_uploads/B1T2IUNC2.png)

---

下圖為該方法和PB-GCN在**遮擋**和**未遮擋**狀態下的歸一化混淆矩陣。

![](https://hackmd.io/_uploads/ByLZP8NRh.png)

從上圖可以看出，在沒有遮擋的情況下，該方法的準確率略低於PB-GCN，但在存在部分遮擋時，該方法的準確率高於PB-GCN。

**簡而言之，在面對遮擋時，所提出的方法比一般方法更好。**

---
### Comparison of the recognition effects when facing different occlusion rates 
針對遮擋情況下的動作識別進行了一組實驗，原理是遮擋導致視頻中工人身體部位缺失，從而導致OpenPose丟失了一些關節坐標，實驗設置了四種遮擋率：11%、50%、72%和94%分別代表遮擋區域的四種大小，如下圖所示。

![](https://hackmd.io/_uploads/H1eVuUE0n.png)

每種情況的遮擋區域中的關節坐標都被刪除，使用所提出的基於GAN的模型來填補缺失的關節信息，最終識別動作。

---
如下圖所示，隨著遮擋面積的增加，所提出方法和PB-GCN模型的準確率逐漸下降，但是PB-GCN 比所提出方法以更高的速度下降。

![](https://hackmd.io/_uploads/ryzeFLNA3.png)

作者提出的方法在第二種和第三種情況下明顯優於PB-GCN。

---
## Contributions and limitations

### Contributions
* 提出了一種動作識別方法，包括三個步驟：
1. 特徵轉換
2. 特徵插補
3. 特徵分類

所提出的方法在存在遮擋的情況下能夠實現 86.62% 的動作識別準確率。

* 提出了一種基於GAN的特徵插補模型：使用 LSTM 作為生成器，而不是常規的全連接網絡，並加入時空注意力機制。
這使的模型對時間序列更加敏感，且能透過注意力機制更好地學習缺失矩陣的時空特徵。

###  Limitations 
根據實驗結果，該方法只有在38.5%~79.6%的遮擋率的情況下結果會優於其他模型，且目前尚不能實時化。

作者測試時使用了54幀影片，消耗時間為17.946s，離real-time還差的遠。

---
## Conclusion

作者提出的特徵轉換與數據插補模型可以在遮擋的情況下得到不錯的準確率，但是計算需求對於我們目前的專案(圓展)還是太大，若想使用抗遮擋相關技術，若基於此篇論文，則必須將數據插補模型中的GAN以其他較輕量化的模型取代。