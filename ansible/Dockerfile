FROM ubuntu:latest
# tag as thikade/ansible:2.7-ubuntu

MAINTAINER  thikade "thomas.hikade@gmail.com"

# Update system
RUN DEBIAN_PRIORITY=critical DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_PRIORITY=critical DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        wget curl less \
        vim vim-editorconfig vim-python-jedi vim-syntastic \
        dnsutils net-tools iputils-ping build-essential \
        python2.7 python-pip python-virtualenv virtualenv python-setuptools python-dev \
        software-properties-common openssh-client \
        gzip man debianutils ncurses-base ncurses-term ncurses-bin inotify-tools \
	openssh-server openssh-client \
	supervisor \
	&& \
    apt-get -yqq clean && apt-get -yqq purge && \
    rm -rf /tmp/* /var/tmp/* && \
    rm -rf /var/lib/apt/lists/*


# RUN pip install --upgrade pip && pip install ansible
RUN pip install ansible
RUN mkdir -p /var/run/sshd /var/log/supervisor /root/.ssh

ADD volumes/default/ansible-ssh-keys/id* /root/.ssh/
ADD volumes/default/git/gitconfig /etc/gitconfig
ADD volumes/default/.bashrc /root/.bashrc
ADD volumes/default/startSSHAgentUnique.sh /root/

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD volumes/default/ansible_hosts /etc/ansible/hosts
ADD volumes/default/ansible.cfg /etc/ansible/

RUN chmod 600 /root/.ssh/id_rsa && chmod 644 /root/.ssh/id_rsa.pub && touch /root/.ssh/known_hosts && chmod 644 /root/.ssh/known_hosts
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys


WORKDIR /root
EXPOSE 22

CMD ["/usr/bin/supervisord"]
