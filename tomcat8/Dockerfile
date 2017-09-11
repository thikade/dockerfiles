FROM opensuse:42.3
MAINTAINER thomas.hikade@gmail.com

RUN zypper refresh -s
RUN zypper install -y scout tomcat tomcat-admin-webapps tomcat-lib tomcat-webapps  vim vim-data curl  net-tools iproute2 telnet vim-plugin-gitdiff bind-utils net-tools 
RUN zypper install -y git python python-virtualenv  python-pip tar gzip man which ncurses-utils inotify-tools
RUN zypper install -y ansible
RUN zypper clean

ADD volumes/default/git/id* volumes/default/git/known_hosts /root/.ssh/
ADD volumes/default/git/gitconfig /etc/gitconfig
ADD volumes/default/.bashrc /root/.bashrc
RUN chmod 600 /root/.ssh/id_rsa && chmod 644 /root/.ssh/id_rsa.pub && chmod 644 /root/.ssh/known_hosts

ADD volumes/default/git-clone.sh /root/clone.sh

WORKDIR /root

CMD   [ "tail", "-f",  "/etc/hosts" ]

