FROM ubuntu:20.04

ARG username
ARG gid
ARG uid
ARG password

# Ubuntu doesn't set this var and without it avery qemu fails
ENV USER=${username}

# supress dialogue when installing tzdata
ENV TZ=Europe/Warsaw
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
#ENV DEBIAN_FRONTEND=noninteractive

RUN <<EOF
# docker build --build-arg username=mbykowsx
groupadd --gid ${gid} ${username}
useradd --uid ${uid} --gid ${gid} --shell /bin/bash --create-home ${username}
usermod -a -G sudo ${username}
usermod -a -G kvm ${username}
echo "${username}:${password}" | chpasswd
EOF

COPY apt.conf /etc/apt/
COPY .bash_aliases /home/${username}
COPY core-image-cxl-sdk-cxlx86-64.rootfs.wic.qcow2 /home/${username}

RUN <<EOF
apt-get -y update
apt-get -y install build-essential chrpath cpio debianutils diffstat file gawk \
  gcc iputils-ping libacl1 liblz4-tool python3 python3-git locales \
  python3-jinja2 python3-pexpect python3-pip python3-subunit socat texinfo unzip \
  wget xz-utils zstd
apt-get -y install sudo vim tmux gzip unzip git
apt-get -y install git
apt-get -y install cpu-checker
apt-get -y install perl libterm-readkey-perl
apt-get -y install libpixman-1-0 libpixman-1-dev
apt-get -y install libglib2.0-0
#required from sv
apt-get -y install dc time libelf1
EOF

# install gh
COPY gh_2.69.0_linux_amd64.deb /home/${username}
RUN dpkg -i /home/${username}/gh_2.69.0_linux_amd64.deb

# make /bin/sh symlink to bash instead of dash:
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

RUN mkdir -p /home/${username}/avery/2023_1215
COPY apciexactor-2.5c.cxl.tar.gz aqcxl_sim-2023_1215.tar.gz \
  avery_pli-2023_1128.tar.gz avery_qemu-docker.zip \
  verdi.tar.gz vcsmx.tar.gz /tmp
RUN for f in /tmp/*tar.gz; do tar -xzf $f -C /home/${username}/avery/2023_1215 && rm $f; done
RUN unzip /tmp/avery_qemu-docker.zip -d /home/${username}/avery/2023_1215
RUN chown -R ${username}:${username} /home/${username}

WORKDIR /home/${username}

USER ${username}
