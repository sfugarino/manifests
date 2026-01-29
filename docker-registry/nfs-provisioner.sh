#!/usr/bin/env bash

helm install docker-nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.server=192.168.1.67 \
    --set nfs.path=/mnt/ssd/docker-registry \
    --set storageClass.name=docker-nfs-client \
    --set storageClass.provisionerName=k8s-sigs.io/docker-nfs-subdir-external-provisioner \
    --namespace=nfs-system
