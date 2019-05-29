

oc new-project custom-jenkins || oc project custom-jenkins

oc create is jenkins-blueocean
oc create is jenkins-blueocean-plugins


# oc import-image openshift/jenkins-2-centos7:v3.11 --confirm

oc new-build openshift/jenkins-2-centos7:v3.11~https://github.com/thikade/dockerfiles.git --name=jenkins-plugins --strategy=source  --context-dir=jenkins
oc new-build https://github.com/thikade/dockerfiles.git --name=jenkins --strategy=docker  --context-dir=jenkins 

oc start-build jenkins-plugins
