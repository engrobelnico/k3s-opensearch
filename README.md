# opensearch deploy on k3s

helm dependency update

argocd app delete opensearch --cascade
argocd app terminate-op opensearch