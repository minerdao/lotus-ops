#!/bin/bash
srcPath=/home/filguard/disk_md0/test/
backupPath=/home/filguard/disk_md0/backup
backupUser=filguard
backupHost=192.168.1.60

inotifywait -mrq -e create,close_write,move,delete,modify $srcPath | while read a b c
do
  rsync -azP --delete $srcPath $backupUser@$backupHost:$backupPath
done