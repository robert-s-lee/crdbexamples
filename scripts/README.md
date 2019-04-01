YCSB is an widely used open source database benchmark.  
A vast number of RDBMS, NoSQL and NewSQL support YCSB.
It is common to find YCSB throughput and latency figures.
Higher througput and low latency are classified as better in these comparison.
These figures can easily used to compare one database to another.

## Background on YCSB

Each row in YCBS has a single primary key and 10 columns.
Two read operations and one update operation are present. 
The reads retrieve one row or multiple rows.
The update changes any one column out of the 10 columns.

There are 5 workloads, A,B,C,D,E,F with pre-defines ratio of the statements.
The workloads represnt common uses cases in modern microservices applications.
IOT applicaitons may update different sensor attributes.
Identify applications may contain passwords and personal profiles attributes.
Financial appications may contain latest balance and previous activities.
Supply chain management may contain current inventory levels.

Primary key support by all databases is used for all operations 
A single statement insert, update, select, delete and range scan are used, also supported by almost all databases.

 
## Data anonomies

YCSB can spawn many simeltaneous read and update threads at the same time.
These thrads can also be spawn in different geographies.
Many threads cause conflict between reader and writer threads.
Treatment of conflict resolution is often called isolation (or the I) in ACID.
Five isolation levels defined in ANSI SQL for common understadning.
Databases can supprt any or none of ioslation levels.

A database with no isolation level support has no guarnataness on the correctness of the data.  
The correctness of results are also called data anomilies.  
For example a database can choose to :

- return an old version of the data (called dirty data)  
- lose one or any of the updates (called lost update)
- return data that has been deleted (called phantom read)
- return no data even if the data is there (Non-repeatable Read)
- return data with random choice of any combination of above (write skew)

Databases implentes isolation levels to prevent these anonomiles. 
These class of databases are often classified as eventually conistent.

## Why Choose Lower Level Isolation

Application is respobsible for choosing the right isolation level.
No applicaiton will knowingly choose a database that returns incorrect results all of the time.
Some applcations may choose a database that somtimes has random data anomilies at some random times.  

READ COMMITTED, REPEATABEL READ, SNAPSHOT, SERIALIZBLE are successively higher isolation levels to prevents one of more anonomiles.
Each successively higher isolation level is expoentially more complex, harder and longer to implement for a database.
Newer databases typically don't support any isolations.
Mature databases tend to support more higher level isoaltions.

Most mission critical application will choose a database that is free from these data abnomolies.  
CockroachDB only runs in SERIALIZABLE isolation and can be used by applcation by the mission critical applications.

## Why settle for Lower Level Isolation

Common reasons for chooising lower level isolations are performance and cost.
Performance is combination of read response time, update response time and scale (how many users and data can I support).
Most comercial applications are satisified with 

- 1 to 2ms read response time for a single row (or limited by speed of light)
- about 4ms write response time a single row (or limited by speed of light)
- about 8ms update response time a single row (or limited by speed of light)
- dynamicaly scale infrastrcture to support varying number of users
- minimum infrastrucure for data that tend to increase at bound rated (for example 10% CAGR - compounded annual grwoth rate)

Each concurency consumes CPU, RAM, IO, Network (or collectively called infrastructure)
Lower isolation levels consume correspondily less resources
The workloads has peaks and valleys
Infrastructure is usually sized for peak workloads
Minimum infrastrcuture for data and scale often uses 10% of available infrastcuure
90% of cost spent on idle resources


## YCSB Comparision Methodology

Comparing the performance of one database to another is often apples and oranges.
The follow list major components required to conduct a test.
Each compoments has has special database specific optimiation.
Each compoments has significant impact on performance.
Each compoments is different for each database.

- YCSB can supprt many YCSB clients 
- Each database has database specific YCSB client
- Each YCSB client uses database specific driver
- Load balancer can be internal or external to database driver  
- Load balancers are configures to choose database closes to it
- distributed databases are interconnected

```
                                            DB1 --+ 
+--------------------+                   /        |
|    YCSB Client 1   | ___ Load Balancer -  DB2 --+
| DB Specifid Driver |                   \        |
+--------------------+                      DB3 --+ 
                                                  |
                                            DB4 --+
+--------------------+                   /        |
|    YCSB Client 2   | ___ Load Balancer -  DB5 --+
| DB Specifid Driver |                   \        |  
+--------------------+                      DB6 --+
                                                  |
                                            DB7 --+
+--------------------+                   /        |
|    YCSB Client n   | ___ Load Balancer -  DB8 --+ 
| DB Specifid Driver |                   \        |
+--------------------+                      DB9 --+
                                              
```

