#!/bin/bash

CF=compose_b2b_yocto-ci_at_all.yml
count=$(docker compose -f $CF config --services | wc -l)
if [[ $1 == up ]]; then
	test -f docker-compose.log && rm -f docker-compose.log
	docker compose --progress=plain -f ${CF} up | tee -a docker-compose.log
	#docker compose -f ${CF} up -d
elif [[ $1 == down ]]; then
	docker compose -f ${CF} down --volumes
elif [[ $1 == ps ]]; then
	docker compose -f ${CF} ps
elif [[ $1 == config ]]; then
	docker compose -f ${CF} config
elif [[ $1 == commit ]]; then
	for t in `docker compose -f ${CF} config | grep container_name: | awk '{print $2}'`; do
		c+=($t)
	done
	for t in `docker compose -f ${CF} config | grep image: | awk '{print $2}'`; do
		i+=($t)
	done
	for t in `docker compose -f ${CF} ps --services`; do
		service+=($t)
	done
	echo "Number of Docker containers in compose: $count"
	for ((t=0;t<$count;t++)); do
		echo "docker compose -f ${CF} commit ${service[$t]} ${i[$t]}"
		#echo "docker commit ${c[$t]} ${i[$t]}"
	done
elif [[ $1 == push ]]; then
	echo "Number of Docker containers in compose: $count"
	for image in `docker compose -f ${CF} config | grep image: | awk '{print $2}'`; do
		echo "docker push $image"
	done
else
	echo "$0 <up|down|ps|config|commit|push>"
fi


