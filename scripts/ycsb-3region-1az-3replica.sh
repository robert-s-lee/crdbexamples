export f=robert-ycsb-3d1z1r
export ver=v20.2.0-beta.4
export branch=master
export _crdb_replicas=5
export _ycsb_replicas=3
export _ycsb_insertcount=100000
export COCKROACH_DEV_ORG='Cockroach Labs Training'
export COCKROACH_DEV_LICENSE='crl-0-EIDA4OgGGAEiF0NvY2tyb2FjaCBMYWJzIFRyYWluaW5n'

# 3 DC - 1 AZ per DC 3 way replicas
roachprod create $f --geo --gce-zones \
europe-west1-b,europe-west2-a,europe-west3-a \
-n 3 

# 3 DC - 1 AZ per DC 3 way replicas
roachprod create $f --geo --gce-zones \
us-central1-a,us-east1-a,us-east4-a \
-n 3 

# 3 DC - 1 AZ per DC 3 way replicas
roachprod create $f --geo --gce-zones \
us-west1-a,us-west2-a,us-west3-a \
-n 3 

# use ycsb-roachprod.sh from here on down
