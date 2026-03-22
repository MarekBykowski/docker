# Updated b2b 2025-3 requires on top
# Ubuntu 24.04 has libncur*6 version 6
RUN apt-get update -y && \
  apt-get install -y libncurses6 libncursesw6 iproute2
