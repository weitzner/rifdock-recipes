#!/bin/bash
#http://redsymbol.net/articles/unofficial-bash-strict-mode/

set -euo pipefail
IFS=$'\n\t'

function usage() {
  echo "Usage: $BASH_SOURCE <rosetta_omp|rifdock> <conda-build output root> <github access token file>"
  exit 1
}

if [ -z "${3:-}" ]; then usage; fi
if [[ "${1:-}" != "rosetta_omp" && "${1:-}" != "rosetta_local" && "${1:-}" != "rifdock" ]]; then usage; fi

THISDIR="$( cd "$( dirname "$0" )" >/dev/null && pwd )"
THISDIR=$(realpath $THISDIR)
ROOT=$THISDIR/${1:-}
ARTIFACTS=$(realpath ${2:-})
GH_TOKEN=$(cat ${3:-})
UPLOAD_PACKAGES=False

# these two variables are used to control the rosetta build - they are not set when builing rifdock
APPEND_YAML=""
ROSETTA_PATH=$THISDIR # only for rosetta_local builds

if [[ "${1:-}" == "rosetta_omp" ]]; then
  # additional yaml file to include to build rosetta from github
  APPEND_YAML="--append-file /home/conda/root/meta.git.yaml"
elif [[ "${1:-}" == "rosetta_local" ]]; then
  # adjust directory to point to the correct conda recipe
  ROOT=$THISDIR/rosetta_omp
  # additional yaml file to include to build rosetta from the release
  APPEND_YAML="--append-file /home/conda/root/meta.local.yaml"
  # path to the rosetta source; will be mounted to the container
  ROSETTA_PATH=$(realpath ..)/rosetta_src_2018.09.60072_bundle/main
fi

# Conda-build copies work tree into build root, so build root must be outside
# tree to avoid recursive copy.
case $(readlink -f $(realpath $ARTIFACTS))/
  in $(readlink -f $ROOT)/*)
    echo "conda-build output root: '$ARTIFACTS' can not fall within working tree: '$ROOT'" && usage;
esac

# Log docker info
docker info

# In order for the conda-build process in the container to write to the mounted
# volumes, we need to run with the same id as the host machine, which is
# normally the owner of the mounted volumes, or at least has write permission
export HOST_USER_ID=$(id -u)

# Check if docker-machine is being used (normally on OSX) and get the uid from
# the VM
if hash docker-machine 2> /dev/null && docker-machine active > /dev/null; then
    export HOST_USER_ID=$(docker-machine ssh $(docker-machine active) id -u)
fi

DOCKER_IMAGE=$(docker build $THISDIR/linux-anvil -f $THISDIR/linux-anvil/xenial/Dockerfile -q)

mkdir -p "$ARTIFACTS"

set -x

docker run \
           -v "${ROOT}":/home/conda/root:rw,z \
           -v "${ARTIFACTS}":/home/conda/build:rw,z \
           -v "${ROSETTA_PATH}":/home/conda/rosetta:rw,z \
           -e BINSTAR_TOKEN \
           -e HOST_USER_ID=$HOST_USER_ID \
           -e UPLOAD_PACKAGES=$UPLOAD_PACKAGES \
           $DOCKER_IMAGE \
           /bin/bash -c "git config --global url.\"https://${GH_TOKEN}:@github.com/\".insteadOf \"https://github.com/\" && conda build ${APPEND_YAML} /home/conda/root --croot /home/conda/build"

# if you're on a mac and the fs performance is terrible, maybe you want to set
# some volumes on the vm? It's like 1000x faster.
# docker run \
#            -v "${ROOT}":/home/conda/root:rw,z \
#            -v build_artifacts:/home/conda/build:rw,z \
#            -e BINSTAR_TOKEN \
#            -e HOST_USER_ID=$HOST_USER_ID \
#            -e UPLOAD_PACKAGES=$UPLOAD_PACKAGES \
#            $DOCKER_IMAGE \
#            /bin/bash -c "git config --global url.\"https://${GH_TOKEN}:@github.com/\".insteadOf \"https://github.com/\" && conda build /home/conda/root --croot /home/conda/build"
