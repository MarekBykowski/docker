#!/bin/bash

# All of the values must be unique per user.
# As the values are exported to the system and available for all the processes
# I use prefix D_ for indicating this is for Docker containers.

# We run containers with 'privileged'. Default builder (BuildKit daemon)
# named 'default' doesn't allow such an entitlement.
#
#	$ docker buildx ls
#	NAME/NODE     DRIVER/ENDPOINT   STATUS    BUILDKIT   PLATFORMS
#	default*      docker
#	 \_ default    \_ default       running   v0.21.0    linux/amd64 (+4), linux/386
#
# We need to create a separate builder and configure it with 'security.insecure' allowing
# creation of the containers with 'privileged`. Additionally need to explicitly
# grant the required entitlements using the --allow flag.
#export BUILDX_BUILDER=secure-builder; echo "Using BuildKit daemon: $BUILDX_BUILDER"

if [[ "$0" == "$BASH_SOURCE" ]]; then
	echo "Error: This script needs to be sourced. Please run as 'source $BASH_SOURCE'" >&2
	exit 1
fi

# List users permitted to use the docker eco-system
#keys=("rvranax" "csmx" "svellipx" "tziyangx" "tonyhunx" "markhox" "test2" "mbykowsx")
#vals=(11100 11200 11300 11400 11500 11600 11700 11800)
keys=("mbykowsx" "test1" "tonyhunx" "markhox" )
vals=(12800 13800 14800 15800)
declare -A START_PORT_PER_USER
for i in "${!keys[@]}"; do
	START_PORT_PER_USER[${keys[$i]}]=${vals[$i]}
done

# Test if a user running the script is on the list
for item in ${keys[@]}; do
	if [[  $USER == $item ]]; then
		found=1
	fi
done

if [[ $found -ne 1 ]]; then
	echo "User '$USER' not permitted to use docker eco-system"
	echo "Ask admin to add the user '$USER' in"
	echo "Current list of permitted users are: ${keys[@]}"
	return 127
fi

env_setup_path=$(readlink -f $BASH_SOURCE)
env_dir=$(dirname "$env_setup_path")
env_setup_name=$(basename "$env_setup_path")
env_config_name=environment-config
env_config_path=$env_dir/$env_config_name

test -f $env_config_path && {
	echo "You have already created a config file \"$env_config_path\" for the docker eco-system."
	echo "Each time you wish to use it run:"
	echo -e "\t'source $env_config_path'"
	echo "If you want to create an updated config file remove this one and re-resource the script, eg."
	echo -e "\t'rm -f $env_config_path && source $env_setup_path'"
	return 127
}

# Common values shared by all the containers
echo "export D_UID=$(id -u)" >> $env_config_path
echo "export D_GID=$(id -g)" >> $env_config_path
echo "export D_PASSWORD=password" >> $env_config_path
D_USER=$USER
echo "export D_USER=$D_USER" >> $env_config_path
echo "export D_HTTPS_PROXY=http://proxy-us.intel.com:912" >> $env_config_path
echo "export D_HTTP_PROXY=http://proxy-us.intel.com:911" >> $env_config_path
echo "export D_HOME=$HOME" >> $env_config_path
COMPOSE_PROJECT_NAME=$D_USER
echo -e "\necho \"Your Docker eco-system is named: $COMPOSE_PROJECT_NAME\"" >> $env_config_path
echo "export COMPOSE_PROJECT_NAME=$COMPOSE_PROJECT_NAME" >> $env_config_path

# All the services use a service profiles. Read more here https://docs.docker.com/compose/how-tos/profiles/
# Compose file
CF=compose_b2b_yocto-ci_at_all.yml
# All the services defined
# I cannot run the compose config to find out a number of services defined
# as first I need to have the variables exported which I can only export followed
# knowing the services a user wants to run , so it is "the chicken-and-egg dilemma".
# What I got left is to list the services manually.
#all_services=($(docker compose --profile "*" -f $CF config --services))
all_services=(b2b yocto-ci generic yocto tdx)
echo "Available services:"
for i in "${!all_services[@]}"; do
	echo "$((i+1))) ${all_services[i]}"
done

