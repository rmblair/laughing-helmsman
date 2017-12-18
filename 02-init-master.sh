#!/bin/bash

source vars.sh

# pick the first controller (kubeadm does not do HA [yet])
# and reset [clean up from previous?], then init the cluster
ssh root@${!controllers[@]} \
  "kubeadm reset"

ssh root@${!controllers[@]} "\
  kubeadm init \
    --pod-network-cidr=${POD_NETWORK_CIDR} \
    --kubernetes-version=${k8s_ver}
"

# configure Canal/Flannel
ssh root@${!controllers[@]} "\
  kubectl --kubeconfig /etc/kubernetes/admin.conf apply -f ${canal_base_url}/rbac.yaml && \
  kubectl --kubeconfig /etc/kubernetes/admin.conf apply -f ${canal_base_url}/canal.yaml
"

