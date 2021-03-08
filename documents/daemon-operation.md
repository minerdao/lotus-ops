# 节点操作
## 1. 节点常用命令
```sh
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
```sh
export IPFS_GATEWAY=https://proof-parameters.s3.cn-south-1.jdcloud-oss.com/ipfs #设置国内下载源
lotus fetch-params 32GiB # 下载 32GiB 扇区对应的 Proof 参数
```
## 3. 导入导出同步数据裁剪快照
当节点运行时间较长`.lotus`文件夹过大时，可选择通过导入导出同步数据来实现裁剪。
```sh
# 先导出本机Daemon的快照，该命令运行时间较长。
lotus chain export --skip-old-msgs --recent-stateroots=900 chain.car
# 导出完成后，关闭lotus daemon
lotus daemon stop
# 首先备份.lotus/datastore/chain文件夹（若导入出现故障可以使用备份文件夹重新恢复即可），清空chain文件夹后进行导入
lotus daemon --import-snapshot chain.car 
# 后续正常启动daemon节点，观察节点是否能够正常同步，正常同步代表快照已经裁剪成功
lotus sync wait
```

## 4. 给Deamon配置公网IP
给Daemon节点配置公网IP以后，可以让节点更稳定、更健康，评分更高，不错过任何一个爆块机会。

### 4.1 配置公网IP
配置公网IP分如下两种情况：
**(1) Daemon有公网IP**
假设Daemon的公网IP为`123.123.73.123`，内网IP为`10.0.1.100`，Daemon监听的端口为`1234`。

**(2) Daemon无公网IP**
如果Daemon没有公网IP，就需要在路由器、或有公网IP的服务器上，增加公网IP和端口向Daemon内网IP和端口的转发规则，假设公网机器的IP为`123.123.73.123`，Daemon的内网IP为`10.0.1.100`，`123.123.73.123:12340`端口映射到内网的`10.0.1.100:1234`端口。

### 4.2 更改Daemon配置
给Daemon节点配置公网IP以后，可以让节点更稳定、更健康，评分更高，不错过任何一个爆块机会。

### 4.1 配置公网IP
配置公网IP分如下两种情况：
**(1) Daemon有公网IP**
假设Daemon的公网IP为`123.123.73.123`，内网IP为`10.0.1.100`，Daemon监听的端口为`1234`。

**(2) Daemon无公网IP**
如果Daemon没有公网IP，就需要在路由器、或有公网IP的服务器上，增加公网IP和端口向Daemon内网IP和端口的转发规则，假设公网机器的IP为`123.123.73.123`，Daemon的内网IP为`10.0.1.100`，公网的`123.123.73.123:12350`端口映射到内网的`10.0.1.100:1235`端口。

### 4.2 更改Daemon配置
修改`$LOTUS_PATH/config.toml`文件中的以下内容：
- 将`ListenAddresses`中的端口改为内网的端口，如`1235`，IP为`0.0.0.0`不用改;
- 将`AnnounceAddresses`中的IP改为公网IP，如`123.123.73.123`，端口改为公网端口`12350`。
```toml
[Libp2p]
ListenAddresses = ["/ip4/0.0.0.0/tcp/1235", "/ip6/::/tcp/0"]
AnnounceAddresses = ["/ip4/123.123.73.123/tcp/12350"]
```
注意：**要修改的是Libp2p部分，而不是API部分。**

修改好并重启Daemon后，可以通过以下命令，查看Daemon的公网连接地址：
```sh
lotus net listen
```

### 4.3 内网其他Daemon连接公网Daemon
内网的其他Daemon，可以通过`lotus net connect /ip4/10.0.1.100/tcp/1235/p2p/12D3Koo.....`来连接配置了公网IP的Daemon。

## 5. 常见问题
- 消息堵塞
使用命令`lotus mpool pending --local | wc -l`查看本地堵塞消息数量，若不为0，则需要手动进行消息清理，具体清理方法参考「消息池操作」一章。
- 高度无法跟上主网
使用命令`lotus sync wait`查看本地与主网高度同步差异，当发现diff始终在2及以上时，需要对lotus节点网络、连接点质量、硬盘容量等进行排查并及时解决，否则将会出现掉算力等情况。
