# Filecoin节点搭建及启动

## 1. 编译安装
### 1.1 安装基础依赖库
```sh
$ sudo apt update
$ sudo apt install mesa-opencl-icd ocl-icd-opencl-dev gcc git bzr jq pkg-config curl clang build-essential hwloc libhwloc-dev wget
$ sudo apt upgrade
```

### 1.2 安装 Golang
```sh
# 下载golang安装包
$ wget -c https://golang.org/dl/go1.15.8.linux-amd64.tar.gz
$ tar -xvf go1.15.8.linux-amd64.tar.gz

$ sudo chown -R root:root ./go
$ sudo rm -rfv /usr/local/go
$ sudo mv go /usr/local

# GOPATH写入环境变量
$ echo "GOPATH=$HOME/go" >> $HOME/.profile
$ echo "export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin" >> $HOME/.profile

# 国内网络环境，可以配置goproxy代理，不然编译会非常慢
# echo "export GOPROXY=https://goproxy.cn" >> $HOME/.profile

# 使环境变量生效
$ source $HOME/.profile

# 查看golang版本
$ go version
```
可直接运行本项目下的`./scripts/install-golang.sh`来安装Golang编译环境。

### 1.3 安装 Rust
```sh
$ curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o ./rust-setup.sh
$ chmod a+x ./rust-setup.sh
$ ./rust-setup.sh -y 
$ rm ./rust-setup.sh
$ source $HOME/.cargo/env
$ rustup default nightly
```
可直接运行本项目下的`./scripts/install-rust.sh`来安装Rust编译环境。

### 1.4 编译Lotus
```sh
$ git clone https://github.com/filecoin-project/lotus.git

# 切换到当前的稳定版本
# 查看稳定版本: https://github.com/filecoin-project/lotus/tags
$ cd lotus
$ git fetch origin
$ git reset --hard v1.4.1

# 针对AMD CPU
env RUSTFLAGS="-C target-cpu=native -g" FFI_BUILD_FROM_SOURCE=1 make clean all

# 针对Intel CPU
env CGO_CFLAGS_ALLOW="-D__BLST_PORTABLE__" RUSTFLAGS="-C target-cpu=native -g" FFI_BUILD_FROM_SOURCE=1 CGO_CFLAGS="-D__BLST_PORTABLE__" make clean all
```
可直接运行本项目下的`./scripts/build-amd.sh`和`./scripts/build-intel.sh`来针对AMD和Intel的CPU分别编译。

## 2. 启动节点
### 2.1 直接启动Lotus节点
```sh
$ lotus daemon
```
lotus daemon启动后，默认会在`~/.lotus`目录下初始化Lotus节点目录。
可在`lotus daemon`启动前，通过指定`LOTUS_PATH`环境变量来更改Lotus节点目录。

### 2.2 通过快照启动Lotus节点
通过以下命令，从现有节点上导出Lotus快照。
```sh
$ lotus chain export --skip-old-msgs --recent-stateroots=2000 snapshot.car
```

通过以下命令，导入到现有节点，需要注意：
- 导入同步数据（在此之前保证`.lotus`目录中的内容是空的）；
- 导入数据之后， daemon 默认自动启动；
- 如果不想在导入数据之后自动启动 daemon，可以加上参数 `--halt-after-import`；

```sh
$ lotus daemon --import-snapshot snapshot.car
```

## 3. 更新配置文件
Daemon配置文件默认在`~/.lotus/config.toml`文件中, 若配置了`$LOTUS_PATH`环境变量，则在此路径下。
把下面的`DAEMON_IP_ADDRESS`改成Deamon本机的内网IP地址，并指定一个端口，默认端口是`1234`。
```toml
[API]
ListenAddress = "/ip4/<DAEMON_IP_ADDRESS>/tcp/1234/http"
#  RemoteListenAddress = ""
#  Timeout = "30s"
```

## 4. 节点常用操作
```sh
# 等待节点同步
$ lotus sync wait

# 查看节点同步状态
$ lotus sync status
```
更多节点操作查看[节点操作](./documents/daemon-operation.md)章节。