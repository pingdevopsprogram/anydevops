#!/usr/bin/env sh

test -f /opt/out/instance/bin/jmeter-csv.csv && csv=$(cat /opt/out/instance/bin/jmeter-csv.csv)

echo "$csv"
echo "TRYING TO SEND RESULTS"
curl -X POST -H 'Content-type: application/json' --data '{"text":"'"${csv}"'"}' https://hooks.slack.com/services/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