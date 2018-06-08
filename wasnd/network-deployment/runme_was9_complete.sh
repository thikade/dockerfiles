#!/bin/bash

docker run -d  --name caddy -p 8080:8080 -v /INSTALL_E:/data caddy
curl -sSo /dev/null  http://192.168.99.100:8080/WASND
if [ $? -eq 0 ] ; then
  echo "caddy is working"
else
  echo "caddy not working. Aborting"!
  exit 100
fi

docker build -t was9_delete_me -f Dockerfile.v9.prereq .
if [ $? -eq 0 ] ; then
  docker rmi was9_delete_me
fi
docker run --rm -v $(pwd):/tmp was9_delete_me

docker-compose -f docker-compose-build_was9.yml wasnd_install_step2

docker-compose -f docker-compose-build_was9.yml build dmgr
docker-compose -f docker-compose-build_was9.yml build node01
docker-compose -f docker-compose-build_was9.yml build node02


docker run -tdi --name node01 -h node01 -e NODE_NAME=CustomNode01   --net=cell-network  -e DMGR_HOST=dmgr -e DMGR_PORT=8879  wasnd-custom
echo "*********"
echo "wait for addNode.sh to finish on first node! Then ctrl-c to exit docker log -f ..."
echo "*********"
docker logs -f node01

docker run -tdi --name node02 -h node02 -e NODE_NAME=CustomNode02   --net=cell-network  -e DMGR_HOST=dmgr -e DMGR_PORT=8879  wasnd-custom
runme.sh (END)
