#!/bin/bash
# Launch an experiment using the docker gpu image

cmd_line="$@"

echo "Executing in the docker (gpu image):"
echo $cmd_line

# TODO: always use new-style once sufficiently widely used 
# (probably 2021 onwards)
if [ -x "$(which nvidia-docker)" ]; then
  # old-style nvidia-docker2
  NVIDIA_ARG="--runtime=nvidia"
else
  NVIDIA_ARG="--gpus all"
fi


# this is the image name and tag
CONTAINER_TAG=gail_formal_methods:latest

# name the running container for better visibility
CONTAINER_NAME="IL_BOX"

# don't run shit as root :)
CONTAINER_USER="ferga"
CONTAINER_UID=69

# this is where the experiments will be run in the
# container image
CODE_LOC="/home/$USR/GAIL-Formal_Methods"

# give the hostname for a nice touch when using the box interactively
CONTAINER_HOSTNAME="licious"

args=(-it $NVIDIA_ARG --rm --network host --ipc=host \
  --name=$CONTAINER_NAME --hostname=$CONTAINER_HOSTNAME \
  --mount src=$(pwd),target=$CODE_LOC,type=bind $CONTAINER_TAG)

if [ -n "$cmd_line" ]
then
      # cmd_line args aren't empty, so user wants to use the env 
      # interactively without running the entrypoint
      args+=(bash -c "cd $CODE_LOC && $cmd_line")
fi

echo "docker run" "${args[@]}"

# now actually run the container with the desired arguments
docker run "${args[@]}"