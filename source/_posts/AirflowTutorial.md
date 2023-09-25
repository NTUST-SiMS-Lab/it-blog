---
title: 【技術分享】Airflow快速入門及如何在Docker上安裝
catalog: true
date: 2023-09-18
author: BO-CHENG SU # 填上你的姓名
categories:
- docker
- airflow
---

# 什麼是Airflow？
先簡單介紹一下什麼是Airflow。 Airflow原先由 Airbnb 開發的開源軟體，現為Apache頂級專案，並且具有GUI介面供使用者使用，是以 Python 寫成的工作流程管理系統（Workflow Management System）。

### 你可能會問，Airflow可以拿來做什麼？

近年不管是資料科學家、資料工程師還是任何需要處理數據的軟體工程師，Airflow 都是他們用來建構可靠的 ETL 以及定期處理批量資料的首選之一。

### 在使用Airflow之前你必須先了解... 
一般而言，我們會將相關的工作設計為一個「**有向無循環圖**」 DAG（Directed Acyclic Graph），顧名思義就是有**方向性**且**無回向**造成循環的結構。因此，往後在使用Airflow進行開發的同時，不要忘記確保工作之間的相依性（Dependencies）好讓 Airflow 這種工作流程管理系統幫我們管理工作流程。

### Airflow的好處
1. 定期執行工作流程，解決自動化的痛點
2. 維護相依性，確保工作流程從上游到下游執行，不會在上游沒完成前執行到下游
3. 各個工作失敗時自動重試（墨菲定律，所有你認為邏輯上萬無一失的工作都會因為各種無法預期的情況失敗）
4. 簡單易懂的 Web UI 方便管理工作流程

接下來就來教大家如何在Docker上安裝Airflow吧！

# 在Docker上安裝Airflow
### 環境準備
在環境部分建議使用Linux系統，我的Ubuntu環境是20.04 LTS。也可以使用Windows的Linux子系統。此外，請預先安裝好：
1. 安裝 Docker
2. 安裝 Docker-Compose

當環境準備好了以後，就可以開始準備安裝啦！
### 安裝
以下提供給大家兩種方法：
1. 我已經幫大家準備好Dockerfile及示範的程式碼啦~如果覺得以下步驟麻煩的可以去載我的repo！
    step 1: 
    ```
    git clone https://github.com/angus2292/Airflow_Quick_Start.git
    ```
    step 2:
    cd到repo的資料夾(應該會看到Dockerfile)輸入：
    ```
    docker build -t airflow_demo:0.0.1 .
    ```
    step 3:
    當image建好以後，執行：
    ```
    docker compose up -d
    ```

