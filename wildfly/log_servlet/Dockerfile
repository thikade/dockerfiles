FROM jboss/wildfly:8.2.1.Final

ENV WF_MGMT_BIND_ADDRESS 0.0.0.0
ENV SYSLOG_SERVER_ADDRESS 127.0.0.1

# Expose the ports we're interested in

# defaulthost port
EXPOSE 8080
# Mgmt port
EXPOSE 9990

USER root

RUN yum -y install iproute net-tools less 

USER jboss 

RUN /opt/jboss/wildfly/bin/add-user.sh admin admin1a --silent

# will just log a timestamp to stdout
# access deployed servlet: http://192.168.99.100:8080//LoggingServlet/log
ADD LoggingServlet.war  /opt/jboss/wildfly/standalone/deployments/

RUN ls -l /opt/jboss/wildfly/standalone/deployments/


# Set the default command to run on boot
# This will boot WildFly in the standalone mode and bind to all interface
CMD /opt/jboss/wildfly/bin/standalone.sh -bmanagement=$WF_MGMT_BIND_ADDRESS -b 0.0.0.0
