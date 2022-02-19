# Lotus Network V15更新说明
### 更新什么内容
##### **Snap Deal**
将数据直接存入CC扇区，需要执行ProveReplicaUpdate计算过程，后续我们会给出如何操作的详细文档。
##### **新的证明参数**
支持Snap Deals的证明参数，需要下载更新的证明参数，并更新到daemon、miner和C2机器上的对应目录。使用以下命令下载证明参数：
  ```
  // 注意是v1.14.0版本的lotus，需自行编译一下官方的
  make lotus-shed
  ./lotus-shed fetch-params --proving-params 32GiB or 64GiB
  ```
**注意：证明参数下载较慢，请提前做好准备。**

### 何时升级
初步的更新时间将在下周五即2.25日左右，到时候将会提供测试完成的二进制代码，直接替换即可。

### 如何升级
- 未封装新算力的，只需要替换daemon和miner上的证明参数、Lotus二进制文件即可；
- 正在封装的，请在升级前1天，停止封装，确保所有扇区已经落盘，时空证明没有错误，升级完成后再开启封装。

### 升级步骤
1. 停止pledge sector的任务脚本。
2. 替换daemon的二进制文件为我们提供的版本，并重启daemon，等待daemon同步完毕。
3. 替换miner和worker上的二进制文件，重启miner和worker。
4. 等待未完成的任务恢复并全部完成后，重新启动pledge sector脚本发任务。