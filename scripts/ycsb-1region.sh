export f=robert-ycsb
export ver=v19.1.1
export branch=master
export _crdb_replicas=5
export _ycsb_replicas=3
export _ycsb_insertcount=1000000
export _ycsb_operationcount=100000
export COCKROACH_DEV_ORG='Cockroach Labs Training'
export COCKROACH_DEV_LICENSE='crl-0-EIDA4OgGGAEiF0NvY2tyb2FjaCBMYWJzIFRyYWluaW5n'

# start the cluster
roachprod create $f --gce-zones europe-west3-a -n 3 --local-ssd-no-ext4-barrier
roachprod create $f -n 3 --gce-machine-type n1-standard-16 --local-ssd-no-ext4-barrier

# use ycsb-roachprod.sh from here on down
