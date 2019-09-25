# Usage:
# ARG 1: required: env file name (including path)
# ARG 2: required: compose file name (including path)
# ARG 3: optional: WAS_INSTALLATION_VERSION number
# example
#       ./.env.v85  ./dc-build-was85.yml   8.5.5.13

# edit .env to support/add new WAS versions!

function usage {
  cat << EOM

  usage: $0 ENV-FILE COMPOSE-FILE [VERSION]

    ENV_FILE is the name of the environment definitions file
    COMPOSE-FILE is the name of the docker-compose BUILD file
    VERSION is the optional WAS version string

  examples:
    $0 .env.v85  docker-compose-build-was85.yml  8.5.5.13
    $0 .env.v85  docker-compose-build-was9.yml   9.0.0.11

EOM
}

EXEC_DIR=$(dirname $0)
ENV_FILE=$1
COMPOSE_FILE=$2
VERSION=$3

# source ENV file and definitions
. $ENV_FILE $VERSION

SLEEP_BETWEEN_NODE_FEDERATION=400
SLEEP_AFTER_DMGR_START=100
echo "=========================================================================="
echo "building complete WAS cell images for version: ${WAS_INSTALLATION_VERSION}"
echo "sleep time between node federation: ${SLEEP_BETWEEN_NODE_FEDERATION}"
echo "=========================================================================="


# docker-compose -f $COMPOSE_FILE down

echo -e "\n\n\n"
echo -e "\nRebuilding images for dmgr and 2 nodes ...\n\n"
docker-compose -f $COMPOSE_FILE build  dmgr node01 node02

echo -e "\nStarting DMGR\n\n"
docker-compose -f $COMPOSE_FILE up -d dmgr
echo sleep $SLEEP_AFTER_DMGR_START
sleep $SLEEP_AFTER_DMGR_START

echo -e "\nStarting NODE01\n\n"
docker-compose -f $COMPOSE_FILE up -d node01
echo sleep $SLEEP_BETWEEN_NODE_FEDERATION
sleep $SLEEP_BETWEEN_NODE_FEDERATION

echo -e "\nStarting NODE02\n\n"
docker-compose -f $COMPOSE_FILE up -d node02
echo sleep $SLEEP_BETWEEN_NODE_FEDERATION
sleep $SLEEP_BETWEEN_NODE_FEDERATION

docker-compose -f $COMPOSE_FILE logs dmgr node01 node02

echo -e "\nCommiting the final CELL IMAGES\n\n"
docker commit dmgr wasnd-cell-dmgr:${WAS_INSTALLATION_VERSION}
docker commit node01 wasnd-cell-node01:${WAS_INSTALLATION_VERSION}
docker commit node02 wasnd-cell-node02:${WAS_INSTALLATION_VERSION}
docker images | grep -- -cell- | grep ${WAS_INSTALLATION_VERSION}
