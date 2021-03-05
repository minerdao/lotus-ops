# Lotus升级指南

## 安装包下载
请先根据自己的CPU和操作系统版本，下载Filguard团队提供的优化后的二进制升级包。

## 更新说明
本次1.5.0 Filguard优化版本主要更新以下功能：
- 优化PreCommit1 CPU核心绑定，可指定CPU绑定核心数和核心组的范围，大大提升CPU核心利用率，使用SDR可以跑更多的P1并发；
- 优化PreCommit2的核心算法，比原有的时间提升了20%左右，并降低了显存使用；

## 升级步骤
1. 停止pledge sector的任务脚本。
2. 替换daemon的二进制文件，确保`lotus -v`的结果为: `lotus version 1.5.0+mainnet+git.bd15c4293.dirty`，并重启daemon，等待daemon同步完毕。
3. 替换miner和worker上的二进制文件，重启miner和worker，确保:
    - `lotus-miner -v`的结果为：`lotus-miner version 1.5.0+mainnet+git.bd15c4293.dirty`
    - `lotus-worker -v`的结果为：`lotus-worker version 1.5.0+mainnet+git.bd15c4293.dirty`
  
4. 等待未完成的任务恢复并全部完成后，重新启动pledge sector脚本发任务。