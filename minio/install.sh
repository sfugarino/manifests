
#!/usr/bin/env bash

helm upgrade --install minio minio/minio --namespace minio --create-namespace -f values.yaml
