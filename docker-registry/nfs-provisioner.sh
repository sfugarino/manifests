#!/usr/bin/env bash

helm upgrade --install docker-nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --values=nfs-values.yaml \
    --namespace=nfs-system