#!/bin/bash
# disable ufw
systemctl stop ufw
systemctl disable ufw

# close swap
sed -i  "s/\/swap.img/#\/swap.img/" /etc/fstab

apt install net-tools -y

# install dep
apt update
apt install -y gcc make libhwloc-dev hwloc jq tree fio cpufrequtils

# CPU performance
cpufreq-set -g performance
# close upgrade
sed -i  's/1/0' /etc/apt/apt.conf.d/10periodic
# recreate kernel initramfs
update-initramfs -u

# disable nvidia update
cat >> /etc/modprobe.d/blacklist-nouveau.conf <<EEE
blacklist nouveau
options nouveau modeset=0
EEE

# sudoers config
cat >>/etc/sudoers <<FFF
fil ALL=(ALL:ALL) ALL
FFF

# extend lv
# lvextend  -L  +150G /dev/mapper/ubuntu--vg-ubuntu--lv
# resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv

# ntp update
apt install ntpdate -y
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
ntpdate ntp.aliyun.com

# setup netplan
tee /etc/netplan/00-installer-config.yaml <<'EOF'
network:
  version: 2
  ethernets:
    eno1:
      addresses:
      - 10.0.1.27/24
      gateway4: 10.0.1.1
      nameservers:
        addresses:
        - 114.114.114.114
    enp65s0:
      addresses:
      - ipAddress/24
      gateway4: 10.0.99.1
      nameservers:
        addresses:
        - 114.114.114.114
EOF

ipaddress=$1
sed -i "s/ipAddress/${ipaddress}/g" /etc/netplan/00-installer-config.yaml

netplan apply

# setup hostname
hostname=$2
sed -i "s/fil/${hostname}/g" /etc/hosts
sed -i "s/fil/${hostname}/g" /etc/hostname
hostname ${hostname}

cat /etc/netplan/00-installer-config.yaml
cat /etc/hosts
cat /etc/hostname

# sudo ./setup-daemon.sh 10.0.99.10 Daemon-10-0-99-10
