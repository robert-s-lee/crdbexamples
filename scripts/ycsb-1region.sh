export f=robert-ycsb
export ver=v19.1.0-beta.20190318
export COCKROACH_DEV_ORG='Cockroach Labs Training'
export COCKROACH_DEV_LICENSE='crl-0-EIDA4OgGGAEiF0NvY2tyb2FjaCBMYWJzIFRyYWluaW5n'

# start the cluster
roachprod create $f --gce-zones europe-west3-a -n 3 --local-ssd-no-ext4-barrier

# start the DB
roachprod run $f -- 'curl -O --location https://s3.amazonaws.com/binaries.cockroachdb.com/cockroach-${ver}.linux-amd64.tgz; gzip -dc cockroach-${ver}.linux-amd64.tgz | tar -xvf -'
roachprod stage $f release $ver
roachprod start $f
roachprod adminurl $f

# stage scripts and binaries for testing
roachprod run $f -- 'sudo apt-get -y update; sudo apt-get -y install openjdk-8-jre'  
roachprod run $f -- 'curl -O --location https://raw.githubusercontent.com/robert-s-lee/distro/master/ycsb-jdbc-binding-0.16.0-SNAPSHOT.tar.gz; tar xfvz ycsb-jdbc-binding-0.16.0-SNAPSHOT.tar.gz'
roachprod run $f -- 'curl -O --location  https://jdbc.postgresql.org/download/postgresql-42.2.4.jar; mv postgresql-42.2.4.jar ycsb-jdbc-binding-0.16.0-SNAPSHOT/lib/.'
roachprod run $f -- 'curl -O --location https://github.com/robert-s-lee/crdbexamples/raw/master/scripts/crdb.sh; curl -O --location https://github.com/robert-s-lee/crdbexamples/raw/master/scripts/ycsb.sh; chmod a+x *.sh'

# setup the schema with default 5 way replica 
roachprod run $f:1 -- "PATH=~/:\$PATH;. ~/ycsb.sh; YCSB=ycsb-jdbc-binding-0.16.0-SNAPSHOT; _ycsb_init; _ycsb_part; _ycsb_lease"

# load initial dataset 1,000,000 from each node, 16 thread each node
roachprod run $f -- "PATH=~/:\$PATH;. ~/ycsb.sh; YCSB=ycsb-jdbc-binding-0.16.0-SNAPSHOT; _ycsb_insertcount=1000000 _ycsb_node=\`hostname | awk -F- '{print (\$3-1)}'\`; _ycsb_threads=16 _ycsb load a"

# run workload b, 8 thread each node using AOST
roachprod run $f -- "PATH=~/:\$PATH;. ~/ycsb.sh; YCSB=ycsb-jdbc-binding-0.16.0-SNAPSHOT; _ycsb_insertcount=1000000 _ycsb_operationcount=100000 _ycsb_node=\`hostname | awk -F- '{print (\$3-1)}'\`; _ycsb_threads=8 _ycsb_dbdialect=jdbc:cockroach _ycsb run b";

# run workload b, 8 thread each node NOT using AOST
roachprod run $f -- "PATH=~/:\$PATH;. ~/ycsb.sh; YCSB=ycsb-jdbc-binding-0.16.0-SNAPSHOT; _ycsb_insertcount=1000000 _ycsb_operationcount=100000 _ycsb_node=\`hostname | awk -F- '{print (\$3-1)}'\`; _ycsb_threads=8 _ycsb_dbdialect=jdbc:postgresql _ycsb run b"

# kill any java running
roachprod run $f -- "pkill -9 java"
