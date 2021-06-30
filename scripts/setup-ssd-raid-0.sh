#!/usr/bin/env bash
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

mdadm --verbose --create /dev/md0 --chunk=128 --level=raid0 --raid-devices=4 /dev/sd[a,b,c,d] <<EOF
  y
EOF
echo "Raid0 array created"

mdadm -D /dev/md0

echo "Generate raid0 config"
mdadm -Dsv > /etc/mdadm/mdadm.conf

echo "Update initramfs"
update-initramfs -u

echo "Format"
mkfs.xfs -f -d agcount=128,su=128k,sw=2 -r extsize=256k /dev/md0

sleep 30s

echo "Mount raid0"
mkdir $mountPoint
mount /dev/md0 $mountPoint

echo "Change owner & mod"
chown $currentUser:$currentUser $mountPoint

echo "Setup fstab"
uuid=$(blkid -o export /dev/md0 | awk 'NR==2 {print}')
echo "${uid} ${mountPoint} xfs defaults 0 0" >> /etc/fstab