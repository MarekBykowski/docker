# ALL shared apt packages
RUN apt-get update -y && \
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
