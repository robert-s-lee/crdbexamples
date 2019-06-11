# database is installed manually with separete YCSB Client 

PATH=~/:$PATH 
YCSB=ycsb-jdbc-binding-0.16.0-SNAPSHOT
. ~/crdb.sh
. ~/ycsb.sh
_crdb_host=robert-ycsb-0001
_crdb_port=26257
_ycsb_host=robert-ycsb-0001
_ycsb_port=26257
branch=composite-key

# stage scripts and binaries for testing
sudo apt-get -y update; sudo apt-get -y install openjdk-8-jre  
curl -O --location https://raw.githubusercontent.com/robert-s-lee/distro/master/ycsb-jdbc-binding-0.16.0-SNAPSHOT.tar.gz; tar xfvz ycsb-jdbc-binding-0.16.0-SNAPSHOT.tar.gz
curl -O --location  https://jdbc.postgresql.org/download/postgresql-42.2.4.jar; mv postgresql-42.2.4.jar ycsb-jdbc-binding-0.16.0-SNAPSHOT/lib/.

# util scripts
curl -O --location https://raw.githubusercontent.com/robert-s-lee/crdbexamples/${branch:-master}/scripts/crdb.sh;  curl -O --location https://raw.githubusercontent.com/robert-s-lee/crdbexamples/${branch:-master}/scripts/ycsb.sh; chmod a+x *.sh

# setup the schema 
cockroach sql  --url "postgresql://${_crdb_hostname}:${_crdb_port}" --insecure -e "SET CLUSTER SETTING cluster.organization='$COCKROACH_DEV_ORG'; SET CLUSTER SETTING enterprise.license='$COCKROACH_DEV_LICENSE'"
_crdb_replicas=${_crdb_replicas} _crdb_num_replicas; _crdb_maps; _ycsb_replicas=${_ycsb_replicas} _ycsb_init; _ycsb_part

# get distance to regions, set haproxy, replica and leaseholder to two nearest regions
_crdb_ping
_crdb_haproxy
pkill -9 haproxy 2>/dev/null; haproxy -D -f ./haproxy.cfg &
_crdb_replicas=${_ycsb_replicas} _ycsb_lease # _crdb_replicas=3 covers 2 DC failures 

# load initial dataset 1,000,000 from each node, 16 thread each node
_ycsb_threads=4
cockroach node status --host $_crdb_host --port $_crdb_port --insecure | tail -n +2 |  awk -F'[ :\t]' '{print $1 " " $2 " " $3}' | while read _ycsb_node _ycsb_host _ycsb_port; do 
  _ycsb load a &
done
tail -f *load*err*

# run workload b, 8 thread each node NOT using AOST
_ycsb_threads=48
cockroach node status --host $_crdb_host --port $_crdb_port --insecure | tail -n +2 |  awk -F'[ :\t]' '{print $1 " " $2 " " $3}' | while read _ycsb_node _ycsb_host _ycsb_port; do  
_ycsb run a &
done

_ycsb_threads=48
cockroach node status --host $_crdb_host --port $_crdb_port --insecure | tail -n +2 |  awk -F'[ :\t]' '{print $1 " " $2 " " $3}' | while read _ycsb_node _ycsb_host _ycsb_port; do  
_ycsb_dbdialect=jdbc:cockroach _ycsb run a & 
done


