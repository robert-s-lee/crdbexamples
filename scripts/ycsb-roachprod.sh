# when roachprod stop is run, the haproxy will die.  restart

# start the DB
roachprod stage $f release $ver
roachprod install $f haproxy
roachprod start $f
roachprod adminurl $f:1

# stage scripts and binaries for testing
roachprod run $f -- 'sudo apt-get -y update; sudo apt-get -y install openjdk-8-jre'  
roachprod run $f -- 'curl -O --location https://raw.githubusercontent.com/robert-s-lee/distro/master/ycsb-jdbc-binding-0.16.0-SNAPSHOT.tar.gz; tar xfvz ycsb-jdbc-binding-0.16.0-SNAPSHOT.tar.gz'
roachprod run $f -- 'curl -O --location  https://jdbc.postgresql.org/download/postgresql-42.2.4.jar; mv postgresql-42.2.4.jar ycsb-jdbc-binding-0.16.0-SNAPSHOT/lib/.'
roachprod run $f -- "curl -O --location https://raw.githubusercontent.com/robert-s-lee/crdbexamples/${branch}/scripts/crdb.sh;  curl -O --location https://raw.githubusercontent.com/robert-s-lee/crdbexamples/${branch}/scripts/ycsb.sh; chmod a+x *.sh"

# setup the schema with default 5 way replica 
roachprod run $f:1 -- "PATH=~/:\$PATH; cockroach sql --insecure -e \"SET CLUSTER SETTING cluster.organization='$COCKROACH_DEV_ORG'; SET CLUSTER SETTING enterprise.license='$COCKROACH_DEV_LICENSE'\""
roachprod run $f -- "PATH=~/:\$PATH;. ~/crdb.sh; _crdb_haproxy;"
roachprod run $f -- "PATH=~/:\$PATH;haproxy -D -f ./haproxy.cfg &"
roachprod run $f:1 -- "PATH=~/:\$PATH;. ~/crdb.sh; _crdb_replicas=${_crdb_replicas} _crdb_num_replicas;_crdb_maps_gcp; . ~/ycsb.sh; YCSB=ycsb-jdbc-binding-0.16.0-SNAPSHOT; _ycsb_replicas=${_ycsb_replicas} _ycsb_init; _ycsb_part"
roachprod run $f -- "PATH=~/:\$PATH;. ~/crdb.sh; _crdb_ping"
roachprod run $f -- "PATH=~/:\$PATH;. ~/crdb.sh;. ~/ycsb.sh; _crdb_replicas=$_ycsb_replicas _ycsb_lease"

# load initial dataset 1,000,000 from each node, 16 thread each node
roachprod run $f:1 -- "PATH=~/:\$PATH;. ~/ycsb.sh; YCSB=ycsb-jdbc-binding-0.16.0-SNAPSHOT; _ycsb_insertcount=${_ycsb_insertcount} _ycsb_node=\`_ycsb_nodeid\`; _ycsb_port=26256 _ycsb_threads=4 _ycsb load a"

# run workload b, 8 thread each node using AOST
roachprod run $f -- "PATH=~/:\$PATH;. ~/ycsb.sh; YCSB=ycsb-jdbc-binding-0.16.0-SNAPSHOT; _ycsb_insertcount=${_ycsb_insertcount} _ycsb_operationcount=500000 _ycsb_node=\`hostname | awk -F- '{print (\$NF-1)}'\`; _ycsb_port=26256 _ycsb_threads=4 _ycsb_dbdialect=jdbc:cockroach _ycsb run b";

# run workload b, 8 thread each node NOT using AOST
roachprod run $f -- "PATH=~/:\$PATH;. ~/ycsb.sh; YCSB=ycsb-jdbc-binding-0.16.0-SNAPSHOT; _ycsb_insertcount=${_ycsb_insertcount} _ycsb_operationcount=100000 _ycsb_node=\`hostname | awk -F- '{print (\$NF-1)}'\`; _ycsb_port=26256  _ycsb_threads=4 _ycsb_dbdialect=jdbc:postgresql _ycsb run a"

# kill any java running
roachprod run $f -- "pkill -9 java"
