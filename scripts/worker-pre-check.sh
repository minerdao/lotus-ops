#!/usr/bin/env bash

echo $(nvidia-smi | grep "GeForce")
echo $(df -hl | grep "disk_md0")
