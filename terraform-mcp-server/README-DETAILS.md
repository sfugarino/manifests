# Terraform MCP Server - Detailed Documentation

## What is Terraform MCP Server?

The Terraform MCP Server is a containerized implementation of the Model Context Protocol (MCP) for Terraform Cloud/Enterprise. It provides a standardized HTTP interface for interacting with Terraform operations, allowing you to manage infrastructure as code through a unified API.

## Architecture

The deployment consists of:

1. **Deployment**: Runs the `hashicorp/terraform-mcp-server` container
2. **Service**: Exposes the server internally within the Kubernetes cluster
3. **Secret**: Stores sensitive configuration (TFE token and organization)

## Security Considerations

- The TFE token is stored as a Kubernetes secret
- The server uses HTTP mode (for local development)
- CORS is set to strict mode for security
- Environment variables are used for configuration

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `MODE` | Set to "http" | Yes |
| `MCP_SESSION_MODE` | Set to "stateless" | Yes |
| `MCP_CORS_MODE` | Set to "strict" | Yes |
| `TFE_TOKEN` | Terraform Enterprise API token | Yes |
| `TFE_ORGANIZATION` | Terraform Enterprise organization | Yes |
| `TF_LOG` | Logging level (DEBUG, INFO, etc.) | No |

## Resource Requirements

- **CPU**: 100m request, 200m limit
- **Memory**: 128Mi request, 256Mi limit

## Health Checks

The deployment includes:
- **Liveness Probe**: Checks `/health` endpoint every 10 seconds
- **Readiness Probe**: Checks `/ready` endpoint every 5 seconds

## Access Patterns

### Internal Access
The service is exposed internally at:
- Service Name: `terraform-mcp-service`
- Port: `80`
- Target Port: `8080`

### External Access
To access from outside the cluster:
```bash
kubectl port-forward service/terraform-mcp-service 8080:80
```

## Deployment Commands

### Deploy
```bash
kubectl apply -f manifests/
```

### Delete
```bash
kubectl delete -f manifests/
```

### Test
```bash
./test-deployment.sh
```

## Troubleshooting

### Common Issues

1. **Pod Not Starting**: Check pod logs with `kubectl logs <pod-name>`
2. **Connection Refused**: Verify service is running with `kubectl get services`
3. **Authentication Issues**: Verify TFE token in secret with `kubectl get secret terraform-mcp-secret -o yaml`

### Debugging Commands

```bash
# Check pod status
kubectl get pods -l app=terraform-mcp-server

# Check pod logs
kubectl logs -l app=terraform-mcp-server

# Describe pod for detailed info
kubectl describe pod -l app=terraform-mcp-server

# Check service details
kubectl get service terraform-mcp-service -o yaml
```

## Future Enhancements

1. **HTTPS Support**: Add TLS termination
2. **Authentication**: Implement proper authentication mechanisms
3. **Monitoring**: Add Prometheus metrics
4. **Logging**: Implement structured logging
5. **Persistence**: Add persistent storage for state management