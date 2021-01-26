#!/bin/bash
sudo apt update
sudo apt install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible

echo "# ansible alias" >> ~/.profile
echo "alias an=/usr/bin/ansible" >> ~/.profile
echo "alias ap=/usr/bin/ansible-playbook" >> ~/.profile
source ~/.profile