2. 參考官方說明文檔操作過程如下：
    step 1: 
    開一個資料夾，下載最新版的`docker-compose.yaml`
    ```
    curl -LfO 'https://airflow.apache.org/docs/apache-airflow/2.7.1/docker-compose.yaml'
    ```
    ![](https://hackmd.io/_uploads/r1Kuj0DkT.png)
    step 2:
    在剛剛建的資料夾下新增3個子資料夾，分別為dags, logs, plugins。並配置user id
    (Note：其他作業系統可能會報錯"沒有設置AIRFLOW_UID"，直接手動建立`.env`並將其內容修改成`AIRFLOW_UID=50000`後儲存)
    ```
    mkdir -p ./dags ./logs ./plugins ./config ＃ 創資料夾
    echo -e "AIRFLOW_UID=$(id -u)" > .env ＃ 配置user id
    ```
    ![](https://hackmd.io/_uploads/S1ff2Rw1p.png)
    step 3:
    接下來可以依照需求選擇要不要寫Dockerfile，主要是看你的DAG有沒有需要其他相依的套件。
    - 無需其他相依套件，直接執行：
        ```
        docker compose up -d
        ```
    - 需其它相依套件：
        1. 準備好Dockerfile
        2. 執行
            ```
            docker build -t <name:version> .
            例如：
            docker build -t airflow_demo:0.0.1 .
            ```
            ![](https://hackmd.io/_uploads/SkJlG1u16.png)
        3. 將 `docker-compose.yaml`中，`images: ${AIRFLOW_IMAGE_NAME:-apache/airflow:2.0.0}`改成上步驟所建的image
            ![](https://hackmd.io/_uploads/HJykm1dJ6.png)
            （在官方docker-compose.yaml其實有提到可以註解此行並改成`build: .`後直接執行`docker compose up`，但實際執行後發現會build許多相同id的images，因此改成上述作法）
        5. 執行
            ```
            docker compose up -d
            ```
   
    
這樣就完成Airflow的安裝囉！趕緊去網頁輸入`localhost:8080`看能不能登入網頁！初始帳號與密碼皆為`airflow`。
![](https://hackmd.io/_uploads/rJvNmkukT.png)

修但幾咧！！！前面前置作業那麼多，我該如何去寫我自己的DAG呢？接下來不只會給你code，而且會給你很多code！

# 如何用Python撰寫DAG？
事實上，一個 DAG 是由多個 Tasks 組成，每個 Task 是分開執行的，Task 是 Airflow 執行基礎單位。而 Task 是由 Operator 所定義，最常使用的 Operator 有：
- **SimpleHttpOperator**:執行HTTP請求的操作器，可以用於呼叫外部API或網站。
- **PythonOperator**:許執行自定義Python函數的操作器，用於任何需要Python代碼執行的任務。
- **PostgresOperator**:執行PostgreSQL數據庫上的SQL操作的操作器，例如執行查詢或數據庫更改。

而 PythonOperator 是 Airflow 內最常用到的 Operator 即使你不熟 Airflow 內建或是第三方寫好的 plugin，幾乎都可以在 PythonOperator 內自己寫出來。以下示範最基本的DAG組成：
```
from airflow import DAG
from airflow.operators.python import PythonOperator

default_args = {
    'owner': 'Angus Su', # 誰擁有這個DAG
    'start_date': days_ago(1), # 從何時開始執行
    "retries": 1, # 報錯時自動重試
    "retry_delay": timedelta(minutes=5) # 自動重試的間隔
}

def task1():
    print('task 1')
    
def task2():
    print('task2')
    
with DAG('example_dag', default_args = default_args) as dag: 

    t1 = PythonOperator(
        task_id = 'task_1'  # 在airflow上顯示的 task 名稱
        python_callable = task1() # 呼叫 python 函式
    )
    
    t2 = PythonOperator(
        task_id = 'task_2'
        python_callable = task2()
    )

    t1 >> t2
```
上述程式碼就是最簡單的DAG，所有語法都是使用Python撰寫，為我們開發上帶來許多便利！


# TaskFlow
什麼是 Task flow？

在Airflow 2.0 中引入了TaskFlow API作為新的DAG編寫範例，透過使用TaskFlow，開發者可以更容易、更簡單地管理DAG的依賴關係和使用XCom。

怎麼說很方便呢？在過往DAG中的Task資料的溝通可能需要透過XCom：
```
def ProcessData(**kwargs):
	#... 資料處理的步驟
	result = get_result()
    push_result_to_xcom(result)
	  

def LoadData(**kwargs):
    data = get_data_from_xcom()
    #...do something

with DAG('123', deafult_args= deafult_args) as dag:
    p = PythonOperator(
        ....
        provide _context = True
    )
    
    l = PythonOperator(
        ....
        provide _context = True
    )
```
在Airflow 2.0之後，我們只須在def前加上`@task`即可。因此，上述程式碼可以改寫成：

```
def example_task_flow():

    @task
    def ProcessData():
        #... 資料處理的步驟
        result = get_result()
        return  result

    @task
    def LoadData(result):
        data = get_data_from_xcom()
        #...do something
        return data
    
    res = ProcessData
    LoadData(res)

example_task_flow()
```

是不是跟我們原先Python寫法很像呢～除此之外，程式碼也更加的直觀了！

總結一下TaskFlow：
-  Airflow 的一個新功能，可以用裝飾器 `@task` 來簡化 PythonOperator 的寫法，並且自動處理 XCom 的資料傳遞。
-  讓程式碼更乾淨，易讀，並且可以直接使用 context 內的參數，而不需要提供 context 參數或是用 template 定義。


# 總結
在本文中，我們簡略介紹了：
- 什麼Airflow
- 如何在Docker上安裝Airflow
- 如何撰寫自己的DAG
- TaskFlow

Airflow真的是非常好用的自動化工具，也希望我的分享可以對大家有幫助！
此外，我也有準備PTT股票板的爬蟲案例(與[安裝](#安裝)的連結一致)：
```
git clone https://github.com/angus2292/Airflow_Quick_Start.git
```
在 `dags` 資料夾中，包含了 `crawling.py` 與 `crawling_task_flow.py` 分別演示了有無使用TaskFlow的兩種撰寫方式，供大家參考。

感謝大家！