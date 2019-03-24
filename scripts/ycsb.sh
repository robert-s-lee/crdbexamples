# $1 load | run
# $2 a b c d e f
# _ycsb_node
# _ycsb_insertcount max per locality (100M) = 100000000
#
# recommneded sequence load a, run a,b,c,f,d load e, run e
# d and e inserts new rows starting from Integer.MAX_VALUE = 2147483647
# if run in parallel, multiple conflicts are expected

_ycsb() {
  local _ycsb_insertcount=${_ycsb_insertcount:-100000}

  if [ ! -z "${_ycsb_node}" ]; then
    local _ycsb_insertstart
    local _ycsb_zeropadding
    _ycsb_insertstart=$(($_ycsb_insertcount * ($_ycsb_node - 1)))
    ((_ycsb_zeropadding= 2 + ${#_ycsb_insertcount}))
  fi

  if [ ! -d $YCSB/bin ]; then echo "YCSB shoud contain $YCSB/bin directory"; return 1; fi

  if [ "$1" == "init" ]; then _ycsb_init; return 0; fi

$YCSB/bin/ycsb $1 jdbc -s -P $YCSB/workloads/workload${_ycsb_workload:-$2} \
  -p db.user=${_ycsb_user:-root} \
  -p db.driver=org.postgresql.Driver \
  -p db.dialect=${_ycsb_dbdialect:-jdbc:cockroach} \
  -p db.url=jdbc:postgresql://${_ycsb_host:-127.0.0.1}:${_ycsb_port:-26257}/${_ycsb_db:-defaultdb}?reWriteBatchedInserts=true\&ApplicationName=${_ycsb_db:-defaultdb}_${2}_${_ycsb_insertstart} \
  -p jdbc.batchupdateapi=true \
  -p db.batchsize=${_ycsb_batchsize:-128} \
  -p fieldcount=${_ycsb_fieldcount:-10} \
  -p fieldlength=${_ycsb_fieldlength:-100} \
  -p zeropadding=${_ycsb_zeropadding:-1} \
  -p insertorder=${_ycsb_insertorder:-ordered} \
  -p requestdistribution=${_ycsb_requestdistribution:-uniform} \
  -p threadcount=${_ycsb_threads:-1} \
  -p insertstart=${_ycsb_insertstart:-100000} \
  -p insertcount=${_ycsb_insertcount} \
  -p recordcount=${_ycsb_recordcount:-0} \
  -p operationcount=${_ycsb_operationcount:-10000} \
  > ycsb.log
}

_ycsb_nodeid() {
cockroach sql -u root --insecure --format csv --url "postgresql://${_ycsb_host:-127.0.0.1}:${_ycsb_port:-26257}/${_ycsb_db:-defaultdb}" -e "show node_id" | tail -n +2
}

# display ranges
_ycsb_range() {
cockroach sql -u root --insecure --url "postgresql://${_ycsb_host:-127.0.0.1}:${_ycsb_port:-26257}/${_ycsb_db:-defaultdb}" <<EOF
select range_id, array_agg(node_id), array_agg(az) 
from 
  ( select range_id,lease_holder,unnest(replicas) as replicas 
    from [show experimental_ranges from table ${_ycsb_db:-defaultdb}.usertable]) a, 
  ( select node_id, locality->>'az' az, locality->>'region' region
    from crdb_internal.kv_node_status) b 
where a.replicas=b.node_id
group by range_id 
;
EOF
}

# cleanup after workload d and e
_ycsb_clean() {
cockroach sql -u root --insecure --url "postgresql://${_ycsb_host:-127.0.0.1}:${_ycsb_port:-26257}/${_ycsb_db:-defaultdb}" <<EOF
delete from usertable where ycsb_key >= 'user2147483647';
EOF
}

#  create database if not exists ${_ycsb_db:-defaultdb};
#  CREATE TABLE if not exists ${_ycsb_db:-defaultdb}.usertable(
#    YCSB_KEY VARCHAR PRIMARY KEY,
#    FIELD0 VARCHAR, FIELD1 VARCHAR,
#    FIELD2 VARCHAR, FIELD3 VARCHAR,
#    FIELD4 VARCHAR, FIELD5 VARCHAR,
#    FIELD6 VARCHAR, FIELD7 VARCHAR,
#    FIELD8 VARCHAR, FIELD9 VARCHAR
#  );
_ycsb_ddl() {
  local sql="create database if not exists ${_ycsb_db:-defaultdb}; \
    SET CLUSTER SETTING kv.range_merge.queue_enabled = false; \
    SET CLUSTER SETTING kv.closed_timestamp.follower_reads_enabled = true; \
    CREATE TABLE if not exists ${_ycsb_db:-defaultdb}.usertable( \
    YCSB_KEY VARCHAR PRIMARY KEY"
  for s in `seq 0 $((${_ycsb_fieldcount:-10}-1))`; do 
    sql="${sql},FIELD${s} VARCHAR"
  done
  echo "$sql"
}

_ycsb_ddl_index() {
  local sql="$1"
  for s in `seq 0 $((${_ycsb_secondindex:-10}-1))`; do sql="$sql,index (FIELD$s)"; done
  echo "$sql"
}

_ycsb_ddl_family() {
  local sql="$1"
  sql="$sql,family (ycsb_key)"
  for s in `seq 0 $((${_ycsb_family:-10}-1))`; do sql="$sql,family (FIELD$s)"; done
  echo "$sql"
}

_ycsb_init () {
  local sql=`_ycsb_ddl`
  while [ 1 ]; do
    case $1 in 
      index) sql=`_ycsb_ddl_index "$sql"`
        ;;
      family) sql=`_ycsb_ddl_family "$sql"`
        ;;
      *) echo "ignoring $1"
    esac
    shift
    if [ -z "$1" ]; then break; fi
  done    
   
  sql="$sql); alter table ${_ycsb_db:-defaultdb}.usertable configure zone using num_replicas=${_ycsb_replicas:-3};" 
  cockroach sql -u root --insecure \
    --url "postgresql://${_ycsb_host:-127.0.0.1}:${_ycsb_port:-26257}/${_ycsb_db:-defaultdb}" \
    -e "${sql}"
}

