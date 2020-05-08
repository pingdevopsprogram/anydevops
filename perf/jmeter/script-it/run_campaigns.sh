#!/usr/bin/env sh
campaign=${1}
test ! -f "${campaign}" && echo "campaign not found" && exit 1
campaignName=$(basename "${campaign}" | cut -f 1 -d '.')
resultsFile="results/${campaignName}.txt"

# campaignJson=$(cat "$campaign")
# testDuration=$(echo "${campaignJson}" | jq -r '.testDuration')



touch "${resultsFile}"
echo "Starting campaign run: $campaignName:" >> "${resultsFile}"
for i in 1 2 3; do 
  echo "Start run $i now:" >> "${resultsFile}"
  ./run_tests.sh -t "${campaign}" -o "${resultsFile}"
done