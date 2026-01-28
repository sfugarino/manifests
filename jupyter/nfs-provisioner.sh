#!/usr/bin/env bash

helm install juphub-nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.server=192.168.1.67 \
    --set nfs.path=/mnt/ssd/jupyter \
    --set storageClass.name=jubhub-nfs-client \
    --set storageClass.provisionerName=k8s-sigs.io/webui-nfs-subdir-external-provisioner \
    --namespace=nfs-system
