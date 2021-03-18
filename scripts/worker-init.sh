#!/bin/bash
#关闭防火墙
systemctl stop ufw
systemctl disable ufw

#关闭swap
sed -i  's/\/swap.img/#\/swap.img/' /etc/fstab

cat > /etc/apt/sources.list <<EOF
deb http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse
EOF


#安装依赖包
apt update
apt install -y make pkg-config mesa-opencl-icd ocl-icd-opencl-dev libclang-dev libhwloc-dev hwloc gcc git bzr jq tree openssh-server python3 cpufrequtils


#开启CPU性能模式
cpufreq-set -g performance
#关闭更新
sed -i  's/1/0' /etc/apt/apt.conf.d/10periodic
#重新生成kernel initramfs
# update-initramfs -u


#禁用显卡驱动更新
cat >> /etc/modprobe.d/blacklist-nouveau.conf <<EEE
blacklist nouveau
options nouveau modeset=0
EEE

#时钟校验
apt install ntpdate -y
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
ntpdate ntp.aliyun.com




