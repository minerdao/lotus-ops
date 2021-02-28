# Filecoin日常运维CheckList

- [ ] **硬件设备日常运行状态监控**
- [ ] **钱包余额检查，及时提醒充币** `lotus-miner actor control list`
- [ ] **lotus daemon 区块同步检查** `lotus sync wait`
- [ ] **掉线的 lotus-worker 检查**
  - `lotus-miner storage list`
  - `lotus-miner sealing workers | grep hostname | sort -k4`: 是否有`disable`状态
- [ ] **消息堵塞检查与疏通**
  `lotus mpool pending -local | grep Message | wc -l`
- [ ] **调度程序工作问题排查**
  `lotus-miner sealing jobs 与 lotus-miner sealing workers | grep hostname`
- [ ] **时空证明日常检查**
  - Miner机器证明文件（证明文件目录中文件是否存在）
  - 时空证明的账户是否有消息堵塞
  - 节点机器使用`lotus sync wait`，查看是否同步到最新高度
  - 检查显卡驱动，`nvidia-smi`看一下驱动是否正常
  - 查看Miner进程（`lotus-miner sealing job`看进程在不在）
- [ ] 异常状态扇区处理 `lotus-miner info`
  - PreCommitFailed: `lotus-miner sectors remove --really-do-it <sectorId>`
  - SealPreCommit1Failed: `lotus-miner sectors remove --really-do-it <sectorId>`
  - CommitFailed: `lotus-miner sectors update-state --really-do-it <sectorId> Committing`
- [ ] 掉算力问题排查与恢复
- [ ] 定时任务脚本程序运行状态检查
  `ps -ef | grep 程序名称`
