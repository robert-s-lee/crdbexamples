
# create the subnets
docker network create -d bridge eastnet
docker network create -d bridge centralnet
docker network create -d bridge westnet

# start the east

tag=v1.0.3

docker run -d \
--cap-add NET_ADMIN \
--name=eastcrdb \
--hostname=eastcrdb \
--net=eastnet \
-e COCKROACH_SCAN_INTERVAL=1m \
-p 26257:26257 -p 8080:8080  \
-v "${PWD}/cockroach-data/roach1:/cockroach/cockroach-data"  \
cockroachdb/cockroach:${tag} start --insecure --locality=region=east --vmodule=allocator=5,replicate_queue=5

docker network connect centralnet eastcrdb
docker exec -t eastcrdb tc qdisc add dev eth1 root netem delay 40ms
docker network connect westnet eastcrdb
docker exec -t eastcrdb tc qdisc add dev eth2 root netem delay 80ms


# start the central

docker run -d \
--cap-add NET_ADMIN \
--name=centralcrdb \
--hostname=centralcrdb \
--net=centralnet \
-e COCKROACH_SCAN_INTERVAL=1m \
-v "${PWD}/cockroach-data/roach2:/cockroach/cockroach-data" \
cockroachdb/cockroach:${tag} start --insecure --locality=region=central --join=eastcrdb --vmodule=allocator=5,replicate_queue=5

docker network connect eastnet centralcrdb
docker exec -t centralcrdb tc qdisc add dev eth1 root netem delay 40ms
docker network connect westnet centralcrdb
docker exec -t centralcrdb tc qdisc add dev eth2 root netem delay 80ms

# start the west

docker run -d \
--cap-add NET_ADMIN \
--name=westcrdb \
--hostname=westcrdb \
--net=westnet \
-e COCKROACH_SCAN_INTERVAL=1m \
-v "${PWD}/cockroach-data/roach3:/cockroach/cockroach-data" \
cockroachdb/cockroach:${tag} start --insecure --locality=region=west --join=eastcrdb --vmodule=allocator=5,replicate_queue=5

docker network connect centralnet westcrdb
docker exec -t westcrdb tc qdisc add dev eth1 root netem delay 40ms
docker network connect eastnet westcrdb
docker exec -t westcrdb tc qdisc add dev eth2 root netem delay 80ms

# confrim 40ms and 80ms ping time
# first ping may come back with higher figures

docker exec -t eastcrdb ping -c 2 centralcrdb   # 40ms
docker exec -t eastcrdb ping -c 2 westcrdb      # 80ms 

docker exec -t centralcrdb ping -c 2 eastcrdb   # 40ms
docker exec -t centralcrdb ping -c 2 westcrdb   # 40ms

docker exec -t westcrdb ping -c 2 centralcrdb   # 40ms
docker exec -t westcrdb ping -c 2 eastcrdb      # 80ms

# copy files 
docker cp ddl.sql eastcrdb:/cockroach/.
docker cp 02-maa-setup-schema.sh eastcrdb:/cockroach/.
docker cp 03-maa-demo.sh eastcrdb:/cockroach/.
docker cp 03-maa-demo.sh centralcrdb:/cockroach/.
docker cp 03-maa-demo.sh westcrdb:/cockroach/.

# create schema
docker exec -t eastcrdb bash -c "/cockroach/02-maa-setup-schema.sh"

cat <<EOF
Run on of the following
docker exec -it eastcrdb bash -c "/cockroach/03-maa-demo.sh"
docker exec -it centralcrdb bash -c "/cockroach/03-maa-demo.sh"
docker exec -it westcrdb bash -c "/cockroach/03-maa-demo.sh"
EOF
