#!/usr/bin/env bash

kubectl create ns gpu-operator --dry-run=client -o yaml | kubectl apply -f -
kubectl label --overwrite ns gpu-operator pod-security.kubernetes.io/enforce=privileged

# Iterate over all nodes in the cluster
for node in $(kubectl get nodes -o name); do
  
  node_name="${node##*/}"
  if [[ "$node_name" != "turing-five" && "$node_name" != "turing-six" ]]; then
     echo "Labeling non-gpu node: $node_name"
     kubectl label nodes --overwrite "$node_name" nvidia.com/gpu.deploy.operands=false
     kubectl label nodes --overwrite "$node_name" nvidia.com/gpu.deploy.driver=false
  else
     echo "Labeling gpu node:  $node_name"
     kubectl label nodes --overwrite "$node_name" nvidia.com/gpu.deploy.operands=true
     kubectl label nodes --overwrite "$node_name" nvidia.com/gpu.deploy.driver=true
  fi
done

helm install --wait gpu-operator \
    nvidia/gpu-operator 
    --namespace gpu-operator --create-namespace \
    --version=v25.10.1 \
    --set driver.enabled=true \ 
    --set devicePlugin.enabled=true \
   
