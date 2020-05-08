#!/usr/bin/env sh
apiKey=$(cat .apiKey)
snaps=$(curl --location -k --request GET 'https://soak-monitoring.ping-devops.com/api/dashboard/snapshots' \
--header "Authorization: Bearer ${apiKey}")

iterations=$(echo "${snaps}" | jq -r '. | length')

for i in $(seq "${iterations}") ; do 
  deleteKey=$(echo "${snaps}" | jq -r ".[$i].key") 
  # echo $deleteKey
  curl --location -k --request DELETE "https://soak-monitoring.ping-devops.com/api/snapshots/${deleteKey}"\
    --header "Authorization: Bearer ${apiKey}"
done
  