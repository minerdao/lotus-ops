#!/bin/bash
# disable ufw
systemctl stop ufw
systemctl disable ufw

# close swap
sed -i  "s/\/swap.img/#\/swap.img/" /etc/fstab

apt install net-tools -y

# install dep
apt update
apt install -y gcc make libhwloc-dev hwloc jq tree openssh-server python3 cpufrequtils

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

# ntp update
apt install ntpdate -y
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
ntpdate ntp.aliyun.com

# SSD make raid0
currentUser=fil
mountPoint=/home/$currentUser/disk_md0

for i in 0 1;
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
echo "${uuid} ${mountPoint} ext4 defaults 0 0" >> /etc/fstab

# setup netplan
tee /etc/netplan/50-cloud-init.yaml <<'EOF'
network:
  version: 2
  ethernets:
    enp197s0f0:
      dhcp4: true
      dhcp6: true
    enp197s0f1:
      dhcp4: true
      dhcp6: true
    enp193s0:
      addresses: [ipAddress/24]
      gateway4: 10.0.1.1
      nameservers:
        addresses: [114.114.114.114]
EOF

ipaddress=$1
sed -i "s/ipAddress/${ipaddress}/g" /etc/netplan/50-cloud-init.yaml

netplan apply

# setup hostname
hostname=$2
sed -i "s/fil/${hostname}/g" /etc/hosts
sed -i "s/fil/${hostname}/g" /etc/hostname

cat /etc/netplan/50-cloud-init.yaml
cat /etc/hosts
cat /etc/hostname


lvextend  -L  +150G /dev/mapper/ubuntu--vg-ubuntu--lv
resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv

# sudo ./setup-precommit-worker.sh 10.0.1.11 WorkerP-10-0-1-11
# https://cs-cn-filecoin.oss-cn-beijing.aliyuncs.com/filguard/amd-7302-ubuntu-1804/lotus-v1.5.0-ubuntu18.04-amd-7302.tar
