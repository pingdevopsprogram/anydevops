#!/usr/bin/env sh

######
#
# DEPRECATED! doesn't save data. boooo. 
#####
set -x 
SNAPFROM="${1}"
SNAPTO="${2}"
SNAPNAME="${3}"
apiKey=$(cat .apiKey)


export SNAPFROM SNAPTO SNAPNAME

envsubst '$SNAPFROM $SNAPTO $SNAPNAME' < snapshotTemplate.json.subst > snapshotTemplate.json


while true ; do 
  tries=0
  snapResult=$(curl --location --request POST -k 'https://soak-monitoring.ping-devops.com/api/snapshots' \
    --header "Authorization: Bearer ${apiKey}" \
    --header 'Content-Type: application/json' \
    -m 3 -d @snapshotTemplate.json )
  test "${?}" -eq 0 && break
  tries=$((tries+1))
  test "${tries}" -gt 3 && exit 1
  sleep 1
done
rm snapshotTemplate.json
echo "${snapResult}" | jq -r '.url' | grep -o "/dashboard.*$"