helm upgrade --install --debug --kube-context "${K8S_CTX}" \
  --create-namespace \
  --namespace="${MDB_NS}" \
  mongodb-kubernetes \
  ${OPERATOR_ADDITIONAL_HELM_VALUES:+--set ${OPERATOR_ADDITIONAL_HELM_VALUES}} \
  "${OPERATOR_HELM_CHART}"

# Create admin user secret
kubectl create secret generic mdb-admin-user-password \
  --from-literal=password="mdb-admin" \
  --dry-run=client -o yaml | kubectl apply  --namespace "${MDB_NS}" -f -

# Create search sync source user secret
kubectl create secret generic "${MDB_RESOURCE_NAME}-search-sync-source-password" \
  --from-literal=password="${MDB_SEARCH_SYNC_USER_PASSWORD}" \
  --dry-run=client -o yaml | kubectl apply --namespace "${MDB_NS}" -f -

# Create regular user secret
kubectl create secret generic mdb-user-password \
  --from-literal=password="${MDB_USER_PASSWORD}" \
  --dry-run=client -o yaml | kubectl apply  --namespace "${MDB_NS}" -f -

echo "User secrets created."
