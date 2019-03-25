# when roachprod stop is run, the haproxy will die.  restart

. ~/github/crdbexamples/scripts/crdb.sh
. ~/github/crdbexamples/scripts/ycsb.sh

export f=robert-ycsb-3d2z5r
export ver=v19.1.0-beta.20190318
export _crdb_replicas=5
export _ycsb_replicas=3
export _ycsb_insertcount=1000
export COCKROACH_DEV_ORG='Cockroach Labs Training'
export COCKROACH_DEV_LICENSE='crl-0-EIDA4OgGGAEiF0NvY2tyb2FjaCBMYWJzIFRyYWluaW5n'

# 4 DC - 3 AZ per DC 3 way replicas
_crdb -c gcp europe-west1-b europe-west2-a europe-west3-a europe-west1-c europe-west2-c europe-west3-b 
_crdb -c gcp us-west2-a us-west2-b us-west1-a us-west1-b us-east1-a us-east1-b us-east4-a us-east4-b

# setup the schema with default 5 way replica 
roachprod run $f -- "PATH=~/:\$PATH;. ~/crdb.sh; _crdb_haproxy;"
roachprod run $f -- "PATH=~/:\$PATH;haproxy -D -f ./haproxy.cfg &"

_crdb_num_replicas -r ${_crdb_replicas}
_crdb_maps_gcp

_ycsb_init 
_ycsb_part 

cockroach node status --insecure | tail -n +2 |  awk -F'[ :\t]' '{print $3}' | while read _crdb_port; do _crdb_ping; _ycsb_lease; done

# load initial dataset
cockroach node status --insecure | tail -n +2 |  awk -F'[ :\t]' '{print $1 " " $3}' | while read _ycsb_node _crdb_port; do  _ycsb load a; done

# run the workload
cockroach node status --insecure | tail -n +2 |  awk -F'[ :\t]' '{print $1 " " $3}' | while read _ycsb_node _crdb_port; do  _ycsb run a; done

# run workload b, 8 thread each node using AOST
cockroach node status --insecure | tail -n +2 |  awk -F'[ :\t]' '{print $1 " " $3}' | while read _ycsb_node _crdb_port; do  _ycsb_dbdialect=jdbc:postgresql _ycsb run a; done

# kill any java running
pkill -9 java
