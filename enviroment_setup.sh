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


# Common values shared by two containers
D_UID=$(id -u)
D_GID=$(id -g)
D_PASSWORD=password
D_USER=$USER
D_HTTPS_PROXY=http://proxy-us.intel.com:912
D_HTTP_PROXY=http://proxy-us.intel.com:911
D_HOME=$HOME
COMPOSE_PROJECT_NAME="${D_USER}"; echo "Your Docker eco-system is named: $COMPOSE_PROJECT_NAME"

export D_UID D_GID D_PASSWORD D_USER D_HTTPS_PROXY D_HTTP_PROXY D_HOME COMPOSE_PROJECT_NAME

# And some of the values must be unique per user and per container
# Ports are defined from 'user id' + number which is system wise unique
# and remains the same across logins.

# Ports for container b2b
D_B2B_SSH_PORT=$(($D_UID+10000)); echo "SSH PORT for b2b: $D_B2B_SSH_PORT"
D_B2B_VNC_PORT=$(($D_UID+10001)); echo "VNC PORT for b2b: $D_B2B_VNC_PORT"
D_B2B_NOVNC_PORT=$(($D_UID+10002)); echo "NOVNC PORT for b2b: $D_B2B_NOVNC_PORT"
export D_B2B_SSH_PORT D_B2B_VNC_PORT D_B2B_NOVNC_PORT

# Ports for container yocto-ci
D_YOCTO_CI_SSH_PORT=$(($D_UID+20000)); echo "SSH PORT for yocto-ci: $D_YOCTO_CI_SSH_PORT"
D_YOCTO_CI_VNC_PORT=$(($D_UID+20001)); echo "VNC PORT for yocto-ci: $D_YOCTO_CI_VNC_PORT"
D_YOCTO_CI_NOVNC_PORT=$(($D_UID+20002)); echo "NOVNC PORT for yocto-ci: $D_YOCTO_CI_NOVNC_PORT"
export D_YOCTO_CI_SSH_PORT D_YOCTO_CI_VNC_PORT D_YOCTO_CI_NOVNC_PORT

export GIT_AUTH_TOKEN="g\
hp_FU32\
vNbprc3\
KsnZKm\
Nmbloh\
oXBE4x\
D0Sb6ng"
