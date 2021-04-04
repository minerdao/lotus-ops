ipAddress=$1
cat /etc/netplan/50-cloud-init.yaml <<'EOF'
network:
  version: 2
  ethernets:
    enp198s0f0:
      dhcp4: true
      dhcp6: true
    enp198s0f1:
      dhcp4: true
      dhcp6: true
    enp194s0:
      addresses: [$ipAddress/24]
      gateway4: 10.0.1.1
      nameservers:
        addresses: [202.106.0.20,114.114.114.114]
EOF

netplan apply