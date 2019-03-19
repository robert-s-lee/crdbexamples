
eastcrdb 172.18.0.2
centralcrdb 172.19.0.2
westcrdb 172.20.0.3

# tc qdisc add dev eth0 root netem loss 100%
# eth1 = central
# eht2 = west
docker exec -t eastcrdb tc qdisc replace dev eth1 root netem loss 100% # east loses connection to central
docker exec -t eastcrdb tc qdisc replace dev eth2 root netem loss 100% # east loses connection to west

tc qdisc show dev eth2

east 172.18.0.0
central 172.19.0.0
west 172.20.0.0


east      eth0
  central eth1
  west    eth2

central eth0
  east  eth1
  west  eth2

west  eth0
  central eth1
  east  eth2