# split the table                 
# doing take long time on globally distributed cluster
# assume locid key encoding for 0 - 213
#  alter table  ${_ycsb_db:-defaultdb}.usertable split at select left(concat('user00', generate_series(0,9)::string),11);
#  alter table  ${_ycsb_db:-defaultdb}.usertable split at select left(concat('user0', generate_series(10,99)::string),11);
# 214 and 215 used for workloads D and E
_ycsb_split() {
  local part_keys="${@:-`_crdb_locs`}"
  local sql=""
  local part_end
  echo "$part_keys" | while read p constraints; do
    echo $p $constraints
    part_end=`printf "'user%03d'" $(($p))`
    cockroach sql -u root --insecure --url "postgresql://${_ycsb_host:-127.0.0.1}:${_ycsb_port:-26257}/${_ycsb_db:-defaultdb}" -e "alter table ${_ycsb_db:-defaultdb}.usertable split at values (${part_end});"
  done
  cockroach sql -u root --insecure --url "postgresql://${_ycsb_host:-127.0.0.1}:${_ycsb_port:-26257}/${_ycsb_db:-defaultdb}" -e "alter table  ${_ycsb_db:-defaultdb}.usertable scatter;"
}

# partition table
# Example of SQL
# _ycsb_part 2 3 4
#   DEFAULT: cockroach node ls --insecure | tail -n +2 | sort
#
# alter table defaultdb.usertable partition by range (YCSB_KEY) ( 
#     PARTITION user1 VALUES FROM (MINVALUE)  TO ('user002') 
#   , PARTITION user2 VALUES FROM ('user002') TO ('user003') 
#   , PARTITION user3 VALUES FROM ('user003') TO ('user004') 
#   , PARTITION user4 VALUES FROM ('user004') TO (MAXVALUE) );
_ycsb_part() {
  local part_min="MINVALUE"
  local part_max="MAXVALUE"
  local sql
  local comma=""
  local part_begin=$part_min
  local part_end
  part_keys="${@:-`cockroach node ls --insecure | tail -n +2 | sort -g`}"
  for p in $part_keys; do
    p=$(($p - 1))
    part_end=`printf "'user%03d'" $(($p+1))`
    sql="$sql $comma PARTITION user$p VALUES FROM ($part_begin) TO ($part_end)"
    comma=","
    part_begin=$part_end
  done

  if [ "$sql" ]; then
    sql="alter table ${_ycsb_db:-defaultdb}.usertable partition by range (YCSB_KEY) ($sql"
    sql="$sql $comma PARTITION user$part_max VALUES FROM ($part_begin) TO ($part_max)"
    sql="$sql );"
    echo $sql
    cockroach sql -u root --insecure --url "postgresql://${_ycsb_host:-127.0.0.1}:${_ycsb_port:-26257}/${_ycsb_db:-defaultdb}" -e "$sql"
  fi
}

