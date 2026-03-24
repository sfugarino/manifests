#!/usr/bin/env bash

helm upgrade --install postgres-nfs-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.path=/mnt/ssd/postgres \
    --set storageClass.name=postgres-nfs-client \
    --set storageClass.provisionerName=k8s-sigs.io/postgres-nfs-subdir-external-provisioner \
    --values=nfs-values.yaml \
    --namespace=nfs-system
