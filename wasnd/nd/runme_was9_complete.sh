#!/bin/bash

WEB_URL=${1:-http://192.168.99.100:8080}

IMAGE_VERSION=9050
BASE_IMAGE=wasnd9-noprofile:9050

echo "#1 checking for base image: \"${BASE_IMAGE}\""

docker images --format ' {{.Repository }}:{{.Tag}}' | grep ${BASE_IMAGE}  > /dev/null
if [ $? -ne 0 ] ; then
    echo "#1.1 building base image \"${BASE_IMAGE}\""
      echo "wait..."
      read key
    echo -e "#2 Checking for WAS.tar export file ..."
    if [ ! -f "was9.tar" ]; then
      echo -e "#2.1 install/was9.tar not found. Installing base WAS."
      if docker ps | grep caddy  > /dev/null ; then
          echo "#2.2 caddy is running"
      else
          echo "#2.2 starting caddy"
          docker run -d  --name caddy -p 8080:8080 -v /INSTALL:/data caddy
      fi

      curl -sSo /dev/null  $WEB_URL/WASND
      if [ $? -eq 0 ] ; then
        echo "#2.3 caddy tested ok"
      else
        echo "#2.3 caddy reported 404. Aborting"!
        exit 100
      fi

      echo "#2.4 installing WASND v9 - Step 1"
      docker-compose -f docker-compose-build-was9.yml build wasnd_install_step1
      docker images --format ' {{.Repository }}:{{.Tag}}'  | grep "was9_delete_me" > /dev/null
      if [ $? -ne 0 ]; then
         echo "#2.4 ERROR: WAS intermediary install container not found!"
         echo "==========="
         docker images
         echo "==========="
         exit 101
      fi

      echo "#2.5 creating was9.tar (installing WASND v9 - Step 2)"
      docker run -ti --rm -v $(pwd):/tmp was9_delete_me
      if [ $? -ne 0 ]; then
         echo "#2.5 Error: creating was9.tar failed"
         exit 102
      fi

      if [ -f "was9.tar" ] ; then
        echo "#2.6 WAS Install image 'was9.tar' created successfully"
        docker rmi was9_delete_me
        ln was9.tar install/
      else
        exit 103
      fi

    else
      echo -e "#2 was9.tar already there. Skipping build."
      # check symlink
      test ! -f install/was9.tar && ln  was9.tar install/
    fi


    echo "#2.10 creating the final WAS v9 Docker base image using tar ..."
    docker-compose -f docker-compose-build-was9.yml build wasnd_install_step2
    docker images --format ' {{.Repository }}:{{.Tag}}' | grep ${BASE_IMAGE}  > /dev/null
    if [ $? -eq 0 ] ; then
      echo "#2.10 WASv9 base image \"${BASE_IMAGE}\" created successfully!"
      echo "#2.10 DEBUG: NOT removing install/was9.tar"
      # rm install/was9.tar was9.tar
    else
      # failed
      exit 104
    fi
else
  echo "#1 already up-to-date base image \"${BASE_IMAGE}\" found"
fi

#
echo "#3 creating a working cell (dmgr + 2 nodes) ..."
docker images --format ' {{.Repository }}:{{.Tag}}' | grep wasnd9-dmgr:$IMAGE_VERSION  > /dev/null
if [ $? -ne 0 ] ; then
  echo "#3 Bootstrapping DMGR ..."
  docker-compose -f docker-compose-build-was9.yml build dmgr
fi
echo "#3 Starting DMGR ..."
docker-compose -f docker-compose-build-was9.yml up -d dmgr
sleep 100
echo "#3 Container dmgr is started"

exit

docker images --format ' {{.Repository }}:{{.Tag}}' | grep wasnd9-node01:$IMAGE_VERSION  > /dev/null
if [ $? -ne 0 ] ; then
  echo "#4 Bootstrapping node01 ..."
  docker-compose -f docker-compose-build-was9.yml build node01
fi
echo "#4 Starting Node01 ..."
docker-compose -f docker-compose-build-was9.yml up -d node01
sleep 120
echo "#4 Container node01 is started"


docker images --format ' {{.Repository }}:{{.Tag}}' | grep wasnd9-node02:$IMAGE_VERSION  > /dev/null
if [ $? -ne 0 ] ; then
  echo "#5 Bootstrapping node02 ..."
  docker-compose -f docker-compose-build-was9.yml build node02
fi
echo "#5 Starting Node02 ..."
docker-compose -f docker-compose-build-was9.yml up -d node02
sleep 120
echo "#5 Container node01 is started"


echo "#6 - committing new cell images ..."
docker commit dmgr wasnd9-cell-dmgr:$IMAGE_VERSION
docker commit node01 wasnd9-cell-node01:$IMAGE_VERSION
docker commit node02 wasnd9-cell-node02:$IMAGE_VERSION

docker images --format ' {{.Repository }}:{{.Tag}}'| grep "wasnd9-cell"| grep $IMAGE_VERSION
echo -e "\n*** WASv9 CELL images commited. All operations finished!\n"
