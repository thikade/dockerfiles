FROM        ubuntu:latest
MAINTAINER  thikade "thomas.hikade@gmail.com"

ENV JENKINS_HOME /cloudbees
ENV JENKINS_OC_HTTP_PORT 8080
ENV JENKINS_MASTER_HTTP_PORT 8081

# Update system 
RUN DEBIAN_FRONTEND=noninteractive apt-get update -qq && \
    apt-get install -yqq \
        wget \
        curl \
        vim \
        dnsutils \
        net-tools  \
	openjdk-8-jdk \
    && \
    apt-get -yqq clean && \
    apt-get -yqq purge && \
    rm -rf /tmp/* /var/tmp/* && \
    rm -rf /var/lib/apt/lists/*

ENV JENKINS_HTTP_PORT 8080

# RUN wget https://downloads.cloudbees.com/cjoc/rolling/latest/jenkins-oc.war && wget https://downloads.cloudbees.com/cje/rolling/latest/jenkins.war 
WORKDIR ${JENKINS_HOME}
COPY start.sh apps/jenkins* ${JENKINS_HOME}/
RUN chmod  o+rx  ${JENKINS_HOME}  && chmod -R a+r ${JENKINS_HOME}/*

# Expose volumes
# VOLUME ["abc"]

EXPOSE $JENKINS_HTTP_PORT

CMD "${JENKINS_HOME}/start.sh"
