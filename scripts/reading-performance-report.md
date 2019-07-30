# Overview

run an apples to apples comparison
select a solution with the best price/performance ratio
this is the strategy used in many organizations
the strategy is simple and sound, but what is the real world perspective?
lets examine factors that complicats this in the real world

# how many apples are there
 
there are over 300 datbases in the market.
many databases have simliiar functions.
datbases in a same categories are groupped together.
subset of databases is selected based on pre-determined criteria
the same test is run on these databases 
the performance is measured
the price is obtained from the database vendors
the end result is a single number that can be ranked and stacked 
a clear winner emerges from the process

# the challenge

a truly apples to apples comparion is extremly difficult  
a requirement of apples to apples is changing just a single component
the application is the same
just change the database


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


