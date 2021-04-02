# myScheduler调度程序使用

## 1. myScheduler 调度程序简介
  目前官方窗口调度Scheduler工作效果不理想，有的worker工作繁忙，有的 worker 又非常轻闲。个人认为filecoin运维人员最为熟悉自己的设备，所以基于运维人员的工作任务指令，重新编写了一套调度程序，摈弃官方窗口调度和纯基于设备资源排序的规则，重新自定义排序规则，总体调度目标是让相关任务均匀分配到各个可以执行的 worker 上面，调度程序支持以下业务功能：
- ①	支持90% 以上的设备利用率；
- ②	由你的运维人员，设置每个 Worker 最大的 AP/P1/P2/C2 工作任务数量；
- ③	支持单 Worker 任意的 AP/P1/P2/C2 数量配比和工作并行；
- ④	支持单 Worker AP/P1 绑定（免传输32GB），P1/P2绑定（免传输453GB），P2/C2 绑定调度，如果三项全部绑定，则该 Worker 进入独立工作模式；
- ⑤	支持 Worker 待离线维护工作模式，不接新任务，完成手头任务后进行安全下线维护；
- ⑥	实时监控 Worker 本地 cache/sealed/unsealed 磁盘空间使用，当空间不足时，自动进入空间紧缩工作模式，支持 Worker 在 out of space 不接收任务工作分配情形下进行特别工作处理；
- ⑦	以上 Worker 参数，均可以在 Worker 运行过程中动态调整、实时生效；
- ⑧	`lotus-miner sectors mypledge` 一次性填充所有 lotus-worker 可以工作AP的数量总和，可用自动化任务定时调用 mypledge

## 2. lotus-worker 动态参数设置
如果首次启动 lotus-worker，调度程序会自动将 run 相关的参数写进 `$LOTUS_WORKER_PATH` 路径下面的参数文件 `myscheduler.json`， miner 本地worker，则是在 `$LOTUS_MINER_PATH` 目录创建此配置文件，并且设置为默认初始状态，相关参数均可以在不重启 lotus-worker 的状态下，动态修改并实时生效。以下是默认参数：
```json
{
  "WorkerName": "",
  "AddPieceMax": 0,
  "PreCommit1Max": 0,
  "PreCommit2Max": 0,
  "Commit2Max": 0,
  "DiskHoldMax": 0,
  "APDiskHoldMax": 0,
  "ForceP1FromLocalAP": true,
  "ForceP2FromLocalP1": true,
  "ForceC2FromLocalP2": false,
  "IsPlanOffline": false,
  "AllowP2C2Parallel": false,
  "IgnoreOutOfSpace": false,
  "AutoPledgeDiff": 0
}
```
|     动态任务参数          |     默认值    |     参数功能说明                                                                                              |
|---------------------------|---------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|     WorkerName            |     ""        |     设置worker 的显示名称，对于同一个物理设备启动多个   worker 时方便区分，默认使用设备HostName|
|     AddPieceMax           |     0         |     设置本地最大允许的 Add   Piece 执行数量，0表示禁用AP功能   |
|     PreCommit1Max         |     0         |     设置本地最大允许的 P1 执行数量，0表示禁用P1功能  |
|     PreCommit2Max         |     0         |     设置本地最大允许的 P2 执行数量，0表示禁用P2功能   |
|     Commit2Max            |     0         |     设置本地最大允许的 C2 执行数量，0表示禁用C2功能    |
|     DiskHoldMax           |     0         |     对于unsealed 和 sealed 目录，每个扇区各计数为 1，对于cache 目录，每个扇区计数为 14，用于控制计算节点的磁盘配额，例如2TB的SSD 则可以设置为 60，本参数没有检测 fetching和其它磁盘目录所占空间，可保守设置。达到此限制后，该worker 将不会接收新任务，进入紧缩空间工作模式，默认值 0 表示不控制，CanStore 支持的存储目录不进行控制。在此状态下面：【1】不接收新的 AP任务     【2】不接收新的 P1任务     【3】可完成本地已经开始工作过的P1     【4】可完成本地绑定的 P2任务     【5】不接收其它 worker 新的 P2任务     【6】不接收其它 worker 新的 C1/C2任务    |
|     APDiskHoldMax         |     0         |     对于 unsealed目录，每个扇区计数为   1，用于控制本地可以保留的最大的 Add Piece数量达到此限制后，该worker 将不会接收新的 AP   任务，默认值 0 表示不控制，CanStore   支持的存储目录不进行控制。   |
|     ForceP1FromLocalAP    |     true      |     强制P1 只工作来自本地完成的   Add Piece                                           |
|     ForceP2FromLocalP1    |     true      |     强制P2 只工作来自本地完成的   P1                                                 |
|     ForceC2FromLocalP2    |     false     |     强制C1/C2 只工作来自本地完成的P2，如果上述三个参数同时设置true，则该计算节点进入一条龙独立工作模式。                                     |
|     IsPlanOffline         |     false     |     如果设置为 true，表示该 worker 计划进入离线维护模式，在此状态下面：     【1】不接收新的 AP任务     【2】不接收新的 P1任务     【3】不接收新的 P2任务     【4】不接收新的 C1/C2任务     在worker 结束离线维护模式，重启时记得将 `IsPlanOffline` 重新设置为 `false`|
|     AllowP2C2Parallel     |     false     |     允许该 worker并行支行 P2/C2 |
|     IgnoreOutOfSpace      |     false     |     当miner日志中看到某个 worker 不断出现`out of space`时，它不会接收任何工作任务。如果此时 worker 的物理磁盘空间其实仍然存在部分剩余，则可以设置此参数为 true，系统临时跳过 out of space检测，此 worker 自动进入紧缩空间工作模式，待可用空间正常，再将此参数设置回   false  |
|     AllowDelay      |     3     |  延迟分配任务，用于任务卡顿时，延迟第一轮的任务分配   |


