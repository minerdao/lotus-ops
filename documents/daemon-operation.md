# 节点操作
## 1. 节点常用命令
```
    # 启动lotus节点
    lotus daemon
    # 停止lotus节点
    lotus daemon stop
    # 导入链快照
    lotus daemon --import-snapshot chain.car 
    # 导出链快照
    lotus chain export --skip-old-msgs --recent-stateroots=900 chain.car
    # 查看连接的节点
    lotus net peers
    # 查看连接状态
    lotus sync status
    # 创建钱包
    lotus wallet new bls
    # 查看钱包余额
    lotus wallet balance
    # 查看与主网高度同步差异
    lotus sync wait
```
## 2. 手动下载同步参数
```
export IPFS_GATEWAY=https://proof-parameters.s3.cn-south-1.jdcloud-oss.com/ipfs #设置国内下载源
lotus fetch-params 32GiB # 下载 32GiB 扇区对应的 Proof 参数
```
## 3. 导入导出同步数据裁剪快照
```
#当节点运行时间较长.lotus文件夹过大时，可选择通过导入导出同步数据来实现裁剪。
#可先导出本机链快照
lotus chain export --skip-old-msgs --recent-stateroots=900 chain.car
#首先备份.lotus/datastore/chain文件夹（若导入出现故障可以使用备份文件夹重新恢复即可），清空chain文件夹后进行导入
lotus daemon --import-snapshot chain.car 
```
## 4. 常见问题
- 消息堵塞
使用命令``lotus mpool pending --local | wc -l``查看本地堵塞消息数量，若不为0，则需要手动进行消息清理，具体清理方法参考「消息池操作」一章。
- 高度无法跟上主网
使用命令``lotus sync wait``查看本地与主网高度同步差异，当发现diff始终在2及以上时，需要对lotus节点网络、连接点质量、硬盘容量等进行排查并及时解决，否则将会出现掉算力等情况。
