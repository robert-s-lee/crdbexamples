
# CRDB version of AWR http://www.oracle.com/technetwork/articles/oem/potvin-awr-em12c-2301727.html

cockroach debug zip `hostname`.zip --insecure

# node_statement_history 
create database crdbsh;
use crdbsh;

-- delta from previous time period 
CREATE TABLE sh_delta (
  datetime timestamp NOT NULL,
  cluster_uuid uuid,
  interval timestamp NOT NULL,
  node_id INT NOT NULL,
  application_name STRING NOT NULL,
  flags STRING NOT NULL,
  key STRING NOT NULL,
  anonymized STRING NULL,
  count INT NOT NULL,
  first_attempt_count INT NOT NULL,
  max_retries INT NOT NULL,
  last_error STRING NULL,
  rows_avg FLOAT NOT NULL,
  rows_var FLOAT NOT NULL,
  parse_lat_avg FLOAT NOT NULL,
  parse_lat_var FLOAT NOT NULL,
  plan_lat_avg FLOAT NOT NULL,
  plan_lat_var FLOAT NOT NULL,
  run_lat_avg FLOAT NOT NULL,
  run_lat_var FLOAT NOT NULL,
  service_lat_avg FLOAT NOT NULL,
  service_lat_var FLOAT NOT NULL,
  overhead_lat_avg FLOAT NOT NULL,
  overhead_lat_var FLOAT NOT NULL,
primary key (datetime,node_id,key)
);

CREATE TABLE sh (
  datetime timestamp NOT NULL,
  cluster_uuid uuid,
  node_id INT NOT NULL,
  application_name STRING NOT NULL,
  flags STRING NOT NULL,
  key STRING NOT NULL,
  anonymized STRING NULL,
  count INT NOT NULL,
  first_attempt_count INT NOT NULL,
  max_retries INT NOT NULL,
  last_error STRING NULL,
  rows_avg FLOAT NOT NULL,
  rows_var FLOAT NOT NULL,
  parse_lat_avg FLOAT NOT NULL,
  parse_lat_var FLOAT NOT NULL,
  plan_lat_avg FLOAT NOT NULL,
  plan_lat_var FLOAT NOT NULL,
  run_lat_avg FLOAT NOT NULL,
  run_lat_var FLOAT NOT NULL,
  service_lat_avg FLOAT NOT NULL,
  service_lat_var FLOAT NOT NULL,
  overhead_lat_avg FLOAT NOT NULL,
  overhead_lat_var FLOAT NOT NULL,
  primary key (datetime,node_id,key)
);


insert into crdbsh.sh select now() as datetime,NULL,* from crdb_internal.node_statement_statistics 
;

select datetime,key,count,
count - lag(count) over(order by datetime,key,count) count_delta,
datetime - lag(datetime) over(order by datetime,key,count) datetime_delta
from crdbsh.sh
;

select datetime,key,count, lag(count) over
(partition by datetime,node_id,key order by count) prev_r limit 1 from crdbsh.sh;

select key,datetime,count from crdbsh.sh order by key asc, datetime asc;

select * from crdbsh.sh 

select * from crdbsh.sh;


cockroach sql --insecure --format tsv -e "
select now() as datetime,service_lat_avg * cast(count as float) as total_time,NULL,* from crdb_internal.node_statement_statistics order by total_time desc
"
