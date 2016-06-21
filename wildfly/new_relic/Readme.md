Based on  jboss/wildfly:8.2.1.Final

* NewRelic java agent added. 
** Specify your NewRelic license string during "docker build --build-arg LICENSE_KEY=134782iahadhx..."
* Sample app deployed: LoggingServlet.war
* JBoss Mmgt interface enabled/set to localhost:9990
+
* Added test-rsyslog-server's self-signed certificate
** server IP/Port are defined in Dockerfile ENV variables

URL: http://host:8080/LoggingServlet/log