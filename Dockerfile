FROM node:17-bullseye

# Applying fs patch for assets
ADD rootfs.tar.gz /

# Install stuff and remove caches
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get install \
        --no-install-recommends \
        --fix-missing \
        --assume-yes \
            apt-utils vim curl wget && \
    apt-get clean autoclean && \
    apt-get autoremove && \
    rm -rf /var/lib/{apt,dpkg,cache,log} /tmp/* /var/tmp/*
