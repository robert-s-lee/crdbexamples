# when roachprod stop is run, the haproxy will die.  restart

. ~/github/crdbexamples/scripts/crdb.sh
. ~/github/crdbexamples/scripts/ycsb.sh

export _crdb_replicas=5
export _ycsb_replicas=3
export _ycsb_insertcount=10000
export COCKROACH_DEV_ORG='Cockroach Labs Training'
export COCKROACH_DEV_LICENSE='crl-0-EIDA4OgGGAEiF0NvY2tyb2FjaCBMYWJzIFRyYWluaW5n'

# AWS
_crdb -c aws eu-west-1a eu-west-1b eu-west-1c 
_crdb -c aws eu-west-2a eu-west-2b eu-west-2c 
_crdb -c aws eu-central-1a eu-central-1b eu-central-1c 

_crdb -c aws ap-southeast-2a ap-southeast-2b ap-southeast-2c

_crdb -c aws us-east-2a us-east-2b us-east-2c
# GCP
_crdb -c gcp europe-west1-b europe-west1-c europe-west1-d 
_crdb -c gcp europe-west2-a europe-west2-b europe-west2-c
_crdb -c gcp europe-west3-a europe-west3-b europe-west3-c 

_crdb -c gcp us-east1-a us-east1-b us-east1-c             # virgina
_crdb -c gcp us-east4-a us-east4-b us-east4-c
_crdb -c gcp us-central1-a us-central1-b us-central1-c
_crdb -c gcp us-west1-a us-west1-b us-west1-c             # portland 
_crdb -c gcp us-west2-a us-west2-a us-east2-a


# demo for corelogic
_crdb -c gcp us-west1-a us-west1-b us-west1-c us-central1-a us-central1-b us-central1-c # portland 
_crdb -c ntt us-west2-a us-central2-a  # ntt

# setup the schema with default 5 way replica 
_crdb_haproxy
haproxy -D -f ./haproxy.cfg &

_crdb_num_replicas -r ${_crdb_replicas}

_ycsb_init 
_ycsb_part 

cockroach node status --insecure | tail -n +2 |  awk -F'[ :\t]' '{print $3}' | while read _crdb_port; do _crdb_ping; _ycsb_lease; done

# load initial dataset
cockroach node status --insecure | tail -n +2 |  awk -F'[ :\t]' '{print $1 " " $3}' | while read _ycsb_node _crdb_port; do  _ycsb load a; done

# run the workloads
for w in e; do 
cockroach node status --insecure | tail -n +2 |  awk -F'[ :\t]' '{print $1 " " $3}' | while read _ycsb_node _crdb_port; do  _ycsb run $w; done
done

# run workload b, 8 thread each node using AOST
for w in a b c d e f; do 
cockroach node status --insecure | tail -n +2 |  awk -F'[ :\t]' '{print $1 " " $3}' | while read _ycsb_node _crdb_port; do  _ycsb_dbdialect=jdbc:cockroach _ycsb run $w; done
done

# report of the run
for w in a b c d e f; do 
version=19.1.20190318;scenario=run;w=$w;r=3;cat ycsb.log.run.$w.* | _ycsb_report
done

# kill any java running
pkill -9 java
