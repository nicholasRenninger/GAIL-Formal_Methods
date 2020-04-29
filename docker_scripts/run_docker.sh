#!/bin/bash
# Launch an experiment using the docker tf-based (CPU / GPU) image
# 
# Example usage:
#   
#   run with a CPU-only image:
#   - ./run_docker.sh --device=cpu $BASH_COMMAND
#
#   run with a GPU-enabled image:
#   - ./run_docker.sh --device=gpu $BASH_COMMAND



# TODO: always use new-style once sufficiently widely used 
# (probably 2021 onwards)
if [ -x "$(which nvidia-docker)" ]; then
  # old-style nvidia-docker2
  NVIDIA_ARG="--runtime=nvidia"
else
  NVIDIA_ARG="--gpus all"
fi



#############################################################################
##   Deciding whether to run CPU or GPU image based on command-line flag   ##
#############################################################################

# use -d or --device to specify whether to use a CPU or GPU docker image
# allowed arguments:
#   - cpu
#   - gpu

for i in "$@"
do

case $i in
    -d=*|--device=*)
    DEVICE="${i#*=}"
    shift # past argument=value
    ;;
    *)
      # unknown option
    ;;
esac
done

# anything not a kwarg is interpreted as a bash command to run in the container
cmd_line_args=$1

# deciding which device image to run based on kwarg
if [ "$DEVICE" = "gpu" ] || [ "$DEVICE" = "GPU" ]; then

  echo "Executing in the docker (gpu image):"
  CONTAINER_TAG="gail_formal_methods"

elif [ "$DEVICE" = "cpu" ] || [ "$DEVICE" = "CPU" ]; then

  echo "Executing in the docker (gpu image):"
  CONTAINER_TAG="gail_formal_methods-cpu"

elif [ -z "$DEVICE" ]; then

    # write error message to stderr
  printf '%s\n' "not given kwarg: --device=  . Choose from: 'gpu' or 'cpu'" >&2 

  # or exit
  exit 1

else

  # write error message to stderr
  printf '%s\n' "given kwarg: --device=${DEVICE}     not 'gpu' or 'cpu'" >&2 

  # or exit
  exit 1

fi

echo $cmd_line_args




#############################################################################
##                   Container configuration and running                   ##
#############################################################################

# this is the image name and tag
CONTAINER_VERSION="latest"
CONTAINER_ID="${CONTAINER_TAG}:${CONTAINER_VERSION}"

# name the running container for better visibility
CONTAINER_NAME="RL_BOX"

# done so we don't run shit as root :). DONT CHANGE THIS, the user is set in
# the dockerfile as well.
CONTAINER_USER="ferg"

# this is where the experiments will be run in the
# container image
CODE_LOC="/home/$CONTAINER_USER/GAIL-Formal_Methods"

# give the hostname for a nice touch when using the box interactively
CONTAINER_HOSTNAME="licious"

args=(-it $NVIDIA_ARG --rm --network host --ipc=host \
  --name=$CONTAINER_NAME --hostname=$CONTAINER_HOSTNAME \
  --mount src=$(pwd),target=$CODE_LOC,type=bind $CONTAINER_ID)

if [ -n "$cmd_line_args" ]
then
      # cmd_line_args aren't empty, so user wants to use the env 
      # interactively without running the entrypoint
      args+=(bash -c "cd $CODE_LOC && $cmd_line_args")
fi

echo "docker run" "${args[@]}"

# now actually run the container with the desired arguments
docker run "${args[@]}"