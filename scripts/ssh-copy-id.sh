#!/usr/bin/env bash
for i in m50 m51
do
  ssh-keyscan $i >> ~/.ssh/known_hosts
  ssh-copy-id $i
done

for i in w{60..78};
do
  ssh-keyscan $i >> ~/.ssh/known_hosts
  ssh-copy-id $i
done

# commit worker
for i in w{80..84};
do
  ssh-keyscan $i >> ~/.ssh/known_hosts
  ssh-copy-id $i
done
