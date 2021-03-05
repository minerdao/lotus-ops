# 手把手教你如何避免掉算力
掉算力是fil挖矿过程中新手会经常出现的问题，持续掉算力还会面临巨额处罚。掉算力是个综合问题，造成的原因有很多，需要仔细排查集群存在的问题。
## 1. WindowPost做了什么？
WindowPost，是指每隔一段时间对已提交的Sector数据进行存在性证明。WindowPost的周期是一天，分成48个Window，证明时会抽取每个partition中的所有Sector抽取10个叶子节点进行计算验证。
所以，WindowPost对集群网络、存储性能、lotus节点状态甚至.lotusminer存放硬盘的性能都有着及其严格的要求，稍有不慎就会导致算力丢失。
## 2. 如何配置集群避免掉算力
### 2.1 节点同步
进行WindowPost需要保持节点区块链始终同步到最新，才能准时进行验证。使用命令``lotus sync wait``查看与主网高度差异。
如果发现节点的连接质量很差，可以考虑从以下两个方面解决：
- 当节点同步时间越长时，`/.lotus/datastore/chain`文件夹就会越大，当该文件夹过大时，节点的同步状态就会变差，所以我们在运维的过程中需要定期对节点快照进行裁剪。
- 给daemon节点配置公网ip，也能够使节点同步更加稳定。
以上两种方法具体操作方法，可以参考文档「Lotus节点操作及常见问题」。
### 2.2 WindowPost时的存储和网络性能
在进行WindowPost计算前需要从存储机抽取数据，一次抽查最多两千多个Sector数据，如果同时还在进行封装，那么整个集群的存储和网络压力就变的很大，此时需要预留足够的存储和网络性能用来WindowPost进行数据抽取。
对于存储和网络的性能测试方法可以参考文档「Filecoin存储管理，存储i/o性能分析，网络分析」，根据自己集群中网络和存储性能测试结果选择升级网络或者修改Miner配置文件控制ParallelFetchLimit的数量。在Miner配置文件config.toml中，修改ParallelFetchLimit的值，该值表示集群可以同时写入存储的Sector数量。例如网络和性能的测试结果支持写入速度是1GB/s，那么假设worker的传输速率是200M/s，那么建议ParallelFetchLimit值设置4，给WindowPost数据传输和读取留出性能空间。
### 2.3 WindowPost计算
读取完成数据后，WindowPost会对抽取的数据进行验证计算，分为计算默克尔树和零知证明。计算默克尔树部分建议采用AMD CPU计算速度更快；零知证明部分会使用GPU进行计算，建议采用两张2080Ti及以上性能的显卡。
### 2.4 SubmitWindowedPoSt消息发送
数据证明计算完成后，会将结果通过消息发送到链上，若此时出现消息堵塞、钱包余额不足或配置费用不足以支付消息费用时就会出现消息无法及时发送到链上，算力依然会丢失。
- 设置WindowPost独立钱包。
即使用一个全新独立的钱包来进行WindowPost消息的发送，该钱包只用来WindowPost消息的扣费，这样就不会因为precommit和prove的消息堵塞而导致WindowPost消息无法发送。
新建钱包地址并往该钱包打入足够的Fil（建议20个以上）：
`lotus wallet new bls`
设置该钱包地址为WindowPoSt消息地址：
`lotus-miner actor control set --really-do-it + 新生成的钱包地址`
检查是否设置成功可以使用命令查看，若刚刚设置的钱包地址后显示「post」则表示设置成功：
`lotus-miner actor control list –verbose`
- 确保Post钱包、Miner钱包余额充足
建议Post钱包维持20fil以上，Miner钱包维持10fil以上，Miner钱包余额可以使用`lotus-miner info`命令查看，若Miner钱包余额不足可使用`lotus send fxxxxxx 10`进行转帐，`fxxxxxx`为节点号，数字`10`为转帐金额，这里可以替换为你需要转帐的节点号和金额。

