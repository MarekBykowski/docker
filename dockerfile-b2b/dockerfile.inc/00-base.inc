FROM ubuntu:20.04

ARG username
ARG gid
ARG uid
ARG password
ARG gt

# default screen size
ENV XRES=1280x800x24

# Ubuntu doesn't set this var and without it avery qemu fails
ENV USER=${username}

# supress dialogue when installing tzdata
ENV TZ=Europe/Warsaw
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV DEBIAN_FRONTEND=noninteractive

# `kvm` group may not exist yet. Do not treat it as an error preventing from
# image building.
RUN groupadd --gid "${gid}" "${username}" && \
  useradd --uid "${uid}" --gid "${gid}" \
          --shell /bin/bash \
          --create-home "${username}" && \
  usermod -a -G sudo "${username}" && \
  usermod -a -G kvm  "${username}"; \
  echo "${username}:${password}" | chpasswd
