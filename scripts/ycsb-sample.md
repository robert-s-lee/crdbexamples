
- cockroachdb

```
export _ycsb_jdbc=postgresql 
export _ycsb_user=root 
export _ycsb_port=26257 
export _ycsb_node=1 
export _ycsb_db=ycsb 
export _ycsb_operationcount=100000 
export _ycsb_threads=1 
_ycsb load b

for t in 1 2 4 8 16 32 64; do
_ycsb_threads=$t _ycsb run b
done
```

- postgres

```
export _ycsb_jdbc=postgresql 
export _ycsb_user=rslee 
export _ycsb_port=5432 
export _ycsb_node=1 
export _ycsb_db=ycsb 
export _ycsb_threads=16 
export _ycsb_operationcount=100000 
_ycsb load b

for t in 1 2 4 8 16 32 64; do
_ycsb_threads=$t _ycsb run b
done
```

- mysql

set persist time_zone = '+00:00
```
export _ycsb_jdbc=mysql 
export _ycsb_user=root 
export _ycsb_port=3306 
export _ycsb_node=1 
export _ycsb_db=ycsb 
export _ycsb_threads=16 
export _ycsb_operationcount=100000 
_ycsb load b

for t in 1 2 4 8 16 32 64; do
_ycsb_threads=$t _ycsb run b
done
```

