#!/bin/bash
############################################################################
## Start by running: sh -x ./runme_wsx86_complete.sh "http://192.168.99.100:8080" "/run/media/hhuebler/hhueStick128G"
############################################################################

WEB_URL=${1:-http://192.168.99.100:8080}
DOC_ROOT=${2:-/INSTALL}

echo "WEB_URL=${WEB_URL}"
echo "DOC_ROOT=${DOC_ROOT}"

export WEB_URL
export DOC_ROOT

docker images | grep wxs86_standalone
if [ $? -ne 0 ] ; then
  #
  # Start the caddy server
  if docker ps | grep caddy ; then
      echo "caddy is running"
  else
      echo "starting caddy"
      #
      # We delete existing containers if they are stopped
      docker ps -a | grep caddy && {
        __containerId=$(docker ps -a | grep caddy | awk '{print $1}')
        docker rm ${__containerId}
        echo "Removed existing caddy container. Will create a new one"
      }
      docker run -d  --name caddy -p 8080:8080 -v ${DOC_ROOT}:/data caddy
      # Allow caddy container to start
      sleep 7
  fi

  curl -sSo /dev/null  $WEB_URL/WASND
  if [ $? -eq 0 ] ; then
    echo "caddy is working"
  else
    echo "caddy not working. Aborting"!
    exit 100
  fi

  docker images | grep wxs86_centos || {
    echo "installing CentOS for WXS v8.6"
    docker-compose -f docker-compose-build-wxs86.yml build wxs86_install_centos
    docker images  | grep "wxs86_centos"
    if [ $? -ne 0 ]; then
       echo "ERROR: Creation of CentOS image failed!"
       echo "==========="
       docker images
       echo "==========="
       exit 101
    fi
  }

  echo "installing WXS v8.6 - Step 1"
  docker-compose -f docker-compose-build-wxs86.yml build wxs86_install_step1
  docker images  | grep "wxs86_delete_me"
  if [ $? -ne 0 ]; then
     echo "ERROR: WXS v8.6 intermediary install container not found!"
     echo "==========="
     docker images
     echo "==========="
     exit 101
  fi

  echo "creating wxs8612.tar (installing WXS v8.6 - Step 2)"
  docker run -ti --rm -v $(pwd):/tmp wxs86_delete_me
  if [ $? -ne 0 ]; then
     echo "Error: failed in step2"
     exit 102
  fi

  if [ -f "wxs8612.tar" ] ; then
    echo "WXS v8.6 Install image \"wxs8612.tar\" created successfully"
    docker rmi wxs86_delete_me
    mv wxs8612.tar install/
  else
    exit 103
  fi

  echo "Creating the final WXS v86 Docker base image ..."
  docker-compose -f docker-compose-build-wxs86.yml build wxs86_install_step2
  docker images | grep wxs86_standalone
  if [ $? -eq 0 ] ; then
    echo "WXS v8.6 image created successfully!"
    echo "removing install/was9.tar"
    rm install/wxs8612.tar
  else
    exit 104
  fi
fi

docker images | grep "wxs86"
echo -e "\n*** WXS v8.6 images commited. All operations finished!\n"
