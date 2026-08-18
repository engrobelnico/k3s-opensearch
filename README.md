# opensearch deploy on k3s

helm repo list | grep opensearch

sudo kubectl apply --namespace=opensearch -f helm/templates/cluster.yaml
sudo kubectl delete opensearchclusters lvopensearch -n opensearch

helm install lvopensearch --namespace=opensearch -f values.yaml opensearch-operator/opensearch-cluster

argocd app delete opensearch --cascade
argocd app terminate-op opensearch

kctl patch application/opensearch --type json --patch='[ { "op": "remove", "path": "/metadata/finalizers" } ]' -n argocd

https://artifacthub.io/packages/helm/opensearch-operator/opensearch-cluster

https://github.com/opensearch-project/opensearch-k8s-operator/blob/main/charts/opensearch-cluster/values.yaml

# update standard user
https://github.com/opensearch-project/opensearch-k8s-operator/blob/main/docs/userguide/main.md#custom-admin-user

# The opensearch-admin-password secret is now created by the helm chart itself
# (helm/templates/admin-credentials-secret.yaml) from .Values.adminCredentials.
# To rotate the password after install, patch the secret directly (the chart
# preserves existing values on upgrade via `lookup`):
echo -n 'newpassword' | base64 -w 0
kctl patch secret opensearch-admin-password -n opensearch -p='{"data": {"password":"<base64>"}}'

# Patcher pour vider les finalizers
kctl get opensearchismpolicy sample-policy -n opensearch -o yaml
kctl delete opensearchismpolicy sample-policy -n opensearch --force --grace-period=0
# Forcer la suppression si nécessaire
kctl patch opensearchismpolicy sample-policy -n opensearch \
  --type='merge' \
  -p '{"metadata":{"finalizers":[]}}'
# Lister toutes les CRD opensearch avec des finalizers
for crd in $(kubectl get crd -o name | grep opensearch); do
  resource=$(echo $crd | cut -d'/' -f2)
  kubectl get $resource -n opensearch -o json 2>/dev/null | \
    jq -r '.items[] | select(.metadata.finalizers != null) | .metadata.name + " -> " + (.metadata.finalizers | join(", "))'
done

# supprimer les PVC
kctl delete pvc data-opensearch-masters-0 data-opensearch-masters-1 data-opensearch-masters-2 -n opensearch 2>&1 & sudo kubectl delete pod opensearch-masters-0 opensearch-masters-1 opensearch-masters-2 -n opensearch --force --grace-period=0 2>&1