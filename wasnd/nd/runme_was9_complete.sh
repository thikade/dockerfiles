#!/bin/bash

docker images | grep wasnd9-noprofile
if [ $? -ne 0 ] ; then

    if [ ! -f "install/was9.tar" ]; then
      echo "installing WASND v9 - Step 1"
      docker-compose -f docker-compose-build-was9.yml build wasnd_install_step1
      docker images  | grep "was9_delete_me"
      if [ $? -ne 0 ]; then
         echo "ERROR: WAS intermediary install container not found!"
         echo "==========="
         docker images
         echo "==========="
         exit 101
      fi

      echo "creating was9.tar (installing WASND v9 - Step 2)"
      docker run -ti --rm -v $(pwd):/tmp was9_delete_me
      if [ $? -ne 0 ]; then
         echo "Error: failed in step2"
         exit 102
      fi

      if [ -f "was9.tar" ] ; then
        echo "WAS Install image 'was9.tar' created successfully"
        docker rmi was9_delete_me
        mv was9.tar install/
        #
        # Copy jar file with customer registry sample class
        cp -p customRegistry.jar install/
      else
        exit 103
      fi

    fi


    echo "creating the final WAS v9 Docker base image ..."
    docker-compose -f docker-compose-build-was9.yml build wasnd_install_step2
    docker images | grep wasnd9-noprofile
    if [ $? -eq 0 ] ; then
      echo "WASv9 base image created successfully!"
      echo "removing install/was9.tar"
      rm install/was9.tar
      rm install/customRegistry.jar
    else
      exit 104
    fi
fi

#
docker images | grep wasnd9-dmgr || docker-compose -f docker-compose-build-was9.yml build dmgr
docker-compose -f docker-compose-build-was9.yml up -d dmgr
sleep 180
echo "Container dmgr is started"

docker images | grep wasnd9-node01 || docker-compose -f docker-compose-build-was9.yml build node01
docker-compose -f docker-compose-build-was9.yml up -d node01
sleep 180
echo "Container node01 is started"

docker images | grep wasnd9-node02 || docker-compose -f docker-compose-build-was9.yml build node02
docker-compose -f docker-compose-build-was9.yml up -d node02
sleep 180
echo "Container node02 is started"


docker commit dmgr wasnd9-cell-dmgr
docker commit node01 wasnd9-cell-node01
docker commit node02 wasnd9-cell-node02

docker images| grep "wasnd9-cell"
echo -e "\n*** WASv9 CELL images commited. All operations finished!\n"
