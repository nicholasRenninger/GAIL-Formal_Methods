ARG PARENT_IMAGE
FROM $PARENT_IMAGE
ARG USE_GPU

RUN apt-get -y update \
    && apt-get -y install \
    curl \
    cmake \
    default-jre \
    git \
    jq \
    python-dev \
    python-pip \
    python3-dev \
    libfontconfig1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    libopenmpi-dev \
    zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV CODE_DIR /root/code/GAIL-Formal_Methods
ENV VENV /root/venv
ENV ENTRY_SCRIPT docker-entrypoint.sh

RUN \
    pip install pip --upgrade && \
    pip install virtualenv && \
    virtualenv $VENV --python=python3 && \
    . $VENV/bin/activate && \
    pip install --upgrade pip && \
    pip install notebook && \
    pip install stable-baselines[mpi] && \
    mkdir -p ${CODE_DIR} && cd ${CODE_DIR} && \
    rm -rf $HOME/.cache/pip

ENV PATH=$VENV/bin:$PATH

CMD /bin/bash

# this is the startup script for the container image
COPY ./scripts/$ENTRY_SCRIPT /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
