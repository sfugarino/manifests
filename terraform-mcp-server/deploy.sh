#!/bin/bash

# Terraform MCP Server Deployment Script
# This script deploys the Terraform MCP server to a Kubernetes cluster

set -e

echo "Deploying Terraform MCP Server to Kubernetes cluster..."

# Apply the secret first
echo "Applying secret..."
kubectl apply -f manifests/secret.yaml

# Wait a moment for the secret to be created
sleep 2

# Apply the deployment and service
echo "Applying deployment and service..."
kubectl apply -f manifests/deployment.yaml

echo "Deployment completed successfully!"
echo ""
echo "To access the server locally, run:"
echo "  kubectl port-forward service/terraform-mcp-service 8080:80"
echo ""
echo "To check the status of the deployment:"
echo "  kubectl get pods -l app=terraform-mcp-server"
echo "  kubectl get services terraform-mcp-service"