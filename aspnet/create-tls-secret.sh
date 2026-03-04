#!/usr/bin/env bash

NAMESPACE="asp-net"
CERT_DIR="./certs"

mkdir -p "$CERT_DIR"

rm -rf "$CERT_DIR"/*

openssl req -x509 -newkey rsa:4096 -days 365 -nodes -sha256 -keyout certs/tls.key -out certs/tls.crt -subj "/CN=asp-net" -addext "subjectAltName=DNS:asp-net"
openssl pkcs12 -export -out certs/asp-net.pfx -inkey certs/tls.key -in certs/tls.crt -name "asp-net-certificate" -password pass:"$1"


if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
    echo "Namespace '$NAMESPACE' does not exist. Creating it now."
    kubectl create namespace "$NAMESPACE"
fi

if kubectl get secret asp-net-tls -n "$NAMESPACE" &>/dev/null; then
    echo "Secret exists, deleting"
    kubectl delete secret asp-net-tls -n "$NAMESPACE"
fi

if kubectl get secret aspnet-tls -n "$NAMESPACE" &>/dev/null; then
    echo "Secret exists, deleting"
    kubectl delete secret aspnet-tls -n "$NAMESPACE"
fi

if kubectl get secret aspnet-tls-pwd -n "$NAMESPACE" &>/dev/null; then
    echo "Secret exists, deleting"
    kubectl delete secret aspnet-tls-pwd -n "$NAMESPACE"
fi

kubectl create secret tls asp-net-tls --cert="$CERT_DIR"/tls.crt --key "$CERT_DIR"/tls.key -n "$NAMESPACE"
kubectl create secret generic aspnet-tls --from-file="$CERT_DIR"/asp-net.pfx -n "$NAMESPACE"
kubectl create secret generic aspnet-tls-pwd --from-literal=password="$1" -n "$NAMESPACE"


