YCSB is an widely used open source database benchmark.
A vast number of traditional RDBMS, NoSQL and NewSQL products support YCSB.
The benchmark measures throughput and latency figures.
Higher througput and low latency are deemed to have better performance.
These figures can easily used to compare one database to another.
There are numerious factors that can influence the performance.
Lets exam the impact of isolation level, the I in the ACID?

## Background on YCSB

Each row in YCBS has a single primary key and 10 columns.
The primary key column is called `YCSB_KEY`.
Each of the columns are called `FIELD0`, `FIELD1`, ... `FIELD9`.
There are types of read operation and one update operation. 
The read can retrieve one row or return (scan) multiple rows.
The update changes any one column out of the 10 columns.

There are 5 workloads, A,B,C,D,E,F with pre-defines ratio of the operations.
Each workload can represnt a common use case in modern microservices applications.

- Smart Devices may update different sensor attributes.
- Ideniity Management read and updte contain passwords and personal profiles attributes.
- Financial appications may scan multple activities to produce balance.

YCSB can spawn many simeltaneous read and update threads.
These thrads can also be spawn in different geographies.
Database could be one region or spread across the globe.
Many threads can cause conflict between reader and writer threads.

Primary key support by all databases is used for all operations 
A single statement insert, update, select, and range scan are used, also supported by almost all databases.

## Isolaion in ACID

Consider a range scan operation on `YCSB_KEY` between user10 and user50.
The ranges scan return all rows that fit the criteria.
Database takes a few mileseconds to collect the result.
At the start of the range scan operation, ycsbkey user10 and user50 exist. 
While in the process of retrieving user10 and user50: 
- a thread inserts user20.
- then another thread updates user10 field1
- then another thread updates user50 field2
- then another thread updates user10 field1 again

| Time | Existing Keys | New Insert  | New Update       | 
| -----| ------------- | ----------- | ---------------- |
|   1  | user10        |             |                  |
|   2  |               | user20      |                  | 
|   3  |               |             | user10 column 1  |                            
|   4  |               |             | user50 column 2  |
|   5  |               |             | user10 column 1  |                                 
|   6  | user50        |             |                  |  
 
What database returns is goverened by the isolation property (or the I) in ACID.
Five isolation levels defined in ANSI SQL for common understadning.
Databases can support some or none of ioslation levels.
        
Should database return:

- only user10 and user50 from time0 (before the query started running)?
- include user20 from time 2?
- user10 from time 3 with updated column 1
- user50 from time 4 or from time 0?
- user10 from time 5 with updated column 2 

## Data anonomies

What is deemed correct depends on point of view.
Relational algebra was born to prove mathemical correctness.
The definition ACID was born in 1970 to remove the `depends`.
In this defintion the `I` stood for serializable isolation. [TODO need a citation]

A database that is not serializable has no corresponding mathemical correctness.
A different set of results can be return each time.
Over the years, demand for better performance forced the isoation to be lowered.

With lower isolation, a database can choose to :

- return an old version of the data (called dirty data)  
- lose one or any of the updates (called lost update)
- return data that has been deleted (called phantom read)
- return no data even if the data is there (Non-repeatable Read)
- return data with random choice of any combination of above (write skew)

The correctness of results are also called data anomilies.  
Databases implentes isolation levels to prevent these anonomiles. 
These class of databases are often classified as eventually conistent.
The eventualy consistent datbase may also violation:

- the `A` in ACID - the atomic operation
- the 'C' in ACID - the consistency of data returned from one node to another
- the 'I' in ACID - the correctness of data in light of concurrent operations
- the 'D' in ACID - the duravitity to retain data from random equipment failure 

## How to choose the right islation level

business requiremnts dictates a database to choose the right isolation level.
if the database cannot provie the right isolation.
Application may choose to enhance the isolation isloation level.

Applicaiton may may request incorrect or inconsisten results all of the time.
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

## Summary

`ACID` was abondended to achieve lower cost and better perforuamce.
The trade off shoud be considred in the light of business impact.
Traditional assumption of beter performance and lower cost are no longer valid.
The expected performance and cost tradeoff of maintaining `ACID` is not great.
Protect you business from data anomolies.
Demand full and strong Atomic, Consistent, Serialiable Isoaltion, Durable database for your business.


# Comparision Methodology

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

What is batch size 
|                    |   Test A  |   Test B  |
|--------------------| --------- | ----------| 
| Response Time      | 16 ms     |   32 ms   |
| Batch Size         |   4       |     1     |
| Concurrency        |   32      |     32    |
| Total rows per sec | 4,000 TPS | 1,000 TPS |  


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


