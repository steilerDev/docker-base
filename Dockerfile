FROM node:17-bullseye

# Applying fs patch for assets
ADD rootfs.tar.gz /

# Install stuff and remove caches
RUN apt-get update \
 && apt-get install \
        --no-install-recommends \
        --fix-missing \
        --assume-yes \
            apt-utils vim \
        && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Execute application
ENTRYPOINT ["node", "/opt/entrypoint.sh"]