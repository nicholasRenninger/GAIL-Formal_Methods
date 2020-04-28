#!/bin/bash

CPU_PARENT=tensorflow/tensorflow:1.15.2-py3-jupyter
GPU_PARENT=tensorflow/tensorflow:1.15.2-gpu-py3-jupyter

TAG=gail_formal_methods

if [[ ${USE_GPU} == "True" ]]; then
  PARENT=${GPU_PARENT}
else
  PARENT=${CPU_PARENT}
  TAG="${TAG}-cpu"
fi


# build such that the container user is the same as the host user
docker build --build-arg PARENT_IMAGE=${PARENT} \
  --build-arg USE_GPU=${USE_GPU} \
  --build-arg HOST_USER_ID=$(id -u ${USER}) \
  --build-arg HOST_GROUP_ID=$(id -g ${USER}) \
  -t ${TAG} \
  .