#!/bin/bash

export D_UID=$(id -u) \
   D_GID=$(id -g) \
   D_PASSWORD=password \
   D_USER=$USER \
   D_HTTPS_PROXY=$HTTPS_PROXY \
   D_HTTP_PROXY=$HTTP_PROXY \
   D_HOME=$HOME
