export f=robert-ycsb-4d2z3r
export ver=v19.1.0-beta.20190318
export branch=replica-lease
export _crdb_replicas=5
export _ycsb_replicas=3
export _ycsb_insertcount=100000
export COCKROACH_DEV_ORG='Cockroach Labs Training'
export COCKROACH_DEV_LICENSE='crl-0-EIDA4OgGGAEiF0NvY2tyb2FjaCBMYWJzIFRyYWluaW5n'

# 4 DC - 2 AZ per DC 3 way replicas

# Europe
roachprod create $f --geo --gce-zones \
europe-west1-b,europe-west2-a,europe-west3-a,europe-west4-a,europe-west1-c,europe-west2-c,europe-west3-b,europe-west4-b \
 -n 8 --local-ssd-no-ext4-barrier

# US
roachprod create $f --geo --gce-zones \
us-west2-a,us-west2-b,us-west1-a,us-west1-b,us-east1-b,us-east1-c,us-east4-a,us-east4-b \
 -n 8 --local-ssd-no-ext4-barrier

# use ycsb-roachprod.sh from here on down
