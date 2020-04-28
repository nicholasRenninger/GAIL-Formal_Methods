#!/bin/bash

CPU_PARENT=baseimage-docker
GPU_PARENT=nvidia/cuda:9.0-cudnn7-runtime-ubuntu16.04

TAG=stable_baselines_modded

if [[ ${USE_GPU} == "True" ]]; then
  PARENT=${GPU_PARENT}
else
  PARENT=${CPU_PARENT}
  TAG="${TAG}-cpu"
fi

docker build --build-arg PARENT_IMAGE=${PARENT} \
  --build-arg USE_GPU=${USE_GPU} -t ${TAG} .