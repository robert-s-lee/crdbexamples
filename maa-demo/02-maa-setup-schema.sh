
# setup the database -- modified TPC-H for more intersting demo later
/cockroach/cockroach sql --url "postgresql://root@localhost:26257/?sslmode=disable" <<EOF
create database if not exists test;
set database=test;
\| cat ddl.sql
EOF

# split the tables on nation boundary
echo "" > /tmp/data.$$
for n in `seq 0 24`;do
  echo "ALTER TABLE orders SPLIT AT VALUES ($n);" >> /tmp/data.$$
  echo "ALTER TABLE lineitem SPLIT AT VALUES ($n);">> /tmp/data.$$
done
/cockroach/cockroach sql --url   "postgresql://root@localhost:26257/test?sslmode=disable" < /tmp/data.$$

# insert some fake data that is split on nation
echo "insert into orders values " > /tmp/data.$$
prefix=""
for n in `seq 0 24`;do
  for o in `seq 0 10`; do
    echo "${prefix}($o,1,$n)" >> /tmp/data.$$
    prefix=","
  done
done
echo ";" >> /tmp/data.$$
/cockroach/cockroach sql --url   "postgresql://root@localhost:26257/test?sslmode=disable" < /tmp/data.$$

echo "insert into lineitem values " > /tmp/data.$$
prefix=""
for n in `seq 0 24`;do
  for o in `seq 0 10`; do
    for l in `seq 0 5`; do
      echo "${prefix}($o,$l,$n)" >> /tmp/data.$$
    prefix=","
    done
  done
done
echo ";" >> /tmp/data.$$
/cockroach/cockroach sql --url   "postgresql://root@localhost:26257/test?sslmode=disable" < /tmp/data.$$

rm /tmp/data.$$


