# Full contents of Dockerfile

FROM nvidia/cuda:10.0-cudnn7-devel
LABEL description="Base docker image with conda and cudatoolkit"
ARG ENV_NAME="base"

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        bash \
        wget \
        curl \
        bzip2 \
        nano \
        procps && \
    rm -rf /var/lib/apt/lists/*

#Install miniconda
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O Miniconda.sh && \
    /bin/bash Miniconda.sh -b -p /opt/conda && \
    rm Miniconda.sh

ENV PATH /opt/conda/bin:$PATH

# Install the conda environment
COPY environment.yml /
RUN conda install --revision 0 && \
    conda env update --quiet --name ${ENV_NAME} --file /environment.yml && \
    conda clean --all --force-pkgs-dirs

# Add conda installation dir to PATH (instead of doing 'conda activate')
ENV PATH /opt/conda/envs/${ENV_NAME}/bin:$PATH

# Dump the details of the installed packages to a file for posterity
RUN conda env export --name ${ENV_NAME} > ${ENV_NAME}_exported.yml

# Initialise shell for conda
RUN conda init bash

# Copy additonal scripts
RUN mkdir /opt/bin
COPY bin/* /opt/bin/
RUN chmod +x /opt/bin/*
ENV PATH="$PATH:/opt/bin/"
