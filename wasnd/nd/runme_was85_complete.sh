#!/bin/bash

docker images | grep wasnd85-noprofile
if [ $? -ne 0 ] ; then

    if [ ! -f "install/was.tar" ]; then
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
        docker rmi -f was85_delete_me
        mv was.tar install/
        #
        # Copy jar file with customer registry sample class
        cp -p customRegistry.jar install/
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
      rm install/customRegistry.jar
    else
      exit 104
    fi
fi

# wait for node rename operation upon first startup of nodes
sleeptime=10
maxwait=600


docker images | grep wasnd85-dmgr || docker-compose -f docker-compose-build-was85.yml build dmgr
docker-compose -f docker-compose-build-was85.yml up -d dmgr

i=0
while (( ($i * $sleeptime) < $maxwait )); do
    sleep $sleeptime
    let i=i+1
    echo -e "\n\n all log entries from dmgr container ..."
    docker-compose -f docker-compose-build-was85.yml logs dmgr
    docker-compose -f docker-compose-build-was85.yml logs dmgr | grep 'DMGR SETUP COMPLETE'
    rc=$?
    test $rc -eq 0 && break
done
if [ $rc -gt 0 ]; then
  echo "\n ** err during dmgr startup"
  exit 99
fi
##### sleep 120
echo "Container dmgr is started. Press any key to continue ..."
##### read hhue

docker images |  grep wasnd85-node01 || docker-compose -f docker-compose-build-was85.yml build node01
docker-compose -f docker-compose-build-was85.yml up -d node01

i=0
while (( ($i * $sleeptime) < $maxwait )); do
    sleep $sleeptime
    let i=i+1
    echo -e "\n\n all log entries from node01 container ..."
    docker-compose -f docker-compose-build-was85.yml logs node01
    docker-compose -f docker-compose-build-was85.yml logs node01 | egrep 'NODE RECONFIG COMPLETE'
    rc=$?
    test $rc -eq 0 && break
done
if [ $rc -gt 0 ]; then
  echo "\n ** err during node01 initial startup"
  exit 98
fi
##### sleep 180
echo "Container node01 is started. Press any key to continue ..."
##### read hhue

docker images |  grep wasnd85-node02 || docker-compose -f docker-compose-build-was85.yml build node02
docker-compose -f docker-compose-build-was85.yml up -d node02

i=0
while (( ($i * $sleeptime) < $maxwait )); do
    sleep $sleeptime
    let i=i+1
    echo -e "\n\n all log entries from node02 container ..."
    docker-compose -f docker-compose-build-was85.yml logs node02
    docker-compose -f docker-compose-build-was85.yml logs node02 | egrep 'NODE RECONFIG COMPLETE'
    rc=$?
    test $rc -eq 0 && break
done
if [ $rc -gt 0 ]; then
  echo "\n ** err during node02 initial startup"
  exit 98
fi
##### sleep 240
echo "Container node02 is started. Press any key to continue ..."
##### read hhue


docker commit dmgr wasnd85-cell-dmgr
docker commit node01 wasnd85-cell-node01
docker commit node02 wasnd85-cell-node02

docker tag wasnd85-cell-dmgr gcr.io/was-config-tool/wasnd-cell-dmgr:8.5.5.17
docker tag wasnd85-cell-node01 gcr.io/was-config-tool/wasnd-cell-node01:8.5.5.17
docker tag wasnd85-cell-node02 gcr.io/was-config-tool/wasnd-cell-node02:8.5.5.17

docker tag wasnd85-cell-dmgr s008aa39r:18444/wasnd85-cell-dmgr:latest
docker tag wasnd85-cell-node01 s008aa39r:18444/wasnd85-cell-node01:latest
docker tag wasnd85-cell-node02 s008aa39r:18444/wasnd85-cell-node02:latest


docker images| grep "wasnd85-cell"
echo -e "\n*** WASv85 CELL images commited. All operations finished!\n"
