#!/bin/sh

oc new-project custom-jenkins-v2 || oc project custom-jenkins-v2

  # oc import-image openshift/jenkins-2-centos7:v3.11 --confirm
  # oc new-build https://github.com/thikade/dockerfiles.git --name=jenkins --strategy=docker  --image-stream=jenkins-2-centos7:v3.11  --context-dir=jenkins2

# use docker build to build our own jenkins image
oc new-build https://github.com/thikade/dockerfiles.git --name=jenkins-v2 -l app=jenkins-v2 --strategy=docker  --docker-image=docker.io/openshift/jenkins-2-centos7:v3.11  --context-dir=jenkins2

# process template and run jenkins
oc process -f jenkins-template.yml -p JENKINS_SERVICE_NAME=jenkins-v2 -p JENKINS_VOLUME_NAME=pv0002 | oc create -f -

oc set env  dc/jenkins-v2  INSTALL_PLUGINS="nvm-wrapper"
oc set env --list dc/jenkins-v2

PODNAME=$(oc get pod -o name -l name=jenkins-v2)
oc logs $PODNAME | grep plugin

oc new-build