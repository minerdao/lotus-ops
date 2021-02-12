# 部署Lotus节点

## 编译安装
### 安装基础依赖库
```sh
$ sudo apt update
$ sudo apt install mesa-opencl-icd ocl-icd-opencl-dev gcc git bzr jq pkg-config curl clang build-essential hwloc libhwloc-dev wget
$ sudo apt upgrade
```

### 安装 Golang
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

### 安装 Rust
```sh
$ curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o ./rust-setup.sh
$ chmod a+x ./rust-setup.sh
$ ./rust-setup.sh -y 
$ rm ./rust-setup.sh
$ source $HOME/.cargo/env
$ rustup default nightly
```
可直接运行本项目下的`./scripts/install-rust.sh`来安装Rust编译环境。

### 编译Lotus
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

## 启动节点
### 直接启动Lotus节点
```sh
$ lotus daemon
```
lotus daemon启动后，默认会在`~/.lotus`目录下初始化Lotus节点目录。
可在`lotus daemon`启动前，通过指定`LOTUS_PATH`环境变量来更改Lotus节点目录。

### 通过快照启动Lotus节点

## 节点常用操作
```sh
# 等待节点同步
$ lotus sync wait

# 查看节点同步状态
$ lotus sync status
```