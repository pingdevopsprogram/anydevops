#!/usr/bin/env sh

# json=$(cat tests.json  | jq '.')
testsJson="tests.json"
outputDashboards="dashboard-urls.txt"
test -n "${1}" && testsJson="${1}"
test -n "${2}" && outputDashboards="${1}"
iterations=$(jq -r ".tests[-1].id" "${testsJson}")

echo "num tests = $((iterations+1))"

for i in $(seq 0 "${iterations}"); do 
  export THREADS=$(jq -r ".tests[$i].THREADS" "${testsJson}") 
  export REPLICAS=$(jq -r ".tests[$i].REPLICAS" "${testsJson}")
  export NAMESPACE=$(jq -r ".tests[$i].NAMESPACE" "${testsJson}")
  export HEAP=$(jq -r ".tests[$i].HEAP" "${testsJson}")
  export CPUS=$(jq -r ".tests[$i].CPUS" "${testsJson}")
  export MEM=$(jq -r ".tests[$i].MEM" "${testsJson}")
  
  if test "${HEAP}" = "none" ;then
    tFile=searchrate-pod-heapless.yaml.subst
    else
    tFile=searchrate-pod.yaml.subst
  fi
  
  # echo "clean leftovers"
  # envsubst < "${tFile}" | kubectl delete -f - >> /dev/null 2>&1
  #   sleep 10
  ## uncomment to save test files.  
  # envsubst < "${tFile}" > "test-${i}.yaml"
  
  startTime=$(date +"%Y-%m-%d %H:%M:%S")
  startEpoch=$(date -jf "%Y-%m-%d %H:%M:%S" "${startTime}" +%s)
  echo "test-$i on :${tFile} start time ${startTime}"
  envsubst < "${tFile}" | kubectl apply -f -
    echo "letting test run 360s"
    sleep 360
  
  echo "test-$i on ${tFile} end time: $(date +'%Y-%m-%d %H:%M:%S')"
  endEpoch=$(date +'%Y-%m-%d %H:%M:%S')
  echo "view test-$i results at https://soak-monitoring.ping-devops.com/d/ccanxq9Zk/pingdirectory-performance-test?orgId=1&refresh=5s&from=${startEpoch}&to=${endEpoch}" >> "${outputDashboards}"
  envsubst < "${tFile}" | kubectl delete -f - >> /dev/null 2>&1
    sleep 20
done