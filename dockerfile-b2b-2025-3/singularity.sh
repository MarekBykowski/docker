#!/bin/bash

set -x

export GIT_AUTH_TOKEN="g\
hp_FU32\
vNbprc3\
KsnZKm\
Nmbloh\
oXBE4x\
D0Sb6ng"

docker_image=b2b:2025.3
docker_safe="${docker_image//:/_}"
dockerfile=Dockerfile-b2b-2025-3

build_args=(
  --progress=plain
  --build-arg username=mbykowsx
  --build-arg gid=$(id -g)
  --build-arg uid=$(id -u)
  --build-arg password=password
  --build-arg gt="${GIT_AUTH_TOKEN}"
  --build-arg HTTP_PROXY="$http://proxy-us.intel.com:911" \
  --build-arg HTTPS_PROXY="http://proxy-us.intel.com:912" \
  -f "$dockerfile"
  -t "$docker_image"
  .
)

# Toggle flags safely
build_args+=(--no-cache)

if [[ $1 == b ]]; then
	docker build "${build_args[@]}"
	# test if previously missing perl module installed
	docker run --rm $docker_image \
		perl -e 'use Term::ReadKey; print "OK\n";'
elif [[ $1 == tr ]]; then
	docker run -d \
	  --name $docker_safe \
	  --hostname $docker_safe \
	  --privileged \
	  -p 50022:22 \
	  -p 55900:5900 \
	  -p 56080:6080 \
	  -v /home/mbykowsx:/home/mbykowsx/host \
	  -v $PWD:/home/mbykowsx/workdir \
	  -v /lib/modules:/lib/modules \
	  -v /boot:/boot \
	  $docker_image
elif [[ $1 == c ]]; then
	docker save $docker_image -o ${docker_safe}.tar

	DIR=/yocto
	SINGULARITY_TMPDIR="$DIR/.singularity/tmp"
	SINGULARITY_CACHEDIR="$DIR/.singularity/cache"
	mkdir -p "$SINGULARITY_TMPDIR" "$SINGULARITY_CACHEDIR"
	export SINGULARITY_TMPDIR
	export SINGULARITY_CACHEDIR

	echo SINGULARITY_TMPDIR=$SINGULARITY_TMPDIR
	echo SINGULARITY_CACHEDIR=$SINGULARITY_CACHEDIR

	singularity build ${docker_safe}.sif docker-archive://${docker_safe}.tar
fi
