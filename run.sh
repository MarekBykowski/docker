#!/bin/bash

# All the services use a service profiles. As a result all the serivces not
# mentioned `profile` to the compose are not visible. Read more here
# https://docs.docker.com/compose/how-tos/profiles/

CF=compose_multiple_container_selection.yml
selected_services=($(docker compose -f $CF config --services))
echo Inspection for all of your services: ${selected_services[@]}
if [[ $1 == up ]]; then
	test -f docker-compose.log && rm -f docker-compose.log
	# We are better off running with --no-cache to ensure a clean build
	docker compose -f ${CF} build --no-cache --progress=plain | tee -a docker-compose.log
	docker compose -f ${CF} up | tee -a docker-compose.log
	#docker compose --progress=plain -f ${CF} up | tee -a docker-compose.log
	#docker compose --progress=plain -f ${CF} up --build | tee -a docker-compose.log
	#COMPOSE_PROFILE=${ARGS[@]} docker compose --progress=plain -f ${CF} up --build | tee -a docker-compose.log
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
	count=${#selected_services[@]}
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
	cat <<-EOF
	$0 <up|down|ps|config|commit|push>
	EOF
fi


