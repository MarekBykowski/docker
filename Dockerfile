FROM ubuntu:20.04

ARG username
ARG gid
ARG uid
ARG password

# Ubuntu doesn't set this var and without it avery qemu fails
ENV USER=${username}

# apt.conf contains proxy for apt-get
COPY apt.conf /etc/apt/

# set `build` proxy. Note when `run` we set proxy as well.
#ENV env | grep -i _PROXY
ENV HTTPS_PROXY=http://proxy-us.intel.com:912
ENV HTTP_PROXY=http://proxy-us.intel.com:911

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

RUN id ${uid}

RUN <<EOF
apt-get -y update && apt-get install -y --no-install-recommends \
  build-essential \
  chrpath \
  cpio \
  debianutils \
  diffstat \
  file \
  gawk \
  gcc \
  iproute2 \
  iputils-ping \
  libacl1 \
  liblz4-tool \
  openssh-client \
  python3 \
  python3-git \
  locales \
  python3-jinja2 \
  python3-pexpect \
  python3-pip \
  python3-subunit \
  socat \
  texinfo \
  unzip \
  wget \
  xz-utils \
  zstd && \
apt-get -y install sudo \
  vim \
  tmux \
  gzip \
  git \
  cpu-checker \
  perl \
  libterm-readkey-perl \
  libpixman-1-0 \
  libpixman-1-dev \
  libglib2.0-0
EOF

# make /bin/sh symlink to bash instead of dash:
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# install gh cli
WORKDIR /home/${username}
COPY gh_2.69.0_linux_amd64.deb ./
RUN dpkg -i gh_2.69.0_linux_amd64.deb
RUN cat /etc/passwd
USER ${username}
COPY mytoken.txt .gitconfig ./
RUN gh auth login --with-token < mytoken.txt

# copy my tmux and vim confs
RUN git clone https://github.com/MarekBykowski/readme.git
RUN sh -c "cd readme; ./run.sh"

# in .bash_aliases I do not yet put anything yet
COPY .bash_aliases ./

WORKDIR /home/${username}/yocto
RUN id && cat ~/.gitconfig
RUN git clone --branch nanbield https://github.com/MarekBykowski/meta-cxl.git
RUN git clone --branch nanbield https://github.com/MarekBykowski/poky.git
RUN git clone https://github.com/openembedded/meta-openembedded.git && \
    cd meta-openembedded; git checkout -b nanbield --track origin/nanbield

#RUN chown -R ${username}:${username} /home/${username}

WORKDIR /home/${username}
