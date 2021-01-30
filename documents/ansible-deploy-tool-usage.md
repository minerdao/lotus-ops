# Ansible部署工具使用

## 1. 安装Ansible
- 在管理机器上安装Ansible，[参照安装文档](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-ubuntu)；
- 在管理机器的`/etc/hosts`中配置远程目标机器的IP和主机名映射关系，例如：
  ```
  # Miner
  192.168.1.11 postminer
  192.168.1.12 sealminer

  # Workers
  192.168.1.65 w65
  192.168.1.66 w66
  192.168.1.67 w67
  192.168.1.68 w68
  192.168.1.69 w69
  192.168.1.70 w70
  ```
- 在要部署的远程目标机器上，安装Python环境；
- 配置管理机器到远程目标机器的SSH免密码登录；
  ```sh
  $ ssh-keyscan <remote-server>> >> ~/.ssh/known_hosts
  $ ssh-copy-id <remote-server>>
  # 其中<remote-server>为远程目标机器的主机名，可以使用脚本批量处理
  ```

## 2. 配置Ansible环境变量
根据自己的实际环境，修改管理机器的Ansible环境变量配置文件`sudo vi /etc/ansible/hosts`:
```
[public-daemon]
192.168.1.10

[window-post-miner]
192.168.1.11

[winning-post-miner]
192.168.1.12

[seal-miner]
192.168.1.13

[precommit-worker]
192.168.1.[20:50]

[commit-worker]
192.168.1.[60:80]

[all:vars]
remote_user=filguard

# fil proofs 环境变量
fil_proofs_param_path=/home/filguard/disk_md0/proofs_param/v28
fil_proofs_parent_cache=/home/filguard/disk_md0/cache/parent
fil_proofs_maximize_caching=1
fil_proofs_use_gpu_column_builder=1
fil_proofs_use_gpu_tree_builder=1

# Rust环境变量
rust_log=trace
rust_backtrace=full

# Repo环境变量
lotus_path=/home/filguard/disk_md0/lotus
lotus_miner_path=/home/filguard/disk_md0/lotusminer
lotus_worker_path_0=/home/filguard/disk_md0/lotusworker0
lotus_worker_path_1=/home/filguard/disk_md0/lotusworker1
log_path=/home/filguard/disk_md0/logs
tmp_dir=/home/filguard/disk_md0/tmp
worker_port=3456
workspace=/home/filguard/workspace

# C2 优化后的环境变量
num_handles=15
num_kernels=2

# 扇区分配Miner的IP和端口
sector_counter_host=192.168.1.11
sector_counter_port=1357

# 替换为Daemon的token和listenAddress
fullnode_api_info=<token>:<address>

# 替换为Miner的token和listenAddress
seal_miner_api_info=<token>:<address>
```

## 2. 部署准备
#### 2.1 设置Ansible别名
在管理机器上，将ansible和ansible-playbook分别设置`an`和`ap`的别名，方便快捷操作：

```sh
$ echo "alias an=/usr/bin/ansible" >> $HOME/.profile
$ echo "alias ap=/usr/bin/ansible-playbook" >> $HOME/.profile
```
#### 2.2 Clone工作目录
将本项目clone至`$HOME/workspace`目录下。
```sh
$ mkdir -p $HOME/workspace
$ cd $HOME/workspace
$ git clone https://github.com/fileguard/lotus-ops.git
```

## 3. Ansible部署脚本使用说明

**注意：以下所有操作都需切换到`$HOME/workspace/lotus-ops/ansible`目录下：**
```sh
$ cd $HOME/workspace/lotus-ops/ansible
```

#### 拷贝二进制文件到worker
```sh
$ ap copy-bin-to-worker.yaml -k -K
# 需要输入worker的ssh远程登录密码
```

#### 启动 Deamon
```sh
$ ap 0-start-daemon.yaml
```

#### 启动 Window-PoSt-Miner
```sh
$ ap 1-start-window-post-miner.yaml
```

#### 启动 Winning-PoSt-Miner
```sh
$ ap 2-start-winning-post-miner.yaml
```

#### 启动 Precommit Worker
```sh
$ ap 5-start-precommit-worker.yaml
```

#### 启动 Commit Worker
```sh
$ ap 6-start-commit-worker.yaml
```

#### 停止Worker
```sh
# 停止 precommit worker
$ ap stop-precommit-worker.yaml
# 停止 commit worker
$ ap stop-commit-worker.yaml
```