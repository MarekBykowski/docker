FROM ubuntu:22.04

# default screen size
ENV XRES=1280x800x24

# default tzdata
ENV TZ=Etc/UTC

ENV DEBIAN_FRONTEND=noninteractive

# install ubuntu filares (xfce, vnc, novnc, etc.)
RUN <<EOF
apt-get update && apt-get upgrade -y
apt-get install -y --no-install-recommends apt-utils sudo supervisor vim \
   openssh-server \
   xserver-xorg xvfb x11vnc dbus-x11 xfce4 \
   xfce4-terminal xfce4-xkb-plugin \
   novnc websockify

# fix "LC_ALL: cannot change locale (en_US.UTF-8)""
apt-get install locales
echo "LC_ALL=en_US.UTF-8" >> /etc/environment
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
locale-gen en_US.UTF-8
EOF


# install Yocto at el.
RUN <<EOF
apt-get -y update
apt-get -y install build-essential chrpath cpio debianutils diffstat file gawk \
  gcc iputils-ping libacl1 liblz4-tool python3 python3-git locales \
  python3-jinja2 python3-pexpect python3-pip python3-subunit socat texinfo unzip \
  wget xz-utils zstd
apt-get -y install tmux gzip unzip git
apt-get -y install cpu-checker
apt-get -y install perl libterm-readkey-perl
apt-get -y install libpixman-1-0 libpixman-1-dev
apt-get -y install libglib2.0-0
#required from sv
apt-get -y install dc time
EOF

# cleanup and fix
RUN <<EOF
apt-get autoremove -y
apt-get --fix-broken install
apt-get clean
rm -rf /var/lib/apt/lists/*
EOF

# required preexisting dirs
RUN mkdir /run/sshd

# users and groups
RUN echo "root:ubuntu" | /usr/sbin/chpasswd \
    && useradd -m ubuntu -s /bin/bash \
    && echo "ubuntu:ubuntu" | /usr/sbin/chpasswd \
    && echo "ubuntu    ALL=(ALL) ALL" >> /etc/sudoers

# add my sys config files
ADD etc /etc

# user config files

# terminal
ADD config/xfce4/terminal/terminalrc /home/ubuntu/.config/xfce4/terminal/terminalrc
# wallpaper
ADD config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml /home/ubuntu/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
# icon theme
ADD config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml /home/ubuntu/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml

# TZ, aliases
RUN cd /home/ubuntu \
  && echo 'export TZ=/usr/share/zoneinfo/$TZ' >> .bashrc \
  && sed -i 's/#alias/alias/' .bashrc  \
  && echo "alias lla='ls -al'" 		>> .bashrc \
  && echo "alias llt='ls -ltr'"  		>> .bashrc \
  && echo "alias llta='ls -altr'" 	>> .bashrc \
  && echo "alias llh='ls -lh'" 		>> .bashrc \
  && echo "alias lld='ls -l|grep ^d'" >> .bashrc \
  && echo "alias hh=history" 			>> .bashrc \
  && echo "alias hhg='history|grep -i" '"$@"' "'" >> .bashrc

# set owner
RUN chown -R ubuntu:ubuntu /home/ubuntu/.*

# ports
EXPOSE 22 5900 6080

# # default command
CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
