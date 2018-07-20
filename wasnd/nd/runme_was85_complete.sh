#!/bin/bash

WEB_URL=${$1:-http://192.168.99.100:8080}

docker images | grep wasnd85-noprofile
if [ $? -ne 0 ] ; then

    if [ ! -f "install/was.tar" ]; then
      if docker ps | grep caddy ; then
          echo "caddy is running"
      else
          echo "starting caddy"
          docker run -d  --name caddy -p 8080:8080 -v /INSTALL:/data caddy
      fi

      curl -sSo /dev/null  $WEB_URL/WASND
      if [ $? -eq 0 ] ; then
        echo "caddy is working"
      else
        echo "caddy not working. Aborting"!
        exit 100
      fi

      echo -e "\ninstalling WASND v85 - Step 1\n"
      docker-compose -f docker-compose-build-was85.yml build wasnd_install_step1
      docker images  | grep "was85_delete_me"
      if [ $? -ne 0 ]; then
         echo "ERROR: WAS intermediary install container not found!"
         echo "==========="
         docker images
         echo "==========="
         exit 101
      fi

      echo -e "\n\n*** creating was.tar (installing WASND v85 - Step 2)\n"
      docker run -ti --rm -v $(pwd):/tmp was85_delete_me
      if [ $? -ne 0 ]; then
         echo "Error: failed in step2"
         exit 102
      fi

      if [ -f "was.tar" ] ; then
        echo -e "*** WAS Install image 'was.tar' created successfully"
        docker rmi was85_delete_me
        mv was.tar install/
      else
        exit 103
      fi

    fi

    echo -e "\n\n*** creating the final WAS v85 Docker base image ...\n"
    docker-compose -f docker-compose-build-was85.yml build wasnd_install_step2
    docker images | grep wasnd85-noprofile
    if [ $? -eq 0 ] ; then
      echo "WASv85 base image created successfully!"
      echo "removing install/was.tar"
      rm install/was.tar
    else
      exit 104
    fi
fi

# wait for node rename operation upon first startup of nodes
sleeptime=10
maxwait=300



docker images | grep wasnd85-dmgr || docker-compose -f docker-compose-build-was85.yml build dmgr
docker-compose -f docker-compose-build-was85.yml up -d dmgr

i=0
while (( ($i * $sleeptime) < $maxwait )); do
    sleep $sleeptime
    let i=i+1
    docker-compose -f docker-compose-build-was85.yml logs dmgr | grep 'DMGR SETUP COMPLETE'
    rc=$?
    test $rc -eq 0 && break
done
if [ $rc -gt 0 ]; then
  echo "\n ** err during dmgr startup"
  exit 99
fi
echo -e "\n*** Container dmgr is started\n"

docker images |  grep wasnd85-node01 || docker-compose -f docker-compose-build-was85.yml build node01
docker-compose -f docker-compose-build-was85.yml up -d node01

i=0
while (( ($i * $sleeptime) < $maxwait )); do
    sleep $sleeptime
    let i=i+1
    docker-compose -f docker-compose-build-was85.yml logs node01 | egrep 'NODE RECONFIG COMPLETE'
    rc=$?
    test $rc -eq 0 && break
done
if [ $rc -gt 0 ]; then
  echo "\n ** err during node01 initial startup"
  exit 98
fi


echo -e "\n*** Container node01 is started\n"

docker images |  grep wasnd85-node02 || docker-compose -f docker-compose-build-was85.yml build node02
docker-compose -f docker-compose-build-was85.yml up -d node02

i=0
while (( ($i * $sleeptime) < $maxwait )); do
    sleep $sleeptime
    let i=i+1
    docker-compose -f docker-compose-build-was85.yml logs node02 | egrep 'NODE RECONFIG COMPLETE'
    rc=$?
    test $rc -eq 0 && break
done
if [ $rc -gt 0 ]; then
  echo "\n ** err during node02 initial startup"
  exit 98
fi

echo -e "\n*** Container node02 is started\n"


docker commit dmgr wasnd85-cell-dmgr
docker commit node01 wasnd85-cell-node01
docker commit node02 wasnd85-cell-node02

docker images| grep "wasnd85-cell"
echo -e "\n*** WASv85 CELL images commited. All operations finished!\n"
