#!/bin/bash

# source VERSION variables
. ./.env

echo ""
echo "==========================================================================="
echo "you are going to build WAS image version: ${WAS_INSTALLATION_VERSION}"
echo ""
echo "Detailed WAS version string: ${WAS_INSTALLATION_VERSION_IM}"
echo "Detailed JDK version string: ${JDK_INSTALLATION_VERSION_IM}"
echo ""
echo "REPOSITORIES: ${IM_REPOSITORIES}"
echo "==========================================================================="
echo ""
sleep 4

WEB_URL=${1:-http://192.168.99.100:8080}

IMAGE_VERSION=${WAS_INSTALLATION_VERSION}
BASE_IMAGE=wasnd9-noprofile:${IMAGE_VERSION}

echo "#1 checking for base image: \"${BASE_IMAGE}\""

docker images --format ' {{.Repository }}:{{.Tag}}' | grep ${BASE_IMAGE}  > /dev/null
if [ $? -ne 0 ] ; then
    echo "#1.1 building base image \"${BASE_IMAGE}\""
      echo "press any key to continue ..."
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
        # ln was9.tar install/
      else
        exit 103
      fi

    else
      echo -e "#2 was9.tar already there. Skipping build."
      # check symlink
      # test ! -f install/was9.tar && ln  was9.tar install/
    fi


    echo "#2.10 creating the final WAS v9 Docker base image using tar ..."
    docker-compose -f docker-compose-build-was9.yml build wasnd_install_step2
    docker images --format ' {{.Repository }}:{{.Tag}}' | grep ${BASE_IMAGE}  > /dev/null
    if [ $? -eq 0 ] ; then
      echo "#2.11 WASv9 base image \"${BASE_IMAGE}\" created successfully!"
      echo "#2.12 DEBUG: NOT removing install/was9.tar"
      # rm install/was9.tar was9.tar
      # rm was9.tar
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


# create NODE_COUNT node images
NODE_COUNT=2

for NN in $(seq  -f '%02.0f' 1 $NODE_COUNT); do

    docker images --format ' {{.Repository }}:{{.Tag}}' | grep wasnd9-node${NN}:$IMAGE_VERSION  > /dev/null
    if [ $? -ne 0 ] ; then
      echo "#4.${NN} Bootstrapping node${NN} ..."
      docker-compose -f docker-compose-build-was9.yml build node${NN}
    fi
    echo "#4.${NN} Starting Node01 ..."
    docker-compose -f docker-compose-build-was9.yml up -d node${NN}
    sleep 120
    echo "#4.${NN} Container node${NN} is started"

done

echo "#5 - committing new cell images ..."
docker commit dmgr wasnd9-cell-dmgr:$IMAGE_VERSION
docker commit node01 wasnd9-cell-node01:$IMAGE_VERSION
docker commit node02 wasnd9-cell-node02:$IMAGE_VERSION

docker images --format ' {{.Repository }}:{{.Tag}}'| grep "wasnd9-cell"| grep $IMAGE_VERSION
echo -e "\n#5 WASv9 CELL images commited. All operations finished!\n"
