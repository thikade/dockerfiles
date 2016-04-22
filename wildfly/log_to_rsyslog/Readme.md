Based on  jboss/wildfly:8.2.1.Final

* Sample app deployed: LoggingServlet.war
* JBoss Mmgt interface enabled/set to localhost:9990
+
* Added test-rsyslog-server's self-signed certificate
* configured JBoss to log to remote rsyslog server
** server IP/Port are defined in Dockerfile ENCV variables

URL: http://host:8080/LoggingServlet/log