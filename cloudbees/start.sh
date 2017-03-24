#!/bin/sh 
cd ${JENKINS_HOME} 
if [ -n "$JENKINS_OPERATIONS_CENTER" ]; then
  echo "starting Cloudbees Operations Center ..."
  java -jar ./jenkins-oc.war --httpPort=${JENKINS_HTTP_PORT}
elif [ -n "$JENKINS_MASTER" ]; then
  echo "starting Cloudbees Master node ..."
  java -jar ./jenkins.war --httpPort=${JENKINS_HTTP_PORT}
else
  echo "-----------------------------------------------------------------------------------------"
  echo "ERROR: missing ENV variable. Specify either JENKINS_OPERATIONS_CENTER or JENKINS_MASTER !"
  echo "-----------------------------------------------------------------------------------------"
fi
