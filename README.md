# opensearch deploy on k3s

helm repo list | grep opensearch

sudo kubectl apply --namespace=opensearch -f helm/templates/cluster.yaml
sudo kubectl delete opensearchclusters lvopensearch -n opensearch

helm install lvopensearch --namespace=opensearch -f values.yaml opensearch-operator/opensearch-cluster

argocd app delete opensearch --cascade
argocd app terminate-op opensearch

https://artifacthub.io/packages/helm/opensearch-operator/opensearch-cluster

https://github.com/opensearch-project/opensearch-k8s-operator/blob/main/charts/opensearch-cluster/values.yaml

# update standard user
https://github.com/opensearch-project/opensearch-k8s-operator/blob/main/docs/userguide/main.md#custom-admin-user

echo -n 'admin' | base64 -w 0
kctl patch secret opensearch-admin-password -n opensearch -p='{"data": {"password":"YWRtaW4="}}'
