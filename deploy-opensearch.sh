#!/bin/bash

# https://docs.microsoft.com/en-us/azure/app-service/configure-authentication-provider-aad

# Set the `errexit` option to make sure that
# if one command fails, all the script execution
# will also fail (see `man bash` for more 
# information on the options that you can set).
set -o errexit

main () {
    myNamespace=opensearch
    appName=opensearch
    NS=$(sudo kubectl get namespace $myNamespace --ignore-not-found);
    if [[ "$NS" ]]; then
        echo "Skipping creation of namespace $myNamespace - already exists";
    else
        echo "Creating namespace $myNamespace";
        sudo kubectl create namespace $myNamespace;
    fi;
    # deploy prometheus with argocd
    sudo kubectl apply -n argocd -f opensearch.yaml
    # sync the application
    argocd login kube.local:443 --grpc-web-root-path /argocd-server --insecure  --username admin --password $(sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

    # If a previous ArgoCD operation is still running, wait for it to finish.
    # If it stays blocked, terminate it and continue with a clean sync.
    if ! argocd app wait "$appName" --operation --timeout 300; then
        echo "An existing ArgoCD operation seems stuck for $appName, terminating it";
        argocd app terminate-op "$appName"
        argocd app wait "$appName" --operation --timeout 120
    fi

    # Retry once if we race with another operation right after the wait.
    if ! argocd app sync "$appName"; then
        echo "First sync failed for $appName, retrying once after terminate-op";
        argocd app terminate-op "$appName" || true
        argocd app wait "$appName" --operation --timeout 120 || true
        argocd app sync "$appName"
    fi

}
main "$@"
