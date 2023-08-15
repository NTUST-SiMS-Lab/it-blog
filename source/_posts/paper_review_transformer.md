---
title: [Paper Review] Transformer: Attention Is All You Need
catalog: true
date: 2023-08-15
author: Frances Kao
categories:
- paper-review
- transformer
---

# 【論文研讀】Transformer: Attention Is All You 

論文連結: [Attention Is All You Need](https://arxiv.org/abs/1706.03762)

# Transformer
先前的序列轉換模型是基於複雜的RNN與CNN，其中包含編碼器與解碼器的組合，而作者發現**通過注意力機制連接編碼器與解碼器的模型表現較佳**。因此，此研究提出一簡單的網路架構Transformer，僅**僅基於注意力機制**而不使用RNN或CNN架構，使模型單純且訓練時間縮短、泛化能力佳。主要用於翻譯或句法分析等語言相關的任務上，近年來也發展多種應用。其主要優點如下：

- 架構單純：由於僅使用注意力機制，其架構相對較為簡單且易於理解。
- 透過自注意力機制，對輸入序列的不同位置進行加權處理，可關注到輸入序列中的重要資訊。
- 透過自注意力機制，可捕捉到長距離依賴關係（Long-range dependence, LRD），處理輸入序列中的上下文信息和語義關係。
- 透過多頭注意力機制進行並行計算，以提高計算效率與泛化能力，可處理更長的輸入序列或更大量的詞彙。
- 主要用於處理語言相關的任務，例如翻譯(Translation)、句法分析(Syntactic Parsing)等。由於其強大的表現和泛化能力，近年來也在其他領域得到廣泛應用，例如圖像生成、語音識別等，延伸技術也有應用於圖像分類的Vision Transformer。

![](https://hackmd.io/_uploads/HJyu0owjh.png)

---

## Encoder & Decoder
在Transformer中，encoder和decoder由[自注意力機制](#Self-Attention)與[逐點全連接層](#Position-wise-Feed-Forward-Networks)堆疊而成。encoder負責將輸入序列作為特徵表示symbol representations($x_1, ..., x_n$)與連續表示continuous representations($z_1, ..., z_n$)進行匹配。而decoder則一次性地生成一輸出序列($y_z, ..., y_n$)，每次模型皆會進行回歸，利用前次所生成的表示（symbols）作為額外輸入。
> 逐點(point-wise)指對輸入的每個數據點皆進行相同計算。例如計算兩向量之相似度或將每一詞嵌入向量相加以獲得一句子的表示（symbols）。

### Encoder
- 輸入: symbol representations($x_1, ..., x_n$)
- 輸出: $x_1, ..., x_n$與$z_1, ..., z_n$匹配的序列結果
- 包含$N=6$層相同的layer
- layer中包含兩個子層，即多頭注意力機制與位置逐元前饋神經網路(Position-Wise Feed-Forward Network, FFN)，[FFN](#Position-wise-Feed-Forward-Networks)用來增強模型之非線性表達能力。
- 通過`Add`(殘差連接)與`layer normalization`(層標準化)。殘差連接有助於模型關注差異特徵。層標準化則穩定隱藏層，例如避免梯度消失或爆炸。
- 所有子層的輸出維度皆為512，以簡化模型。

### Decoder
- 輸入: 目標序列表示（即ground truth）; 其中比encoder多了一子層的多頭注意力，將encoder之輸出納入該層之輸入。
- 輸出: 預測的目標序列表示$y_z, ..., y_n$
- 包含$N=6$層相同的layer
- 除了與encoder相同的兩個子層外，另加上一個子層對encoder之輸出進行多頭注意力，以捕捉上下文訊息(context)。
- `Masked Multi-Head Attention`用以避免序列之不同位置共享位置資訊，即$position_ｉ$僅會利用$position_i$以前(含)的資訊。透過防止當前位置的訊息向後流動，以保持其自回歸的能力，確保生成目標序列的正確性。

---

## Self-Attention
自注意力機制會對序列中的不同位置進行關注，計算該位置的表示(representation)。
- 傳統注意力機制通常為**一整個序列對另一個序列**進行關注。
- 自注意力則是將**單個序列中的不同位置相互關聯**，以得到更為全面的關聯資訊。
![](https://hackmd.io/_uploads/rJ9tkfdo2.png)
### Scaled Dot-Product Attention
Dot-Product (multiplicative) Attention的延伸，再加上了縮放因子(scaling factor) $\dfrac{1}{\sqrt{d_k}}$。$d_k$為query和key的維度時，點積的值會極大，因此利用縮放因子以避免softmax的輸入過大，導致梯度變得極小，而造成模型難以學習或輸出數值不穩定。該縮放因子的作用也能提升模型效率。
$Attention(Q, K, V)=softmax(\dfrac{QK^T}{\sqrt{d_k}})V$
> 公式的實際運算可以看李宏毅老師的影片介紹會較詳細

### Multi-Head Attention
使用單個注意力機制時，模型僅能關注單一子空間的表示，而無法充分捕捉不同子空間之間的交互資訊。而多頭注意力機制使每一注意力頭擁有自己的權重，使模型以不同角度捕捉特徵資訊，進而提高模型表現與泛化能力。多頭注意力機制運作如下:
1. 將Query、Key和Value分別進行線性變換，得到$h$個Query向量、Key向量和Value向量，其中$h$是注意力頭的數量。
2. 對每個注意力頭$Head_i$，計算Query向量$Q_i$和Key向量$K_i$的點積(dot product)，並將該點積除以縮放因子$\sqrt{d_k}$，其中$d_k$為Query和Key向量的維度。
3. 將縮放後的點積作為softmax的輸入，以獲得值的**權重**。
4. 將權重與Value向量$V_i$相乘並加權，得到每一注意力頭的輸出向量**注意力分數**。
5. 所有的輸出向量拼接。
6. 將上述拼接的向量透過權重$W^O$進行線性變換映射至另一向量空間中得到最終輸出$Z$。在此輸出矩陣$Z$和輸入矩陣$X$的維度相同，以便後續的全連接層處理。
    $MultiHead(Q, K, V) = Concat(head_1, ..., head_h)W^O$
    $head_i = Attention(QW^Q_i, KW^K_i, VW^V_i$)
> Query向量$Q_i$和Key向量$K_i$的點積意即兩者是否相似、相關；經過softmax則是兩者的cosine相似度，即視為「相關性」。

> Query、Key和Value是怎麼來的？
> 我們的輸入序列為一矩陣，這個輸入序列各乘上三種不同的權重矩陣$W^Q$、$W^K$、$W^V$，就得到$Q$、$K$和$V$這三個向量了。這些權重矩陣是經過線性轉換訓練來的。而這些權重會有$i$組，如本篇論文所述有8 layers的話就是$i=8$。

本論文的注意力機制有以下特色：
- encoder-decoder層中，Query來自於前一層decoder，而Key-Value則為encoder的輸出。因此，decoder所有位置皆可關注到輸入序列(即encoder)的所有位置的資訊。
- encoder自注意力層中，Query、Key、Value皆來自於前一層encoder的輸出。因此，encoder所有位置皆可關注到前層encoder所有位置的資訊，也就是可以同時關注到不同位置間的依賴關係。
- decoder的Masked多頭自注意力使decoder所有位置皆可關注到該位置以前(含)所有位置的資訊。

---

## Position-wise Feed-Forward Networks
FFN為由兩層全連接層組成，它會對每個位置的隱藏層獨立進行非線性轉換。第一層線性轉換，其隱藏層維度為2048，並且通過激活函數ReLU以捕捉序列中的非線性關係與局部特徵；而第二層則不使用激活函數，直接將維度映射回原本的維度，因此FFN的輸入與輸出維度相同。

$FFN(x) = max(0, xW_1 + b_1)W_2 + b_2$

---

## Input

### Embedding(嵌入層)
嵌入層將輸入和輸出序列中的token轉換為向量表示，它使用學習到的嵌入矩陣將每個token映射到一個$d_{model}$維的向量空間中。這個向量空間的維度通常是512(此為hyper-parameter)。其將離散的token轉換為連續的向量表示，使模型能夠更好處理輸入和輸出序列中的語義信息和上下文關係。
> 白話就是，假設我們的輸入是個句子，我們將每個單詞都向量化(Word Embedding)作為Transformer的輸入，向量化的方法有很多，如word2vec就是一種。

---

### Position Encoding(位置編碼)

位置編碼與嵌入層的維度相同，因此兩者可相加。

$PE_{(pos, 2i)} = sin(pos/10000^{2i}/d_{model})$
$PE_{(pos, 2i+1)} = cos(pos/10000^{2i}/d_{model})$

> 作者實驗過使用以上公式和使用訓練位置嵌入層以獲得位置編碼，但得到的結果相近，因此採用了泛化性較高的正弦公式。如此，要是遇到比訓練資料中更長的序列資料時，會較好進行處理。

---

## 實驗設定
* dataset: 
    * WMT 2014 English-German dataset
    * WMT 2014 English-French dataset
* hardware: 8 NVIDIA P100 GPUs
* Training scheule: 100,000 steps(12 hours)
* optimizer: Adam
* regularization
    * residual dropout: 1)每一子層輸入前的Norm之前，以及2)嵌入層和位置編碼加總後
    * label smoothing
        > 標籤平滑：將訓練數據中的one-hot標籤向量進行平滑化，即將標籤向量中的1分配到正確的標籤上，將剩餘的概率分配給其他標籤。這樣做的目的是使得模型在訓練過程中不會過於自信地預測某個標籤，而是對其他標籤也有一定的預測概率，從而減少模型對訓練數據中噪聲和不確定性的過擬合。

備註：實驗結果主要是翻譯任務，這邊不再深入探討。

---

## Reference
[Attention Is All You Need](https://arxiv.org/abs/1706.03762)
[Transformer模型详解（图解最完整版）](https://zhuanlan.zhihu.com/p/338817680)
[Transformer(上)](https://www.youtube.com/watch?v=ugWDIIOHtPA&list=PLJV_el3uVTsOK_ZK5L0Iv_EQoL1JefRL4&index=61)
[Transformer(下)](https://www.youtube.com/watch?v=N6aRv06iv2g&list=PLJV_el3uVTsMhtt7_Y6sgTHGHp1Vb2P2J&index=13)
[Self-attention](https://www.youtube.com/watch?v=yHoAq1IT_og&list=PLJV_el3uVTsPM2mM-OQzJXziCGJa8nJL8&index=6)
https://zhuanlan.zhihu.com/p/148737297
https://blog.csdn.net/qq_43210957/article/details/121843999
https://ithelp.ithome.com.tw/m/articles/10270016

---