# set replica and lease
# ALTER PARTITION user1 OF TABLE defaultdb.usertable CONFIGURE ZONE USING constraints='[+r=east]', lease_preferences='[[+r=east]]'; 
# ALTER PARTITION user2 OF TABLE defaultdb.usertable CONFIGURE ZONE USING constraints='[+r=central]', lease_preferences='[[+r=central]]';
# ALTER PARTITION user3 OF TABLE defaultdb.usertable CONFIGURE ZONE USING constraints='[+r=west]', lease_preferences='[[+r=west]]';
_ycsb_lease_old() {
  local part_keys="${@:-`_crdb_locs`}"
  local sql=""
  local part_end
  echo "$part_keys" | while read p constraints; do
    echo $p $constraints
    # constraints='[+$constraints]' set the replca
    sql="ALTER PARTITION user$p OF TABLE ${_ycsb_db:-defaultdb}.usertable \
      CONFIGURE ZONE USING lease_preferences='[[+$constraints]]';"
    echo $sql
    cockroach sql -u root --insecure --url "postgresql://${_ycsb_host:-127.0.0.1}:${_ycsb_port:-26257}/${_ycsb_db:-defaultdb}" -e "$sql"
  done
}

_ycsb_lease() {
  local lease_order=`_crdb_ping_leaseorder`
  local replica_order=`_crdb_ping_replicaorder`
  _crdb_whereami | while read node_id addr http_port az region; do
    echo  "$node_id $addr $http_port $az $region"
    sql="ALTER PARTITION user$node_id OF TABLE ${_ycsb_db:-defaultdb}.usertable \
      CONFIGURE ZONE USING constraints='$replica_order', lease_preferences='$lease_order';"
    echo $sql
    cockroach sql -u root --insecure --url "postgresql://${_ycsb_host:-127.0.0.1}:${_ycsb_port:-26257}/${_ycsb_db:-defaultdb}" -e "$sql"
  done
}

# summarize the ycsb log file
_ycsb_report () {
  if [ ! -f results.csv ]; then
    echo "db,scenario,workload,replica,time,read,update,rmw,insert,scan" > results.csv
  fi
  grep -e "Operations" -e "RunTime" $1 -e "Using shards:" | \
    awk  -v db=$version -v scenario="load" -v workload=$w -v replica=$r \
      'BEGIN {times=0;threads=0;batchsize=0;\
        read=0;update=0;rmw=0;insert=0;scan=0; \
        readerr=0;updateerr=0;rmwerr=0;inserterr=0;scanerr=0; } \
      $1=="Using" {threads=threads+1} \
      $1=="[OVERALL]," {time=$3} \
      $1=="[READ]," {read=$3} \
      $1=="[READ-FAILED]," {readerr=$3} \
      $1=="[UPDATE]," {update=$3} \
      $1=="[UPDATE-FAILED]," {updateerr=$3} \
      $1=="[READ-MODIFY-WRITE]," {rmw=$3} \
      $1=="[READ-MODIFY-WRITE-FAILED]," {rmwerr=$3} \
      $1=="[INSERT]," {insert=$3} \
      $1=="[INSERT-FAILED]," {inserterr=$3} \
      $1=="[SCAN]," {scan=$3} 
      $1=="[SCAN-FAILED]," {scanerr=$3} 
      END {print db "," scenario "," workload "," replica "," threads \
        "," time \
        "," read "," update "," rmw "," insert "," scan \
        "," readerr "," updateerr "," rmwerr "," inserterr "," scanerr }' | \
    tee -a results.csv
}
