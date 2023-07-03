---
title: 如何在 Hackmd 中 push 自己的文章至 Github
catalog: true
date: 2023-07-02
author: Hsiangj-Jen Li
categories:
- it-blog
---

# Hexo 
Hexo 是一個靜態網頁生成框架，關鍵字都給你了，自己去查什麼叫做靜態網頁吧。  

`Hexo`, `Hugo`, `jekyll` 這些都是目前比較主流的靜態網頁生成框架，它們的使用方式基本上都差不多，如果有興趣的話可以自己去研究看看它們的使用方式。

## Theme
本次所使用到 hexo 主題為 [V-Vincen/hexo-theme-livemylife](https://github.com/V-Vincen/hexo-theme-livemylife)

Hexo 的主題可以在 [Hexo-Themes](https://hexo.io/themes/) 這裡找到，各位如果有想建立自己的 blog 也可以在這裡找找看有沒有自己喜歡的模板。

## Build on Github Workflow
在 [NTUST-SiMS-Lab/it-blog](https://github.com/NTUST-SiMS-Lab/it-blog/blob/master/.github/workflows/auto-blog.yaml) 裡面找到 `.github/workflows/auto-blog.yaml` 這個檔案，裡面包含了觸發 workflow 的方式、node.js 的版本、安裝的 dependencies，最後打包到 github pages。

## Build by yourself
雖然可以在 Github 上直接建立靜態網站，但有時候會想要自己修改一些版面配置，這個時候在自己本地端建立一個開發環境會比較方便，你可以在 [NTUST-SiMS-Lab/it-blog](https://github.com/NTUST-SiMS-Lab/it-blog) 裡面有 `Dockerfile` `compose-dev.yaml` 這兩個檔案可以快速的使用 docker 建立好 hexo 的開發環境

當你建立好環境後，進入 docker 的 container 並在 terminal 打上

```shell
hexo server
```
如果你有成功看到 [localhost:4000](localhost:4000) 點進去，如果有成功渲染就代表成功。


# Hackmd
HackMD 是個跨平台的 [Markdown](https://www.markdownguide.org/cheat-sheet/) 即時協作筆記。

如果要將 hackmd 上的文章 push 到 GitHub 上，首先要確保你現在的 hackmd 帳號有連接到你的 GitHub 帳號。

另外，當你每次 push 到 GitHub 的時候，GitHub Workflow 都會重建一次整個網站，所以文章確定已經寫完在 push 上去。

## 每篇文章的標準格式
因為本次所使用到的 hexo 靜態網頁生成框架對於 markdown 的撰寫有些要求，你需要在文章的最一開始打上一些基本資訊，如下所示：

```yaml
---
title: 必填-放上文章的標題
catalog: true
date: 2023-07-02
author: Hsiangj-Jen Li # 填上你的姓名
categories:
- tag1 # 這邊擺放標籤
- tag2
---

# H1 這是標題
這邊是內文，按照正常的 markdown 格式即可
```
![](https://hackmd.io/_uploads/Hy_OU3kK3.png)

**categories**
因為 hackmd 的標籤寫法與 hexo 的寫法有差異，為了讓兩個平台都能夠同時使用，所以改使用 categories 代替。建議在寫 categories 的時候都是使用**小寫**代替，空格使用 `-` 或是 `_`


如果還是看不懂的話可以到 [GitHub](https://github.com/NTUST-SiMS-Lab/it-blog/tree/master/source/_posts) 上看別人都是怎麼寫的，以及最後網頁渲染的結果。

## push 到 GitHub 上
1. 在 Hackmd 的右上角點選 `...`，選擇**版本與GitHub 同步**

   ![](https://hackmd.io/_uploads/r1EqP2yFn.png)

1. 選擇**推送至 GitHub**

   ![](https://hackmd.io/_uploads/Byqy_hyY2.png)

1. 選擇要 push 到哪個 repo、branch、以及要同步的檔案
   
   ![](https://hackmd.io/_uploads/rJC__31t3.png)
   - repo: `NTUST-SiMS-Lab/it-blog`
   - branch: `master`
   - 要同步的檔案: 一定要在 `source/_posts` 這個目錄底下，但是你可以在這個目錄下在新增資料夾
      - 第一次 push 的時候因為這個檔案還不存在，所以會要你建立新的檔案
      - 你可以替這個文章取的名稱，記住這個檔案名稱最後會變成你的文章的網址，所以好好取名，不要有空白、中文
      - 例如：`this_is_demo.md` --> `https://ntust-sims-lab.github.io/it-blog/this_is_demo`
