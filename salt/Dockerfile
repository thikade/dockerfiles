# Salt container
#
# docker run -it \
#   -n saltmaster \
#   -h master \
#   -p 4505 \
#   -p 4506 \
#   -p 8080 \
#   -p 8081 \
#   -e SALT_NAME=master \
#   -e SALT_USE=master \
#   -v `pwd`/srv/salt:/srv/salt:rw \
#   thikade/salt

FROM        debian:jessie
MAINTAINER  thikade "thomas.hikade@gmail.com"

# Update system 
RUN DEBIAN_FRONTEND=noninteractive apt-get update -qq && \
    apt-get install -yqq \
        wget \
        curl \
        vim \
        dnsutils \
        net-tools \
        python-pip \
        python-dev \
        python-apt \
        software-properties-common \
        dmidecode

# install saltstack
RUN echo "deb http://repo.saltstack.com/apt/debian/8/amd64/latest jessie main" | tee /etc/apt/sources.list.d/saltstack.list && \
    wget -q -O- "https://repo.saltstack.com/apt/debian/8/amd64/latest/SALTSTACK-GPG-KEY.pub" | apt-key add - && \
    DEBIAN_FRONTEND=noninteractive apt-get update -qq && \
    apt-get install -yqq \
    salt-master \
    salt-minion \
    salt-cloud \
    salt-api \
    salt-ssh \
    salt-syndic \
    && \
    pip install docker-py \
    && \
    apt-get -yqq clean && \
    apt-get -yqq purge && \
    rm -rf /tmp/* /var/tmp/* && \
    rm -rf /var/lib/apt/lists/*

# Add salt config files
COPY etc/master /etc/salt/master
COPY etc/minion /etc/salt/minion
COPY etc/reactor /etc/salt/master.d/reactor

# Expose volumes
VOLUME ["/etc/salt", "/var/cache/salt", "/var/logs/salt", "/srv/salt", "/etc/salt/pki"]

WORKDIR /srv/salt
EXPOSE 4505 4506 8080 8081
COPY start.sh /start.sh
CMD ["bash", "/start.sh"]
