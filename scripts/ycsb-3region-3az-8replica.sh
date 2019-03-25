export f=robert-ycsb-3d3z8r
export ver=v19.1.0-beta.20190318
export branch=replica-lease
export _crdb_replicas=5
export _ycsb_replicas=8
export _ycsb_insertcount=100000
export COCKROACH_DEV_ORG='Cockroach Labs Training'
export COCKROACH_DEV_LICENSE='crl-0-EIDA4OgGGAEiF0NvY2tyb2FjaCBMYWJzIFRyYWluaW5n'

roachprod create $f --geo --gce-zones \
europe-west1-b,europe-west2-a,europe-west3-a,europe-west1-c,europe-west2-b,europe-west3-b,europe-west1-d,europe-west2-c,europe-west3-c \
-n 9 --local-ssd-no-ext4-barrier 

# use ycsb-roachprod.sh from here on down
