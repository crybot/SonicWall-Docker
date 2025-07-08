FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    coreutils \
    sed \
    gawk \
    grep \
    util-linux \
    perl \
    bzip2 \
    tar \
    kmod \
    openjdk-17-jre \
    ca-certificates \
    openssl \
    sudo \
    libx11-6 \
    libxtst6 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrender1 \
    libxrandr2 \
    fontconfig \
    libfreetype6 \
    libglib2.0-0 \
    ppp \
    && rm -rf /var/lib/apt/lists/*

# Copy the ConnectTunnel directory (containing install.sh and the tar.bz2) into the image
COPY ConnectTunnel /tmp/ConnectTunnelInstaller

WORKDIR /tmp/ConnectTunnelInstaller

# Simpler workaround for 'modprobe tun' and 'mknod /dev/net/tun' checks
# This involves renaming the actual utilities and symlinking their original paths to /bin/true
# We try multiple common paths where these utilities might reside.
RUN \
    # Backup real utilities and link their paths to /bin/true
    echo "Temporarily replacing modprobe and mknod with /bin/true for installation..." && \
    \
    (if [ -f /sbin/modprobe ]; then mv /sbin/modprobe /sbin/modprobe.real && ln -sf /bin/true /sbin/modprobe; fi) || true; \
    (if [ -f /usr/sbin/modprobe ]; then mv /usr/sbin/modprobe /usr/sbin/modprobe.real && ln -sf /bin/true /usr/sbin/modprobe; fi) || true; \
    (if [ -f /bin/modprobe ]; then mv /bin/modprobe /bin/modprobe.real && ln -sf /bin/true /bin/modprobe; fi) || true; \
    (if [ -f /usr/bin/modprobe ]; then mv /usr/bin/modprobe /usr/bin/modprobe.real && ln -sf /bin/true /usr/bin/modprobe; fi) || true; \
    \
    (if [ -f /bin/mknod ]; then mv /bin/mknod /bin/mknod.real && ln -sf /bin/true /bin/mknod; fi) || true; \
    (if [ -f /usr/bin/mknod ]; then mv /usr/bin/mknod /usr/bin/mknod.real && ln -sf /bin/true /usr/bin/mknod; fi) || true; \
    (if [ -f /sbin/mknod ]; then mv /sbin/mknod /sbin/mknod.real && ln -sf /bin/true /sbin/mknod; fi) || true; \
    (if [ -f /usr/sbin/mknod ]; then mv /usr/sbin/mknod /usr/sbin/mknod.real && ln -sf /bin/true /usr/sbin/mknod; fi) || true; \
    \
    # The install script attempts 'mkdir /dev/net'. This should succeed.
    # The dummy mknod (now /bin/true) won't create /dev/net/tun, but the script checks its exit code.
    mkdir -p /dev/net && \
    \
    # Make install.sh executable and run it
    echo "Running install.sh..." && \
    chmod +x install.sh && ./install.sh --auto && \
    echo "install.sh finished." && \
    \
    # Restore real utilities
    echo "Restoring original modprobe and mknod..." && \
    (if [ -f /sbin/modprobe.real ]; then rm -f /sbin/modprobe && mv /sbin/modprobe.real /sbin/modprobe; fi) || true; \
    (if [ -f /usr/sbin/modprobe.real ]; then rm -f /usr/sbin/modprobe && mv /usr/sbin/modprobe.real /usr/sbin/modprobe; fi) || true; \
    (if [ -f /bin/modprobe.real ]; then rm -f /bin/modprobe && mv /bin/modprobe.real /bin/modprobe; fi) || true; \
    (if [ -f /usr/bin/modprobe.real ]; then rm -f /usr/bin/modprobe && mv /usr/bin/modprobe.real /usr/bin/modprobe; fi) || true; \
    \
    (if [ -f /bin/mknod.real ]; then rm -f /bin/mknod && mv /bin/mknod.real /bin/mknod; fi) || true; \
    (if [ -f /usr/bin/mknod.real ]; then rm -f /usr/bin/mknod && mv /usr/bin/mknod.real /usr/bin/mknod; fi) || true; \
    (if [ -f /sbin/mknod.real ]; then rm -f /sbin/mknod && mv /sbin/mknod.real /sbin/mknod; fi) || true; \
    (if [ -f /usr/sbin/mknod.real ]; then rm -f /usr/sbin/mknod && mv /usr/sbin/mknod.real /usr/sbin/mknod; fi) || true; \
    echo "Utilities restored."

WORKDIR /usr/local/Aventail

CMD ["/bin/bash"]
