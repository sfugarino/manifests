#!/usr/bin/env bash

helm install open-webui-nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.server=192.168.1.83 \
    --set nfs.path=/mnt/open-web-ui \
    --set storageClass.name=open-webui-nfs-client \
    --set storageClass.provisionerName=k8s-sigs.io/open-webui-nfs-subdir-external-provisioner \
    --namespace=nfs-system
