

oc new-project custom-jenkins || oc project custom-jenkins

oc create is jenkins-blueocean
oc create is jenkins-blueocean-plugins


# oc import-image openshift/jenkins-2-centos7:v3.11 --confirm

# use 2 s2i build to install update plugins
oc new-build openshift/jenkins-2-centos7:v3.11~https://github.com/thikade/dockerfiles.git --name=jenkins-plugins --strategy=source  --context-dir=jenkins

# use docker build to build our own jenkins image
oc new-build https://github.com/thikade/dockerfiles.git --name=jenkins --strategy=docker  --context-dir=jenkins  --image-stream=jenkins-plugins:latest

# process template and run jenkins
oc process -f jenkins-template.yml | oc -n custom-jenkins create -f -