while true; do
	read -p "Choose one or more (numbers, space-separated): " -a choices
	valid=true

	selected_services=()

	for c in "${choices[@]}"; do
		# Check if input is a number
		if ! [[ "$c" =~ ^[0-9]+$ ]]; then
			echo "'$c' is not a valid number."
			valid=false
			break
		fi

		# Check if within range
		if (( c < 1 || c > ${#all_services[@]} )); then
			echo "'$c' is out of range (1-${#all_services[@]})."
			valid=false
			break
		fi
		selected_services+=("${all_services[c-1]}")
	done

	if $valid; then
		break
	else
		echo "Please try again."
	fi
done

COMPOSE_PROFILES=$(IFS=','; echo "${selected_services[*]}")
echo "You selected: ${selected_services[@]}"

echo -e "\necho \"Your Docker eco-system will run the following services (containers): ${selected_services[@]}\"" >> $env_config_path
echo "export COMPOSE_PROFILES=$COMPOSE_PROFILES" >> $env_config_path

# Ports must be unique system-wise and ideally remain unchanged to the end of life of containeres.
# The algorithm for assigning the ports is in a 'port-assignment.sh' file.
# I need ports for:
echo "Doing ports for: ${selected_services[*]}"
# 3x ports per service
NUMBER_OF_PORTS=$((${#selected_services[@]}*3))
echo "... so total number of ports looked for is: $NUMBER_OF_PORTS"

# Range of ports to check
START_PORT=${START_PORT_PER_USER[$USER]}
# It will search a NUMBER_OF_PORTS in the range from START_PORT thr END_PORT
END_PORT=$((START_PORT+30))
source $env_dir/port-assignment.sh
ports=()
count=0
while [ "${#ports[@]}" -lt $NUMBER_OF_PORTS ]; do
	port=$(echo_free_port $START_PORT)
	if [[ ! " ${ports[*]} " =~ " $port " ]]; then
		ports+=($port)
		((START_PORT+=1))
	fi
	((count++))
	if [[ $count -eq $END_PORT ]]; then
		echo "Cannot allocate $NUMBER_OF_PORTS ports in the range set $START_PORT..$END_PORT. Maybe the docker eco-system is up and running."
		echo "If so before re-creating the configuration you have to stop the docker eco-system first, eg."
		echo -e "\t'source $env_config_path && $env_dir/run.sh down'"
		return 127
	fi
done

echo "Ports allocated: ${ports[@]}"

#for i in "${selected_services[@]}"; do
#	service=${selected_services[$i]}
#	SERVICE=${service^^}
#	echo "export D_${SERVICE}_SSH_PORT=${ports[]}" >> $env_config_path
#done

for ((i=0,j=0; i<${#selected_services[@]}; i++)); do
	service=${selected_services[$i]}
	# Convert to UPPERCASE
	SERVICE=${service^^}
	# Convert all dashes (-) to underscores (_)
	SERVICE=${SERVICE//-/_}

	# i is a service
	# j is a protocol incrementing the service by:
	# - 0,1,2 at 1st iteration
	# - then 2,3,4 at 2nd iteration, etc.
	k=$((i+j))
	echo "D_${SERVICE}_SSH_PORT is ${ports[$k]}"
	echo -e "\necho \"${SERVICE} ssh port: ${ports[$k]}\"" >> $env_config_path
	echo "export D_${SERVICE}_SSH_PORT=${ports[$k]}" >> $env_config_path

	((j++)); k=$((i+j))
	echo "D_${SERVICE}_VNC_PORT is ${ports[$k]}"
	echo -e "\necho \"${SERVICE} vnc port: ${ports[$k]}\"" >> $env_config_path
	echo "export D_${SERVICE}_VNC_PORT=${ports[$k]}" >> $env_config_path

	((j++)); k=$((i+j))
	echo "D_${SERVICE}_NOVNC_PORT is ${ports[$k]}"
	echo -e "\necho \"${SERVICE} novnc port: ${ports[$k]}\"" >> $env_config_path
	echo "export D_${SERVICE}_NOVNC_PORT=${ports[$k]}" >> $env_config_path
done

:<<COMMENT
# Ports for the 'b2b' container
D_B2B_SSH_PORT=${ports[0]}
D_B2B_VNC_PORT=${ports[1]}
D_B2B_NOVNC_PORT=${ports[2]}
echo "export D_B2B_SSH_PORT=$D_B2B_SSH_PORT" >> $env_config_path
echo "export D_B2B_VNC_PORT=$D_B2B_VNC_PORT" >> $env_config_path
echo "export D_B2B_NOVNC_PORT=$D_B2B_NOVNC_PORT" >> $env_config_path
cat << EOF >> $env_config_path
echo "SSH port for b2b container is: $D_B2B_SSH_PORT"
echo "VNC port for b2b container is: $D_B2B_VNC_PORT"
echo "NOVNC port for b2b container is: $D_B2B_NOVNC_PORT"
EOF

# Ports for the 'yocto-ci' container
D_YOCTO_CI_SSH_PORT=${ports[3]}
D_YOCTO_CI_VNC_PORT=${ports[4]}
D_YOCTO_CI_NOVNC_PORT=${ports[5]}
echo "export D_YOCTO_CI_SSH_PORT=$D_YOCTO_CI_SSH_PORT" >> $env_config_path
echo "export D_YOCTO_CI_VNC_PORT=$D_YOCTO_CI_VNC_PORT" >> $env_config_path
echo "export D_YOCTO_CI_NOVNC_PORT=$D_YOCTO_CI_NOVNC_PORT" >> $env_config_path
cat << EOF >> $env_config_path
echo "SSH port for yocto-ci container is: $D_YOCTO_CI_SSH_PORT"
echo "VNC port for yocto-ci container is: $D_YOCTO_CI_VNC_PORT"
echo "NOVNC port for yocto-ci container is: $D_YOCTO_CI_NOVNC_PORT"
EOF

# Ports for the 'generic' container
D_GENERIC_SSH_PORT=${ports[6]}
D_GENERIC_VNC_PORT=${ports[7]}
D_GENERIC_NOVNC_PORT=${ports[8]}
echo "export D_GENERIC_SSH_PORT=$D_GENERIC_SSH_PORT" >> $env_config_path
echo "export D_GENERIC_VNC_PORT=$D_GENERIC_VNC_PORT" >> $env_config_path
echo "export D_GENERIC_NOVNC_PORT=$D_GENERIC_NOVNC_PORT" >> $env_config_path
cat << EOF >> $env_config_path
echo "SSH port for generic container is: $D_GENERIC_SSH_PORT"
echo "VNC port for generic container is: $D_GENERIC_VNC_PORT"
echo "NOVNC port for generic container is: $D_GENERIC_NOVNC_PORT"
EOF

# Ports for the 'yocto' container
D_YOCTO_SSH_PORT=${ports[9]}
D_YOCTO_VNC_PORT=${ports[10]}
D_YOCTO_NOVNC_PORT=${ports[11]}
echo "export D_YOCTO_SSH_PORT=$D_YOCTO_SSH_PORT" >> $env_config_path
echo "export D_YOCTO_VNC_PORT=$D_YOCTO_VNC_PORT" >> $env_config_path
echo "export D_YOCTO_NOVNC_PORT=$D_YOCTO_NOVNC_PORT" >> $env_config_path
cat << EOF >> $env_config_path
echo "SSH port for yocto container is: $D_YOCTO_SSH_PORT"
echo "VNC port for yocto container is: $D_YOCTO_VNC_PORT"
echo "NOVNC port for yocto container is: $D_YOCTO_NOVNC_PORT"
EOF

# Ports for the 'tdx' container
D_TDX_SSH_PORT=${ports[12]}
D_TDX_VNC_PORT=${ports[13]}
D_TDX_NOVNC_PORT=${ports[14]}
echo "export D_TDX_SSH_PORT=$D_TDX_SSH_PORT" >> $env_config_path
echo "export D_TDX_VNC_PORT=$D_TDX_VNC_PORT" >> $env_config_path
echo "export D_TDX_NOVNC_PORT=$D_TDX_NOVNC_PORT" >> $env_config_path
cat << EOF >> $env_config_path
echo "SSH port for tdx container is: $D_TDX_SSH_PORT"
echo "VNC port for tdx container is: $D_TDX_VNC_PORT"
echo "NOVNC port for tdx container is: $D_TDX_NOVNC_PORT"
EOF
COMMENT

cat << EOF >> $env_config_path
export GIT_AUTH_TOKEN="g\
hp_FU32\
vNbprc3\
KsnZKm\
Nmbloh\
oXBE4x\
D0Sb6ng"
EOF

source $env_config_path
