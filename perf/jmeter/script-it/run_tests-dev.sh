#!/usr/bin/env sh

# json=$(cat tests.json  | jq '.')
iterations=$(cat tests.json  | jq -r '.tests[-1].id')

echo "num tests = $((iterations+1))"

for i in $(seq 0 "${iterations}"); do 
  export THREADS=$(cat tests.json  | jq -r ".tests[$i].THREADS")
  export REPLICAS=$(cat tests.json  | jq -r ".tests[$i].REPLICAS")
  export NAMESPACE=$(cat tests.json  | jq -r ".tests[$i].NAMESPACE")
  export HEAP=$(cat tests.json  | jq -r ".tests[$i].HEAP")
  export CPUS=$(cat tests.json  | jq -r ".tests[$i].CPUS")
  export MEM=$(cat tests.json  | jq -r ".tests[$i].MEM")
  
  if test "${HEAP}" = "none" ;then
    tFile=searchrate-pod-heapless.yaml.subst
    else
    tFile=searchrate-pod.yaml.subst
  fi
  
  # echo "clean leftovers"
  # envsubst < "${tFile}" | kubectl delete -f - >> /dev/null 2>&1
  #   sleep 10
  
  startTime=$(date +"%Y-%m-%d %H:%M:%S")
  startEpoch=$(date -jf "%Y-%m-%d %H:%M:%S" "${startTime}" +%s)
  echo "test-$i on :${tFile} start time ${startTime}"
  # envsubst < "${tFile}" | kubectl apply -f -
  envsubst < "${tFile}" > "test-${i}.yaml"
    echo "letting test run 4s"
    sleep 4
  
  endTime=$(date +"%Y-%m-%d %H:%M:%S")
  endEpoch=$(date -jf "%Y-%m-%d %H:%M:%S" "${endTime}" +%s)
  echo "test-$i on :${tFile} end time ${endTime}"
  echo "view test-$i results at https://soak-monitoring.ping-devops.com/d/ccanxq9Zk/pingdirectory-performance-test?orgId=1&from=${startEpoch}&to=${endEpoch}"
  # envsubst < "${tFile}" | kubectl delete -f - >> /dev/null 2>&1
    sleep 2
done