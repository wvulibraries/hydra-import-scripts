#!/bin//bash

if [[ -z $HYDRA_PROJECT_NAME ]]; then
  echo "ENV variable HYDRA_PROJECT_NAME must be defined. Use add_project_env."
  exit 1
fi

mkdir -p /mnt/nfs-exports/mfcs-exports/"$HYDRA_PROJECT_NAME"/control/
mkdir -p /mnt/nfs-exports/mfcs-exports/"$HYDRA_PROJECT_NAME"/control/mfcs
mkdir -p /mnt/nfs-exports/mfcs-exports/"$HYDRA_PROJECT_NAME"/control/hydra/error
mkdir -p /mnt/nfs-exports/mfcs-exports/"$HYDRA_PROJECT_NAME"/control/hydra/finished
mkdir -p /mnt/nfs-exports/mfcs-exports/"$HYDRA_PROJECT_NAME"/control/hydra/in-progress
mkdir -p /mnt/nfs-exports/mfcs-exports/"$HYDRA_PROJECT_NAME"/control/hydra/staged
mkdir -p /mnt/nfs-exports/mfcs-exports/"$HYDRA_PROJECT_NAME"/export
