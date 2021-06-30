#!/usr/bin/env bash

echo $(nvidia-smi | grep "GeForce")
echo $(df -hl | grep "md0")
echo "内存："$(free -g | grep Mem | awk '{print $2}')G
