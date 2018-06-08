NAME = phusion/baseimage
VERSION = latest

.PHONY: all build test tag_latest release ssh

all: build


prereq-step2:
	docker build --build-arg user=wasadmin --build-arg group=wasadmin -t wasnd -f Dockerfile.install install/

dmgr: 
	docker build -t wasnd-dmgr -f Dockerfile dmgr/

custom: 
	docker build -t wasnd-custom  -f Dockerfile custom/

build: prereq-step2 dmgr custom 

# test:
#     env NAME=$(NAME) VERSION=$(VERSION) ./test/runner.sh

# tag_latest:
#     docker tag -f $(NAME):$(VERSION) $(NAME):latest