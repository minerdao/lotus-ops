#!/bin/bash

P1_MAX=70

while true
do
  totalP1=$(lotus-miner sectors list --fast | grep "PreCommit1" | wc -l)
  willPledge=$((${P1_MAX} - ${totalP1}))

  if [ ${willPledge} -gt 0 ]
  then
    echo "Will pledge ${willPledge} sectors"
    for ((i=0; i<$willPledge; i++))
    do
      lotus-miner sectors pledge
      echo "Pledge sector ${i}"
      sleep 30s
    done
    sleep 3600s
  fi

  sleep 60s
done
