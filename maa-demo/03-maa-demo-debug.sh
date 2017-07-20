
psql  "postgresql://root@localhost:26257/"

# for V1.1 
# 
PATH=./:$PATH;export PATH
n=0
while [ 1 ]; do
  time cockroach sql --url "postgresql://root@localhost:26257/test?sslmode=disable" <<EOF
show testing_ranges from table orders;
SHOW TRACE FOR select * from orders where c_nationkey=1;
  select * from orders where c_nationkey=1;
EOF
  sleep 1
done

# for v1.0.3

PATH=./:$PATH
n=0
while [ 1 ]; do
  time cockroach sql --url "postgresql://root@localhost:26257/test?sslmode=disable" <<EOF
show testing_ranges from table orders;
  explain (trace) select * from orders where c_nationkey=$n;
  select * from orders where c_nationkey=$n;
EOF
  sleep 1
done

while [ 1 ]; do
  time cockroach sql --url "postgresql://root@localhost:26257/test?sslmode=disable" <<EOF
  select * from orders where c_nationkey=$n;
EOF
  sleep 1
done


