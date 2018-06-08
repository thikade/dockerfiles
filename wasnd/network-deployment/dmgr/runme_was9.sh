docker build -t wasnd9-dmgr .
docker run -tdi --name dmgr9 -h dmgr    -p 9060:9060 -p 9043:9043 wasnd9-dmgr

