#!/bin/bash

# This file is meant to run before the specified `entrypoint` of a container.

#services:
#  hello-world:
#    image: hello-world:dev
#    environment:
#      NODE_ENV: development
#    comman: /init/init-hook.sh
#    volumes:
#    - <some-dir-conatining-this-file>/:/init/
#    - /var/run/docker.sock:/tmp/docker.sock

apt-get update && \
apt-get install \
    --no-install-recommends \
    --fix-missing \
    --assume-yes \
        apt-utils vim jq curl \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

DOCKER_SOCKET="/var/run/docker.sock"
if [ ! -e $DOCKER_SOCKET ]; then
    echo "Unable to find docker socket (/var/run/docker.sock), aborting!"
    exit 1
fi

echo "Installing docker cli..."
DOCKER_VERSION=$(curl -s --unix-socket $DOCKER_SOCKET http://localhost/version | jq .Version | tr -d '"')
DOCKER_URL="https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz"
echo $DOCKER_URL
curl -fsSLO ${DOCKER_URL} \
  && tar xzvf docker-${DOCKER_VERSION}.tgz --strip 1 \
                 -C /usr/local/bin docker/docker \
  && rm docker-${DOCKER_VERSION}.tgz

echo "Extracting entypoint..."
IMAGE_ID=$(cat /proc/self/cgroup | grep docker | head -1)
IMAGE_ID=${IMAGE_ID##*/}
IMAGE_NAME=$(/usr/local/bin/docker inspect $IMAGE_ID | jq .[0].Config.Image | tr -d '"')
IMAGE_ENTRYPOINT=$(/usr/local/bin/docker inspect $IMAGE_NAME | jq .[0].Config.Entrypoint[0] | tr -d '"')
echo "Extracted entrypoint $ENTRYPOINT"

if [ -e /init/user-init.sh ]; then
    echo "Running user-init script..."
    /init/user-init.sh
fi

echo "Clearing apt cache..."
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

echo "Running entrypoint ($ENTRYPOINT)"
"$ENTRYPOINT"
