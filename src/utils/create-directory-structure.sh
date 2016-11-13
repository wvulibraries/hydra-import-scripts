#!/bin//bash

mkdir -p /mnt/nfs-exports/mfcs-exports/$1/control/
mkdir -p /mnt/nfs-exports/mfcs-exports/$1/control/hydra/error
mkdir -p /mnt/nfs-exports/mfcs-exports/$1/control/hydra/finished
mkdir -p /mnt/nfs-exports/mfcs-exports/$1/control/hydra/in-progress
mkdir -p /mnt/nfs-exports/mfcs-exports/$1/control/hydra/staged
mkdir -p /mnt/nfs-exports/mfcs-exports/$1/export
