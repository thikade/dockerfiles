#!/bin/sh

PROJECT=custom-jenkins-v2
oc delete project $PROJECT
oc new-project $PROJECT

# oc import-image openshift/jenkins-2-centos7:v3.11 --confirm

# use docker build to build our own jenkins image
oc new-build https://github.com/thikade/dockerfiles.git --name=jenkins -l app=jenkins --strategy=docker  --docker-image=docker.io/openshift/jenkins-2-centos7:v3.11  --context-dir=jenkins2

# create configmap for XML configurations that will be mounted into container later-on
oc create configmap jenkins-config-maven --from-file=configuration/hudson.tasks.Maven.xml --dry-run -o yaml | oc -n $PROJECT apply -f -

# process template and run jenkins
### oc delete all -l template=jenkins-digi-template
### oc get all -l template=jenkins-digi-template

oc process -f
 jenkins-template.yml -p NAMESPACE=$PROJECT -p JENKINS_IMAGE_STREAM_TAG=jenkins:latest -p JENKINS_SERVICE_NAME=jenkins -p JENKINS_VOLUME_NAME=pv0002 | oc apply -f -

oc set triggers dc/jenkins --manual

### configure JENKINS

oc set volume dc/jenkins --add  --name=maven-config --mount-path=/var/lib/jenkins/hudson.tasks.Maven.xml --sub-path=hudson.tasks.Maven.xml  --type=configmap --configmap-name=jenkins-config-maven

oc set env  dc/jenkins  INSTALL_PLUGINS="nvm-wrapper"
# oc set env --list dc/jenkins

oc set triggers dc/jenkins --auto

PODNAME=$(oc get pod -o name -l name=jenkins)
oc logs -f $PODNAME
oc logs $PODNAME | grep plugin

oc create -f pipeline_buildconfig.yml


oc delete bc jenkins-v3; oc delete is jenkins-v3
oc new-build https://github.com/thikade/dockerfiles.git --name=jenkins-v3 -l app=jenkins-v3 --strategy=docker  --docker-image=docker.io/openshift/jenkins-2-centos7:v3.11  --context-dir=jenkins2 --dockerfile $'FROM dummy\nRUN echo $JENKINS_HOME\nRUN test -f $JENKINS_HOME/hudson.tasks.Maven.xml && ls -l $JENKINS_HOME/hudson.tasks.Maven.xml || echo "file does not exist yet!"\nADD configuration/* $JENKINS_HOME/\nRUN cat $JENKINS_HOME/hudson.tasks.Maven.xml'
oc logs -f bc/jenkins-v3
