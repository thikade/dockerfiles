#!/bin/bash

# Usage:
# optionally specify a WAS_INSTALLATION_VERSION number as argument
# eg. 9.0.0.11 or 9.0.5.0
# default is 9.0.5.0
# edit .env to support/add new WAS versions!

function help {
  cat << EOM

    Build complete WAS cell (dmgr + 2 nodes) docker images
    with WAS version specified in ".env" file.

    Optionally specify a WAS_INSTALLATION_VERSION number as argument.
    E.g:
       $0 9.0.0.11

    # default version is 9.0.5.0

EOM
}

# print help
test "$1" = "-h" -o "$1" = "--help" && help && exit 0

# get calling path
EXEC_DIR=$(dirname $0)

ENVIRONMENT=$EXEC_DIR/.env
# source Environment & WAS_INSTALLATION_VERSION
. $ENVIRONMENT $1

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

# Fileserver configuration
FILESERVER_NAME=nginx
FILESERVER_HTTP_PORT=8080
# WAS binaries are located here: /INSTALL/WASND/9.0.0.0, /INSTALL/WASND/9.0.0.11, ...
FILESERVER_DIR=/INSTALL/WASND
FILESERVER_CONTAINER_NAME=fileserver

BASE_IMAGE=wasnd-noprofile:${WAS_INSTALLATION_VERSION}

echo "#1   checking for base image: \"${BASE_IMAGE}\""

docker images --format ' {{.Repository }}:{{.Tag}}' | grep ${BASE_IMAGE}  > /dev/null
if [ $? -ne 0 ] ; then
    echo "#1.1 re-building base image ..."
    sleep 3

    # start a simple nginx fileserver based on nginx:stable-alpine image
    #  serving directory $FILESERVER_DIR
    if docker ps | grep $FILESERVER_CONTAINER_NAME  > /dev/null ; then
        echo "#1.2 $FILESERVER_NAME is running"
    else
        echo "#1.2 starting fileserver container: $FILESERVER_NAME"
        # docker run -d  --name caddy -p 8080:8080 -v /INSTALL:/data caddy
        docker run --name $FILESERVER_CONTAINER_NAME --rm -v $FILESERVER_DIR:/usr/share/nginx/html:ro -d -p$FILESERVER_HTTP_PORT:80 nginx:stable-alpine \
              /bin/sh -c "sed -i 's/location \/ {/location \/ {\nautoindex on;/' /etc/nginx/conf.d/default.conf  && echo 'starting nginx ....' && exec nginx -g 'daemon off;'"
        sleep 4
    fi

    curl -sSo /dev/null  $WEB_URL
    if [ $? -eq 0 ] ; then
      echo "#1.3 $FILESERVER_NAME tested ok"
    else
      echo "#1.3 $FILESERVER_NAME reported 40x. Aborting"!
      exit 100
    fi

    echo "#1.4 installing WASND v9"
    CMD="docker-compose -f $EXEC_DIR/docker-compose-build-was9.yml build wasnd_chained_build"
    echo $CMD
    $CMD
    docker images --format ' {{.Repository }}:{{.Tag}}'  | grep "$BASE_IMAGE" > /dev/null
    if [ $? -ne 0 ]; then
       echo "#1.4 ERROR: base image $BASE_IMAGE not found!"
       exit 101
    fi
    cat << EOM

============================================================
#1.5 base image is now complete: $BASE_IMAGE
============================================================

EOM

else
  cat << EOM

============================================================
#1 base image exists: ${BASE_IMAGE}  -  skipping rebuild.
   Delete base image if you want to rebuild!
============================================================

EOM
fi

cat << EOM


============================================================
  #2 creating a working cell (dmgr + 2 nodes) ...

     (running "$EXEC_DIR/build_was_cell.sh  $ENVIRONMENT  $EXEC_DIR/docker-compose-build-was9.yml  ${WAS_INSTALLATION_VERSION}")
============================================================

EOM

# $EXEC_DIR/build_cell_was9.sh ${WAS_INSTALLATION_VERSION}
$EXEC_DIR/build_was_cell.sh $ENVIRONMENT  $EXEC_DIR/docker-compose-build-was9.yml  ${WAS_INSTALLATION_VERSION}

echo -e "\nWAS CELL images v${WAS_INSTALLATION_VERSION} committed. All operations finished!\n"
