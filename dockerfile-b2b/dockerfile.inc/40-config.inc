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