Database specific component do change database performance.
Many database specific components make isolating the YCSB client performance from the database performance difficult.  
An apples to apples comparison would have all components the sames except for a single difference, the database.
CockroachDB uses generic compoment to make this comparison as easy as possible:

- generic JDBC YCSB client and has no CockroachDB specific optimizations
- generic Postgres JDBC driver and has no CockroachDB specific optimizations
- generic external HAproxy load balancer and has no CockroachDB specific optimizations
- ANSI SQL serializable isolation and has no CockroachDB specific optimizations

## Modern Microservices Architecture 

Modern microservice applications are deployed in many locations.  
Each application connecting to databas located only to one location would be subject to poor response times.
The further away from the database location, the worse the performance.
The best response time can be achieved by localting the databases closes to the application as possible.
In turn, applications are deployed close to users as possible.


Workload dominated by East and West user localtions
```
W1 ---- E1
 |       |
W2 ---- E2
```

Workload dominated by East and West but some Central user locations
```
W1 ----- E1
 |   C1   |
W2 ----- E2
```

Workload uniformly distributed East thru West
```
W1 ---- C1 ---- E1
 |       |       |
 |       |       |
W2 ---- C2 ---- E2

```

In all these cases, CockroachDB yields the following performance:

- read performance is 1 to 2ms
- write performance is constrainted to speed of light to nearest data center
- each region can scale up and down independently
- a region failure causes speed of light to nearest data center performance constrainted 
- write performance can be controlled by choosing data center distances and fault domain

In terms of scale, each server is capable of:
- holding 10 million rows
- servering 16 concurrent users at 100% concurrency
- serializable isolation

 
|  | 4 DCs | 5 DCs | 6 DCs |
|--| --- | --- | --- |
|1 |       |       |       |
|2 |       |       |       |
|3 |       |       |       |



# Response time and throughput relationship

Response time an TPS (transacptions per second) are common comparison metrics.
Higher the TPS, the better. 
Faster (lower the response time), the better.
Generally, a better response time yields correspondingly better TPS.
2x better response time will usually yield 2x better TPS.
Is it possible to have 10% improvement in response time, but 4x better TPS?

## Missing variables

TPS is also influcneded by the batch size.
Batch size is number of disparate trnasactions that can be included as a single transaction.
The response time is returned for the one batched transaction and not each disparate transactions.

Lets assume we are inserting data into a table.
The number of rows written per sec is being measured. 
The below shows default assumption of batch size of 1 showing direct relationship between response time and TPS.

|                    |   Test A  |   Test B  |
|--------------------| --------- | ----------| 
| Response Time      |   16 ms   |   32 ms   |
| Concurrency        |   32      |     32    |
| Total rows per sec | 2,000 TPS | 1,000 TPS |  


|                    |   Test A  |   Test B  |
|--------------------| --------- | ----------| 
| Response Time      | 16 ms     |   32 ms   |
| Batch Size         |   4       |     1     |
| Concurrency        |   32      |     32    |
| Total rows per sec | 2,000 TPS | 1,000 TPS |  


16 threads, each threads

Three factors influence TPS


Response time determines the performance.
Throughput is a measure of scale.
Assume a 2ms response time composed of the following:
- round trip time (RTT) between YCSB client and Load Balancer is .5ms
- RTT between load balacner and one of database nodes is .5ms.
- DB response time on average 1ms

```
                                            DB1 --+ 
+--------------------+                   /        |
|    YCSB Client     | ___ Load Balancer -  DB2 --+
| DB Specifid Driver |                   \        |
+--------------------+                      DB3 --+ 
```

There is 1000ms per 1 second.
Then a single running as fast as possible back to back results in 500 TPS. (500 TPS = 1 txn / 2ms * 1000ms / sec) 
4 threads then results in 2,000 TPS.
This is a perfect linear scalabilty.
It is almost impossible to delivery perfect lineary scalability indefintately.
The scalability depends many factors including the applicaiton, database and infrastrucutre.
A throughout figures need accompanying response time and concurrency.
Lets assume a 100,000 TPS is reported using 10 threads.  

```
100,000 txn    10 threads  
-----------  * ----------
   1 sec          txn 
```

 what are that is widley supported by NoSQL and eventual consistency databases. 

