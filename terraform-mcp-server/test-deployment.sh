#!/bin/bash

# Test script to verify Terraform MCP Server deployment
# This script tests if the deployment is working correctly

set -e

echo "Testing Terraform MCP Server deployment..."

# Check if the deployment exists
echo "Checking deployment status..."
if kubectl get deployment terraform-mcp-server -n terraform &> /dev/null; then
    echo "✓ Deployment exists"
else
    echo "✗ Deployment does not exist"
    exit 1
fi

# Check if the pod is running
echo "Checking pod status..."
POD_NAME=$(kubectl get pods -l app=terraform-mcp-server -n terraform -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$POD_NAME" ]; then
    echo "✓ Pod found: $POD_NAME"
    POD_STATUS=$(kubectl get pod $POD_NAME -n terraform -o jsonpath='{.status.phase}')
    echo "✓ Pod status: $POD_STATUS"
    if [ "$POD_STATUS" = "Running" ]; then
        echo "✓ Pod is running"
    else
        echo "✗ Pod is not running"
        kubectl describe pod $POD_NAME -n terraform
        exit 1
    fi
else
    echo "✗ No running pod found"
    exit 1
fi

# Check if the service exists
echo "Checking service status..."
if kubectl get service terraform-mcp-service -n terraform &> /dev/null; then
    echo "✓ Service exists"
    SERVICE_IP=$(kubectl get service terraform-mcp-service -n terraform -o jsonpath='{.spec.clusterIP}')
    echo "✓ Service IP: $SERVICE_IP"
else
    echo "✗ Service does not exist"
    exit 1
fi

# Check if the secret exists
echo "Checking secret status..."
if kubectl get secret terraform-mcp-secret -n terraform &> /dev/null; then
    echo "✓ Secret exists"
else
    echo "✗ Secret does not exist"
    exit 1
fi

echo ""
echo "✓ All tests passed! Terraform MCP Server deployment is ready."