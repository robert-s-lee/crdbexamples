export f=robert-ycsb-3d3z8r
export ver=v19.1.0-beta.20190318
export replicas=8
export COCKROACH_DEV_ORG='Cockroach Labs Training'
export COCKROACH_DEV_LICENSE='crl-0-EIDA4OgGGAEiF0NvY2tyb2FjaCBMYWJzIFRyYWluaW5n'
 way replicas
roachprod create $f --geo --gce-zones \
europe-west1-b,europe-west2-a,europe-west3-a,europe-west1-c,europe-west2-b,europe-west3-b,europe-west1-d,europe-west2-c,europe-west3-c \
-n 9 --local-ssd-no-ext4-barrier 

# start the DB
roachprod stage $f release $ver
roachprod install $f haproxy
roachprod start $f
roachprod adminurl $f:1

# stage scripts and binaries for testing
roachprod run $f -- 'sudo apt-get -y update; sudo apt-get -y install openjdk-8-jre'  
roachprod run $f -- 'curl -O --location https://raw.githubusercontent.com/robert-s-lee/distro/master/ycsb-jdbc-binding-0.16.0-SNAPSHOT.tar.gz; tar xfvz ycsb-jdbc-binding-0.16.0-SNAPSHOT.tar.gz'
roachprod run $f -- 'curl -O --location  https://jdbc.postgresql.org/download/postgresql-42.2.4.jar; mv postgresql-42.2.4.jar ycsb-jdbc-binding-0.16.0-SNAPSHOT/lib/.'
roachprod run $f -- 'curl -O --location https://github.com/robert-s-lee/crdbexamples/raw/master/scripts/crdb.sh; curl -O --location https://github.com/robert-s-lee/crdbexamples/raw/master/scripts/ycsb.sh; chmod a+x *.sh'

# setup the schema with default 5 way replica 
roachprod run $f:1 -- "PATH=~/:\$PATH; cockroach sql --insecure -e \"SET CLUSTER SETTING cluster.organization='$COCKROACH_DEV_ORG'; SET CLUSTER SETTING enterprise.license='$COCKROACH_DEV_LICENSE';\""
roachprod run $f:1 -- "PATH=~/:\$PATH;. ~/crdb.sh; _crdb_num_replicas -r ${replicas};. ~/ycsb.sh; YCSB=ycsb-jdbc-binding-0.16.0-SNAPSHOT; _ycsb_replica=${replicas} _ycsb_init; _ycsb_part; _ycsb_lease"

# load initial dataset 1,000,000 from each node, 16 thread each node
roachprod run $f -- "PATH=~/:\$PATH;. ~/ycsb.sh; YCSB=ycsb-jdbc-binding-0.16.0-SNAPSHOT; _ycsb_insertcount=1000 _ycsb_node=\`hostname | awk -F- '{print (\$NF-1)}'\`; _ycsb_threads=4 _ycsb load a"

# run workload b, 8 thread each node using AOST
roachprod run $f -- "PATH=~/:\$PATH;. ~/ycsb.sh; YCSB=ycsb-jdbc-binding-0.16.0-SNAPSHOT; _ycsb_insertcount=1000 _ycsb_operationcount=500000 _ycsb_node=\`hostname | awk -F- '{print (\$NF-1)}'\`; _ycsb_port=26256 _ycsb_threads=4 _ycsb_dbdialect=jdbc:cockroach _ycsb run b";

# run workload b, 8 thread each node NOT using AOST
roachprod run $f -- "PATH=~/:\$PATH;. ~/ycsb.sh; YCSB=ycsb-jdbc-binding-0.16.0-SNAPSHOT; _ycsb_insertcount=1000 _ycsb_operationcount=100000 _ycsb_node=\`hostname | awk -F- '{print (\$NF-1)}'\`; _ycsb_port=26256 _ycsb_threads=4 _ycsb_dbdialect=jdbc:postgresql _ycsb run a"

# kill any java running
roachprod run $f -- "pkill -9 java"

# _ycsb_insertcount=1000; for i in `seq 1 $_crdb_instance`; do ((_ycsb_node=$i-1)); _ycsb load a; done
