default: all
all:
	docker-compose  -f docker-compose-run-was9.yml  up -d dmgr node01 node02
all-ldap:
	docker-compose  -f docker-compose-run-was9.yml  up -d dmgr node01 node02 ldap ldap2
start-dmgr:
	docker-compose  -f docker-compose-run-was9.yml  up -d dmgr 
stop-all:
	docker-compose  -f docker-compose-run-was9.yml  down
