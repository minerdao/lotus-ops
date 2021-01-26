#!/usr/bin/env bash
mount_path=/home/cs/disk_md0

for i in {0..5};
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

mdadm --verbose --create /dev/md0 --level=raid0 --raid-devices=6 /dev/nvme[0,1,2,3,4,5]n1p1 <<EOF
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
mkdir $mount_path
mount /dev/md0 $mount_path

echo "Change owner & mod"
chown cs:cs $mount_path

echo "Setup fstab"
uuid=$(blkid -o export /dev/md0 | awk 'NR==2 {print}')
echo "${uuid} ${mount_path} ext4 defaults 0 0" >> /etc/fstab