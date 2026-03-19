#!/usr/bin/env bash

helm upgrade --install langflow-nfs-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.path=/mnt/ssd/langflow \
    --set storageClass.name=langflow-nfs-client \
    --set storageClass.provisionerName=k8s-sigs.io/langflow-nfs-subdir-external-provisioner \
    --values=nfs-values.yaml \
    --namespace=nfs-system

helm upgrade --install openrag-document-nfs-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.path=/mnt/ssd/openrag-documents \
    --set storageClass.name=openrag-document-nfs-client \
    --set storageClass.provisionerName=k8s-sigs.io/openrag-document-nfs-subdir-external-provisioner \
    --values=nfs-values.yaml \
    --namespace=nfs-system

helm upgrade --install openrag-keys-nfs-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.path=/mnt/ssd/openrag-keys \
    --set storageClass.name=openrag-keys-nfs-client \
    --set storageClass.provisionerName=k8s-sigs.io/openrag-keys-nfs-subdir-external-provisioner \
    --values=nfs-values.yaml \
    --namespace=nfs-system

helm upgrade --install openrag-config-nfs-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.path=/mnt/ssd/openrag-config \
    --set storageClass.name=openrag-config-nfs-client \
    --set storageClass.provisionerName=k8s-sigs.io/openrag-config-nfs-subdir-external-provisioner \
    --values=nfs-values.yaml \
    --namespace=nfs-system

helm upgrade --install openrag-data-nfs-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.server=192.168.1.83 \
    --set nfs.path=/mnt/ssd/openrag-data \
    --set storageClass.name=openrag-data-nfs-client \
    --set storageClass.provisionerName=k8s-sigs.io/openrag-data-nfs-subdir-external-provisioner \
    --values=nfs-values.yaml \
    --namespace=nfs-system

