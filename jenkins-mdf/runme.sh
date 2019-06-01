#!/bin/sh

oc delete project custom-jenkins
oc new-project custom-jenkins


# oc import-image openshift/jenkins-2-centos7:v3.11 --confirm

# use 2 s2i build to install update plugins
oc new-build openshift/jenkins-2-centos7:v3.11~https://github.com/thikade/dockerfiles.git --name=jenkins-plugins --strategy=source  --context-dir=jenkins-mdf

# use docker build to build our own jenkins image
oc new-build https://github.com/thikade/dockerfiles.git --name=jenkins -l app=jenkins --strategy=docker  --context-dir=jenkins-mdf  --image-stream=jenkins-plugins:latest  --allow-missing-imagestream-tags

# process template and run jenkins
oc process -f jenkins-template.yml -p JENKINS_SERVICE_NAME=jenkins -p JENKINS_VOLUME_NAME=pv0001 | oc -n custom-jenkins create -f -
oc create -f pipeline_buildconfig.yml