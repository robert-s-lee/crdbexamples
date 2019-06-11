# when roachprod stop is run, the haproxy will die.  restart

. ~/github/crdbexamples/scripts/crdb.sh
. ~/github/crdbexamples/scripts/ycsb.sh

export _crdb_replicas=5
export _ycsb_replicas=3
export _ycsb_insertcount=10000
export _ycsb_operationcount=10000
export host=localhost
export port=26257
export COCKROACH_DEV_ORG='Cockroach Labs Training'
export COCKROACH_DEV_LICENSE='crl-0-EIDA4OgGGAEiF0NvY2tyb2FjaCBMYWJzIFRyYWluaW5n'

_crdb_haproxy; haproxy -D -f ./haproxy.cfg &  # optional create haproxy.cfg and start haproxy
_crdb_num_replicas -r ${_crdb_replicas}       # optional 5 way replication for system tables

_ycsb_init  # required schema
_ycsb_part  # optional partition the table need enterprise license

# recommneded set constrains and lease preferences if locality is defined
cockroach node status --host $host --port $port --insecure | tail -n +2 |  awk -F'[ :\t]' '{print $1 " " $2 " " $3}' | while read _ycsb_node _ycsb_host _ycsb_port; do _crdb_hostname=$_ycsb_host; _crdb_port=$_ycsb_port; _crdb_ping; _ycsb_lease; done

# load initial dataset
cockroach node status --host $host --port $port --insecure | tail -n +2 |  awk -F'[ :\t]' '{print $1 " " $2 " " $3}' | while read _ycsb_node _ycsb_host _ycsb_port; do  _ycsb load a; done

# run the workloads
for w in a; do 
cockroach node status --host $host --port $port --insecure | tail -n +2 |  awk -F'[ :\t]' '{print $1 " " $2 " " $3}' | while read _ycsb_node _ycsb_host _ycsb_port; do  _ycsb run $w; done
done

# run using AOST and upsert
for w in a; do 
cockroach node status --host $host --port $port --insecure | tail -n +2 |  awk -F'[ :\t]' '{print $1 " " $2 " " $3}' | while read _ycsb_node _ycsb_host _ycsb_port; do  _ycsb_dbdialect=jdbc:cockroach _ycsb run $w; done
done

# run upsert for singleton insert and update
for w in a; do 
cockroach node status --host $host --port $port --insecure | tail -n +2 |  awk -F'[ :\t]' '{print $1 " " $2 " " $3}' | while read _ycsb_node _ycsb_host _ycsb_port; do  _ycsb_dbdialect=jdbc:phoenix _ycsb run $w; done
done


# report of the run
for w in a b c d e f; do 
v=19.1.20190318;s=run;w=$w;r=3;cat ycsb.log.run.$w.* | _ycsb_report
done

# kill any java running
pkill -9 java
