#!/usr/bin/env bash
for i in h1{81..99}
do
  ssh-keyscan $i >> ~/.ssh/known_hosts
#  ssh-copy-id $i
ssh-copy-id -i /home/caslx/.ssh/id_rsa.pub caslx@$i
done

# for i in h2{17..32};
# do
#   ssh-keyscan $i >> ~/.ssh/known_hosts
#   ssh-copy-id $i
# done
