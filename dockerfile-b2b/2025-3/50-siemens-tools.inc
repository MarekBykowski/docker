# Put MOTD in .bash_aliases. MOTD is variant sepcific.
COPY .bash_aliases /home/${username}

# Install b2b tools
RUN mkdir -p /opt/avery/2025-3
COPY cxlvs-2025.3.tgz vics-2025.2.1.tgz 2026.1.tgz \
  vip-2025.3.tgz verdi.tar.gz vcsmx.tar.gz /tmp
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

