FROM tensorflow/tensorflow:latest-gpu-jupyter

# Fix: https://github.com/hadolint/hadolint/wiki/DL4006
# Fix: https://github.com/koalaman/shellcheck/wiki/SC3014
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

# Install system dependencies required for downloading and installing CUDA
RUN apt-get update && apt-get install -y --no-install-recommends \
        gnupg2 \
        curl \
        software-properties-common && \
    rm -rf /var/lib/apt/lists/*

# R pre-requisites
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    fonts-dejavu \
    unixodbc \
    unixodbc-dev \
    r-cran-rodbc \
    gfortran \
    gcc && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

USER ${NB_UID}

# Install Miniconda to manage packages such as mamba
RUN curl -LO https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -p /miniconda -b && \
    rm Miniconda3-latest-Linux-x86_64.sh

# Add Conda to PATH
ENV PATH=/miniconda/bin:${PATH}

# Install mamba from conda-forge
RUN conda install -c conda-forge mamba

# Ensure conda-forge is used
RUN conda config --add channels conda-forge

# Install core R and Python packages separately to avoid conflicts
RUN mamba install --yes \
    'r-base' \
    'r-irkernel' \
    'python=3.11' \
    'libxml2' \
    'fontconfig' \
    'pango' && \
    mamba clean --all -f -y

# Install R kernel
RUN R -e "install.packages('IRkernel', repos = 'https://cloud.r-project.org');IRkernel::installspec()"

# Install R packages
RUN mamba install --yes \
    'r-caret' \
    'r-crayon' \
    'r-devtools' \
    'r-e1071' \
    'r-forecast' \
    'r-hexbin' \
    'r-htmltools' \
    'r-htmlwidgets' \
    'r-nycflights13' \
    'r-randomforest' \
    'r-rcurl' \
    'r-rmarkdown' \
    'r-rodbc' \
    'r-rsqlite' \
    'r-shiny' \
    'r-tidymodels' \
    'r-reticulate' \
    'r-tidyverse' \
    'xeus-r' \ 
    'unixodbc' \
    'h5py' && \
    mamba clean --all -f -y

# R deepG
RUN echo 'devtools::install_github("genomenet/deepg")' > /tmp/packages.R && Rscript /tmp/packages.R

# Zsh kernel
RUN python -m pip install notebook zsh_jupyter_kernel


# Configure Reticulate on startup
RUN echo 'reticulate::use_python("/usr/bin/python3")' > /tf/.Rprofile
