#!/usr/bin/env bash

echo $(nvidia-smi -L)
echo $(df -hl | grep "disk_md0")
