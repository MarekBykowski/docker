# Updated b2b 2025-3 requires on top
RUN apt-get update -y && \
  apt-get install -y libncurses5 libncursesw5 iproute2
