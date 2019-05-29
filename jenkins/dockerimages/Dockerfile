From jenkins:latest
Maintainer thomas.hikade@gmail.com

# extend plugins and plugin.config


RUN env| grep -i jenkins

## DOCKERHUB JENKINSJENKINS_HOME=/var/jenkins_home
    JENKINS_UC_EXPERIMENTAL=https://updates.jenkins.io/experimental
    HOME=/var/jenkins_home
    JENKINS_UC=https://updates.jenkins.io
    JENKINS_VERSION=2.60.3
    JENKINS_SLAVE_AGENT_PORT=50000
    COPY_REFERENCE_FILE_LOG=/var/jenkins_home/copy_reference_file.log


### OPENSHIFT JENKINS
    ## JENKINS_HOME=/var/lib/jenkins
    ## JENKINS_UC=https://updates.jenkins.io
    ## HOME=/var/lib/jenkins
    ## OPENSHIFT_JENKINS_IMAGE_VERSION=3.11
    ## JENKINS_VERSION=2


USER root

#    cd /opt && wget http://www-eu.apache.org/dist/maven/maven-3/3.5.4/binaries/apache-maven-3.5.4-bin.tar.gz && \
#    tar xzf apache-maven-3.5.4-bin.tar.gz && ln -s apache-maven-3.5.4 maven && \
#    mkdir -p /var/jenkins_home/tools/hudson.tasks.Maven_MavenInstallation/ &&  \
#    ln -s /opt/apache-maven-3.5.4 /var/jenkins_home/tools/hudson.tasks.Maven_MavenInstallation/Maven-3.5.0 && \
#    chown -R 1001:root maven* && chown -R 1001:root /var/jenkins_home/ 

RUN rm -f /etc/localtime && ln -s /usr/share/zoneinfo/Europe/Vienna /etc/localtime

RUN ls -l $JENKINS_HOME/


ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0
    

USER 1000



