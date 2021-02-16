# 常用环境变量说明

## 1. 通用环境变量
- `FIL_PROOFS_PARAMETER_CACHE`：proof 证明参数路径，默认在`/var/tmp/filecoin-proof-parameters`下。
  ```sh
  export FIL_PROOFS_PARAMETER_CACHE=/home/user/nvme_disk/filecoin-proof-parameters
  ```
- `FFI_BUILD_FROM_SOURCE`：从源码编译底层库。
  ```sh
  export FFI_BUILD_FROM_SOURCE=1
  ```
- `IPFS_GATEWAY`：配置证明参数下载的代理地址。
  ```sh
  export IPFS_GATEWAY=https://proof-parameters.s3.cn-south-1.jdcloud-oss.com/ipfs/
  ```
- `TMPDIR`：临时文件夹路径，用于存放显卡锁定文件。
  ```sh
  export TMPDIR=/home/user/nvme_disk/tmp
  ```
- `RUST_LOG`：配置Rust日志级别。
  ```sh
  export RUST_LOG=Debug
  ```
- `GOPROXY`：配置Golang代理。
  ```sh
  export GOPROXY=https://goproxy.cn
  ```

## 2. Lotus Deamon环境变量
- `LOTUS_PATH`：lotus daemon 路径，例如：
  ```sh
  export LOTUS_PATH=/home/user/nvme_disk/lotus
  ```

## 3. Lotus Miner环境变量
- `LOTUS_MINER_PATH`：lotus miner 路径，例如：
  ```sh
  export LOTUS_MINER_PATH=/home/user/nvme_disk/lotusminer
  ```
- `FULLNODE_API_INFO`：lotus daemon API 环境变量；
  ```sh
  export FULLNODE_API_INFO=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJBbGxvdyI6WyJyZWFkIiwid3JpdGUiLCJzaWduIiwiYWRtaW4iXX0.JSdq-OviNQW2dZslvyargJsqgLrlYCjoZCIFkb2u96g:/ip4/192.168.1.10/tcp/1234/http
  ```
- `BELLMAN_CUSTOM_GPU`：指定GPU型号；

## 4. Lotus Worker环境变量
- `LOTUS_WORKER_PATH`：Lotus worker 路径；
  ```sh
  export LOTUS_WORKER_PATH=/home/user/nvme_disk/lotusworker
  ```
- `FIL_PROOFS_MAXIMIZE_CACHING`：最大化内存参数；
  ```sh
  export FIL_PROOFS_MAXIMIZE_CACHING=1
  ```
- `FIL_PROOFS_USE_MULTICORE_SDR`：CPU多核心绑定；
  ```sh
  export FIL_PROOFS_USE_MULTICORE_SDR=1
  ```
- `FIL_PROOFS_USE_GPU_TREE_BUILDER`：使用GPU计算Precommit2 TREE hash
  ```sh
  export FIL_PROOFS_USE_GPU_TREE_BUILDER=1
  ```
- `FIL_PROOFS_USE_GPU_COLUMN_BUILDER`：使用GUP计算Precommit2 COLUMN hash；
  ```sh
  export FIL_PROOFS_USE_GPU_COLUMN_BUILDER=1
  ```
- `BELLMAN_NO_GPU`：不使用GPU计算Commit2；
  - 如果要启用 GPU，则不能让这个环境变量（BELLMAN_NO_GPU）出现在系统的环境变量中（env）;
  - 如果它出现在 env 中，则需要使用`unset BELLMAN_NO_GPU`命令取消，因为设置 `export BELLMAN_NO_GPU=0` 无效；
  ```sh
  export BELLMAN_NO_GPU=1
  ```
- `MINER_API_INFO`：Lotus miner的API信息；
  ```sh
  export MINER_API_INFO=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJBbGxvdyI6WyJyZWFkIiwid3JpdGUiLCJzaWduIiwiYWRtaW4iXX0.JSdq-OviNQW2dZslvyargJsqgLrlYCjoZCIFkb2u96g:/ip4/192.168.1.10/tcp/1234/http
  ```
- `BELLMAN_CUSTOM_GPU`：指定Commit2的GPU型号；
  ```sh
  export BELLMAN_CUSTOM_GPU="GeForce RTX 2080 Ti:4352"
  ```