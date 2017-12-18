#!/bin/bash

source vars.sh

# copy over distribution files
for node in ${!controllers[@]} ${!instances[@]}; do
  scp \
    "${k8s_dist_dir}/kubeadm" \
    "${k8s_dist_dir}/kubelet" \
    "${k8s_dist_dir}/kubectl" \
    root@${node}:/usr/local/bin
  ssh root@${node} "chown root:root /usr/local/bin/{kubeadm,kubelet,kubectl}"
  ssh root@${node} "chmod 0755 /usr/local/bin/{kubeadm,kubelet,kubectl}"
done

