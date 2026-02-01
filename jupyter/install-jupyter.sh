#!/usr/bin/env bash

helm upgrade --cleanup-on-fail \
  --install jupyterhub jupyterhub/jupyterhub \
  --namespace jupyter \
  --create-namespace \
  --values values.yaml
