#!/bin/bash
srcPath=$1
backupPath=$2
backupUser=$3
backupHost=$4

inotifywait -mrq -e create,close_write,move,delete,modify $srcPath | while read a b c
do
  rsync -azP --delete $srcPath $backupUser@$backupHost:$backupPath
done