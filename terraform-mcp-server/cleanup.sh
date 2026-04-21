#!/bin/bash

# Terraform MCP Server Cleanup Script
# This script removes the Terraform MCP server deployment from a Kubernetes cluster

set -e

echo "Cleaning up Terraform MCP Server deployment..."

# Delete the deployment and service
echo "Deleting deployment and service..."
kubectl delete -f manifests/deployment.yaml --ignore-not-found

# Delete the secret
echo "Deleting secret..."
kubectl delete secret terraform-mcp-secret --ignore-not-found

echo "Cleanup completed successfully!"