#!/bin/bash

source vars.sh

# pick the first controller (kubeadm does not do HA [yet])
# and reset [clean up from previous?], then init the cluster
ssh root@${!controllers[@]} \
  "kubeadm reset"

ssh root@${!controllers[@]} "\
  kubeadm init \
    --pod-network-cidr=${POD_NETWORK_CIDR} \
    --kubernetes-version=${k8s_ver} ;\
  mkdir -p ~/.kube && \
  cp /etc/kubernetes/admin.conf ~/.kube/config
"

case "$POD_NETPLUGIN" in
  calico)
    # configure Calico
    ssh root@${!controllers[@]} "\
      kubectl apply -f "${calico_url}" && \
      kubectl apply -f "${calicoctl_url}"
    "
    echo 'call calicoctl like so:'
    echo 'kubectl exec -ti -n kube-system calicoctl -- /calicoctl get profiles -o wide'
    ;;
  canal)
    # configure Canal/Flannel
    ssh root@${!controllers[@]} "\
      kubectl apply -f ${canal_base_url}/rbac.yaml && \
      kubectl apply -f ${canal_base_url}/canal.yaml
    "
    ;;
  flannel)
    # configure Canal/Flannel
    ssh root@${!controllers[@]} "\
      kubectl apply -f "${flannel_url}"
    "
    ;;
  romana)
    # configure Canal/Flannel
    ssh root@${!controllers[@]} "\
      kubectl apply -f "${romana_url}"
    "
    ;;
  weave)
    ssh root@${!controllers[@]} "\
      kubever=\$(kubectl version | base64 | tr -d '\n') ;\
      kubectl apply -f \"https://cloud.weave.works/k8s/net?k8s-version=\$kubever\"
    "
    ;;
  *)
    echo POD_NETWORK: "$POD_NETPLUGIN" not installable by this script
    echo continuing without ...
esac

# taint the master (allows user pods to be scheduled here)
#ssh root@${!controllers[@]} "\
#  kubectl --kubeconfig /etc/kubernetes/admin.conf taint nodes --all node-role.kubernetes.io/master-
#"

echo join nodes this way using the kubeadm join command from above:
echo for node in ${!instances[@]}\; do
echo ssh root@\${node} \'kubeadm join ....\'
echo done
