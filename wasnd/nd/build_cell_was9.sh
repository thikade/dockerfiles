# Usage:
# optionally specify a WAS_INSTALLATION_VERSION number as argument
# eg. 9.0.0.11 or 9.0.5.0
# default is 9.0.5.0
# edit .env to support/add new WAS versions!

EXEC_DIR=$(dirname $0)
. $EXEC_DIR/.env $1

SLEEP_BETWEEN_NODE_FEDERATION=400
SLEEP_AFTER_DMGR_START=100
echo "=========================================================================="
echo "building complete WAS cell images for version: ${WAS_INSTALLATION_VERSION}"
echo "sleep time between node federation: ${SLEEP_BETWEEN_NODE_FEDERATION}"
echo "=========================================================================="


docker-compose -f $EXEC_DIR/docker-compose-build-was9.yml down

echo -e "\n\n\n"
echo -e "\nRebuilding images for dmgr and 2 nodes ...\n\n"
docker-compose -f $EXEC_DIR/docker-compose-build-was9.yml build  dmgr node01 node02

echo -e "\nStarting DMGR\n\n"
docker-compose -f $EXEC_DIR/docker-compose-build-was9.yml up -d dmgr
echo sleep $SLEEP_AFTER_DMGR_START
sleep $SLEEP_AFTER_DMGR_START

echo -e "\nStarting NODE01\n\n"
docker-compose -f $EXEC_DIR/docker-compose-build-was9.yml up -d node01
echo sleep $SLEEP_BETWEEN_NODE_FEDERATION
sleep $SLEEP_BETWEEN_NODE_FEDERATION

echo -e "\nStarting NODE02\n\n"
docker-compose -f $EXEC_DIR/docker-compose-build-was9.yml up -d node02
echo sleep $SLEEP_BETWEEN_NODE_FEDERATION
sleep $SLEEP_BETWEEN_NODE_FEDERATION

docker-compose -f $EXEC_DIR/docker-compose-build-was9.yml logs dmgr node01 node02

echo -e "\nCommiting the final CELL IMAGES\n\n"
docker commit dmgr wasnd9-cell-dmgr:${WAS_INSTALLATION_VERSION}
docker commit node01 wasnd9-cell-node01:${WAS_INSTALLATION_VERSION}
docker commit node02 wasnd9-cell-node02:${WAS_INSTALLATION_VERSION}
docker images | grep -- -cell- | grep ${WAS_INSTALLATION_VERSION}
