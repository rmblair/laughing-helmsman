function join { local IFS="$1"; shift; echo "$*"; }

source cluster_vars.sh
rc=$?
if [[ 0 -ne "$rc" ]]; then
  echo "copy cluster_vars.sh.template to cluster_vars.sh and fix"
  exit 1
fi
unset rc

# Flannel / Canal required
POD_NETWORK_CIDR="10.244.0.0/16"

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
