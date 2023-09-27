---
title: 重灌後，安裝 GPU 驅動以及 Docker
catalog: true
date: 2023-09-27
author: Hsiangj-Jen Li
categories:
- docker
---



# 重灌後，安裝 GPU 驅動以及 Docker

設備規格
- **CPU** : i7-10700 
- **GPU** : RTX-3060
- **系統** : Ubuntu 20.04

## NIVIDIA GPU 驅動

### 確認有沒有安裝到 GPU 驅動程式

```
nvidia-smi
```

```shell
>>> Command 'nvidia-smi' not found, but can be installed with:
```

### 安裝
安裝的教學可以參考 [[Linux] Ubuntu 安裝、移除 NVIDIA 顯示卡驅動程式（Driver）教學](https://www.tokfun.net/os/linux/linux-ubuntu-install-remove-nvidia-driver/)


```
sudo add-apt-repository ppa:graphics-drivers
```

查詢可以安裝哪個版本的驅動
```
sudo apt-get update
sudo apt-cache search nvidia-driver-*
```

我是安裝 `nvidia-driver-535`，理論 install 完要自己下指令去 reboot，但是不知道為何螢幕直接黑掉，但是重開後就裝好了...
```
sudo apt-get install nvidia-driver-535
# sudo reboot
```

### 安裝成功後的畫面
要出現這個才算安裝成功

```javascript
+---------------------------------------------------------------------------------------+
| NVIDIA-SMI 535.104.05             Driver Version: 535.104.05   CUDA Version: 12.2     |
|-----------------------------------------+----------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |         Memory-Usage | GPU-Util  Compute M. |
|                                         |                      |               MIG M. |
|=========================================+======================+======================|
|   0  NVIDIA GeForce RTX 3060        On  | 00000000:01:00.0  On |                  N/A |
|  0%   51C    P8              19W / 170W |    504MiB / 12288MiB |      5%      Default |
|                                         |                      |                  N/A |
+-----------------------------------------+----------------------+----------------------+
                                                                                         
+---------------------------------------------------------------------------------------+
| Processes:                                                                            |
|  GPU   GI   CI        PID   Type   Process name                            GPU Memory |
|        ID   ID                                                             Usage      |
|=======================================================================================|
|    0   N/A  N/A      1130      G   /usr/lib/xorg/Xorg                           35MiB |
|    0   N/A  N/A     24470      G   /usr/lib/xorg/Xorg                          149MiB |
|    0   N/A  N/A     24633      G   /usr/bin/gnome-shell                         34MiB |
|    0   N/A  N/A     26275      G   /usr/lib/firefox/firefox                    258MiB |
|    0   N/A  N/A     42730      G   gnome-control-center                          2MiB |
+---------------------------------------------------------------------------------------+

```
![](https://hackmd.io/_uploads/By0PiSxkp.png)


## 安裝 Docker + 可以執行 GPU 的 Container

要在 docker 裡面執行 GPU 的話要安裝：
1. docker-ce（community edition）
2. NVIDIA Container Toolkit

原則上按照 [docker 官方](https://docs.docker.com/engine/install/ubuntu/)的安裝即可，如果有出現任何 ERROR 請到下面的 [ERROR 區](#ERROR)查看解法。這邊就不提供安裝 Docker Desktop 的教學，因為好像安裝了 Docker Desktop 就沒辦法在 Container 裡面使用 GPU，參考自 [nvidia-docker ](https://github.com/NVIDIA/nvidia-docker/issues/1746#issuecomment-1599294621)。

### 確認電腦都沒有舊的 docker 
```
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
```

### 開始安裝 Docker
```shell
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

```shell
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

安裝完後在終端機打上
```
docker
```
應該會出現一大串，像是下面這樣，這樣就算安裝成功
```java
Usage:  docker [OPTIONS] COMMAND

A self-sufficient runtime for containers

Common Commands:
  run         Create and run a new container from an image
  exec        Execute a command in a running container
  ps          List containers
  build       Build an image from a Dockerfile
  pull        Download an image from a registry
  push        Upload an image to a registry
  images      List images
  login       Log in to a registry
  logout      Log out from a registry
  search      Search Docker Hub for images
  version     Show the Docker version information
  info        Display system-wide information

```


### 開始安裝 NVIDIA Container Toolkit

```javascript
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list \
  && \
    sudo apt-get update
```
```javascript
sudo apt-get install -y nvidia-container-toolkit
```

```javascript
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

## 測試是否可以執行 GPU
執行 docker image
```
sudo docker run -it --gpus all pytorch/pytorch:2.0.1-cuda11.7-cudnn8-runtime bash
```
進入 docker container 的終端機，類似下面的畫面後輸入 `python` 後就會進入 python 的 console
![](https://hackmd.io/_uploads/SkjNEdlkT.png)

依序輸入下面，如果都有正常顯示就是裝成功了

```python
import torch

print(torch.cuda.is_available())
print(torch.cuda.get_device_name())
```
![](https://hackmd.io/_uploads/SJQhrOg1a.png)

## ERROR
> #### docker.socket: Failed with result 'service-start-limit-hit'
> 如果打這個指令會出現上面的 ERROR 的解法
> ```
> sudo systemctl restart docker
> ```
> 解決方案參考自網路上的[方法](https://blog.csdn.net/qq_43551263/article/details/115186371)，將檔案名稱更改即可 `daemon.json` --> `daemon.conf`
> 
> ```
> sudo mv /etc/docker/daemon.json /etc/docker/daemon.conf
> ```