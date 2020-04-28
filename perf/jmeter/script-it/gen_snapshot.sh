#!/usr/bin/env sh
# set -x 
SNAPFROM="${1}"
SNAPTO="${2}"
SNAPNAME="${3}"
EXTERNAL=

export SNAPFROM SNAPTO SNAPNAME

envsubst '$SNAPFROM $SNAPTO $SNAPNAME' < snapshotTemplate.json.subst > snapshotTemplate.json


while true ; do 
  snapResult=$(curl --location --request POST -k 'https://soak-monitoring.ping-devops.com/api/snapshots' \
    --header 'Authorization: Bearer eyJrIjoiZGFvMVhWSDJLVlFQNFlpWnZkUjNZdklNUjlKM1g4SVkiLCJuIjoic25hcGFkbWluIiwiaWQiOjF9' \
    --header 'Content-Type: application/json' \
    -m 3 -d @snapshotTemplate.json )
  test "${?}" -eq 0 && break
  sleep 1
done
rm snapshotTemplate.json
echo "${snapResult}" | jq -r '.url' | grep -o "/dashboard.*$"