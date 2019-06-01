#!/bin/sh

PROJECT=custom-jenkins-v2
oc new-project $PROJECT || oc project $PROJECT

  # oc import-image openshift/jenkins-2-centos7:v3.11 --confirm
  # oc new-build https://github.com/thikade/dockerfiles.git --name=jenkins --strategy=docker  --image-stream=jenkins-2-centos7:v3.11  --context-dir=jenkins2

# use docker build to build our own jenkins image
oc new-build https://github.com/thikade/dockerfiles.git --name=jenkins-v2 -l app=jenkins-v2 --strategy=docker  --docker-image=docker.io/openshift/jenkins-2-centos7:v3.11  --context-dir=jenkins2

# process template and run jenkins
oc process -f jenkins-template.yml -p NAMESPACE=$PROJECT -p JENKINS_IMAGE_STREAM_TAG=jenkins-v2 -p JENKINS_SERVICE_NAME=jenkins-v2 -p JENKINS_VOLUME_NAME=pv0002 | oc create -f -

oc set env  dc/jenkins-v2  INSTALL_PLUGINS="nvm-wrapper"
oc set env --list dc/jenkins-v2

PODNAME=$(oc get pod -o name -l name=jenkins-v2)
oc logs $PODNAME | grep plugin

oc create -f pipeline_buildconfig.yml


oc delete bc jenkins-v3; oc delete is jenkins-v3
oc new-build https://github.com/thikade/dockerfiles.git --name=jenkins-v3 -l app=jenkins-v3 --strategy=docker  --docker-image=docker.io/openshift/jenkins-2-centos7:v3.11  --context-dir=jenkins2 --dockerfile $'FROM dummy\nRUN echo $JENKINS_HOME\nRUN test -f $JENKINS_HOME/hudson.tasks.Maven.xml && ls -l $JENKINS_HOME/hudson.tasks.Maven.xml || echo "file does not exist yet!"\nADD configuration/* $JENKINS_HOME/\nRUN cat $JENKINS_HOME/hudson.tasks.Maven.xml'
oc logs -f bc/jenkins-v3
