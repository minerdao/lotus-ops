# Lotus日常运维CheckList

- [ ] **硬件设备日常运行状态监控**
- [ ] **币值余额检查 `lotus-miner actor control list`**
- [ ] **lotus daemon 区块同步检查 `lotus sync wait`**
- [ ] **消息堵塞检查与疏通**
  `lotus mpool pending -local | grep Message | wc -l`
- [ ] 异常状态扇区处理 `lotus-miner info`
  - PreCommitFailed: `lotus-miner sectors update-state --really-do-it XXX Removing`
  - CommitFailed: `lotus-miner sectors update-state --really-do-it XXX Committing`
  - SealPreCommit1Failed: `lotus-miner sectors update-state --really-do-it XXX Removing`
- [ ] 调度程序工作问题排查（繁忙时命令会有所堵塞）
  `lotus-miner sealing jobs 与 lotus-miner sealing workers | grep hostname`
- [ ] 掉线的 lotus-worker 检查
  - `lotus-miner storage list`
  - `lotus-miner sealing workers | grep hostname | sort -k4`: 是否有`disable`状态
- [ ] 掉算力问题排查与恢复
- [ ] 定时任务脚本程序运行状态检查
  `ps -ef | grep 程序名称`