#!/usr/bin/env sh
campaign=${1}
test ! -f "${campaign}" && echo "campaign not found" && exit 1
campaignName=$(basename "${campaign}" | cut -f 1 -d '.')
if test -n "${2}"; then 
  resultsFile="${2}"
else
  resultsFile="results/dg/${campaignName}.txt"
fi

# campaignJson=$(cat "$campaign")
# testDuration=$(echo "${campaignJson}" | jq -r '.testDuration')



touch "${resultsFile}"
echo "Starting campaign run: $campaignName:" >> "${resultsFile}"
for i in 1 2; do 
  echo "Start run $i now:" >> "${resultsFile}"
  ./run_tests.sh -t "${campaign}" -o "${resultsFile}"
done