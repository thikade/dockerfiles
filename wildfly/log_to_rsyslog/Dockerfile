FROM jboss/wildfly:8.2.1.Final

ENV WF_MGMT_BIND_ADDRESS 0.0.0.0

ENV RSYSLOG_IP=46.101.229.67
ENV RSYSLOG_PORT=10514

# Expose the ports we're interested in

# defaulthost port
EXPOSE 8080
# Mgmt port
EXPOSE 9990

USER root

# RUN yum -y update && yum -y install iproute net-tools less 
RUN yum -y install iproute net-tools less 

# add rsyslog's server certificate
ADD  ca.pem /etc/pki/ca-trust/extracted/java/ca.pem
RUN	keytool -import -alias rsyslog.test -file /etc/pki/ca-trust/extracted/java/ca.pem  -keystore /etc/pki/ca-trust/extracted/java/cacerts -storepass changeit  -noprompt
RUN	keytool -list -alias rsyslog.test  -keystore /etc/pki/ca-trust/extracted/java/cacerts -storepass changeit


USER jboss 

# needed to access admin console localhost:9990/console/
RUN /opt/jboss/wildfly/bin/add-user.sh admin admin1a --silent

ADD logger-config.cli /home/jboss/commands.cli
ADD execute-cli.sh    /home/jboss/execute-cli.sh
RUN /bin/bash /home/jboss/execute-cli.sh

# will just log a timestamp to stdout
# access deployed servlet: http://192.168.99.100:8080//LoggingServlet/log
ADD LoggingServlet.war  /opt/jboss/wildfly/standalone/deployments/

#RUN ls -l /opt/jboss/wildfly/standalone/deployments/
# needed to fix startup error: https://github.com/tsaarni/docker-ejbca/issues/1
RUN rm -rf /opt/jboss/wildfly/standalone/configuration/standalone_xml_history/current

# Set the default command to run on boot
# This will boot WildFly in the standalone mode and bind to all interface
CMD /opt/jboss/wildfly/bin/standalone.sh -bmanagement=$WF_MGMT_BIND_ADDRESS -b 0.0.0.0
