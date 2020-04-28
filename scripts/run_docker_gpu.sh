#!/bin/bash
# Launch an experiment using the docker gpu image

cmd_line="$@"

echo "Executing in the docker (gpu image):"
echo $cmd_line

# TODO: always use new-style once sufficiently widely used (probably 2021 onwards)
if [ -x "$(which nvidia-docker)" ]; then
  # old-style nvidia-docker2
  NVIDIA_ARG="--runtime=nvidia"
else
  NVIDIA_ARG="--gpus all"
fi

# this is where the experiments will be run in the
# container image
CODE_LOC="/root/code/GAIL-Formal_Methods"

# this is the image name and tag
CONTAINER_TAG=stable_baselines_modded:latest

# name the running container for better visibility
CONTAINER_NAME="IL_BOX"

# give the hostname for a nice touch when using the box interactively
CONTAINER_HOSTNAME="licious"

# run a jupyter notebook session in the container
JUPYTER_CMD="jupyter notebook --no-browser --allow-root --port 1234"

docker run -it ${NVIDIA_ARG} --rm --network host --ipc=host \
  --name=${IL_BOX} --hostname=${CONTAINER_HOSTNAME} \
  --mount src=$(pwd),target=${CODE_LOC},type=bind ${CONTAINER_TAG} \
  bash -c "cd $CODE_LOC && $JUPYTER_CMD"
