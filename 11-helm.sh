#!/bin/bash

source vars.sh

if [[ ! -d "${helm_dist_dir}" ]]; then
  mkdir -p "${helm_dist_dir}"
fi

(
  cd "${helm_dist_dir}"
  if [[ ! -f "${helm_file}" ]]; then
    wget -q --show-progress --https-only --timestamping \
      "${helm_base_url}"
  fi

  tar -xvf "${helm_file}" linux-amd64/helm
  rm -f /usr/local/bin/helm
  cp linux-amd64/helm /usr/local/bin/helm

  # clean up existing RBAC bits
  kubectl delete sa/tiller role/tiller-manager rolebinding/tiller-binding \
    --namespace=kube-system
  kubectl delete role/tiller-manager rolebinding/tiller-binding \
    --namespace=default

  # deploy tiller in kube-system namespace, with restriction
  # to deploying into default namespace
  kubectl create serviceaccount --namespace kube-system tiller
cat << EOF | kubectl apply -f -
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: tiller-manager
  namespace: default
rules:
- apiGroups: ["", "extensions", "apps", "policy"]
  resources: ["*"]
  verbs: ["*"]
EOF

cat << EOF | kubectl apply -f -
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: tiller-binding
  namespace: default
subjects:
- kind: ServiceAccount
  name: tiller
  namespace: kube-system
roleRef:
  kind: Role
  name: tiller-manager
  apiGroup: rbac.authorization.k8s.io
EOF

cat << EOF | kubectl apply -f -
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: kube-system
  name: tiller-manager
rules:
- apiGroups: ["", "extensions", "apps", "policy"]
  resources: ["configmaps"]
  verbs: ["*"]
EOF

cat << EOF | kubectl apply -f -
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: tiller-binding
  namespace: kube-system
subjects:
- kind: ServiceAccount
  name: tiller
  namespace: kube-system
roleRef:
  kind: Role
  name: tiller-manager
  apiGroup: rbac.authorization.k8s.io
EOF

  helm init \
    --service-account tiller \
    --tiller-namespace kube-system
  helm repo update
)
