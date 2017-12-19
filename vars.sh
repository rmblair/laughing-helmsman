function join { local IFS="$1"; shift; echo "$*"; }

source cluster_vars.sh
rc=$?
if [[ 0 -ne "$rc" ]]; then
  echo "copy cluster_vars.sh.template to cluster_vars.sh and fix"
  exit 1
fi
unset rc

# calico, canal, flannel, romana, weave
POD_NETPLUGIN=${NETPLUGIN:-canal}

case "$POD_NETPLUGIN" in
  calico)
    # Calico default
    POD_NETWORK_CIDR="192.168.0.0/16"
    calico_ver="v2.6"
    calico_url="https://docs.projectcalico.org/${calico_ver}/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml"
    calicoctl_url="https://docs.projectcalico.org/${calico_ver}/getting-started/kubernetes/installation/hosted/calicoctl.yaml"
    ;;
  canal)
    # Flannel / Canal required
    POD_NETWORK_CIDR="10.244.0.0/16"
    ;;
  flannel)
    # Flannel / Canal required
    POD_NETWORK_CIDR="10.244.0.0/16"
    flannel_ver="v0.9.1"
    flannel_url="https://raw.githubusercontent.com/coreos/flannel/${flannel_ver}/Documentation/kube-flannel.yml"
    ;;
  romana)
    # Romana required
    POD_NETWORK_CIDR="172.20.0.0/21" # kops default
    romana_url="https://raw.githubusercontent.com/romana/romana/master/docs/kubernetes/romana-kubeadm.yml"
    ;;
  weave)
    # Weave Net default
    POD_NETWORK_CIDR="10.32.0.0/12"
    ;;
  *)
  POD_NETWORK_CIDR="10.244.0.0/16"
esac

#k8s_ver="v1.8.5"
k8s_ver="v1.9.0"
k8s_base_url="https://storage.googleapis.com/kubernetes-release/release/${k8s_ver}/bin/linux/amd64"
k8s_dist_dir="${PWD}/dist/k8s-dist-${k8s_ver}"

cfssl_ver="1.2"
cfssl_base_url="https://pkg.cfssl.org/R${cfssl_ver}"
cfssl_dist_dir="${PWD}/dist/cfssl-R${cfssl_ver}"

cni_plugins_ver="v0.6.0"
cni_plugins_file="cni-plugins-amd64-${cni_plugins_ver}.tgz"
cni_plugins_url="https://github.com/containernetworking/plugins/releases/download/${cni_plugins_ver}/${cni_plugins_file}"
cni_dist_dir="${PWD}/dist/cni-${cni_plugins_ver}"

canal_ver="1.7"
canal_base_url="https://raw.githubusercontent.com/projectcalico/canal/master/k8s-install/${canal_ver}"

helm_ver="v2.7.2"
helm_file="helm-${helm_ver}-linux-amd64.tar.gz"
helm_base_url="https://kubernetes-helm.storage.googleapis.com/${helm_file}"
helm_dist_dir="${PWD}/dist/helm-${helm_ver}"
