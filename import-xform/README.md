# background

(CockroachDB CSV import)[https://www.cockroachlabs.com/docs/stable/migrate-from-csv.html] requires (IEFT4180)[https://tools.ietf.org/html/rfc4180] compliant CSV format.  This provides a inline mechansim to convert the non-compliant CSV in-line.

(Python CSV reader and writer)[https://docs.python.org/3/library/csv.html] is used to convert the format.


Dialect.delimiter       |
Dialect.doublequote     |
Dialect.escapechar      |
Dialect.lineterminator  |
Dialect.quotechar       |
Dialect.quoting         |
Dialect.skipinitialspace|
Dialect.strict          |  
 

- `/Users/rslee/data/cockroach-data/1/extern/quotetestdata.csv`

line 2 has improper CSV with `"|A"`
```
1|***TESTDATA ABC DEF “A” GHI10|***COPY TEST ABC DEF “A” GHI10
2|***TESTDATA ABC DEF "|A" GHI10|***COPY TEST ABC DEF "A" GHI10
3|"***TESTDATA ABC DEF "A" GHI10"|***COPY TEST ABC DEF "A" GHI10
4|""***TESTDATA ABC DEF "A" GHI10"|***COPY TEST ABC DEF "A" GHI10
```

- show error lines from the test

```
curl 'http://localhost:8000/?url=file:///Users/rslee/data/cockroach-data/1/extern/quotetestdata.csv&delimiter=|&nf=3&showerr=5'
```

- example the transforming CSV to CRDB compliant
```
curl 'http://localhost:8000/?url=file:///Users/rslee/data/cockroach-data/1/extern/quotetestdata.csv&delimiter=|&nf=3'

1,***TESTDATA ABC DEF “A” GHI10,***COPY TEST ABC DEF “A” GHI10
3,"***TESTDATA ABC DEF A"" GHI10""","***COPY TEST ABC DEF ""A"" GHI10"
4,"***TESTDATA ABC DEF ""A"" GHI10""","***COPY TEST ABC DEF ""A"" GHI10"
```
- import into CockroachDB
```
import table q1 create using 'nodelocal:///quotetestdata.ddl'
  csv data ('http://localhost:8000/me?url=file:///Users/rslee/data/cockroach-data/1/extern/quotetestdata.csv&delimiter=|&nf=3')
  with delimiter = ',';
        job_id       |  status   | fraction_completed | rows | index_entries | system_records | bytes
+--------------------+-----------+--------------------+------+---------------+----------------+-------+
  483022337698234369 | succeeded |                  1 |    3 |             0 |              0 |   225
```

