#!/usr/bin/env bash

for i in h1{16..20};
do
  ssh-keyscan $i >> ~/.ssh/known_hosts
  ssh-copy-id -f fil@$i
done

# commit worker
for i in h2{11..15};
do
  ssh-keyscan $i >> ~/.ssh/known_hosts
  ssh-copy-id fil@$i
done

# miner
for i in m{10..14};
do
  ssh-keyscan $i >> ~/.ssh/known_hosts
  ssh-copy-id fil@$i
done
