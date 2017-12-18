#!/bin/bash

source vars.sh

### cloudflare SSL
if [[ ! -d "${cfssl_dist_dir}" ]]; then
  mkdir -p "${cfssl_dist_dir}"
fi

(
  cd "${cfssl_dist_dir}"

  for binary in cfssl_linux-amd64 cfssljson_linux-amd64; do
    if [[ ! -f "${binary}" ]]; then
      wget -q --show-progress --https-only --timestamping \
        "${cfssl_base_url}/${binary}"
      chmod +x "${binary}"
    fi
  done

  #cp cfssl_linux-amd64 /usr/local/bin/cfssl
  #cp cfssljson_linux-amd64 /usr/local/bin/cfssljson

  #cfssl version
)

### download Kubernetes dist to push out
if [[ ! -d "${k8s_dist_dir}" ]]; then
  mkdir -p "${k8s_dist_dir}"
fi

(
  cd "${k8s_dist_dir}"
  controller_binaries="kube-apiserver kube-controller-manager kube-scheduler kubectl"
  instance_binaries="kubectl kube-proxy kubelet"
  admin_binaries="kubeadm"

  for binary in $controller_binaries $instance_binaries $admin_binaries; do
    if [[ ! -f "${binary}" ]]; then
      wget -q --show-progress --https-only --timestamping \
       "${k8s_base_url}/${binary}"
    fi
  done
)
