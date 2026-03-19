#!/usr/bin/env bash

helm delete langflow-nfs-provisioner  -n nfs-system

helm delete openrag-document-nfs-provisioner  -n nfs-system

helm delete openrag-keys-nfs-provisioner  -n nfs-system

helm delete openrag-config-nfs-provisioner  -n nfs-system

helm delete openrag-data-nfs-provisioner  -n nfs-system
