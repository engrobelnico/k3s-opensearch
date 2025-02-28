# opensearch deploy on k3s

helm dependency update

argocd app delete opensearch --cascade
argocd app terminate-op opensearch

{"statusCode":401,"error":"Unauthorized","message":"Authentication required"}

https://opensearch.org/docs/latest/install-and-configure/install-opensearch/helm/

curl -XGET https://kube.local/opensearch -u 'admin:VerySecurePassword12!' --insecure