# when roachprod stop is run, the haproxy will die.  restart

. ~/github/crdbexamples/scripts/crdb.sh
. ~/github/crdbexamples/scripts/ycsb.sh

export f=robert-ycsb-3d2z5r
export ver=v19.1.0-beta.20190318
export _crdb_replicas=3
export COCKROACH_DEV_ORG='Cockroach Labs Training'
export COCKROACH_DEV_LICENSE='crl-0-EIDA4OgGGAEiF0NvY2tyb2FjaCBMYWJzIFRyYWluaW5n'

# 3 DC - 3 AZ per DC 5 way replicas
_crdb -c gcp europe-west1-b europe-west2-a europe-west3-a europe-west1-c europe-west2-c europe-west3-b 

# setup the schema with default 5 way replica 
roachprod run $f -- "PATH=~/:\$PATH;. ~/crdb.sh; _crdb_haproxy;"
roachprod run $f -- "PATH=~/:\$PATH;haproxy -D -f ./haproxy.cfg &"
_crdb_num_replicas -r ${_crdb_replicas}; _crdb_maps_gcp; _crdb_ping; YCSB=ycsb-jdbc-binding-0.16.0-SNAPSHOT; _ycsb_replica=${_crdb_replicas} _ycsb_init; _ycsb_part; _ycsb_lease"

# load initial dataset 1,000,000 from each node, 16 thread each node
roachprod run $f -- "PATH=~/:\$PATH;. ~/ycsb.sh; YCSB=ycsb-jdbc-binding-0.16.0-SNAPSHOT; _ycsb_insertcount=1000000 _ycsb_node=\`hostname | awk -F- '{print (\$NF-1)}'\`; _ycsb_port=26256 _ycsb_threads=4 _ycsb load a"

# run workload b, 8 thread each node using AOST
roachprod run $f -- "PATH=~/:\$PATH;. ~/ycsb.sh; YCSB=ycsb-jdbc-binding-0.16.0-SNAPSHOT; _ycsb_insertcount=1000000 _ycsb_operationcount=500000 _ycsb_node=\`hostname | awk -F- '{print (\$NF-1)}'\`; _ycsb_port=26256 _ycsb_threads=8 _ycsb_dbdialect=jdbc:cockroach _ycsb run b";

# run workload b, 8 thread each node NOT using AOST
roachprod run $f -- "PATH=~/:\$PATH;. ~/ycsb.sh; YCSB=ycsb-jdbc-binding-0.16.0-SNAPSHOT; _ycsb_insertcount=1000000 _ycsb_operationcount=100000 _ycsb_node=\`hostname | awk -F- '{print (\$NF-1)}'\`; _ycsb_port=26256  _ycsb_threads=8 _ycsb_dbdialect=jdbc:postgresql _ycsb run b"

# kill any java running
roachprod run $f -- "pkill -9 java"