## 3. lotus-worker run 初始参数
对于 `lotus-worker run` 初始参数， myscheduler 可以不额外添加设置任何自定义项目，直接仅使用官方的标准参数，这样方便在官方标准程序之间来回切换。

## 4. 调度外部 lotus-worker 参数设置
myScheduler 社区版加入以下外部 lotus-worker 功能支持：
- ①	支持调度各类开源软件编译的 lotus-worker 优化版本；
- ②	支持调度外部 C2 的 lotus-worker 版本；
- ③	支持调度外部阿里 FPGA卡的 lotus-worker P2优化版本；
- ④	支持调度官方标准的 lotus-worker 等其它通用版本。
通过动态修改 `$LOTUS_MINER_PATH` 路径下面的 `testOpenSource.json`，可以控制被调度的 Worker 进行任意 AP/P1/P2/C2 数量配比和工作并行，以及 AP/P1/P2本地文件绑定不传输：
```json
{
  "AddPieceMax": 1,
  "PreCommit1Max": 1,
  "PreCommit2Max": 1,
  "Commit2Max": 1,
  "ForceP1FromLocalAP": true,
  "ForceP2FromLocalP1": true,
  "ForceC2FromLocalP2": false,
  "AllowP2C2Parallel": true
}
```
## 5. 自义定 pledge 任务实用工具

- ①	`lotus-miner sectors mypledge`
mypledge 一次性填充所有可以工作AP的 lotus-worker 的数量 `AddPieceMax` 总和，自动化任务可以定时调用 mypledge

- ②	`lotus-miner sectors mypledgeonce`
mypledgeonce 一次性为每个可以工作AP　的 lotus-worker 发送一个 AP，适合初始实施时，第一次使用 AP 模板复制功能

## 6. 调度过程日志分析与问题排查
由于调度的频繁度，在运行过程中，有大量的日志用于记录任务分配细节，可以通过下面的方式轻松查询相关成功分配和未分配的调度情况列表：
- ①	`more miner.log |grep -a trySchedMine > trySchedMine.txt`， 这个里面记录了，所有成功调度的 `has sucessfully scheduled` 相关信息。
- ②	`more miner.log |grep -a "not scheduling" > not_scheduling.txt`， 则是拒绝接收任务分配的worker 的日志。
- ③	对于个别扇区的调度分配过程，则可以用以下方式查询和它相关的全部日志过程，
`more miner.log |grep -a "s-t0XXXX-YYYY"> s-t0XXXX-YYYY.txt` ，格式是 "s-t0你的MinerID-某个扇区编号“。对于长时间不分配任务工作的 worker，一般是在 miner日志中可以看到 `out of space` 或者 `didn't receive heartbeats for` 的官方标准错误提醒。
- ④ 如果在 `sealing workers` 看到大量的 worker 闲置情况，但是挺多已经预分配的工作任务在 Preparing 里面，而长时间无法到在 Running。Preparing 通过了第一步的预备分配，在实际分配响应任务的时候不满足条件，就无法到达 Running 执行状态。尽量减少在动态参数配置文件中不必要的限制，限制条件越多，则越容易无法达到真正可运行状态。有时可以偿试进行一次 `lotus-miner sectors mypledgeonce` 触发新一轮的 AP 分配和调度。

下面的三种 miner 日志，存在任何一种，都表示这个 worker 不会接收任何工作任务：
```sh
$ cat miner.log |grep -a "didn't receive heartbeats for"|awk '{print $8}'|sort -rn|uniq -c

$ cat miner.log |grep -a "out of space "|awk '{print $8}'|sort -rn|uniq -c

$ cat miner.log |grep -a "trySchedMine skipping disabled worker "|awk '{print $9}'|sort -rn|uniq -c
```
对于这种 disabled worker 状态又不是断连，从调度程序的角度来看，disabled worker 和  out of space 一样的，不接收工作，更像是假死，而且 disabled 和 enabled 是互相动态变化的。
