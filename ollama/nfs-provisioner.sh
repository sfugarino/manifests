#!/usr/bin/env bash

helm install ollama-nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.server=192.168.1.67 \
    --set nfs.path=/mnt/ollama \
    --set storageClass.name=ollama-nfs-client \
    --set storageClass.provisionerName=k8s-sigs.io/ollama-nfs-subdir-external-provisioner \
    --namespace=nfs-system
