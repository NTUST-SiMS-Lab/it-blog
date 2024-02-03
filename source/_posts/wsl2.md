---
title: 【技術分享】在 windows 安裝 wsl2 (ubuntu)
date: 2024-02-03
author: Hsiangj-Jen Li, David Chen, Bo-Cheng Su
categories: 
  - ubuntu
  - wsl
---

## WSL2

> ⭐ win 11務必更新到**最新版**, 否則無法成功安裝 WSL

1. Open Control Panel  
1. Search `Turn Windows Features on or off`
    <img width='300px' src='https://i.imgur.com/h7BWsGf.png'>
    
    - Virtual Machine Platform
    - Windows Hypervisor Platform
    - Window Subsystem for Linux
    <img width='400px' src='https://i.imgur.com/w8krU78.png'>

1. `wsl --install`

![](https://i.imgur.com/oFo9ioj.png)


## 🚀 **疑難排解**
> `WslRegisterDistribution failed with error: 0x800701bc`
> 1. 進入[官網](https://learn.microsoft.com/zh-tw/windows/wsl/install-manual)下載Linux 核心更新套件
> <img width="400px" src="https://i.imgur.com/kWXjmue.png">

## Reference
- [Win11 Dokcer安裝 中文教學](https://www.ruyut.com/2022/09/windows-11-install-docker.html)
