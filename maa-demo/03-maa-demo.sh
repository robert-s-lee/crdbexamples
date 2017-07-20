
n=${n:-0}

while [ 1 ]; do
  time /cockroach/cockroach sql --url "postgresql://root@localhost:26257/test?sslmode=disable" <<EOF
  explain (trace) select * from orders where c_nationkey=$n;
  select * from orders where c_nationkey=$n;
EOF
  sleep 1
done


