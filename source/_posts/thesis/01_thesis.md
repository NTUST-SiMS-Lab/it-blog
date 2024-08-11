---
title: 【畢業論文】學習寫論文的小工具 - 我好想畢業
catalog: true
date: 2024-03-06
author: Hsiangj-Jen Li
categories:
- research paper
- thesis
---
    

> 祝各位在寫論文的路上可以少走一些歪路。
> 以下內容如有錯誤歡迎直接在 github 上指正，歡迎共編，感謝。
> [![](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/NTUST-SiMS-Lab/it-blog/tree/master/source/_posts/thesis/01_thesis.md)


# 🚀 尋找主題 
可以從 Paper with Code 的 [**SOTA**](https://paperswithcode.com/sota) 以及 [**Methods**](https://paperswithcode.com/methods) 去找一些方向。

# 🚀 怎麼選 paper 以及閱讀順序
1. 先從 review paper 開始看，慢慢縮小目標，再去尋找目標的 SOTA
1. 可以找 paper 的網站
1. 確認 paper 的 publisher 值得信任

## @ Scope

### **💡 什麼叫做 review paper？**

> 其主要目的是**綜述**和**評論**特定領域的文獻資料、研究進展和重要觀點。與原創研究論文不同，review paper的主要重點在於**彙總過去的研究**，提供讀者一個**全面且系統化的概述**，以幫助他們了解該領域的最新發展和趨勢。

***它對你的研究能有什麼樣的幫助*？**
1. 瞭解特定領域的研究趨勢和問題
   - 通常綜合了大量的文獻資料，對特定領域的研究趨勢和問題進行了全面的概述
   - 助於瞭解該領域目前的研究重點、最新的發展和未來的趨勢
1. 掌握重要觀點和理論基礎
   - 提供對特定領域的重要觀點和理論基礎
   - 理解該領域的核心概念和主要論點
1. 提供開源資料集

### **💡 SOTA (State-of-the-Art)**

> 指在該研究任務中，目前表現最好的模型

***它對你的研究能有什麼樣的幫助*？**
1. 瞭解目前的研究成果
1. 確定研究空白
   - 研究領域中常常存在一些未被解決或未被完全理解的問題
   - 了解到現有方法的解決方案以及其侷限性，從而發現新的研究機會
1. 選擇合適的方法
   - SOTA 提供了一個框架，用於評估不同方法或技術的有效性和效能
1. 加強論文可信度
   - 證明你的方法在特定領域中的優越性

## @ Paper（找 paper 的好工具）
| Website                                                    | Description |
|:---------------------------------------------------------- | ----------- |
| [Free - Google Scholar](https://scholar.google.com/)       | 簡單好用 |
| [Free - Paper with code](https://paperswithcode.com/)      | 裡面會提供開源的 dataset, benchmark, sota model, code，可以省去找資源的時間 |
| [Free - Read This Paper](https://readthispaper.com/tw/)    | 比起 Google Scholar 是按照 cite 或是發表的時間進行排序，Read this Paper 會從參考文獻中安排閱讀順序，慢慢補充所需要的先備知識 |
| [Free - ResearchRabbit](https://www.researchrabbit.ai/)    | ![image](https://hackmd.io/_uploads/HJNXHFH6a.png) <br>---<br> 使用網路圖的方式呈現這篇 paper 的 citetation network，提供 similar paper|
| [Free - Inciteful](https://inciteful.xyz/)                 | 使用網路圖的方式呈現這篇 paper 的 citetation network，同時提供它的 similar, most important and review papers，而且也會列出這跟這篇 paper 相關的 top 100 authors，以及哪些機構有在發相關的 paper 和這個主題有關的 Journal |
| [Paid - Connected Papers](https://www.connectedpapers.com) | 使用網路圖的方式呈現這篇 paper 的 citetation network，同時提供它的 prior works 跟 derivative works |

## @ Quality（確認 paper 的品質）
[Journal Citation Reports™](https://jcr.clarivate.com/jcr/home)
用來評斷該 paper 是否為[掠奪性期刊](https://libraryfile.lib.ntust.edu.tw/web/Investigative/Investigative.html)，可以看它 [**JIF QUARTILE**](http://www.chimei.org.tw/main/cmh_department/54110/news/JCR202211新平台使用說明.pdf) 的數值，Q1 代表是這個領域的 Tier 1 期刊；**Impact Factor** 也是其中一個指標，越高越好，在閱讀文獻的時候可以參考這些數值來排文獻的閱讀先後順序。
![](https://hackmd.io/_uploads/BJbHT0fch.png)

# 📄 開始寫 paper 囉 ～～

## 論文結構

> 括弧後面為論文撰寫順序
- Abstract（6）
1. Introduction（5）
1. Literature review / Related works（1）
1. Methodology（2）
1. Result（3）
1. Conclustion（4）

## 貼心提醒
2. Endnote可以最後一次用就好，因為和老師報告進度的中間可能會加上或砍掉不少，但記得自己先整理好資料
3. 每個段落講一件事情，可以延伸，但不要混雜很多重點在裡面
4. 第一次找老師報論文進度的時候，可以做幾張ppt，其中包含論文的整個架構圖
5. 開始寫論文時直接跟學長姐要論文的模板來進行修改，會省一點時間
6. 文獻探討很花時間，甚至到研究都做完了還會動，建議在找文獻前先想好大概論文會有哪幾個小節，每個小節要寫些什麼

## LaTeX

LaTeX是一種專業的排版系統，雖然 word 已經是非常方便的寫論文工具，但還是有一些需要經常撰寫數學公式的系所熱愛使用 LaTeX。但是 LaTeX 使用門檻相對於 word 高上不少，對於初學者來說學習成本相當的高，尤其對於以中文為主要撰寫語言的人來說，LaTeX 所需要的設定相當的繁雜。

目前最主流的 LaTeX 線上編輯器叫做 Overleaf。你可以直接在線上的方式編輯 LaTeX。不需要再額外擔心環境問題。

- [線上編輯器 - Overleaf](https://www.overleaf.com/)
- [Writefull for overleaf](https://chromewebstore.google.com/detail/writefull-for-overleaf/edhnemgfcihjcpfhkoiiejgedkbefnhg?hl=en)
- [數學公式 - KaTex Cheat Sheet](https://katex.org/docs/supported.html)
- [Excel to LaTeX](https://tableconvert.com/excel-to-latex)

### pseudo code
- Algorithm2e

> 🌟 注意：如果內文會使用到中文，compiler 請選擇 **XeLaTex**。