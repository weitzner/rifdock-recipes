#!/bin/bash
#http://redsymbol.net/articles/unofficial-bash-strict-mode/

set -euo pipefail
IFS=$'\n\t'

function usage() {
  echo "Usage: $BASH_SOURCE <local conda channel path>"
  exit 1
}

if [ -z "${1:-}" ]; then usage; fi
CHANNEL=$(realpath ${1:-})

DOCKER_IMAGE=$(docker build linux-anvil -f linux-anvil/miniconda3/Dockerfile -q)

set -x

# this needs to be done outside of the docker build because we need to mount
# the conda channel
docker run \
        -v ${CHANNEL}:/cache \
        $DOCKER_IMAGE \
        conda install rifdock -c file:///cache --yes

# get the container id
CID=$(docker ps -qn 1)

# save new image and write it to disk
docker commit $CID rifdock:latest
docker save "rifdock:latest" > rifdock.latest.tar

echo "Successfuly created rifdock image\!" \
"To load the image on your system, do" \
"'docker load < rifdock.latest.tar'."
