#!/bin/bash

set -x

container_state() {
	rc=$(./scripts/check_docker_container.sh $1)
	return $rc
}


container_state marek
echo $?
