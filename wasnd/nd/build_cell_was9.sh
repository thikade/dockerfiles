docker-compose -f docker-compose-build_was9.yml down

docker-compose -f docker-compose-build_was9.yml build  dmgr node01 node02

docker-compose -f docker-compose-build_was9.yml up -d dmgr
sleep 90
docker-compose -f docker-compose-build_was9.yml logs dmgr

docker-compose -f docker-compose-build_was9.yml up -d node01
sleep 90
docker-compose -f docker-compose-build_was9.yml logs node01

docker-compose -f docker-compose-build_was9.yml up -d node02
docker-compose -f docker-compose-build_was9.yml logs node02
