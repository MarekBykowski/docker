#!/bin/bash

# All the services use a service profiles. As a result all the serivces not
# mentioned `profile` to the compose are not visible. Read more here
# https://docs.docker.com/compose/how-tos/profiles/

CF=compose_multiple_container_selection.yml
CF=compose.yml
selected_services=($(docker compose -f $CF config --services))
echo Inspection for all of your services: ${selected_services[@]}
if [[ $1 == build ]]; then
	mkdir -p workdir
	test -f docker-compose.log && rm -f docker-compose.log
	# --no-cache forces build even though the images are already build
	docker compose -f ${CF} build --no-cache --progress=plain | tee -a docker-compose.log
elif [[ $1 == up ]]; then
	docker compose -f ${CF} up -d
>>>>>>> 89ccac1 (Cherry pick it to fragments)
elif [[ $1 == down ]]; then
	docker compose -f ${CF} down --volumes
	rm -rf workdir
elif [[ $1 == rmi ]]; then
	for t in `docker compose -f ${CF} config | grep image: | awk '{print $2}'`; do
		echo "docker rmi $t"
		docker rmi $t
	done
elif [[ $1 == ps ]]; then
	docker compose -f ${CF} ps
	echo
	docker compose -f ${CF} images
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
	$0 <build|up|down|stop|rmi|ps|config|commit|push>
	EOF
fi
