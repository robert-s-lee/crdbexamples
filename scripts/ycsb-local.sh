# when roachprod stop is run, the haproxy will die.  restart

. ~/github/crdbexamples/scripts/crdb.sh
. ~/github/crdbexamples/scripts/ycsb.sh

export f=robert-ycsb-3d2z5r
export ver=v19.1.0-beta.20190318
export _crdb_replicas=5
export _ycsb_replicas=3
export _ycsb_insertcount=10000
export COCKROACH_DEV_ORG='Cockroach Labs Training'
export COCKROACH_DEV_LICENSE='crl-0-EIDA4OgGGAEiF0NvY2tyb2FjaCBMYWJzIFRyYWluaW5n'

# 4 DC - 3 AZ per DC 3 way replicas
_crdb -c gcp europe-west1-b europe-west1-b  \
             europe-west1-c europe-west1-c  \
             europe-west1-d europe-west1-d  \
             europe-west2-a                 \
             europe-west2-b europe-west2-b  \
             europe-west2-c                 \
             europe-west3-a                 \
             europe-west3-b                 \
             europe-west3-c 

_crdb -c aws eu-west-1a eu-west-1a \
             eu-west-1b eu-west-1b \
             eu-west-1c eu-west-1c \
            eu-west-2a \
            eu-west-2b eu-west-2b \
            eu-west-2c \
            eu-central-1a \
            eu-central-1b \
            eu-central-1c 

_crdb -c gcp europe-west1-b europe-west2-a europe-west3-a europe-west1-c
_crdb -c gcp europe-west1-b europe-west2-a europe-west3-a europe-west4-a europe-west6-a europe-west1-c

_crdb -c gcp us-west2-a us-west2-b us-west1-a us-west1-b us-east1-b us-east1-c us-east4-a us-east4-b
_crdb -c gcp us-west2-a us-west1-a us-east1-b us-east4-a
_crdb -c gcp us-west2-a us-west1-a us-east1-a

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
for w in a b c d e f; do 
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
