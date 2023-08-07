# 伺服器位置
## 上面那台
localhost : simslab-server@140.118.1.26
password : simslab7111
可以用ssh直接從外網連

## 下面那台(有GPU)
localhost : simslab@192.168.1.193
password : simslab7111!
只能從實驗室內網連線
或者使用上面那台當作跳板（詳見下面的跳板章節）

# 常用命令
## ssh連線
- ssh <localhost> ==> 連線到指定的loaclhost
```ssh simslab-server@140.118.1.26```

## 效能監看  
- htop ==> 查看效能(類似工作管理員)，不過要先sudo apt install htop
- nvidia-smi 在有裝cuda/cudnn的電腦可以查看GPU用量，配合下面的指令可以變成幾秒鐘回傳一次
    ```nvidia-smi -l <幾秒>```
## 檔案傳輸
scp <欲傳輸檔案> <目的地位置> ==> 將本地的檔案以ssh方式傳到目的地
```scp test.py simslab-server@140.118.1.26:~/Desktop/David```

scp -r <欲傳輸資料夾> <目的地位置> ==> 將本地的資料夾以ssh方式傳到目的地
```scp -r test_file simslab-server@140.118.1.26:~/Desktop/David```

    備註：上面的指令只要目的地位置跟欲傳檔案位置對調就可以把目的端資料傳送回來本地端


## 查看命令使用紀錄(Linux專有/如果是Windows可以把grep轉換成findstr)
history ==> 查看歷史輸入命令
history|grep <搜尋關鍵字> ==> 查詢包含關鍵字的歷史紀錄

## 查看該路徑下有多少個檔案
```ls |wc -l```
    
# 跳板機設定(Mac)
1. 安裝ssh client
2. ssh keygen產生一組自己的sshkey
```bash=
ssh-keygen #然後連續按enter
```
3. 把生成的sshkey加進去server裡面（這邊需要輸入兩個機器的密碼）
```bash=
ssh-copy-id -i ~/.ssh/id_rsa.pub simslab-server@140.118.1.26
ssh-copy-id -i ~/.ssh/id_rsa.pub ProxyJump=simslab-server@140.118.1.26 simslab@192.168.1.193
```
4. 更改~/.ssh/config把下面的東西貼進去
``` bash=
Host simslab-server
    hostname 140.118.1.26
    user simslab-server
    IdentityFile ~/.ssh/id_rsa #或是用任何生成的ssh key位置
Host simslab
    hostname 192.168.1.193
    user simslab
    IdentityFile ~/.ssh/id_rsa
    ProxyJump simslab-server
```
4. 測試，執行下面這兩個指令應該不需要密碼加上應該也可以透過外網直接連線
```bash=
ssh simslab-server
ssh simslab
```
# 跳板機設定(Windows)
1. ssh keygen產生一組自己的sshkey
```bash=
ssh-keygen #然後連續按enter
```
(這邊使用手動複製公鑰)
2. 用記事本打開公鑰文件(通常是 ~/.ssh/id_rsa.pub,我的是"C:\Users\David\ .ssh\id_rsa.pub")
    
3. 將公鑰文件內的內容複製起來
4. 連線到跳板機伺服器(跳板機伺服器用上面那台為範例)
```bash= 
ssh simslab-server@140.118.1.26
```
5. 使用命令將公鑰內容新增到遠端伺服器的authorized_keys
```bash=
echo <貼上公鑰文件內的內容> >> ~/.ssh/authorized_keys
```
6. 使用命令設置權限
``` bash=
chmod 600 ~/.ssh/authorized_keys
```
7. 連線到目的地伺服器並把4~6再做一遍(目的地伺服器用下面那台為範例)
```bash= 
ssh simslab@192.168.1.193
echo <貼上公鑰文件內的內容> >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```
8. 更改~/.ssh/config把下面的東西貼進去
```bash= 
Host simslab-server
  hostname 140.118.1.26
  user simslab-server
  IdentityFile ~/.ssh/id_rsa
Host simslab
  hostname 192.168.1.193
  user simslab
  IdentityFile ~/.ssh/id_rsa
  ProxyJump simslab-server
```
9. 測試
執行以下指令應該不需要密碼就可以從外網直接連線
scp也可以直接傳，不會被擋
```
ssh simslab-server(連到上面那台)
ssh simslab(連到下面那台)
scp -r test simslab:~/Desktop/David(將test資料夾傳到下面那台的~/Desktop/David)
```

    
# 可研究
- rsync（速度比scp快，可以設定同步方法、要不要刪除等等，但需要先sudo apt install rsync）
    - https://blog.gtwang.org/linux/rsync-local-remote-file-synchronization-commands/
- 其他
    - https://www.ssh.com/academy/ssh/copy-id
    - https://chunyeung.medium.com/%E8%87%AA%E5%88%B6%E4%B8%80%E5%80%8B-linux-%E4%BD%9C%E6%A5%AD%E7%B3%BB%E7%B5%B1-3-run-os-run-c3f9232532c6