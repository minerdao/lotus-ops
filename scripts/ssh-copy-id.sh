#!/usr/bin/env bash
for i in h211 h212 h215 h216
do
  ssh-keyscan $i >> ~/.ssh/known_hosts
  ssh-copy-id $i
done

for i in h1{11..19};
do
  ssh-keyscan $i >> ~/.ssh/known_hosts
  ssh-copy-id $i
done