Scripts demonstrate the following capabilitites of CockroachDB using [YCSB](https://github.com/brianfrankcooper/YCSB) as th

e workload.  

- bulk insert
- geo-partitioning for data domciling
- replica and leaseholder controls for better performance  
- local, reginal, and global load balancer configuration

# Steps 

- install [roachprod](https://github.com/cockroachdb/cockroach/tree/master/pkg/cmd/roachprod). Please refer to [full instructions](https://github.com/cockroachdb/cockroach/blob/master/CONTRIBUTING.md).  TLDR below:

```
mkdir -p $(go env GOPATH)/src/github.com/cockroachdb
cd $(go env GOPATH)/src/github.com/cockroachdb
git clone https://github.com/cockroachdb/cockroach
cd cockroach
make bin/roachprod
```
- Copy and Paste each line from one of the topologies below:

Script | Description 
------ | ----------- 
ycsb-1region.sh              | Single region
ycsb-3region-2az-5replica.sh | 3 Regions, 2 Availabiity Zones per Region, 5 Replicas
ycsb-3region-2az-5replica.sh | 3 Regions, 2 Availabiity Zones per Region, 5 Replicas


![US 4 Regions](./images/us-gcp-4dc.png)

- Copy and Paste each line from [ycsb-roachprod.sh](https://github.com/robert-s-lee/crdbexamples/blob/replica-lease/scripts/ycsb-roachprod.sh)

## Failover

When a node fails, haproxy will automatically reconnect to a new CRDB node.  JDBC driver and YCSB do not have logic to reconnect automatically. The reconnect is initiated by stopping and restarting YCSB.  haproxy takes about one second to reconnect. Once the watchdog detects connection failure, it will stop, wait 5 seconds to allow haproxy to switch over, then restart YCSB.

The watchdog looks for ```^Error``` in the stderr. 

## Schema

Default schema.

```
CREATE TABLE usertable (
  ycsb_key VARCHAR NOT NULL,
  field0 VARCHAR NULL,
  field1 VARCHAR NULL,
  field2 VARCHAR NULL,
  field3 VARCHAR NULL,
  field4 VARCHAR NULL,
  field5 VARCHAR NULL,
  field6 VARCHAR NULL,
  field7 VARCHAR NULL,
  field8 VARCHAR NULL,
  field9 VARCHAR NULL,
  CONSTRAINT "primary" PRIMARY KEY (ycsb_key ASC)
  ); 
```
## Partition

_ycsb_part creates partion for each node in the cluster. 

```
ALTER TABLE PARTITION BY RANGE (ycsb_key) (
  PARTITION user0 VALUES FROM (MINVALUE) TO ('user001'),
  PARTITION user1 VALUES FROM ('user001') TO ('user002'),
  PARTITION user2 VALUES FROM ('user002') TO ('user003'),
  PARTITION user3 VALUES FROM ('user003') TO ('user004'),
  PARTITION user4 VALUES FROM ('user004') TO ('user005'),
  PARTITION user5 VALUES FROM ('user005') TO ('user006'),
  PARTITION usermaxvalue VALUES FROM ('user006') TO (MAXVALUE)
);
```

## Replica and Leaseholder

```
ALTER PARTITION user0 OF TABLE defaultdb.usertable CONFIGURE ZONE USING constraints='{"+region=europe-west1":1,"+region=europe-west2":1,"+region=europe-west3":1}', lease_preferences='[[+region=europe-west1],[+region=europe-west2],[+region=europe-west3]]';
ALTER PARTITION user1 OF TABLE defaultdb.usertable CONFIGURE ZONE USING constraints='{"+region=europe-west2":1,"+region=europe-west3":1,"+region=europe-west1":1}', lease_preferences='[[+region=europe-west2],[+region=europe-west3],[+region=europe-west1]]';
ALTER PARTITION user2 OF TABLE defaultdb.usertable CONFIGURE ZONE USING constraints='{"+region=europe-west3":1,"+region=europe-west1":1,"+region=europe-west2":1}', lease_preferences='[[+region=europe-west3],[+region=europe-west1],[+region=europe-west2]]';
ALTER PARTITION user3 OF TABLE defaultdb.usertable CONFIGURE ZONE USING constraints='{"+region=europe-west1":1,"+region=europe-west3":1,"+region=europe-west2":1}', lease_preferences='[[+region=europe-west1],[+region=europe-west3],[+region=europe-west2]]';
ALTER PARTITION user4 OF TABLE defaultdb.usertable CONFIGURE ZONE USING constraints='{"+region=europe-west2":1,"+region=europe-west3":1,"+region=europe-west1":1}', lease_preferences='[[+region=europe-west2],[+region=europe-west3],[+region=europe-west1]]';
ALTER PARTITION user5 OF TABLE defaultdb.usertable CONFIGURE ZONE USING constraints='{"+region=europe-west3":1,"+region=europe-west2":1,"+region=europe-west1":1}', lease_preferences='[[+region=europe-west3],[+region=europe-west2],[+region=europe-west1]]';
```


