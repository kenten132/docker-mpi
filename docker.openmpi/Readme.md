## docker.openmpi

With the code in this repository, you can build a Docker container that provides 
the OpenMPI runtime and tools along with various supporting libaries, 
including the MPI4Py Python bindings. The container also runs an OpenSSH server
so that multiple containers can be linked together and used via `mpirun`.


## Start an MPI Container Cluster

While containers can in principle be started manually via `docker run`, we suggest that your use 
[Docker Compose](https://docs.docker.com/compose/), a simple command-line tool 
to define and run multi-container applications. We provde a sample `docker-compose.yml`
file in the repository:

```
mpi_head:
  image: openmpi
  ports: 
   - "22"
  links: 
   - mpi_worker

mpi_node: 
  image: openmpi

```

The file defines an `mpi_head` and an `mpi_node`. Both containers run the same `openmpi` image. 
The only difference is, that the `mpi_head` container exposes its SHH server to 
the host system, so you can log into it to start your MPI applications.


The following command will start one `mpi_head` container and three `mpi_node` containers: 

```
$> docker-compose up -d
$> docker-compose scale mpi_node=16 mpi_head=1
```
Once all containers are running, figure out the host port on which Docker exposes the  SSH server of the  `mpi_head` container: 

```
$> docker-compose ps
```

Now you know the port, you can login to the `mpi_head` container. The username is `tutorial`:


 ```
 $> chmod 400 ssh/id_rsa.mpi
 $> ssh -i ssh/id_rsa.mpi -p 23227 tutorial@localhost
 ```

For testing an mpi4py example using the mpi_nodes:
	
	cd mpi4py_benchmarks
	create machines file from /etc/hosts (copy only the IP adresses, nothing else)
	mpiexec -hostfile machines -n 3 python helloworld.py   	

For testing dispel4py with mpi mapping:
     
	mpiexec -n 6 -hostfile machines dispel4py mpi dispel4py.examples.graph_testing.pipeline_test	

