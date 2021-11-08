#!/bin/bash

sectorId=$1
if [ ! -n "$sectorId" ]; then
  echo "Sector id missing"
else
  lotus-miner sectors remove --really-do-it $sectorId
  echo "Sector ${sectorId} removed"
fi