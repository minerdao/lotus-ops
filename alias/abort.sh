#!/bin/bash

sectorId=$1

if [ ! -n "$sectorId" ]; then
  echo "Sector id missing"
else
  lotus-miner sealing abort $sectorId
  echo "Sector ${sectorId} aborted"
fi
