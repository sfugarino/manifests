# Terraform MCP Server Deployment

This project contains the Kubernetes deployment configuration for a Terraform MCP server running in a local Kubernetes cluster.

## Overview

The Terraform MCP Server provides an HTTP interface for interacting with Terraform Cloud/Enterprise through the Model Context Protocol (MCP). This deployment allows you to manage Terraform configurations and operations through a standardized API.

## Components

1. **Deployment** (`deployment.yaml`) - Defines the Terraform MCP server container with appropriate resource limits and probes
2. **Service** (`service.yaml`) - Exposes the MCP server within the cluster
3. **Secret** (`secret.yaml`) - Stores sensitive configuration including TFE token and organization

## Prerequisites

- Kubernetes cluster (local or remote)
- kubectl configured to access the cluster
- Terraform Cloud/Enterprise account with API token

## Deployment

To deploy the Terraform MCP server:

```bash
kubectl apply -f manifests/
```

To remove the deployment:

```bash
kubectl delete -f manifests/
```

## Configuration

The deployment uses the following environment variables:

- `MODE`: Set to "http" for HTTP mode
- `MCP_SESSION_MODE`: Set to "stateless" for stateless sessions
- `MCP_CORS_MODE`: Set to "strict" for strict CORS handling
- `TFE_TOKEN`: Terraform Enterprise API token (from secret)
- `TFE_ORGANIZATION`: Terraform Enterprise organization name (from secret)
- `TF_LOG`: Set to "DEBUG" for verbose logging

## Accessing the Server

The service is exposed internally within the cluster at:
- Service Name: `terraform-mcp-service`
- Port: `80`
- Target Port: `8080`

To access from outside the cluster, you can use:
```bash
kubectl port-forward service/terraform-mcp-service 8080:80
```

## Security

The deployment uses Kubernetes secrets to store sensitive information. The secret contains:
- `tfe-token`: Terraform Enterprise API token
- `organization`: Terraform Enterprise organization name

## Resources

The deployment includes resource requests and limits:
- CPU: 100m (request), 200m (limit)
- Memory: 128Mi (request), 256Mi (limit)