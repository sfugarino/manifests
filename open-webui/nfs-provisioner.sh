#!/usr/bin/env bash

helm install webui-nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.server=192.168.1.67 \
    --set nfs.path=/mnt/open-web-ui \
    --set storageClass.name=webui-nfs-client \
    --set storageClass.provisionerName=k8s-sigs.io/webui-nfs-subdir-external-provisioner \
    --namespace=nfs-system
