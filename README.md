# opensearch deploy on k3s

helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts

helm repo list | grep opensearch

sudo kubectl apply --namespace=opensearch -f helm/templates/cluster.yaml
sudo kubectl delete opensearchclusters lvopensearch -n opensearch

helm install lvopensearch --namespace=opensearch -f values.yaml opensearch-operator/opensearch-cluster

argocd app delete opensearch --cascade
argocd app terminate-op opensearch

https://artifacthub.io/packages/helm/opensearch-operator/opensearch-cluster

https://github.com/opensearch-project/opensearch-k8s-operator/blob/main/charts/opensearch-cluster/values.yaml