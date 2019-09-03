export f=robert-ycsb
export ver=v19.1.4
export COCKROACH_DEV_ORG='Cockroach Labs Training'
export COCKROACH_DEV_LICENSE='crl-0-EIDA4OgGGAEiF0NvY2tyb2FjaCBMYWJzIFRyYWluaW5n'

roachprod create robert-n1s4 -c gce -n 1
roachprod create robert-n1s16 -c gce -n 1 --gce-machine-type n1-standard-16

roachprod stage robert-n1s4 release $ver
roachprod stage robert-n1s16 release $ver

roachprod stage $f release $ver
roachprod start $f:1-3
roachprod install $f:4 haproxy
roachprod run $f:4 -- "./cockroach gen haproxy --host $f-0001 --insecure; haproxy -D -f haproxy.cfg &"

cd /mnt/data1
duration=60
s=seqwrite
for d in 32kiB 96Kib; do  # distribution
  for c in 1; do # concurrency
cockroach systembench seqwrite --concurrency $c --duration ${duration}s --write-size $d >$s.$d.$c.log 2>&1
  sleep 15
  done
  sleep 60
done


sysbench

cd /mnt/data1
curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.deb.sh | sudo bash
sudo apt -y install sysbench make automake libtool pkg-config libaio-dev libmysqlclient-dev libssl-dev libpq-dev
sysbench fileio --file-total-size=8G --file-num=64 prepare > IO_LOAD_results

for each in 1 4 8 16 32 64; do sysbench fileio --file-total-size=8G --file-test-mode=rndwr --time=240 --max-requests=0 --file-block-size=32K --file-num=64 --file-fsync-all --threads=$each run; sleep 10; done > IO_WR_results
for each in 1 4 8 16 32 64; do sysbench fileio --file-total-size=8G --file-test-mode=rndwr --time=240 --file-block-size=32K --file-num=64 --file-fsync-all --threads=$each run; sleep 10; done > IO_WR_results



# TODO stage prometheus or sysstats

# ##################################################################
# Cockroach YCSB Setup

roachprod ssh $f:4
export PATH=~/:$PATH
tmux
# tmux session 1
# cockroach ycsb on database ycsb
cockroach workload init ycsb --drop --initial-rows 1000000
duration=60
s=crdbycsb
for d in zipfian uniform; do  # distribution
  for c in 1 3 6 9 12 15 18 21 24 48 96; do # concurrency
    echo "****************************************************************"
    echo $d $c
      cockroach workload run ycsb postgresql://root@127.0.0.1:26257/?sslmode=disable --concurrency $c --duration ${duration}s --workload a --request-distribution $d >$s.$d.$c.log 2>&1
  sleep 15
  done
  sleep 60
done
# tmux session 2
export PATH=./:$PATH


# ##################################################################
# out into CSV

echo "scenario,distribution,total concurrency,elapsed,errors,ops(total),ops/sec(cum),avg(ms),p50(ms),p95(ms),p99(ms),pMax(ms),result" > ycsb.csv
for f in *ycsb*.log; do
tail -6 $f | grep -v -e '^_' -e '^$' | awk '{split(f,a,"."); print a[1]","a[2]","a[3]","$1","$2","$3","$4","$5","$6","$7","$8","$9","$10;}' f=$f >> ycsb.csv
done

# ##################################################################
# opensource YCSB Setup

# stage scripts and binaries for testing
roachprod run $f -- 'sudo apt-get -y update; sudo apt-get -y install openjdk-8-jre'  
roachprod run $f -- 'curl -O --location https://raw.githubusercontent.com/robert-s-lee/distro/master/ycsb-jdbc-binding-0.16.0-SNAPSHOT.tar.gz; tar xfvz ycsb-jdbc-binding-0.16.0-SNAPSHOT.tar.gz'
roachprod run $f -- 'curl -O --location  https://jdbc.postgresql.org/download/postgresql-42.2.4.jar; mv postgresql-42.2.4.jar ycsb-jdbc-binding-0.16.0-SNAPSHOT/lib/.'
roachprod run $f -- 'curl -O --location  https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.17.tar.gz; gzip -dc mysql-connector-java-8.0.17.tar.gz | tar -xvf -; mv mysql-connector-java-8.0.17/mysql-connector-java-8.0.17.jar ycsb-jdbc-binding-0.16.0-SNAPSHOT/lib/.'

# opensource ycsb on database defaultdb

# create the table
# cockroach start --insecure --background
cat <<EOF | cockroach sql --insecure
create database if not exists ycsb;
CREATE TABLE usertable (
	YCSB_KEY VARCHAR(255) PRIMARY KEY,
	FIELD0 TEXT, FIELD1 TEXT,
	FIELD2 TEXT, FIELD3 TEXT,
	FIELD4 TEXT, FIELD5 TEXT,
	FIELD6 TEXT, FIELD7 TEXT,
	FIELD8 TEXT, FIELD9 TEXT
);
EOF

# load 1M rows
./cockroach sql --insecure -e "truncate usertable"
cd ycsb-jdbc-binding-0.16.0-SNAPSHOT/
bin/ycsb load jdbc -s -P workloads/workloada -p threadcount=8 -p db.driver=org.postgresql.Driver -p db.url="jdbc:postgresql://127.0.0.1:26257/defaultdb?autoReconnect=true&sslmode=disable&ssl=false&reWriteBatchedInserts=true" -p db.user=root -p db.passwd="" -p db.batchsize=128  -p jdbc.fetchsize=32 -p jdbc.autocommit=true -p jdbc.batchupdateapi=true -p recordcount=1000000 | tee  cockraochdb.batchrewrite.log

# run the workloads
duration=60
s=openycsb
for d in zipfian uniform; do  # distribution
  for c in 1 3 6 9 12 15 18 21 24 48 96; do # concurrency
    echo "****************************************************************"
    echo $d $c
      bin/ycsb run jdbc -s -P workloads/workloada -p threadcount=$c -p db.driver=org.postgresql.Driver -p db.url="jdbc:postgresql://127.0.0.1:26257/defaultdb?autoReconnect=true&sslmode=disable&ssl=false&reWriteBatchedInserts=true" -p db.user=root -p db.passwd="" -p db.batchsize=128  -p jdbc.fetchsize=32 -p jdbc.autocommit=true -p jdbc.batchupdateapi=true -p recordcount=100000 -p operationcount=10000000 -p requestdistribution=$d > $s.$d.$c.log 2>&1 &
    sleep $duration
    pkill -9 java
  sleep 15
  done
  sleep 60
done


# ##################################################################
# openycsb results into CSV

echo "scenario,distribution,total concurrency,elapsed,errors,ops(total),ops/sec(cum),avg(ms),p50(ms),p95(ms),p99(ms),pMax(ms),result" > ycsb.csv
for f in *ycsb*.log; do
tail -6 $f | grep -v -e '^_' -e '^$' | awk '{split(f,a,"."); print a[1]","a[2]","a[3]","$1","$2","$3","$4","$5","$6","$7","$8","$9","$10;}' f=$f
done

