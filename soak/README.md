# Dev-soak guidelines. 

Multiple scenarios:
  - individual products 
  - fullstack (starts with PD,PF,PA)

for a successful environment need: 
  - necessary ping products running. 
  - tools to generate load:
    - ldap-sdk, jmeter. 
    - ldap-sdk command
    - jmeter test scripts
  - tools to monitor health and metrics of environment:
    - Prometheus, Grafana. (I'd think these should be able to be shared across scenarios) 

## Monitoring Architecture

### Currently:

**Prometheus**
scraping data from:
- K8s Cluster
- PingDirectory statsd exporter

This scrapes across all namespaces in the cluster, and stores the metrics relative to their namespace. 


Grafana: 
Dashboards for: 
- K8s Cluster
- Pingdirectory

The PingDirectory dashboards are set up so that you can just change the namespace and it will pull the metrics specifc to that ns. 
Need to consider having some dashboards hard coded to a known ns. 

## soak-pingdirectory
in the namespace `soak-pingdirectory`:
- 3 PD instances
- 9 ldap sdk tools:
  - 3 modrate 10 threads
  - 3 authrate ok 10 threads
  - 3 authrate ko 10 threads

## Full-stack soak: 


