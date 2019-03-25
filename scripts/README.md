Scripts demonstrate the following capabilitites of CockroachDB using [YCSB](https://github.com/brianfrankcooper/YCSB) as the workload.  

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


