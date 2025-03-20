FROM ubuntu:22.04
 
RUN <<EOF
groupadd --gid 1004 mbykowsx
useradd --uid 1003 --gid 1004 --shell /bin/bash --create-home mbykowsx
usermod -a -G sudo mbykowsx
echo "mbykowsx:marian12" | chpasswd
EOF

COPY apt.conf /etc/apt/

RUN <<EOF
apt-get -y update
apt-get -y install sudo vim git tmux
EOF

WORKDIR /home/mbykowsx
 
USER mbykowsx
