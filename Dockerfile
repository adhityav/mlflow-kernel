FROM python:3.8

ARG NB_USER="sagemaker-user"
ARG NB_UID="1000"
ARG NB_GID="100"


######################
# OVERVIEW
# 1. Creates the `sagemaker-user` user with UID/GID 1000/100.
# 2. Ensures this user can `sudo` by default. 
# 3. Install the mlflow kernel from PyPI and install its dependencies.
# 4. Make the default shell `bash`. This enhances the experience inside a Jupyter terminal as otherwise Jupyter defaults to `sh`
######################

# Setup the "sagemaker-user" user with root privileges.
RUN \
    apt-get update && \
    apt-get install -y sudo && \
    apt-get install -y vim && \
    useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    chmod g+w /etc/passwd && \
    echo "${NB_USER}    ALL=(ALL)    NOPASSWD:    ALL" >> /etc/sudoers && \
    # Prevent apt-get cache from being persisted to this layer.
    rm -rf /var/lib/apt/lists/*

# Install and configure the kernel. 
RUN \
    pip install mlflow_kernel boto3 awscli jupyter-console && \
    # This ensures that the kernelspec.json is installed in location expected by Jupyter/KernelGateway.
    python -m mlflow_kernel.install --sys-prefix

# Make the default shell bash (vs "sh") for a better Jupyter terminal UX
ENV SHELL=/bin/bash

USER $NB_UID
