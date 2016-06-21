FROM jboss/wildfly:8.2.1.Final

ENV WF_MGMT_BIND_ADDRESS 0.0.0.0

ARG LICENSE_KEY='replace_with_your_newrelic_license_key'

# Expose the ports we're interested in

# defaulthost port
EXPOSE 8080
# Mgmt port
EXPOSE 9990

USER root

# RUN yum -y update && yum -y install iproute net-tools less 
RUN yum -y install iproute net-tools less socat nc telnet

# add remote server certificate to Java trust file
COPY  ca.pem /etc/pki/ca-trust/extracted/java/ca.pem
RUN	keytool -import -alias rsyslog.test -file /etc/pki/ca-trust/extracted/java/ca.pem  -keystore /etc/pki/ca-trust/extracted/java/cacerts -storepass changeit  -noprompt
RUN	keytool -list -alias rsyslog.test  -keystore /etc/pki/ca-trust/extracted/java/cacerts -storepass changeit


USER jboss 

# needed to access admin console localhost:9990/console/
RUN /opt/jboss/wildfly/bin/add-user.sh admin admin1a --silent

# INSTALL newrelic java agent
COPY resources/newrelic /opt/jboss/wildfly/newrelic
# Add our config yml
COPY config/newrelic.yml  /opt/jboss/wildfly/newrelic/newrelic.yml


USER root
RUN cd /opt/jboss/wildfly/newrelic/ && sed -e "s/@LICENSE_KEY@/$LICENSE_KEY/" newrelic.yml > newrelic.yml.2 && mv newrelic.yml.2 newrelic.yml
RUN chown -R jboss:jboss /opt/jboss/wildfly/newrelic

USER jboss 
RUN cd /opt/jboss/wildfly/newrelic && java -jar newrelic.jar install

RUN grep "2innovate" /opt/jboss/wildfly/newrelic/newrelic.yml


# not needed at the moment!
# COPY logger-config.cli /home/jboss/commands.cli
# COPY execute-cli.sh    /home/jboss/execute-cli.sh
# RUN /bin/bash /home/jboss/execute-cli.sh

# will just log a timestamp to stdout
# access deployed servlet: http://1.2.3.4:8080//LoggingServlet/log
COPY LoggingServlet.war  /opt/jboss/wildfly/standalone/deployments/

#RUN ls -l /opt/jboss/wildfly/standalone/deployments/
# needed to fix startup error: https://github.com/tsaarni/docker-ejbca/issues/1
RUN rm -rf /opt/jboss/wildfly/standalone/configuration/standalone_xml_history/current

# Set the default command to run on boot
# This will boot WildFly in the standalone mode and bind to all interface
CMD /opt/jboss/wildfly/bin/standalone.sh -bmanagement=$WF_MGMT_BIND_ADDRESS -b 0.0.0.0
#RUN echo /opt/jboss/wildfly/bin/standalone.sh -bmanagement=$WF_MGMT_BIND_ADDRESS -b 0.0.0.0
#CMD /bin/bash
