FROM jupyter/scipy-notebook

# Add ssh-client, vim, htop and tmux
USER root
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
     htop \
     openssh-client \
     vim \
     visidata \
     tmux && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/ && \
  rm -rf /tmp/downloaded_packages/ /tmp/*.rds 

# Use vim as default editor
RUN update-alternatives --set editor /usr/bin/vim.basic

# Add script to execute long-running notebooks
COPY ./run_notebook_background.sh /usr/local/bin/

USER $NB_UID

# Add kernel with pythonloc
RUN pip install pythonloc && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
COPY ./pythonloc /opt/conda/share/jupyter/kernels/pythonloc/

# Install support for spellchecking
RUN jupyter labextension install @ijmbarr/jupyterlab_spellchecker && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Install go-to-definition extensions
RUN jupyter labextension install @krassowski/jupyterlab_go_to_definition && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Add SQL extension
# RUN pip install jupyterlab_sql && \
#  jupyter serverextension enable jupyterlab_sql --py --sys-prefix && \
#  jupyter lab build

# Add git extension
RUN jupyter labextension install @jupyterlab/git && \
  pip install --upgrade jupyterlab-git && \
  jupyter serverextension enable --py jupyterlab_git && \
   fix-permissions $CONDA_DIR && \
   fix-permissions /home/$NB_USER
