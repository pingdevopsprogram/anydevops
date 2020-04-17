#!/usr/bin/env sh

testsJsonFile="tests-template.json"
test -n "${1}" && testsJsonFile="${1}"
testsJson=$(cat "$testsJsonFile")
outputDashboards="dashboard-urls.txt"
test -n "${2}" && outputDashboards="${2}"

numPd=$(echo "${testsJson}" | jq -r '.pdCount')
pdIterations=$((numPd -1))
testDuration=$(echo "${testsJson}" | jq -r '.testDuration')

numTests=$(echo "${testsJson}" | jq -r '.tests | length')
echo "number of tests to run: $numTests"

testIterations=$((numTests -1))
NAMESPACE=$(echo "${testsJson}" | jq -r ".namespace")
DURATION=$(echo "${testsJson}" | jq -r ".testDuration")
export NAMESPACE DURATION

for i in $(seq 0 "${testIterations}"); do 
  numThreadGroups=$(echo "${testsJson}" | jq ".tests[$i].threadgroups | length")
  tgIterations=$((numThreadGroups -1))
  for tg in $(seq 0 "${tgIterations}"); do 
    thisTg=$(echo "${testsJson}" | jq -r ".tests[$i].threadgroups[$tg]")
    THREADGROUP=$(echo "${thisTg}" | jq -r ".name")
    THREADS=$(echo "${thisTg}" | jq -r ".vars.threads") 
    REPLICAS=$(echo "${thisTg}" | jq -r ".vars.replicas") 
    HEAP=$(echo "${thisTg}" | jq -r ".vars.heap") 
    CPUS=$(echo "${thisTg}" | jq -r ".vars.cpus") 
    MEM=$(echo "${thisTg}" | jq -r ".vars.mem")
    export THREADGROUP THREADS REPLICAS HEAP CPUS MEM

    
    for pd in $(seq 0 "${pdIterations}"); do
      PDI="$pd"
      export PDI
    
      if test "${HEAP}" = "none" ;then
        tFile=yamls/xrate-heapless.yaml.subst
        else
        tFile=yamls/xrate.yaml.subst
      fi
      
      test ! -f "yamls/tmp/test-${i}.yaml" && touch "yamls/tmp/test-${i}.yaml"
      envsubst < "${tFile}" >> "yamls/tmp/test-${i}.yaml"
    done
      testFile="yamls/tmp/test-${i}.yaml"
  done
  
  echo "clean leftovers"
  kubectl delete -f "${testFile}"
  startTime=$(date +"%Y-%m-%d %H:%M:%S")
  startEpoch=$(date -jf "%Y-%m-%d %H:%M:%S" "${startTime}" +%s000)
  
  echo "test-$i on: ${testFile} start time ${startTime}"
  kubectl apply -f "${testFile}"
    echo "letting test run ${testDuration}s"
    sleep "${testDuration}"

  endTime=$(date +"%Y-%m-%d %H:%M:%S")
  endEpoch=$(date -jf "%Y-%m-%d %H:%M:%S" "${endTime}" +%s000)
  echo "test-$i on: ${testFile} end time ${endTime}"
  test ! -f "${outputDashboards}" && touch "${outputDashboards}"
  echo "view test-$i results at https://soak-monitoring.ping-devops.com/d/ccanxq9Zk/pingdirectory-performance-test?orgId=1&refresh=5s&from=${startEpoch}&to=${endEpoch}" >> "${outputDashboards}"
    sleep 3
  
  kubectl delete -f "${testFile}" > /dev/null 2>&1
  rm "${testFile}"
done