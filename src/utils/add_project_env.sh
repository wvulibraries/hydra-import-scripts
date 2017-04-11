#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Usage add_project_env.sh HYDRA_PROJECT_NAME"
    echo "HYDRA_PROJECT_NAME is the name of the project, where the following directory exists"
    echo "/home/HYDRA_PROJECT_NAME.lib.wvu.edu/hydra/"
    echo "it is also the same value that is in the control_file.yaml, that is created with MFCS"
    exit 1
fi

echo "HYDRA_PROJECT_NAME=$1" | tee -a /etc/environment
source /etc/environment
