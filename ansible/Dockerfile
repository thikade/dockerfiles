FROM        ubuntu:latest
MAINTAINER  thikade "thomas.hikade@gmail.com"

# Update system 
# RUN DEBIAN_FRONTEND=noninteractive apt-get update 
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y \
        wget curl vim \
        dnsutils  net-tools  iputils-ping \
        python-pip python-dev  python-apt \
        software-properties-common \
        dmidecode  \
        ansible \
        openssh-server openssh-client \
        supervisor \
        && \
        apt-get -yqq clean && \
        apt-get -yqq purge && \
        rm -rf /tmp/* /var/tmp/* && \
        rm -rf /var/lib/apt/lists/*

# copy configs
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN mkdir -p /var/run/sshd /var/log/supervisor /home/root/.ssh /opt/ansible/extlib /opt/ansible/src
COPY sshkeys/* /home/root/.ssh/
RUN cp /home/root/.ssh/id_rsa.pub /home/root/.ssh/authorized_keys && chmod 700 /home/root/.ssh && chmod 600 /home/root/.ssh/authorized_keys /home/root/.ssh/id*


EXPOSE 22 


ENV ANSIBLE_LIBRARY  /opt/ansible/extlib
 
# Expose volumes
VOLUME ["/opt/ansible/extlib" , "/opt/ansible/src" ]

WORKDIR "/opt/ansible/src"

#EXPOSE 4505 4506 8080 8081
#COPY start.sh /start.sh
#CMD ["bash", "/start.sh"]

# CMD tail -n0 -f /etc/hosts
CMD ["/usr/bin/supervisord"]
