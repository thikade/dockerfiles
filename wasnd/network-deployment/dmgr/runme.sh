docker build -t wasnd-dmgr .
docker run -tdi --name dmgr -h dmgr   --net=cell-network  -p 9060:9060 -p 9043:9043 wasnd-dmgr

