# included (variant override): /home/mbykowsx/docker-intel/dockerfile-b2b/2025-3-ubuntu-24.04/00-base.inc
FROM ubuntu:24.04

ARG username
ARG gid
ARG uid
ARG password
ARG gt

RUN cat /etc/os-release

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
# included (default): /home/mbykowsx/docker-intel/dockerfile-b2b/dockerfile.inc/10-apt-intel.inc
# This apt-conf includes the http proxy used in Intel. Run it only for Intel.
COPY apt.conf /etc/apt/

# included (variant override): /home/mbykowsx/docker-intel/dockerfile-b2b/2025-3-ubuntu-24.04/20-common-tools.inc
# ALL shared apt packages
RUN apt-get -o Acquire::Retries=5 update && \
  # esentially Yocto tools
  apt-get -y update && apt-get -y install build-essential chrpath cpio debianutils diffstat file gawk \
    gcc iputils-ping libacl1 liblz4-tool python3 python3-git locales \
    python3-jinja2 python3-pexpect python3-pip python3-subunit socat texinfo unzip \
    wget xz-utils zstd iproute2 && \
  apt-get -y install sudo vim tmux gzip unzip git cpu-checker  perl libterm-readkey-perl \
    libpixman-1-0 libpixman-1-dev  libglib2.0-0 && \
  # required from sv
  apt-get -y install dc time libelf1 && \
  # install kmod (modprobe) gh, slirp, libslirp, etc.
  apt-get install -y kmod gh libslirp-dev sphinx-basic-ng python3-sphinx-rtd-theme \
    ninja-build pkg-config libglib2.0-dev && \
  # install remaining build dependencies for pciutils 3.13+ installed from repo (note ubuntu has 3.10)
  apt-get install -y libpci-dev && \
  # install GUI, vnc, novnc
  apt-get install -y --no-install-recommends apt-utils sudo supervisor vim \
    openssh-server \
    xserver-xorg xvfb x11vnc dbus-x11 xfce4 \
    xfce4-terminal xfce4-xkb-plugin \
    novnc websockify

# Install firefox
RUN apt-get -y update && apt-get -y install firefox
# included (variant override): /home/mbykowsx/docker-intel/dockerfile-b2b/2025-3-ubuntu-24.04/30-variant-tools.inc
# Updated b2b 2025-3 requires on top
# Ubuntu 24.04 has libncur*6 version 6
RUN apt-get update -y && \
  apt-get install -y libncurses6 libncursesw6 iproute2
# included (default): /home/mbykowsx/docker-intel/dockerfile-b2b/dockerfile.inc/40-config.inc
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
# included (variant override): /home/mbykowsx/docker-intel/dockerfile-b2b/2025-3-ubuntu-24.04/50-siemens-tools.inc
# Put MOTD in .bash_aliases. MOTD is variant sepcific.
COPY .bash_aliases /home/${username}

# Install b2b tools
RUN mkdir -p /opt/avery/2025-3
COPY cxlvs-2025.3.tgz vics-2025.2.1.tgz \
  vip-2025.3.tgz verdi.tar.gz vcsmx.tar.gz /tmp
#RUN for f in /tmp/*.tar.gz /tmp/*.tgz; do tar -xzf $f -C /opt/avery/2025-3 && rm $f; done
RUN for f in /tmp/*.tar.gz /tmp/*.tgz; do \
  [ -e "$f" ] || continue; \
    tar -xf "$f" -C /opt/avery/2025-3 && rm -f "$f"; \
  done

# apciexactor-gen7* is a special case: it needs to be extracted to /opt/avery/2025-3/vip-2025.3
COPY apciexactor-gen7_2025_2_0814_cbe30abcfb.cxl.dmi.lpif.tar.gz /tmp
RUN tar -xzf /tmp/apciexactor-gen7_2025_2_0814_cbe30abcfb.cxl.dmi.lpif.tar.gz -C \
  /opt/avery/2025-3/vip-2025.3 && rm /tmp/apciexactor-gen7_2025_2_0814_cbe30abcfb.cxl.dmi.lpif.tar.gz

RUN git clone --branch avery-2025.3 https://${gt}@github.com/MarekBykowski/avery_qemu.git \
  /opt/avery/2025-3/avery_qemu_env

# Copy sample qcow to have what to get started with
COPY core-image-cxl-sdk-cxlx86-64.rootfs.wic.qcow2 /opt/avery/2025-3

# Apply the patch into the run_qemu.pl
COPY 0001-Bugfix-for-run_qemu.pl.patch /tmp/
RUN set -eux; \
    cd /opt/avery/2025-3/vics-2025.2.1; \
    patch -p1 < /tmp/0001-Bugfix-for-run_qemu.pl.patch; \
    rm -f /tmp/0001-Bugfix-for-run_qemu.pl.patch

# Fix qemu release by shipping pc-bios missing along with the binary
RUN set -eux; \
    git clone --depth 1 https://github.com/qemu/qemu.git /tmp/qemu; \
    mkdir -p /opt/avery/2025-3/vics-2025.2.1/vics/tools/qemu-bundle/usr/local/share/qemu; \
    cp -r /tmp/qemu/pc-bios/* \
       /opt/avery/2025-3/vics-2025.2.1/vics/tools/qemu-bundle/usr/local/share/qemu/; \
    rm -rf /tmp/qemu

# included (default): /home/mbykowsx/docker-intel/dockerfile-b2b/dockerfile.inc/60-user-env-ux.inc
# User  env & UX
# terminal
COPY config/xfce4/terminal/terminalrc /home/${username}/.config/xfce4/terminal/terminalrc
# wallpaper
COPY config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml /home/${username}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
# icon theme
COPY config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml /home/${username}/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml

# add my sys config files
COPY etc /etc
# included (default): /home/mbykowsx/docker-intel/dockerfile-b2b/dockerfile.inc/70-ownership.inc
# Claim ownership
RUN chown -v -R ${username}:${username} /home/${username}

# Claim ownership of /opt. If not sudo is required to make any
# changes to Avery files, including git
RUN chown -v -R ${username}:${username} /opt

# included (default): /home/mbykowsx/docker-intel/dockerfile-b2b/dockerfile.inc/90-runtime.inc
# ports
EXPOSE 22 5900 6080

# default command
CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
