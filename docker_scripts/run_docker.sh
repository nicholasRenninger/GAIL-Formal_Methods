#!/bin/bash
# Launch an experiment using the docker tf-based (CPU / GPU) image
# 
# Example usage:
#   
#   1) run with a CPU-only image:
#   ./run_docker.sh --device=cpu $OPTIONAL_BASH_COMMAND_FOR_INTERACTIVE_MODE
#
#   2) run with a GPU-enabled image:
#   ./run_docker.sh --device=gpu $OPTIONAL_BASH_COMMAND_FOR_INTERACTIVE_MODE
#
#   3) run with a GPU-enabled image and start a jupyter notebook server with
#   default network settings:
#   ./run_docker.sh --device=gpu
# 
#   4) run with a GPU-enabled image and drop into the terminal:
#   ./run_docker.sh --device=gpu bash
#   
#   5) run with a GPU-enabled image with the jupyter notebook served over a
#      desired host port, in this example, port 8008, with tensorboard
#      configured to run on port 6006:
#   ./run_docker.sh --device=gpu --jupyterport=8008 --tensorboardport=6969
# 
#   To access this notebook, 
#   
#   make sure you can access port 8008 on the host machine and then modify the
#   generated jupyter url:
#   (e.g.) http://localhost:8888/?token=TOKEN_STRING
# 
#   with the new, desired port number:
#   (e.g.) http://localhost:8008/?token=TOKEN_STRING
#   
#   and paste this url into the host machine's browser. 
#   
#   To access tensorboard,
#   make sure you can access port 6969 on the host machine and then modify the
#   generated tensorboard  url:
#
#   (e.g. TensorBoard 1.15.0) http://0.0.0.0:6006/
#
#   with the new, desired port number:
#   (e.g.) http://localhost:6969
#   
#   and paste this url into the host machine's browser. 


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
    -j=*|--jupyterport=*)
    JUPYTER_PORT="${i#*=}"
    shift # past argument=value
    ;;
    -t=*|--tensorboardport=*)
    TENSORBOARD_PORT="${i#*=}"
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

  # need to add in an argument to the container runner enabling GPU hardware
  # ONLY when using the GPU container image
  args=($NVIDIA_ARG)

elif [ "$DEVICE" = "cpu" ] || [ "$DEVICE" = "CPU" ]; then

  echo "Executing in the docker (cpu image):"
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

# allow the user to configure a different port for jupyter to run over on the
# host in case the default 8888 is already in use, or if you just want to
# change it
if [ -n "$JUPYTER_PORT" ]; then 

    args+=(-p=$JUPYTER_PORT:8888)
else

    # by default, always just connect to the standard 8888 port
    args+=(-p=8888:8888)

fi

# allow the user to configure a different port for tensorboard to run over on
# the host in case the default 6006 is already in use, or if you just want to
# change it
if [ -n "$TENSORBOARD_PORT" ]; then 

    args+=(-p=$TENSORBOARD_PORT:6006)
else

    # by default, always just connect to the TB standard 6006 port
    args+=(-p=6006:6006)

fi

args+=(-it --rm \
  --name=$CONTAINER_NAME --hostname=$CONTAINER_HOSTNAME \
  --mount src=$(pwd),target=$CODE_LOC,type=bind $CONTAINER_ID)


# cmd_line_args aren't empty, so user wants to use the env 
# interactively without running the entrypoint
if [ -n "$cmd_line_args" ]; then

      args+=(bash -c "cd $CODE_LOC && $cmd_line_args")
fi

echo "docker run" "${args[@]}"

# now actually run the container with the desired arguments
docker run "${args[@]}"