# Azurite on Kubernetes with Persistent Storage

This guide explains how to run [Azurite](https://github.com/Azure/Azurite), Microsoft's storage emulator for Azure Storage (Blob, Queue, and Table Storage), on Kubernetes with persistent data storage.

## Overview

Azurite is a lightweight open-source emulator for developing and testing Azure Storage applications locally. This setup deploys Azurite to a Kubernetes cluster with:

- **Persistent Storage**: Data persists across pod restarts using PersistentVolumeClaim (PVC)
- **TLS Support**: Secure HTTPS connections with certificates
- **Multi-Protocol Support**: Blob (10000), Queue (10001), and Table (10002) storage services
- **Load Balancer Service**: Easy external access to Azurite endpoints

## Architecture

```
┌─────────────────────────────────────────┐
│     Kubernetes Cluster (azurite ns)     │
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────────────────────────────┐  │
│  │  storage-azurite-service         │  │
│  │  (LoadBalancer)                  │  │
│  │  - Port 10000 → Blobs            │  │
│  │  - Port 10001 → Queues           │  │
│  │  - Port 10002 → Tables           │  │
│  └──────────┬───────────────────────┘  │
│             │                          │
│  ┌──────────▼───────────────────────┐  │
│  │ storage-azurite-deployment       │  │
│  │  ┌────────────────────────────┐  │  │
│  │  │ azurite container          │  │  │
│  │  │  - OAuth: basic auth       │  │  │
│  │  │  - TLS certificates        │  │  │
│  │  │  - Debug logging enabled   │  │  │
│  │  └─────────┬──────────────────┘  │  │
│  │            │                    │  │
│  │  ┌─────────▼──────────────────┐ │  │
│  │  │ Volumne Mounts             │ │  │
│  │  │ - /data → azurite-pvc      │ │  │
│  │  │ - /certs → azurite-certs   │ │  │
│  │  └────────────────────────────┘ │  │
│  └────────────────────────────────┘  │
│             │                         │
│  ┌──────────▼──────────────────────┐ │
│  │ PersistentVolumeClaim (50Gi)    │ │
│  │ - Storage Class: local-path     │ │
│  │ - Access Mode: ReadWriteOnce    │ │
│  └──────────────────────────────────┘ │
│                                       │
└───────────────────────────────────────┘
```

## Prerequisites

- Kubernetes cluster (v1.20+)
- `kubectl` configured to access your cluster
- A storage class available in the cluster (e.g., `local-path`)
- TLS certificates (included in setup)
- Access to the `azurite` namespace

## Quick Start

### 1. Create the Namespace

```bash
kubectl create namespace azurite
```

### 2. Create TLS Certificates Secret

First, generate TLS certificates using the provided configuration:

```bash
# Generate private key
openssl genrsa -out key.pem 2048

# Generate certificate using the tls.config
openssl req -new -x509 -key key.pem -out cert.pem -days 365 -config tls.config

# Create Kubernetes secret
kubectl create secret tls azurite-certs \
  --cert=cert.pem \
  --key=key.pem \
  -n azurite
```

### 3. Deploy PersistentVolumeClaim

```bash
kubectl apply -f pvc.yaml
```

Verify the PVC is bound:

```bash
kubectl get pvc -n azurite
```

Expected output:
```
NAME           STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS
azurite-pvc    Bound    ...      50Gi       RWO            local-path
```

### 4. Deploy Azurite

```bash
kubectl apply -f deployment.yaml
```

### 5. Verify Deployment

```bash
# Check pod status
kubectl get pods -n azurite
kubectl logs -n azurite -l app=storage-azurite --tail=50

# Port forwarding (optional for local testing)
kubectl port-forward -n azurite svc/storage-azurite-service 10000:10000 10001:10001 10002:10002
```

## Configuration Details

### Deployment Configuration (`deployment.yaml`)

| Field | Value | Description |
|-------|-------|-------------|
| **Replicas** | 1 | Single instance (PVC limitation) |
| **Image** | `mcr.microsoft.com/azure-storage/azurite` | Official Microsoft Azurite image |
| **Node Selector** | `kubernetes.io/hostname: radxa-dragon-q6a` | Pinned to specific node |
| **Storage** | 50Gi via `local-path` SC | Persistent data storage |
| **OAuth** | basic | Azure Storage shared key authentication |
| **Loose Mode** | Enabled | Relaxed validation for compatibility |
| **Data Location** | `/data` | Mount point for persistent volume |

### Port Mapping

| Service | Port | Protocol | Purpose |
|---------|------|----------|---------|
| Blob Storage | 10000 | HTTPS | Create, read, manage blobs |
| Queue Storage | 10001 | HTTPS | Manage message queues |
| Table Storage | 10002 | HTTPS | NoSQL table operations |

### Default Credentials

```
Account Name: devstoreaccount1
Account Key:  Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==
```

These are **fixed** credentials used by Azurite for emulation purposes.

### TLS Configuration (`tls.config`)

The certificate is configured for:
- **Common Name**: localhost
- **Subject Alternative Names**:
  - `127.0.0.1`
  - `192.168.1.115` (internal IP)
  - `azurite.azurite` (K8s DNS - namespace local)
  - `azurite.azurite.svc.cluster.local` (K8s FQDN)
  - `localhost`

## Accessing Azurite

### From Inside Kubernetes

Use the internal service DNS name and ports:

```
# Blob Storage
https://storage-azurite-service.azurite.svc.cluster.local:10000

# Queue Storage
https://storage-azurite-service.azurite.svc.cluster.local:10001

# Table Storage
https://storage-azurite-service.azurite.svc.cluster.local:10002
```

### From Outside Kubernetes (LoadBalancer)

```
# Get the external IP
kubectl get svc -n azurite storage-azurite-service

# Example endpoints (adjust IP as needed)
https://192.168.1.115:10000  # Blob
https://192.168.1.115:10001  # Queue
https://192.168.1.115:10002  # Table
```

### Port Forwarding (Local Testing)

```bash
kubectl port-forward -n azurite svc/storage-azurite-service 10000:10000 10001:10001 10002:10002

# Then connect to:
https://localhost:10000  # Blob
https://localhost:10001  # Queue
https://localhost:10002  # Table
```

## Test Program

The included `test/` directory contains a C# console application that demonstrates how to interact with Azurite's Queue Storage service.

### Program Structure

**`Program.cs`**
- Entry point for the test application
- Creates a `QueueClient` connected to Azurite
- Sends a test message to the queue
- Retrieves and displays the message

**`QueueManager.cs`**
- `EnqueueAsync()`: Creates a queue (if needed) and sends a message
- `RetrieveNextMessageAsync()`: Retrieves the next message from the queue and deletes it

**`test.csproj`**
- Target Framework: .NET 10.0
- Dependency: `Azure.Storage.Queues` v12.25.0

### Running the Test Program

#### Prerequisites

```bash
# Install .NET 10.0 SDK
# Available from: https://dotnet.microsoft.com/download/dotnet/10.0
```

#### Local Testing (with Port Forwarding)

```bash
# Terminal 1: Port-forward to Azurite
kubectl port-forward -n azurite svc/storage-azurite-service 10001:10001

# Terminal 2: Run the test
cd test
dotnet run

# Expected output:
# The queue was created.
# Message sent with ID: <UUID>
# Received message: Hello, Azure Queue Storage!
```

#### Running Inside Kubernetes (as a Job)

Create a Kubernetes Job to run the test:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: azurite-test-job
  namespace: azurite
spec:
  template:
    spec:
      containers:
      - name: test
        image: mcr.microsoft.com/dotnet/sdk:10.0
        workingDir: /app
        command:
        - dotnet
        - run
        volumeMounts:
        - name: test-code
          mountPath: /app
      volumes:
      - name: test-code
        configMap:
          name: test-program
      restartPolicy: Never
  backoffLimit: 3
```

### Customizing the Test Program

To interact with different services or modify behavior:

1. **Change Queue Name**: Update `queueName` constant in `Program.cs`
2. **Change Endpoint**: Update `url` to point to different service (Blob, Queue, Table)
3. **Add Blob Operations**: Reference `Azure.Storage.Blobs` NuGet package
4. **Add Table Operations**: Reference `Azure.Data.Tables` NuGet package

Example for Blob Storage connection:

```csharp
using Azure.Storage.Blobs;

var endpoint = new Uri("https://192.168.1.115:10000");
var credential = new StorageSharedKeyCredential("devstoreaccount1", "<account-key>");
var blobClient = new BlobContainerClient(endpoint, "mycontainer", credential);
```

## Data Persistence

### How It Works

- Azurite stores all data in the `/data` directory inside the container
- This directory is mounted to a `PersistentVolumeClaim` (azurite-pvc) 
- The PVC uses the `local-path` storage class to store data on the node's filesystem
- When the pod restarts, the same PVC is remounted, preserving all data

### Verifying Persistent Storage

```bash
# List current data
kubectl exec -it -n azurite deployment/storage-azurite-deployment -- ls -lah /data

# View queue message files
kubectl exec -it -n azurite deployment/storage-azurite-deployment -- find /data -type f
```

### Storage Limitations

- **Access Mode**: `ReadWriteOnce` - Only one pod can write at a time
- **Storage Class**: `local-path` - Data is local to the node
- **Pod Affinity**: Fixed to `radxa-dragon-q6a` node via nodeSelector
- **Replicas**: Must remain 1 due to RWO access mode and local storage

## Troubleshooting

### Pod Won't Start

```bash
# Check pod events and logs
kubectl describe pod -n azurite -l app=storage-azurite
kubectl logs -n azurite -l app=storage-azurite --tail=100

# Common issues:
# 1. Node not found: Verify nodeSelector matches actual node name
#    kubectl get nodes
#
# 2. Storage class not available: Check available storage classes
#    kubectl get storageclass
#
# 3. Certificate secret missing: Verify secret exists
#    kubectl get secret -n azurite azurite-certs
```

### Connection Refused

```bash
# Verify service is running
kubectl get svc -n azurite
kubectl get endpoints -n azurite storage-azurite-service

# Check if port is actually listening
kubectl exec -it -n azurite deployment/storage-azurite-deployment -- netstat -tlnp
```

### Certificate Errors

```bash
# Recreate the certificate secret if needed
kubectl delete secret azurite-certs -n azurite
openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 365 -config tls.config
kubectl create secret tls azurite-certs --cert=cert.pem --key=key.pem -n azurite

# Restart the pod to pick up new certificate
kubectl rollout restart deployment/storage-azurite-deployment -n azurite
```

### Test Program Connection Issues

```bash
# Verify connectivity from test pod
kubectl run -it --image=mcr.microsoft.com/dotnet/sdk:10.0 -n azurite test-shell -- bash

# Inside the pod, test DNS resolution
nslookup storage-azurite-service.azurite.svc.cluster.local

# Test TLS connection
curl -k https://storage-azurite-service.azurite.svc.cluster.local:10001
```

## Monitoring and Debugging

### View Debug Logs

```bash
# Azurite logs are written to /tmp/debug.log
kubectl exec -it -n azurite deployment/storage-azurite-deployment -- tail -f /tmp/debug.log
```

### Monitor Resource Usage

```bash
# CPU and memory usage
kubectl top pod -n azurite

# Persistent volume usage
kubectl exec -it -n azurite deployment/storage-azurite-deployment -- du -sh /data
```

### Clean Up Test Data

```bash
# Delete all data while preserving deployment
kubectl exec -it -n azurite deployment/storage-azurite-deployment -- rm -rf /data/*
```

## Advanced Configuration

### Increasing Storage Size

Edit `pvc.yaml` and increase the storage request:

```yaml
resources:
  requests:
    storage: 100Gi  # Changed from 50Gi
```

Then apply:

```bash
kubectl apply -f pvc.yaml
# Note: PVC resize may require storage class that supports expansion
```

### Changing Storage Class

If your cluster uses a different storage class, update `pvc.yaml`:

```yaml
storageClassName: your-storage-class-name
```

Available classes can be listed with:

```bash
kubectl get storageclass
```

### Running Multiple Instances (Advanced)

To run multiple Azurite pods with separate data storage:

1. Create multiple PVCs with different names
2. Use a StatefulSet instead of Deployment
3. Ensure storage class supports `ReadWriteMany` access mode

This is beyond the scope of this basic setup.

## Security Considerations

⚠️ **Warning**: This setup is designed for development and testing only. For production use:

1. **Use real Azure Storage** instead of Azurite
2. **Secure certificate generation** - Use proper CA-signed certificates
3. **Network policies** - Restrict access using Kubernetes `NetworkPolicy`
4. **RBAC** - Implement Pod Security Policies
5. **Secret management** - Use proper secret management solutions
6. **Authentication** - Consider implementing OAuth 2.0 instead of basic auth

## References

- [Azurite GitHub Repository](https://github.com/Azure/Azurite)
- [Azure Storage SDKs Documentation](https://learn.microsoft.com/en-us/azure/storage/)
- [Kubernetes Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [Azure Storage Queue C# SDK](https://github.com/Azure/azure-sdk-for-net/tree/main/sdk/storage/Azure.Storage.Queues)

## License

This configuration is provided as-is for development purposes.
