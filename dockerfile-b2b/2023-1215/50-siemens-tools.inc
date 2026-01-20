# Put MOTD in .bash_aliases. MOTD is variant sepcific.
COPY .bash_aliases /home/${username}

# Install b2b tools
RUN mkdir -p /opt/avery/2023_1215
COPY apciexactor-2.5c.cxl.tar.gz aqcxl_sim-2023_1215.tar.gz \
  avery_pli-2023_1128.tar.gz verdi.tar.gz vcsmx.tar.gz /tmp
RUN for f in /tmp/*.tar.gz; do tar -xzf $f -C /opt/avery/2023_1215 && rm $f; done

RUN git clone --branch avery-2023_1215 https://${gt}@github.com/MarekBykowski/avery_qemu.git \
  /opt/avery/2023_1215/avery_qemu_env

# Copy sample qcow to have what to get started with
COPY core-image-cxl-sdk-cxlx86-64.rootfs.wic.qcow2 /opt/avery/2023_1215
