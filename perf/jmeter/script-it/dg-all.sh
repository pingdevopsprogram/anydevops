#!/usr/bin/env sh

kubectl scale sts pingdatagovernance --replicas=1
echo "scaling down"
sleep 20

./run_campaigns.sh campaigns/dg/openbanking-1dg.json && \
./run_campaigns.sh campaigns/dg/postapi-1dg.json

kubectl scale sts pingdatagovernance --replicas=2
echo "scaling up"
sleep 120

./run_campaigns.sh campaigns/dg/openbanking-2dg.json && \
./run_campaigns.sh campaigns/dg/postapi-2dg.json


kubectl scale sts pingdatagovernance --replicas=3
echo "scaling up"
sleep 120

./run_campaigns.sh campaigns/dg/openbanking-3dg.json && \
./run_campaigns.sh campaigns/dg/postapi-3dg.json 