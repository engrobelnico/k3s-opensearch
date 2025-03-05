# opensearch deploy on k3s

helm repo list | grep opensearch

sudo kubectl apply --namespace=opensearch -f helm/templates/cluster.yaml
sudo kubectl delete opensearchclusters lvopensearch -n opensearch

argocd app delete opensearch --cascade
argocd app terminate-op opensearch