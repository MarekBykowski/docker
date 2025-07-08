#!/bin/bash

if [[ $1 == up ]]; then
	docker compose -f compose-armds-a55-a55arm32.yml up -d
elif [[ $1 == down ]]; then
	docker compose -f compose-armds-a55-a55arm32.yml down --volumes
elif [[ $1 == ps ]]; then
	docker compose -f compose-armds-a55-a55arm32.yml ps
elif [[ $1 == config ]]; then
	docker compose -f compose-armds-a55-a55arm32.yml config
elif [[ $1 == commit ]]; then
	for t in `docker compose -f compose-armds-a55-a55arm32.yml config | grep container_name: | awk '{print $2}'`; do
		c+=($t)
	done
	for t in `docker compose -f compose-armds-a55-a55arm32.yml config | grep image: | awk '{print $2}'`; do
		i+=($t)
	done
	for t in `docker compose -f compose-armds-a55-a55arm32.yml ps --services`; do
		service+=($t)
	done
	for ((t=0;t<3;t++)); do 
		echo "docker compose -f compose-armds-a55-a55arm32.yml commit ${service[$t]} ${i[$t]}"
		#echo "docker commit ${c[$t]} ${i[$t]}"
	done
elif [[ $1 == push ]]; then
	for image in `docker compose -f compose-armds-a55-a55arm32.yml config | grep image: | awk '{print $2}'`; do
		echo "docker push $image"
	done
else
	echo "$0 <up|down|ps|config|commit|push>"
fi


