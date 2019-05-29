FROM registry.access.redhat.com/openshift3/jenkins-2-rhel7:v3.11

USER root

RUN yum repolist > /dev/null && \
    yum-config-manager --enable rhel-7-server-rpms && \
    yum-config-manager --enable rhel-7-server-ose-3.11-rpms && \
    yum-config-manager --enable rhel-7-server-extras-rpms && \
    yum-config-manager --enable rhel-7-server-optional-rpms && \
    yum install -y --setopt=tsflags=nodocs skopeo atomic-openshift-clients maven libselinux-utils && \
    yum clean all && \
    rm -f /etc/localtime && ln -s /usr/share/zoneinfo/Europe/Vienna /etc/localtime && \
    cd /opt && wget http://www-eu.apache.org/dist/maven/maven-3/3.5.4/binaries/apache-maven-3.5.4-bin.tar.gz && \
    tar xzf apache-maven-3.5.4-bin.tar.gz && ln -s apache-maven-3.5.4 maven && \
    mkdir -p /var/jenkins_home/tools/hudson.tasks.Maven_MavenInstallation/ && ln -s /opt/apache-maven-3.5.4 /var/jenkins_home/tools/hudson.tasks.Maven_MavenInstallation/Maven-3.5.0 && \
    chown -R 1001:root maven* && chown -R 1001:root /var/jenkins_home/ 
    

COPY cert/cacerts /tmp/cacerts

RUN  /usr/lib/jvm/java-1.8.0/bin/keytool -importkeystore -srcstorepass changeit -deststorepass changeit -srckeystore /tmp/cacerts -destkeystore /etc/pki/ca-trust/extracted/java/cacerts

ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0
#ENV PATH=${M2_HOME}/bin:${PATH}
    

USER 1000
