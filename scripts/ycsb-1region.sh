export f=robert-ycsb
export ver=v19.1.0-beta.20190318
export branch=replica-lease
export _crdb_replicas=5
export _ycsb_replicas=3
export _ycsb_insertcount=100000
export COCKROACH_DEV_ORG='Cockroach Labs Training'
export COCKROACH_DEV_LICENSE='crl-0-EIDA4OgGGAEiF0NvY2tyb2FjaCBMYWJzIFRyYWluaW5n'

# start the cluster
roachprod create $f --gce-zones europe-west3-a -n 3 --local-ssd-no-ext4-barrier

# use ycsb-roachprod.sh from here on down
