#!/usr/bin/env bash
NAMESPACE="docker-registry"
AUTH_DIR="./auth"
PASS_FILE="$AUTH_DIR/htpasswd"

mkdir -p "$AUTH_DIR"

rm -rf "$AUTH_DIR"/*

htpasswd -c -B -b "$PASS_FILE" "$1" "$2"

chmod 644 "$PASS_FILE"

echo "Contents of $PASS_FILE:"
cat "$PASS_FILE"

if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
    echo "Namespace '$NAMESPACE' does not exist. Creating it now."
    kubectl create namespace "$NAMESPACE"
fi

if kubectl get secret docker-registry-auth -n "$NAMESPACE" &>/dev/null; then
    echo "Secret exists, deleting"
    kubectl delete secret docker-registry-auth -n "$NAMESPACE"
fi

kubectl create secret generic docker-registry-auth --from-file "$PASS_FILE" -n "$NAMESPACE"
