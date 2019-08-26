- setup

YCSB_HOME=ycsb-jdbc-binding-0.16.0-SNAPSHOT

```
sudo apt-get -y update; sudo apt-get -y install openjdk-8-jre
curl -O --location https://raw.githubusercontent.com/robert-s-lee/distro/master/ycsb-jdbc-binding-0.16.0-SNAPSHOT.tar.gz; tar xfvz ycsb-jdbc-binding-0.16.0-SNAPSHOT.tar.gz
curl -O --location  https://jdbc.postgresql.org/download/postgresql-42.2.4.jar; mv postgresql-42.2.4.jar ycsb-jdbc-binding-0.16.0-SNAPSHOT/lib/.
curl -O --location  https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.17.tar.gz; gzip -dc mysql-connector-java-8.0.17.tar.gz | tar -xvf -; mv mysql-connector-java-8.0.17/mysql-connector-java-8.0.17.jar ycsb-jdbc-binding-0.16.0-SNAPSHOT/lib/.
```

- cockroachdb

```
export _ycsb_jdbc=postgresql 
export _ycsb_user=root 
export _ycsb_port=26257 
export _ycsb_node=1 
export _ycsb_db=ycsb 
export _ycsb_operationcount=100000 
export _ycsb_threads=1 


java -cp $YCSB/lib/jdbc-binding-0.16.0-SNAPSHOT.jar:postgresql-42.2.4.jar com.yahoo.ycsb.db.JdbcDBCreateTable -P db.properties -n usertable

java -cp YCSB_HOME/jdbc-binding/lib/jdbc-binding-0.4.0.jar:mysql-connector-java-5.1.37-bin.jar com.yahoo.ycsb.db.JdbcDBCreateTable -P db.properties -n usertable



_ycsb load b

for t in 1 2 4 8 16 32 64; do
_ycsb_threads=$t _ycsb run b
done
```

- postgres

```
export _ycsb_jdbc=postgresql 
export _ycsb_user=rslee 
export _ycsb_port=5432 
export _ycsb_node=1 
export _ycsb_db=ycsb 
export _ycsb_threads=16 
export _ycsb_operationcount=100000 
_ycsb load b

for t in 1 2 4 8 16 32 64; do
_ycsb_threads=$t _ycsb run b
done
```

- mysql

set persist time_zone = '+00:00
```
export _ycsb_jdbc=mysql 
export _ycsb_user=root 
export _ycsb_port=3306 
export _ycsb_node=1 
export _ycsb_db=ycsb 
export _ycsb_threads=16 
export _ycsb_operationcount=100000 
_ycsb load b

for t in 1 2 4 8 16 32 64; do
_ycsb_threads=$t _ycsb run b
done
```

