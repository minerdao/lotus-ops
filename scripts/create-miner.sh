#!/usr/bin/env bash
set -x

let faucet
if [ -z $1 ]; then
  # faucet=https://faucet.testnet.filecoin.io/
  faucet=https://faucet.calibration.fildev.network/
else
  faucet=$1
fi

sectorSize=34359738368

owner=$(lotus wallet new bls)
result=$(curl -D - -XPOST -F "sectorSize=${sectorSize}" -F "address=$owner" $faucet/mkminer | grep Location)
query_string=$(grep -o "\bf=.*\b" <<<$(echo $result))

declare -A param
while IFS='=' read -r -d '&' key value && [[ -n "$key" ]]; do
  param["$key"]=$value
done <<<"${query_string}&"

lotus state wait-msg "${param[f]}"

maddr=$(curl "$faucet/msgwaitaddr?cid=${param[f]}" | jq -r '.addr')

lotus-miner init --actor=$maddr --owner=$owner
