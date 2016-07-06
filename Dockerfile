FROM ubuntu:vivid

RUN apt-get update && apt-get install -y --no-install-recommends \
  gcc \
  openssh-server \
  openmpi-bin \
  libopenmpi-dev \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /var/run/sshd
RUN echo 'root:asdf' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

#ENV NOTVISIBLE "in users profile"
#RUN echo "export VISIBLE=now" >> /etc/profile

#EXPOSE 22

RUN adduser --disabled-password --gecos "" mpi
RUN echo 'mpi:asdf' | chpasswd
ENV HOME /home/mpi
WORKDIR $HOME

#COPY hosts /tmp/hosts
#RUN mkdir -p -- /lib-override && cp /lib/x86_64-linux-gnu/libnss_files.so.2 /lib-override
#RUN perl -pi -e 's:/etc/hosts:/tmp/hosts:g' /lib-override/libnss_files.so.2
#RUN echo "export LD_LIBRARY_PATH=/lib-override" >> $HOME/.bash_profile

COPY hosts /tmp/hosts
#RUN mkdir -p -- /lib-override && cp /lib/x86_64-linux-gnu/libnss_files.so.2 /lib-override
RUN perl -pi -e 's:/etc/hosts:/tmp/hosts:g' /lib/x86_64-linux-gnu/libnss_files.so.2
#RUN echo "export LD_LIBRARY_PATH=/lib-override" >> $HOME/.bash_profile
#ENV LD_LIBRARY_PATH /lib-override

COPY config .ssh/config
COPY id_rsa .ssh/id_rsa
COPY id_rsa.pub .ssh/authorized_keys
RUN chmod 600 .ssh/*
RUN chmod 644 .ssh/config
#RUN chown mpi .ssh/id_rsa .ssh/authorized_keys .ssh/config
#RUN chgrp mpi .ssh/id_rsa .ssh/authorized_keys .ssh/config

ADD machinefile machinefile

ADD barrier_test.c barrier_test.c
ADD hello.c hello.c
ADD ring.c ring.c
RUN mpicc -std=c99 -o hello hello.c
RUN mpicc -std=c99 -o ring ring.c
RUN mpicc -std=c99 -o barrier_test barrier_test.c

#RUN echo "export LD_LIBRARY_PATH=/usr/lib/openmpi/lib/" >> $HOME/.bash_profile
#RUN echo "export HOSTALIASES=~/hosts" >> $HOME/.bash_profile

RUN chgrp -R mpi $HOME
RUN chown -R mpi $HOME

#RUN echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

CMD ["/usr/sbin/sshd", "-D"]
#CMD ["sleep", "infinity"]
