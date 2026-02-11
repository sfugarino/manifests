#!/usr/bin/env bash

NAMESPACE="docker-registry"
CERT_DIR="./certs"

mkdir -p "$CERT_DIR"

rm -rf "$CERT_DIR"/*

openssl req -x509 -newkey rsa:4096 -days 365 -nodes -sha256 -keyout certs/tls.key -out certs/tls.crt -subj "/CN=registry-service" -addext "subjectAltName=DNS:registry-service"

if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
    echo "Namespace '$NAMESPACE' does not exist. Creating it now."
    kubectl create namespace "$NAMESPACE"
fi

if kubectl get secret docker-registry-tls -n "$NAMESPACE" &>/dev/null; then
    echo "Secret exists, deleting"
    kubectl delete secret docker-registry-tls -n "$NAMESPACE"
fi

kubectl create secret tls docker-registry-tls --cert="$CERT_DIR"/tls.crt --key "$CERT_DIR"/tls.key -n "$NAMESPACE"

