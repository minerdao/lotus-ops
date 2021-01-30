# Ansible部署工具使用

## 1. 安装并配置环境变量
使用 Ansible部署前，需要先在管理机器上安装 Ansible，并配置好 Ansible 系统环境变量，修改配置文件`/etc/ansible/hosts`:

```sh
[daemon]
192.168.1.10

[miner]
192.168.1.11

[worker-precommit]
192.168.1.[20:50]

[worker-commit]
192.168.1.[60:80]

[all:vars]
fil_proofs_param_path=/home/root/disk_md0/proofs_param/v28
fil_proofs_use_gpu_column_builder=0
fil_proofs_use_gpu_tree_builder=0
lotus_path=/home/root/disk_md0/lotus
lotus_miner_path=/home/root/disk_md0/lotusminer
lotus_worker_path=/home/root/disk_md0/lotusworker
log_path=/home/root/disk_md0/logs
workerport=3456

# 替换为Daemon的token和listenAddress
fullnode_api_info=<token>:<address>

# 替换为Miner的token和listenAddress
miner_api_info=<token>:<address>

```

## 2. 部署准备
#### 2.1 设置Ansible别名
在管理机器上，将ansible和ansible-playbook分别设置`an`和`ap`的别名，方便快捷操作：

```sh
$ echo "alias an=/usr/bin/ansible" >> $HOME/.profile
$ echo "alias ap=/usr/bin/ansible-playbook" >> $HOME/.profile
```
#### 2.2 创建工作目录
```sh
$ mkdir -p $HOME/workspace
$ cd $HOME/workspace
$ git clone https://github.com/fileguard/lotus-ops.git
```

## 3. Ansible部署脚本使用说明

注意：以下所有操作都需切换到`$HOME/workspace/lotus-ops/ansible`目录下：
```sh
cd $HOME/workspace/lotus-ops/ansible
```

#### 拷贝二进制文件到worker
```sh
$ ap copy-bin-to-worker.yaml -k -K
# 需要输入worker的ssh密码
```

#### 启动Miner
```sh
$ ap start-seal-miner.yaml
```

#### 启动Precommit Worker
```sh
$ ap start-precommit-worker.yaml
```

#### 启动Commit Worker
```sh
$ ap start-commit-worker.yaml
```

#### 停止Worker
```sh
# 停止 precommit worker
$ ap stop-precommit-worker.yaml
# 停止 commit worker
$ ap stop-commit-worker.yaml
```