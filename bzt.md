
docker run -itd -v ${PWD}/cockroach-data/:/cockroach --name=bzt bzt:jmeter bash

for net in east west central sw sc se; do
  echo $net
  docker network connect ${net}net bzt
done


