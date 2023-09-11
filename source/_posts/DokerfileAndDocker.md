---
title: 基本Dockerdfile寫法與Command Line
catalog: true
date: 2023-09-11
author: BO-CHENG SU # 填上你的姓名
categories:
- docker
---

1. 首先準備一個 Dockerfile，這邊給一個簡單的範例：
    *   Dockerfile
        ```
        //這是python image
        FROM python:3.11
        
        //把 requirement.txt複製到container中
        COPY requirement.txt requirement.txt

        // 執行pip install 指令
        RUN pip install -r requirement.txt
        ```
    * requirement.txt
        ```
        pandas==2.0.0
        ```
2. 在cmd中打開執行以下指令，用來建立 image

    ```
    docker build -t <name:tag> .
    ```
    Note：如果你沒有要安裝其他套件，可以直接pull別人的image。
3. 查看自己的 image 有哪些
    ```
    docker image ls 
    or
    docker images
    ```
    ![](https://hackmd.io/_uploads/BJSzGoAqn.png)
4. 建立 Container 並執行
    ```
    docker run -it --name <name> <image> bash
    ```
    * `--name <name>` :替你的container取名
    * `-i`:代表交互式模式（interactive mode）
    * `-t`:分配一個虛擬終端給容器給你操作
    * `-d`:在背景執行
    （`-t`、`-i`、`-t`可以混用，如：`-it`、`-itd`）
    * `bash`:進到bash操作(也可以換成`sh`運行shell指令)

    結果如下圖：
    ![](https://hackmd.io/_uploads/H143NiRc3.png)
    
    如果要掛載一個與Container共用的資料夾可以做以下操作：
    ```
    docker run -it --name <name> -v <路徑>:/app <image>  bash
    ```
    例如說：`docker run -it --name admin -v C:/Users/bc200/OneDrive/桌面/fortest/test:/app test bash`，本機端的`test`資料夾就會與container中的`app`資料夾共用，只要修改本機端`test`內容就會修改`app`的內容。
    ![](https://hackmd.io/_uploads/ByHJdjRc3.png)
    執行 `python test.py`即可運行程式：
    ![](https://hackmd.io/_uploads/S1l6DuiC53.png)
    `exit`就可以離開container
    （請注意這時會結束容器的運行）
    
5. 啟動/結束容器可以使用：
    ```
    // 啟動容器
    docker start <Container ID> or <Container Name>
    // 結束容器
    docker stop <Container ID> or <Container Name>
    ```
    
    這裡啟動/結束容器可以使用容器ID或是你有設定container Name也可以使用名稱
    
6. 進入到容器內部：
    ```
    docker exec -it <Container ID> <bash or sh>
    ```
7.    查看有哪些容器正在運行：
        ```
        docker ps
        ```
        (加上`-a`就是看目前所有容器）
8. 刪除 image 或 Container：
    ```
    // 刪除 image
    docker rmi <image ID>
    // 刪除 container
    docker rm <container ID>
    ```
    
其他Docker指令:
https://medium.com/alberthg-docker-notes/docker%E7%AD%86%E8%A8%98-docker%E5%9F%BA%E7%A4%8E%E6%95%99%E5%AD%B8-7bbe3a351caf