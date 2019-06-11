export f=robert-ycsb-3d1z1r
export ver=v19.1.1
export branch=master
export _crdb_replicas=5
export _ycsb_replicas=3
export _ycsb_insertcount=100000
export COCKROACH_DEV_ORG='Cockroach Labs Training'
export COCKROACH_DEV_LICENSE='crl-0-EIDA4OgGGAEiF0NvY2tyb2FjaCBMYWJzIFRyYWluaW5n'

# 3 DC - 1 AZ per DC 3 way replicas
roachprod create $f --geo --gce-zones \
europe-west1-b,europe-west2-a,europe-west3-a \
-n 3 --local-ssd-no-ext4-barrier 

# use ycsb-roachprod.sh from here on down
