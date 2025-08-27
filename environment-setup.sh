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
# Common values shared by two containers
echo "export D_UID=$(id -u)" >> $env_config_path
echo "export D_GID=$(id -g)" >> $env_config_path
echo "export D_PASSWORD=password" >> $env_config_path
D_USER=$USER
echo "export D_USER=$D_USER" >> $env_config_path
echo "export D_HTTPS_PROXY=http://proxy-us.intel.com:912" >> $env_config_path
echo "export D_HTTP_PROXY=http://proxy-us.intel.com:911" >> $env_config_path
echo "export D_HOME=$HOME" >> $env_config_path
COMPOSE_PROJECT_NAME=$D_USER
echo "echo \"Your Docker eco-system is named: $COMPOSE_PROJECT_NAME\"" >> $env_config_path
echo "#COMPOSE_PROJECT_NAME is a compose defined var exported. Do not change its name!" >> $env_config_path
echo "export COMPOSE_PROJECT_NAME=$COMPOSE_PROJECT_NAME" >> $env_config_path

# Ports for container b2b
# Ports must be unique system-wise and ideally remain the same at next compose run.
# The algorithm for assigning the ports is in port-assignment.sh file.
# It sets `ports` array variable with the 6x ports (3x for b2b and 3 for yocto-ci)
source $env_dir/port-assignment.sh
ports=()
count=1
while [ "${#ports[@]}" -lt 6 ]; do
	port=$(echo_free_port $START_PORT)
	if [[ ! " ${ports[*]} " =~ " $port " ]]; then
		ports+=($port)
		((START_PORT+=1))
	fi
	((count++))
	if [[ $count -eq 11 ]]; then
		echo "Cannot allocate available ports in the range set $START_PORT..$END_PORT. Maybe the docker eco-system is up and running."
		echo "If so before re-creating the configuration you have to stop the docker eco-system first, eg."
		echo -e "\t'source $env_config_path && $env_dir/run.sh down'"
		return 127
	fi
done

# Ports for container b2b
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

# Ports for container yocto-ci
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
