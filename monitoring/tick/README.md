# TICK stack

This folder is here to be used to deploy the TICK stack: 
- Telegraf - run as a daemonset, monitors CPU, Mem + other metrics for the entire cluster. 
- InfluxDB - run as an sts. Database that holds all the metrics. 
- Chronograf - run as a deployment. Dashboard to view the metrics. 
- Kapacitor (coming soon)

# Deploy Instructions

## Pre-reqs. 

- helm - don't need tiller, just latest version of helm. 
```
brew install helm
```

## Start Deploying

1. Create the storage class for InfluxDB
```
kubectl apply -f influxdb/storageclass.yaml
```

2. use helm to install influxdb
```
helm install influx -f influxdb/values.yaml stable/influxdb 
```

3. deploy chronograf. This command will deploy: 
- chronograf - deployment
- ingress `chronograf.anydevops.com.`
- create a tls cert for anydevops.com
- create a pvc
```
kubectl apply -f chronograf/
```
4. deploy telegraf 
```
kubectl apply -f telegraf/
```

## Cleanup

1. the easy ones..
```
kubectl delete -f chronograf/
kubectl delete -f telegraf/
```
2. helm for influxdb: 
```
helm uninstall influx
```
3. also need to remove PVCs and PVs: 
```
kubectl get pvc
##find the influxdb and chronograf ones, delete them. 
kubectl delete pvc <influx-influxdb-data-influx-influxdb-0> <var-lib-chronograf> <chronograf>

## Then delete the corresponding PV and delete it. 
kubectl get pv
k delete pv <pvc-someId>
```