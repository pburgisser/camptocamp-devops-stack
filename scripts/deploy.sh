#!/bin/sh

# Install ArgoCD if not present
if test $(kubectl -n argocd get pods --selector "app.kubernetes.io/name=argocd-server" --output=name|wc -l) -eq 0; then
  helm dependency update argocd/argocd
  kubectl create namespace argocd || true
  helm template --include-crds argocd argocd/argocd \
    --set bootstrap=true \
    --namespace argocd | kubectl $KUBECTL_COMMAND -n argocd -f -
  kubectl -n argocd wait $(kubectl -n argocd get pods --selector "app.kubernetes.io/name=argocd-server" --output=name) --for=condition=Ready --timeout=-1s
fi

account_pipeline_tokens=$(kubectl -n argocd get secrets argocd-secret -o=jsonpath="{.data['accounts\.pipeline\.tokens']}"|base64 -d)
# Create token for pipeline if not exists
if test -z "$account_pipeline_tokens"; then
  jti=$(cat /proc/sys/kernel/random/uuid)
  iat=$(date +%s)
  account_pipeline_tokens=$(echo -n "[{\"id\":\"$jti\",\"iat\":$iat}]"|base64 -w0)
  kubectl -n argocd patch $KUBECTL_OPTIONS secret argocd-secret -p "{\"data\": {\"accounts.pipeline.tokens\": \"$account_pipeline_tokens\"}}"
else
  jti=$(echo $account_pipeline_tokens | python3 -c "import sys, json; print(json.load(sys.stdin)[0]['id'])")
  iat=$(echo $account_pipeline_tokens | python3 -c "import sys, json; print(json.load(sys.stdin)[0]['iat'])")
fi

# Generate JWT token for "pipeline" user to connect to ArgoCD
iss="argocd"
nbf=$iat
sub="pipeline"
secret=$(kubectl -n argocd get secret argocd-secret -o=jsonpath="{.data['server\.secretkey']}" | base64 -d)

header=$(echo -n '{"alg":"HS256","typ":"JWT"}' | base64 -w0 | tr '/+' '_-' | tr -d '=')
payload=$(echo -n "{\"jti\":\"$jti\",\"iat\":$iat,\"iss\":\"$iss\",\"nbf\":$nbf,\"sub\":\"$sub\"}" | base64 -w0 | tr '/+' '_-' | tr -d '=')
signature=$(echo -n $header.$payload | openssl dgst -sha256 -hmac $secret -binary | base64 -w0 | tr '/+' '_-' | tr -d '=')

export ARGOCD_AUTH_TOKEN=$header.$payload.$signature

argocd app list
