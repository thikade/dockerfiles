IMAGE_C7=skopeo-build:centos7
IMAGE_C8=skopeo-build:centos8

default: centos7

centos7:
	docker build  -f Dockerfile-centos7 -t $(IMAGE_C7) .
	docker run --rm -ti $(IMAGE_C7)
	docker run --rm -ti $(IMAGE_C7) cat bin/skopeo > skopeo-centos7
	chmod a+rx skopeo-centos7

# does not work yet
centos8:
	docker build  -f Dockerfile-centos8 -t $(IMAGE_C8) .
	docker run --rm -ti $(IMAGE_C8)
	docker run --rm -ti $(IMAGE_C8) cat bin/skopeo > skopeo-centos8
	chmod a+rx skopeo-centos8


all: centos7 # centos8
