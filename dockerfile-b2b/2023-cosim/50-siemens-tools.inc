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
