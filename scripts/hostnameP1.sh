#!/bin/bash
apt install net-tools -y
IP=`ifconfig |grep broadcast |awk '{print $2}'`
IP01=`ifconfig |grep broadcast |awk '{print $2}'|awk -F. '{print $1}'`
IP02=`ifconfig |grep broadcast |awk '{print $2}'|awk -F. '{print $2}'`
IP03=`ifconfig |grep broadcast |awk '{print $2}'|awk -F. '{print $3}'`
IP04=`ifconfig |grep broadcast |awk '{print $2}'|awk -F. '{print $4}'`

echo "WorkerP-$IP01-$IP02-$IP03-$IP04" >/etc/hostname
echo "WorkerP-$IP01-$IP02-$IP03-$IP04" >>/etc/hosts

