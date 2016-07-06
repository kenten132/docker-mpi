#!/bin/bash

docker kill mpi
docker rm mpi
docker run --name mpi -d rakurai/openmpi
sudo pipework/pipework br1 mpi 10.10.1.100/24

for i in `seq 1 8`; do
  ip=10.10.1.10$i
  name=mpi-$i
  ssh xwing$i "docker kill mpi; docker rm mpi; docker pull rakurai/openmpi; docker run -h $name --name mpi -d rakurai/openmpi; sudo mpitest/pipework/pipework br1 mpi $ip/24" &
done
