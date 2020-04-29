#######################################
###### container base environ.   ######
#######################################

ARG PARENT_IMAGE
FROM $PARENT_IMAGE
ARG USE_GPU
ARG HOST_USER_ID
ARG HOST_GROUP_ID

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
    zlib1g-dev \
    python-opengl \
    xvfb

RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*



#######################################
###### config. the user environ. ######
#######################################

# need to create a new user that will ultimately be the user that runs the
# container's application, for security reasons
# 
# Here we are going to map the internal user to the building user, so hopefully
# the host user and the container user have file permissions that perfectly
# align and you can safely mount a drive in the container from the host user
# 
# Source:
# https://jtreminio.com/blog/running-docker-containers-as-current-host-user/
ENV USR "ferg"
RUN groupadd -g $HOST_GROUP_ID appuser && \
    useradd -r -u $HOST_USER_ID -g appuser $USR

# these configure where the working dir will be, and where the startup script
# is
ENV USR_HOME /home/$USR
ENV CODE_DIR $USR_HOME/GAIL-Formal_Methods

ENV CMD_DIR docker_scripts
ENV CMD_SCRIPT docker-entrypoint.sh
ENV CMD_PATH $CMD_DIR/$CMD_SCRIPT

# make the user's home area with the right permissions
RUN mkdir -p $CODE_DIR/$CMD_DIR && \
    chown -R $USR:appuser $USR_HOME

# this is the container's working directory
WORKDIR $CODE_DIR

# have to do temp copying stuff so things are moved to the container from
# local, and only then is cmd script moved into position and chmod'd. Bash 
# commands on the moved file will only stack if done in the same RUN command,
# as RUN records the changes in it's own environment - changes aren't shared
# across RUNs
COPY --chown=$USR:appuser $CMD_PATH $CODE_DIR/$CMD_PATH

# need to make the startup script executable as root, but then chown the whole
# home of the user to the user so there are no permission issues
RUN chmod +x $CODE_DIR/$CMD_PATH && \
    chown -R $USR:appuser $CODE_DIR/$CMD_PATH

# this adds the user's .local to the path so that the user python install is on
# on their path -> nice
ENV PATH="$USR_HOME/.local/bin:${PATH}"

# upgrade pip while still root
RUN pip install --upgrade pip

# now Transform™ into the user -> no more root for le safeties
# need to install everything as the desired user, not as root, or you'll have
# permissions problems
USER $USR



#######################################
###### install jupyter dev tools ######
#######################################

### BUT NOT dependencies
### put dependencies in the section at the bottom of the file to

# Running pip install with the --user flag installs the dependencies for the
# current user in the .local/bin directory in the user's home directory.
# Therefore, we need to add this newly created directory to the PATH
# environment variable.
RUN pip install --user jupyterthemes \
    jupyterthemes \
    jupyter_contrib_nbextensions

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

# try to get sublime keymaps
RUN mkdir -p "$(jupyter --config-dir)/custom/"
RUN echo "require(["codemirror/keymap/sublime", "notebook/js/cell", "base/js/namespace"], function(sublime_keymap, cell, IPython) { // setTimeout(function(){ // uncomment line to fake race-condition cell.Cell.options_default.cm_config.keyMap = 'sublime'; var cells = IPython.notebook.get_cells(); for(var cl=0; cl< cells.length ; cl++){ cells[cl].code_mirror.setOption('keyMap', 'sublime'); } // }, 1000)// uncomment line to fake race condition } );" >> "$(jupyter --config-dir)/custom/custom.js"

# configure jupyter notebook theme
RUN jt -t onedork -fs 95 -altp -tfs 11 -nfs 115 -cellw 88% -T -f firacode



#######################################
###### install python code deps. ######
#######################################

# add any packages here that the container application may need
RUN pip install stable-baselines[mpi]

# cleanup
RUN rm -rf $HOME/.cache/pip



#######################################
###### container process startup ######
#######################################

# here, the default application of the container is in $CMD_SCRIPT, but if the
# user wants to use the container differently, he / she can just go ahead and
# override the default behavior
CMD ["sh", "-c", "$CODE_DIR/$CMD_PATH"]
