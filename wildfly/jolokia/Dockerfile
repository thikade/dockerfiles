FROM jboss/wildfly:10.1.0.Final

ARG WAR_LOCATION
ENV WAR_LOCATION=${WAR_LOCATION}

ENV WILDFLY_MGMT_BIND_ADDRESS 0.0.0.0


# Expose the ports we're interested in

# defaulthost port
EXPOSE 8080
EXPOSE 9990

USER root

# RUN yum -y update && yum -y install iproute net-tools less 
RUN yum -y install iproute net-tools less socat nc telnet


USER jboss 

# DEPLOY APPS
COPY apps/*.war    /opt/jboss/wildfly/standalone/deployments/

COPY config/* /opt/jboss/wildfly/standalone/configuration/

RUN ls -ltr /opt/jboss/wildfly/standalone/deployments/  /opt/jboss/wildfly/standalone/configuration

# Set the default command to run on boot
# This will boot WildFly in the standalone mode and bind to all interface
CMD /opt/jboss/wildfly/bin/standalone.sh -bmanagement=$WILDFLY_MGMT_BIND_ADDRESS -b 0.0.0.0
