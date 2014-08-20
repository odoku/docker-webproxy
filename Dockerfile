FROM ubuntu:14.04


MAINTAINER odoku


## Install Packages
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y aptitude
RUN apt-get install -y software-properties-common
RUN apt-get install -y openssh-server openssh-client

## Create user
RUN bash -c "echo 'docker:docker::::/home/docker:/bin/bash' | newusers"


## Change passwords
RUN bash -c 'echo "root:root" | chpasswd'


## Create PID directory
mkdir /var/run/sshd


## Set up SSH
RUN mkdir -p /home/docker/.ssh
RUN chown docker:docker /home/docker/.ssh
RUN chmod 700 /home/docker/.ssh


## setup sudoers
RUN echo "docker    ALL=(ALL)       ALL" >> /etc/sudoers.d/docker


## Set up SSHD config
RUN sed -ri 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config
RUN sed -ri 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/PubkeyAuthentication yes/PubkeyAuthentication no/g' /etc/ssh/sshd_config

## Init SSHD
RUN service ssh start
RUN service ssh stop


## Install HAProxy
RUN add-apt-repository ppa:vbernat/haproxy-1.5
RUN apt-get update -y
RUN apt-get install -y haproxy
RUN sed -ri 's/ENABLED=0/ENABLED=1/g' /etc/default/haproxy
ADD haproxy/haproxy.tmpl /home/docker/haproxy.tmpl


## Install docker-gen
RUN wget -P /usr/local/bin https://github.com/jwilder/docker-gen/releases/download/0.3.2/docker-gen-linux-amd64-0.3.2.tar.gz
RUN tar xvzf /usr/local/bin/docker-gen-linux-amd64-0.3.2.tar.gz -C /usr/local/bin
RUN chmod u+x /usr/local/bin/docker-gen
RUN rm /usr/local/bin/docker-gen-linux-amd64-0.3.2.tar.gz


## Install supervisor
RUN apt-get install -y supervisor
ADD supervisor/dockergen.conf /etc/supervisor/conf.d/docker-gen.conf
RUN mkdir /var/log/supervisor/dockergen
RUN service supervisor stop
RUN service supervisor start


## Restart rsyslog & haproxy
RUN service rsyslog restart
RUN service haproxy restart


## Open ports
EXPOSE 22
EXPOSE 80:80
EXPOSE 443:443


## Command
ENTRYPOINT ["/usr/sbin/sshd", "-D"]
