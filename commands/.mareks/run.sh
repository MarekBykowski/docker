#!/bin/bash 

#build
docker --debug build --progress=plain --no-cache --build-arg username=marek --build-arg gid=$(id -g) --build-arg uid=$(id -u) --build-arg password=marian12 -t yocto:nanbield ~/docker
docker --debug build --progress=plain --no-cache --build-arg username=marek --build-arg gid=$(id -g) --build-arg uid=$(id -u) --build-arg password=marian12 -t marekbykowski/yocto-qemu-simics:nanbield ~/docker

#run
docker run --rm -it --env HTTP_PROXY=http://proxy-us.intel.com:911 --env HTTPS_PROXY=http://proxy-us.intel.com:912 --env NO_PROXY=127.0.0.1 --env FTP_PROXY=http://proxy-us.intel.com:911 -v /home/mbykowsx:/home/marek/host --privileged yocto:nanbield
docker run --rm -it \
	--env HTTP_PROXY=http://proxy-us.intel.com:911 --env http_proxy=$HTTP_PROXY \
	--env HTTPS_PROXY=http://proxy-us.intel.com:912 --env https_proxy=$HTTPS_PROXY \
	--env NO_PROXY=127.0.0.1 --env no_proxy=$NO_PROXY \
	--env FTP_PROXY=http://proxy-us.intel.com:911 --env ftp_proxy=$FTP_PROXY \
	-v /home/mbykowsx:/home/marek/host --privileged marekbykowski/yocto-qemu-simics:nanbield
