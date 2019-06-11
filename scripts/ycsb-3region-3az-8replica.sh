export f=robert-ycsb-3d3z9r
export ver=v19.1.1
export branch=master
export _crdb_replicas=9
export _ycsb_replicas=9
export _ycsb_insertcount=100000
export COCKROACH_DEV_ORG='Cockroach Labs Training'
export COCKROACH_DEV_LICENSE='crl-0-EIDA4OgGGAEiF0NvY2tyb2FjaCBMYWJzIFRyYWluaW5n'

# 1 node per AZ
roachprod create $f --geo --gce-zones \
europe-west1-b, europe-west1-c, europe-west1-d, \
europe-west2-a, europe-west2-b, europe-west2-c, \
europe-west3-a, europe-west3-b, europe-west3-c \
-n 9 --local-ssd-no-ext4-barrier 

# 2 nodes in west1 1 node otherwise
roachprod create $f --geo --gce-zones \
europe-west1-b,europe-west1-c,europe-west1-d,\
europe-west2-a,europe-west2-b,europe-west2-c,\
europe-west3-a,europe-west3-b,europe-west3-c \
-n 12 --local-ssd-no-ext4-barrier 

# use ycsb-roachprod.sh from here on down
