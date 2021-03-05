#!/usr/bin/env bash
workspace=$HOME/workspace

cd $workspace &&
wget -c https://golang.org/dl/go1.16.linux-amd64.tar.gz &&
tar -xvf go1.16.linux-amd64.tar.gz

sudo chown -R root:root ./go
sudo rm -rfv /usr/local/go
sudo mv go /usr/local

echo "GOPATH=$HOME/go" >> $HOME/.profile
echo "export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin" >> $HOME/.profile
# echo "export GOPROXY=https://goproxy.cn" >> $HOME/.profile

source $HOME/.profile
go version