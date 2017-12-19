#!/bin/bash

source vars.sh

for node in ${!instances[@]} ${!controllers[@]}; do
  kubectl --kubeconfig /etc/kubernetes/admin.conf drain ${node} --delete-local-data --force --ignore-daemonsets
  kubectl --kubeconfig /etc/kubernetes/admin.conf delete node ${node}
  ssh root@${node} "kubeadm reset ; rm ~/.kube/config"
done
