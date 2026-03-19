#!/usr/bin/env bash

helm install comfyui-nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.server=192.168.1.75 \
    --set nfs.path=/nfs/comfyui \
    --set storageClass.name=comfyui-nfs-client \
    --set storageClass.provisionerName=k8s-sigs.io/comfyui-nfs-subdir-external-provisioner \
    --namespace=nfs-system
