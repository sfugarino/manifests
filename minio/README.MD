# MinIO on k3s

This folder contains Kubernetes and Helm manifests to deploy MinIO in standalone mode on a k3s cluster.

## Files in this directory

- `pvc.yaml`: PersistentVolumeClaim named `s3-pvc` in namespace `minio` (100Gi, Longhorn).
- `secret.yaml`: Kubernetes Secret named `minio` with MinIO root credentials.
- `values.yaml`: Helm values used for MinIO deployment.
- `install.sh`: Helm install/upgrade command.
- `uninstall.sh`: Cleanup script.

## Prerequisites

- A running k3s cluster.
- `kubectl` configured to access your k3s cluster.
- `helm` installed.
- A storage class named `longhorn` available in the cluster (used by `pvc.yaml`).
- A node named `turing-four` if you keep the current `nodeSelector` in `values.yaml`.

## 1) Add MinIO Helm repo

Run once on your workstation:

```bash
helm repo add minio https://charts.min.io/
helm repo update
```

## 2) Create namespace (optional but recommended)

```bash
kubectl create namespace minio --dry-run=client -o yaml | kubectl apply -f -
```

## 3) Create Secret and PVC

Apply the required objects before Helm install:

```bash
kubectl apply -f secret.yaml
kubectl apply -f pvc.yaml
```

## 4) Install or upgrade MinIO

Make script executable and run it:

```bash
chmod +x install.sh
./install.sh
```

The script runs:

```bash
helm upgrade --install minio minio/minio --namespace minio --create-namespace -f values.yaml
```

## 5) Verify deployment

Check pod, service, and PVC status:

```bash
kubectl -n minio get pods
kubectl -n minio get svc
kubectl -n minio get pvc s3-pvc
```

Wait until MinIO pod is `Running` and service is created.

## Access MinIO Console

Your current config sets:

- `consoleService.type: LoadBalancer`
- `consoleService.port: 9001`

Get external endpoint:

```bash
kubectl -n minio get svc minio-console
```

If your k3s environment does not provide external LoadBalancers, use port-forward:

```bash
kubectl -n minio port-forward svc/minio-console 9001:9001
```

Then open:

- http://localhost:9001

## Credentials

Credentials come from `secret.yaml`:

- root user: `admin`
- root password: `password`

These are currently weak default credentials. Change them for any non-local environment.

Example for updating values:

```bash
echo -n 'myadmin' | base64
echo -n 'my-strong-password' | base64
```

Replace `rootUser` and `rootPassword` in `secret.yaml`, then re-apply:

```bash
kubectl apply -f secret.yaml
kubectl -n minio rollout restart statefulset minio
```

## Uninstall

If `uninstall.sh` already contains your uninstall commands:

```bash
chmod +x uninstall.sh
./uninstall.sh
```

Or manually:

```bash
helm -n minio uninstall minio
kubectl delete -f pvc.yaml
kubectl delete -f secret.yaml
kubectl delete namespace minio
```

## Notes about current values

From `values.yaml`:

- Mode is `standalone`.
- Persistence uses existing claim `s3-pvc`.
- Pod is pinned to node `turing-four` using `nodeSelector`.
- Metrics `serviceMonitor` is enabled (requires Prometheus Operator CRDs in cluster).
