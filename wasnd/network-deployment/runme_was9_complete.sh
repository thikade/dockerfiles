#!/bin/bash

WEB_URL=http://192.168.99.102:8080

docker images | grep was9-noprofile
if [ $? -ne 0 ] ; then

    if [ ! -f "install/was.tar" ]; then
      # cd ~/Documents/GitHub/dockerfiles/wasnd/network-deployment/
      if docker ps | grep caddy ; then
          echo "caddy is running"
      else
          echo "starting caddy"
          docker run -d  --name caddy -p 8080:8080 -v /INSTALL_E:/data caddy
      fi

      curl -sSo /dev/null  $WEB_URL/WASND
      if [ $? -eq 0 ] ; then
        echo "caddy is working"
      else
        echo "caddy not working. Aborting"!
        exit 100
      fi

      echo "installing WASND v9 - Step 1"
      docker-compose -f docker-compose-build_was9.yml build wasnd_install_step1
      docker images  | grep "was9_delete_me"
      if [ $? -ne 0 ]; then
         echo "ERROR: WAS intermediary install container not found!"
         echo "==========="
         docker images
         echo "==========="
         exit 101
      fi

      echo "creating was.tar (installing WASND v9 - Step 2)"
      docker run -ti --rm -v $(pwd):/tmp was9_delete_me
      if [ $? -ne 0 ]; then
         echo "Error: failed in step2"
         exit 102
      fi

      if [ -f "was.tar" ] ; then
        echo "WAS Install image 'was.tar' created successfully"
        docker rmi was9_delete_me
        mv was.tar install/
      else
        exit 103
      fi

    fi


    echo "creating the final WAS v9 Docker base image ..."
    docker-compose -f docker-compose-build_was9.yml build wasnd_install_step2
    docker images | grep was9-noprofile
    if [ $? -eq 0 ] ; then
      echo "WASv9 base image created successfully!"
      echo "removing install/was.tar"
      rm install/was.tar
    else
      exit 104
    fi
fi

#
docker images | grep wasnd9-dmgr || docker-compose -f docker-compose-build_was9.yml build dmgr
docker-compose -f docker-compose-build_was9.yml run -d dmgr
sleep 100
echo "Container dmgr is started"

# docker images | grep wasnd9-node01 || docker-compose -f docker-compose-build_was9.yml build node01
docker-compose -f docker-compose-build_was9.yml run -d node01
sleep 120
echo "Container node01 is started"

docker-compose -f docker-compose-build_was9.yml run -d node02
sleep 120
echo "Container node02 is started"
