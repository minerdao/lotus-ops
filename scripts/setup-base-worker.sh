#!/bin/bash
# 关闭防火墙
systemctl stop ufw
systemctl disable ufw

# 关闭swap
sed -i  's/\/swap.img/#\/swap.img/' /etc/fstab

# apt 更新
apt-get update
apt-get upgrade

apt install net-tools -y

# 安装依赖包
apt update
apt install -y libhwloc-dev hwloc jq tree openssh-server python3 cpufrequtils

# 开启CPU性能模式
cpufreq-set -g performance
# 关闭更新
sed -i  's/1/0' /etc/apt/apt.conf.d/10periodic
# 重新生成kernel initramfs
update-initramfs -u

# 禁用显卡驱动更新
cat >> /etc/modprobe.d/blacklist-nouveau.conf <<EEE
blacklist nouveau
options nouveau modeset=0
EEE

# sudo配置
cat >>/etc/sudoers <<FFF
fil ALL=(ALL:ALL) ALL
FFF

# 时钟校验
apt install ntpdate -y
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
ntpdate ntp.aliyun.com

# SSD组raid0
currentUser=fil
mountPoint=/home/$currentUser/disk_md0

for i in {0..1};
do
ssd=/dev/nvme${i}n1
echo $ssd
parted -a optimal $ssd <<EOF
  rm 1
  rm 2
  rm 3
  mklabel gpt
  mkpart primary ext4 0% 100%
  set 1 raid on
  ignore
  quit
EOF
echo "${ssd} was fdisked"
sleep 1s
done

mdadm --verbose --create /dev/md0 --level=raid0 --raid-devices=2 /dev/nvme[0,1]n1p1 <<EOF
  y
EOF
echo "Raid0 array created"

mdadm -D /dev/md0

echo "Generate raid0 config"
mdadm -Dsv > /etc/mdadm/mdadm.conf

echo "Update initramfs"
update-initramfs -u

echo "Format"
mkfs.ext4 /dev/md0

sleep 30s

echo "Mount raid0"
mkdir $mountPoint
mount /dev/md0 $mountPoint

echo "Change owner & mod"
chown $currentUser:$currentUser $mountPoint

echo "Setup fstab"
uuid=$(blkid -o export /dev/md0 | awk 'NR==2 {print}')
echo "/dev/md0 ${mountPoint} ext4 defaults 0 0" >> /etc/fstab

# 配置网卡
ipAddress=$1
tee /etc/netplan/50-cloud-init.yaml <<-'EOF'
network:
  version: 2
  ethernets:
    enp198s0f0:
      dhcp4: true
      dhcp6: true
    enp198s0f1:
      dhcp4: true
      dhcp6: true
    enp194s0:
      dhcp: no
      addresses: [$ipAddress/24]
      gateway4: 10.0.1.1
      nameservers:
        addresses: [202.106.0.20,114.114.114.114]
EOF

netplan apply

# 配置hostname
hostname=$2
sed -i 's/127.0.0.1 fil/127.0.0.1 ${hostname}/g' /etc/hosts
sed -i 's/fil/${hostname}/g' /etc/hostname

# ./setup-base-worker.sh 10.0.1.11 WorkerP-10-0-1-11