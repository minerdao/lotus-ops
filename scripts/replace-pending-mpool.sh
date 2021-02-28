#!/bin/bash
# auto replace mpool gas fee

owner_id=$(lotus wallet default)

set -x
while true; do
	nonce=$(lotus mpool pending --local | jq '.[]|.Nonce' | head -1)
	if [ "$nonce" != "" ]; then
		lotus mpool replace --auto  --max-fee 250000000000000000  ${owner_id} ${nonce}
	fi
	sleep 10
done;