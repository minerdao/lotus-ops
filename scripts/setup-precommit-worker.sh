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

# ntp update
apt install ntpdate -y
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
ntpdate time.windows.com

# SSD make raid0
currentUser=root
mountPoint=/mnt/md0

for i in {b,c,d,e};
do
ssd=/dev/sd${i}
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

mdadm --create --verbose /dev/md0 --chunk=128 --level=0 --raid-devices=5 /dev/sd[b,c,d,e] <<EOF
  y
EOF
echo "Raid0 array created"

mdadm -D /dev/md0

echo "Generate raid0 config"
mdadm -Dsv > /etc/mdadm/mdadm.conf

echo "Update initramfs"
update-initramfs -u

echo "Format"
mkfs.xfs -f -d agcount=128,su=128k,sw=5 -r extsize=640k /dev/md0

# sudo mkfs.xfs -f -d agcount=128,su=128k,sw=2 -r extsize=256k  /dev/md0
# mkfs.xfs -f -d agcount=128,su=128k,sw=5 -r extsize=640k /dev/md0

sleep 10s

echo "Mount raid0"
mkdir $mountPoint
mount /dev/md0 $mountPoint

echo "Change owner & mod"
chown $currentUser:$currentUser $mountPoint

echo "Setup fstab"
uuid=$(blkid -o export /dev/md0 | awk 'NR==2 {print}')
echo "${uuid} ${mountPoint} xfs defaults 0 0" >> /etc/fstab

# setup netplan
tee /etc/netplan/00-installer-config.yaml <<'EOF'
network:
  version: 2
  ethernets:
    eno1:
      addresses:
      - ipAddress/24
      gateway4: 10.0.1.1
      nameservers:
        addresses:
        - 114.114.114.114
    enp66s0:
      addresses:
      - ipAddress/24
      gateway4: 10.0.1.1
      nameservers:
        addresses:
        - 114.114.114.114
EOF

ipaddress=$1
sed -i "s/ipAddress/${ipaddress}/g" /etc/netplan/00-installer-config.yaml

netplan apply

# setup hostname
hostname=$2
sed -i "s/root/${hostname}/g" /etc/hosts
sed -i "s/root/${hostname}/g" /etc/hostname
hostname ${hostname}

cat /etc/netplan/00-installer-config.yaml
cat /etc/hosts
cat /etc/hostname

# sudo ./setup-precommit-worker.sh 10.0.1.11 WorkerP-10-0-1-11
