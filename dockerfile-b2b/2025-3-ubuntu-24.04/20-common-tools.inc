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
