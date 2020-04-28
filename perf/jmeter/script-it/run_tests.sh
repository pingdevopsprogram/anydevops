#!/usr/bin/env sh
# set -x
usage ()
{
        test -n "${*}" && echo "${*}"
    cat <<END_USAGE
Usage: ${0} {options}
    where {options} include:
    -t, --testFile) ** Required
        relative path to test.json file. 
    -o, --output
        relative path of where to publish output.
    -c, --cooldown
        time between tests
    --help
        Display general usage information
END_USAGE
    exit 99
}

outputDashboards="dashboard-urls.txt"

while ! test -z "${1}" ; 
do
    case "${1}" in
        -t|--testFile)
            shift
            if test -n "${1}" -a -f "${1}"; then
              testsJsonFile="${1}"
            else usage "test file not found"; fi
            ;;
        -o|--output)
            shift
            if test -n "${1}"; then
              outputDashboards="${1}"
            else usage "out file not found"; fi
            ;;
        -c|--cooldown)
            shift
            if test -n "${1}"; then
              cooldown="${1}"
            else usage "out file not found"; fi
            ;;
        *)
            usage "Unrecognized option"
            ;;
    esac
    shift
done

testsJson=$(cat "$testsJsonFile")

numPd=$(echo "${testsJson}" | jq -r '.pdCount')
pdIterations=$((numPd -1))
testDuration=$(echo "${testsJson}" | jq -r '.testDuration')

numTests=$(echo "${testsJson}" | jq -r '.tests | length')
echo "number of tests to run: $numTests"

testIterations=$((numTests -1))
NAMESPACE=$(echo "${testsJson}" | jq -r ".namespace")
DURATION=$(echo "${testsJson}" | jq -r ".testDuration")
export NAMESPACE DURATION

echo "clean leftovers"
for f in yamls/tmp/* ; do kubectl delete -f $f ; rm $f ; done

for i in $(seq 0 "${testIterations}"); do 
  numThreadGroups=$(echo "${testsJson}" | jq ".tests[$i].threadgroups | length")
  testId=$(echo "${testsJson}" | jq -r ".tests[$i].id")
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
  
  kubectl delete -f "${testFile}"
  startTime=$(date +"%Y-%m-%dT%H:%M:%S.000Z")
  startTimeUtc=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
  startEpoch=$(date -jf "%Y-%m-%dT%H:%M:%S.000Z" "${startTime}" +%s000)
  
  echo "test-$testId on: ${testFile} start time ${startTime}"
  kubectl apply -f "${testFile}"
    echo "letting test run ${testDuration}s"
    sleep "${testDuration}"

  endTime=$(date +"%Y-%m-%dT%H:%M:%S.000Z")
  endTimeUtc=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
  endEpoch=$(date -jf "%Y-%m-%dT%H:%M:%S.000Z" "${endTime}" +%s000)
  echo "test-$testId on: ${testFile} end time ${endTime}"
  test ! -f "${outputDashboards}" && touch "${outputDashboards}"
  
    sleep 3  
  kubectl delete -f "${testFile}" > /dev/null 2>&1

  echo "test-$testId dashboard: https://soak-monitoring.ping-devops.com/d/pdperfrw/pingdirectory-performance-test?orgId=1&from=${startEpoch}&to=${endEpoch}" >> "${outputDashboards}"
  
  # returns similar to: /dashboard/snapshot/D2Emm6lWdWM0mnsfSPjcZ8qsj4quN62o
  echo "snapshotting results"
  snapshotPath=$(./gen_snapshot.sh "${startTimeUtc}" "${endTimeUtc}" "${testsJsonFile}-${testId}")
  test -z "${snapshotPath}" && exit 1
  echo "test-$testId snapshot: https://soak-monitoring.ping-devops.com${snapshotPath}" >> "${outputDashboards}"

  # Store Overall Campaign Results: 
  test "${i}" -eq 0 && campaignStartTimeUtc="${startTimeUtc}" && campaignStartEpoch="${startEpoch}"
  if test "${i}" -eq "${testIterations}" ; then
    campaignEndTimeUtc="${endTimeUtc}"
    campaignEndEpoch="${endEpoch}"
    echo "Campaign - $testsJsonFile dashboard: https://soak-monitoring.ping-devops.com/d/pdperfrw/pingdirectory-performance-test?orgId=1&from=${campaignStartEpoch}&to=${campaignEndEpoch}" >> "${outputDashboards}"
    snapshotPath=$(./gen_snapshot.sh "${campaignStartTimeUtc}" "${campaignEndTimeUtc}" "${testsJsonFile}-${testId}")
    test -z "${snapshotPath}" && exit 1
    echo "Campaign - $testsJsonFile snapshot: https://soak-monitoring.ping-devops.com${snapshotPath}" >> "${outputDashboards}"
  fi

  # cooldown between tests
  sleep $cooldown
  rm "${testFile}"
  echo "end of this iteration"
done