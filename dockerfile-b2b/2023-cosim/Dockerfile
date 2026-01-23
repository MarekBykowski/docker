# included: /home/mbykowsx/docker-intel/dockerfile-b2b/dockerfile.inc/00-base.inc
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
# included: /home/mbykowsx/docker-intel/dockerfile-b2b/dockerfile.inc/10-apt-intel.inc
# This apt-conf includes the http proxy used in Intel. Run it only for Intel.
COPY apt.conf /etc/apt/

# included: /home/mbykowsx/docker-intel/dockerfile-b2b/dockerfile.inc/20-common-tools.inc
# ALL shared apt packages
RUN apt-get -o Acquire::Retries=5 update && \
  # esentially Yocto tools
  apt-get install -y build-essential chrpath cpio debianutils diffstat \
    file gawk gcc iputils-ping libacl1 liblz4-tool python3 python3-git \
    locales python3-jinja2 python3-pexpect python3-pip python3-subunit \
    socat texinfo unzip  wget xz-utils zstd && \
  # others
  apt-get install -y sudo vim tmux gzip unzip git cpu-checker perl \
    libterm-readkey-perl libpixman-1-0 libpixman-1-dev libglib2.0-0 && \
  # required from sv
  apt-get install -y dc time libelf1 && \
  # install GUI, vnc, novnc
  apt-get install -y --no-install-recommends apt-utils sudo supervisor vim \
   openssh-server xserver-xorg xvfb x11vnc dbus-x11 xfce4 \
   xfce4-terminal xfce4-xkb-plugin novnc websockify

# Install firefox
RUN apt-get -y update && apt-get -y install firefox

# install gh. in Ubuntu 20.04 it is not in apt
COPY gh_2.69.0_linux_amd64.deb /home/${username}
RUN dpkg -i /home/${username}/gh_2.69.0_linux_amd64.deb
# skipped (not found): /home/mbykowsx/docker-intel/dockerfile-b2b/2023-cosim/30-variant-tools.inc
# included: /home/mbykowsx/docker-intel/dockerfile-b2b/dockerfile.inc/40-config.inc
# sshd setup
RUN mkdir -p /run/sshd && chmod 0755 /run/sshd && \
   rm -f /etc/ssh/ssh_host_* && \
   ssh-keygen -A && \
   chmod 600 /etc/ssh/ssh_host_*_key && \
   chmod 644 /etc/ssh/ssh_host_*_key.pub && \
   /usr/sbin/sshd -t

# Shell behaviour: make /bin/sh symlink to bash instead of dash
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash
# included: /home/mbykowsx/docker-intel/dockerfile-b2b/2023-cosim/50-siemens-tools.inc
# Put MOTD in .bash_aliases. MOTD is variant sepcific.
COPY .bash_aliases /home/${username}

# Install b2b tools
RUN mkdir -p /opt/avery/2023_cosim
COPY apciexactor-2.5c.cxl.tgz aqcxl_sim-2023_1215.4.tgz \
  avery_pli-2025.3_1.tgz verdi.tar.gz vcsmx.tar.gz /tmp
#RUN for f in /tmp/*.tar.gz; do tar -xzf $f -C /opt/avery/2023_cosim && rm $f; done
RUN for f in /tmp/*.tar.gz /tmp/*.tgz; do \
  [ -e "$f" ] || continue; \
    tar -xf "$f" -C /opt/avery/2023_cosim && rm -f "$f"; \
  done


RUN git clone --branch avery-2023_cosim https://${gt}@github.com/MarekBykowski/avery_qemu.git \
  /opt/avery/2023_cosim/avery_qemu_env

# Copy sample qcow to have what to get started with
COPY core-image-cxl-sdk-cxlx86-64.rootfs.wic.qcow2 /opt/avery/2023_cosim
# included: /home/mbykowsx/docker-intel/dockerfile-b2b/dockerfile.inc/60-user-env-ux.inc
# User  env & UX
# terminal
COPY config/xfce4/terminal/terminalrc /home/${username}/.config/xfce4/terminal/terminalrc
# wallpaper
COPY config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml /home/${username}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
# icon theme
COPY config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml /home/${username}/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml

# add my sys config files
COPY etc /etc
# included: /home/mbykowsx/docker-intel/dockerfile-b2b/dockerfile.inc/70-ownership.inc
# Claim ownership
RUN chown -v -R ${username}:${username} /home/${username}

# Claim ownership of /opt. If not sudo is required to make any
# changes to Avery files, including git
RUN chown -v -R ${username}:${username} /opt

# included: /home/mbykowsx/docker-intel/dockerfile-b2b/dockerfile.inc/90-runtime.inc
# ports
EXPOSE 22 5900 6080

# default command
CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
