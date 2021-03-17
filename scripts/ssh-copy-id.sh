#!/usr/bin/env bash
for i in h2{17..32}
do
  ssh-keyscan $i >> ~/.ssh/known_hosts
  ssh-copy-id $i
done

# for i in h2{17..32};
# do
#   ssh-keyscan $i >> ~/.ssh/known_hosts
#   ssh-copy-id $i
# done
