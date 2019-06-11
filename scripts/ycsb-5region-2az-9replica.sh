export f=robert-ycsb-5d2z9r
export ver=v19.1.1
export branch=master
export _crdb_replicas=9
export _ycsb_replicas=9
export _ycsb_insertcount=100000
export COCKROACH_DEV_ORG='Cockroach Labs Training'
export COCKROACH_DEV_LICENSE='crl-0-EIDA4OgGGAEiF0NvY2tyb2FjaCBMYWJzIFRyYWluaW5n'


# 5 DC - 2 AZ per DC 9 way replicas
roachprod create $f --geo --gce-zones \
europe-west1-b,europe-west2-a,europe-west3-a,europe-west4-a,europe-west6-a,europe-west1-c,europe-west2-c,europe-west3-b,europe-west4-b,europe-west6-b \
 -n 9 --local-ssd-no-ext4-barrier

# use ycsb-roachprod.sh from here on down

