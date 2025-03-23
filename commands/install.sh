#!/bin/bash

echo marian12 | sudo install -v image check_docker_container.sh /usr/local/bin/
echo marian12 | sudo install -v -m 644 image-completion.sh /etc/bash_completion.d/
