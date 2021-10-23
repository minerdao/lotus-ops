#!/usr/bin/env bash

echo $(nvidia-smi -L | grep "GeForce") "||" echo "Raid:"$(df -hl | grep "disk_md0" | awk '{print $2}') "||" echo "内存:"$(free -g | grep Mem | awk '{print $2}')G