#!/usr/bin/env bash

helm upgrade --install minio-nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.server=192.168.1.83 \
    --set nfs.path=/mnt/minio \
    --set storageClass.name=minio-nfs-client \
    --set storageClass.provisionerName=k8s-sigs.io/minio-nfs-subdir-external-provisioner \
    --namespace=nfs-system
