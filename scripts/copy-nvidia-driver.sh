#!/usr/bin/env bash

driverFile=$1

for i in h1{11..20};
do
  scp -r $driverFile fil@$i:~/
done

# commit worker
for i in h2{11..15};
do
  scp -r $driverFile fil@$i:~/
done

