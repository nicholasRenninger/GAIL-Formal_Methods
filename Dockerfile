#######################################
###### container base environ.   ######
#######################################

ARG PARENT_IMAGE
FROM $PARENT_IMAGE
ARG USE_GPU

RUN apt-get -y update
RUN apt-get -y install \
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
    zlib1g-dev

RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*



#######################################
###### install jupyter dev tools ######
#######################################

# BUT NOT dependencies
# put these in the section at the bottom of the file to
RUN pip install --upgrade pip
RUN pip install jupyterthemes
RUN pip install --upgrade jupyterthemes
RUN pip install jupyter_contrib_nbextensions

# configure jupyter notebook extensions
RUN jupyter contrib nbextension install --user
RUN jupyter nbextension enable latex_envs/latex_envs
RUN jupyter nbextension enable autosavetime/main
RUN jupyter nbextension enable collapsible_headings/main
RUN jupyter nbextension enable livemdpreview/livemdpreview
RUN jupyter nbextension enable nbextensions_configurator/tree_tab/main
RUN jupyter nbextension enable ruler/main
RUN jupyter nbextension enable codefolding/main
RUN jupyter nbextension enable execute_time/ExecuteTime
RUN jupyter nbextension enable nbextensions_configurator/config_menu/main
RUN jupyter nbextension enable snippets_menu/main
RUN jupyter nbextension enable table_beautifier/main
RUN jupyter nbextension enable codefolding/edit
RUN jupyter nbextension enable freeze/main
RUN jupyter nbextension enable runtools/main
RUN jupyter nbextension enable codemirror_mode_extensions/main
RUN mkdir -p "`jupyter --config-dir`/custom/"
RUN echo "require(["codemirror/keymap/sublime", "notebook/js/cell", "base/js/namespace"], function(sublime_keymap, cell, IPython) { // setTimeout(function(){ // uncomment line to fake race-condition cell.Cell.options_default.cm_config.keyMap = 'sublime'; var cells = IPython.notebook.get_cells(); for(var cl=0; cl< cells.length ; cl++){ cells[cl].code_mirror.setOption('keyMap', 'sublime'); } // }, 1000)// uncomment line to fake race condition } );" >> "`jupyter --config-dir`/custom/custom.js"

# configure jupyter notebook theme
RUN jt -t onedork -fs 95 -altp -tfs 11 -nfs 115 -cellw 88% -T



#######################################
###### install python code deps. ######
#######################################

# add any packages here that the container application may need
RUN pip install stable-baselines[mpi]

# cleanup
RUN rm -rf $HOME/.cache/pip




#######################################
###### development var to change ######
#######################################

# don't run shit as root :)
ENV USR "ferga"

ENV CODE_DIR /home/$USR/GAIL-Formal_Methods

ENV CMD_DIR scripts
ENV CMD_SCRIPT docker-entrypoint.sh
ENV CMD_PATH $CMD_DIR/$CMD_SCRIPT



#######################################
###### container process startup ######
#######################################

# then, prepare the container's application to run
RUN mkdir -p $CODE_DIR/$CMD_PATH
WORKDIR $CODE_DIR

# have to do temp copying stuff so things are moved to the container from
# local, and only then is cmd script moved into position and chmod'd. Bash 
# commands on the moved file will only stack if done in the same RUN command,
# as RUN records the changes in it's own environment - changes aren't shared
# across RUNs
COPY $CMD_PATH /tmp/$CMD_PATH
RUN mv /tmp/$CMD_PATH $CODE_DIR/$CMD_PATH && \
    chmod +x $CODE_DIR/$CMD_PATH

# now Transform™ into the user -> no more root for le safties
RUN useradd -s /bin/bash $USR
USER $USR

# here, the default application of the container is in $CMD_SCRIPT, but if the
# user wants to use the container differently, he / she can just go ahead and
# override the default behavior
CMD ["sh", "-c", "$CODE_DIR/$CMD_PATH"]
