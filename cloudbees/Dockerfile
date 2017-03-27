FROM registry.access.redhat.com/rhel7

RUN yum-config-manager --enable rhel-7-server-rpms 
RUN yum install -y --setopt=tsflags=nodocs java-1.8.0-openjdk-headless && yum clean all

ENV JENKINS_HOME /cloudbees
ENV JENKINS_HTTP_PORT 8080

EXPOSE 8080

WORKDIR ${JENKINS_HOME}

RUN wget https://downloads.cloudbees.com/cjoc/rolling/latest/jenkins-oc.war && wget https://downloads.cloudbees.com/cje/rolling/latest/jenkins.war 

# COPY start.sh apps/jenkins* ${JENKINS_HOME}/
COPY start.sh ${JENKINS_HOME}/

RUN chmod  o+rx  ${JENKINS_HOME}  && chmod -R a+r ${JENKINS_HOME}/*

USER 10001

CMD "${JENKINS_HOME}/start.sh"
