docker build -t wasnd-custom  .
docker run -tdi --name node01 -h node01 -e NODE_NAME=CustomNode01   --net=cell-network  -e DMGR_HOST=dmgr -e DMGR_PORT=8879  wasnd-custom
echo "*********"
echo "wait for addNode.sh to finish on first node! Then ctrl-c to exit docker log -f ..."
echo "*********"
docker logs -f node01

docker run -tdi --name node02 -h node02 -e NODE_NAME=CustomNode02   --net=cell-network  -e DMGR_HOST=dmgr -e DMGR_PORT=8879  wasnd-custom
