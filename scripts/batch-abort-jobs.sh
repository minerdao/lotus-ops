#!/bin/bash

while read line
do
  jobId=`echo $line | awk '{print $1}'`
  sectorId=`echo $line | awk '{print $2}'`
  lotus-miner sealing abort $jobId
  echo "Job ${jobId} aborted" 
  sleep 3
  lotus-miner sectors remove --really-do-it $sectorId
  echo "Sector ${sectorId} removed"
  sleep 5
done < jobs.txt