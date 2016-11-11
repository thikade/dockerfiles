#!/bin/sh

docker build -t thikade/wf821:newrelic-0.2  --build-arg LICENSE_KEY=e0bc4c990ecabe873dc5ebdb09b8ef28aabd6c62 .
if [  $? -eq 0 ]; then
  docker run  -ti --rm --name wf -v /c/Users/ThomasHikade/DockerVolumes/wildfly:/opt/jboss/wildfly/standalone/log -p 8080:8080 -p 9990:9990 -h wf821-newrelic --entrypoint /bin/bash thikade/wf821:newrelic-0.2
else
  echo "**** ERROR during docker build step!"
fi
