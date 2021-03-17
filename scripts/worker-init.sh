#!/bin/bash
#关闭防火墙
systemctl stop ufw
systemctl disable ufw

#关闭swap
sed -i  's/\/swap.img/#\/swap.img/' /etc/fstab

#创建用户
password="abc.123"
username="caslx"
pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
useradd -m -p $pass $username
groupadd caslx
usermod -g caslx caslx

usermod -s /bin/bash caslx

#拷贝阿里apt源
mv /etc/apt/sources.list /etc/apt/sources.list.bat

mkdir /home/usb

mount -t vfat /dev/sdb1 /home/usb

cp /home/usb/sources.list /etc/apt/
#apt-get update
#apt-get upgrade


#安装依赖包
apt update
apt install -y make pkg-config mesa-opencl-icd ocl-icd-opencl-dev libclang-dev libhwloc-dev hwloc gcc git bzr jq tree openssh-server python3 cpufrequtils

#安装显卡
#cp /home/usb/NVIDIA-Linux-x86_64-460.32.03.run /home/caslx
#chmod +x /home/caslx/NVIDIA-Linux-x86_64-460.32.03.run
#cd /home/caslx/
#./NVIDIA-Linux-x86_64-460.32.03.run

#开启CPU性能模式
cpufreq-set -g performance
#关闭更新
sudo sed -i  's/1/0' /etc/apt/apt.conf.d/10periodic
#重新生成kernel initramfs
update-initramfs -u


#禁用显卡驱动更新
#sudo cat >> /etc/modprobe.d/blacklist-nouveau.conf <<EEE
#blacklist nouveau
#options nouveau modeset=0
#EEE

#时钟校验
apt install ntpdate -y
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
ntpdate ntp.aliyun.com




