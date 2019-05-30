

oc new-project custom-jenkins-v2 || oc project custom-jenkins-v2


# oc import-image openshift/jenkins-2-centos7:v3.11 --confirm


# use docker build to build our own jenkins image
oc new-build https://github.com/thikade/dockerfiles.git --name=jenkins --strategy=docker  --image-stream=openshift/jenkins-2-centos7:v3.11  --context-dir=jenkins2

# process template and run jenkins
oc process -f jenkins-template.yml | oc -n custom-jenkins create -f -
