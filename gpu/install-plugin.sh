#!/bin/bash

#gpu discovery does not report the correct values for embedded devices, so it will not be enabled
kubectl label node turing-five feature.node.kubernetes.io/cpu-model.vendor_id=NVIDIA --overwrite
kubectl label node turing-six feature.node.kubernetes.io/cpu-model.vendor_id=NVIDIA --overwrite
 

helm upgrade -i nvdp nvdp/nvidia-device-plugin \
   --namespace nvdp  \
   --create-namespace \
   --version 0.17.4 \
   --values values.yaml
