#!/bin/bash

API_URL="https://api.nordvpn.com/v2/servers?limit=0"

# Fetch JSON from API
json=$(curl -s "$API_URL")

# Output table header without updated_at
echo "| Name | Hostname | IP | Status | Load | Public Key | Port | Created_at |"
echo "|------|----------|----|--------|------|------------|------|------------|"

echo "$json" | jq -r '
  .servers[] |
  (.technologies[] | select(.id == 35) | .metadata[] | select(.name == "public_key") | .value) as $pubkey |
  (.technologies[] | select(.id == 51) | .metadata[] | select(.name == "port") | .value) as $port |
  (.ips[0].ip.ip) as $ip |
  [
    .name,
    .hostname,
    $ip,
    .status,
    (.load | tostring),
    $pubkey,
    $port,
    .created_at
  ] | @tsv
' | while IFS=$'\t' read -r name hostname ip status load pubkey port created_at; do
  # Escape pipe chars
  name=${name//|/\\|}
  hostname=${hostname//|/\\|}
  ip=${ip//|/\\|}
  status=${status//|/\\|}
  pubkey=${pubkey//|/\\|}
  port=${port//|/\\|}
  created_at=${created_at//|/\\|}
  echo "| $name | $hostname | $ip | $status | $load | $pubkey | $port | $created_at |"
done
