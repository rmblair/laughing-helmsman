function join { local IFS="$1"; shift; echo "$*"; }

# Flannel / Canal required
POD_NETWORK_CIDR="10.244.0.0/16"

k8s_ver="v1.9.0"
k8s_base_url="https://storage.googleapis.com/kubernetes-release/release/${k8s_ver}/bin/linux/amd64"
k8s_dist_dir="${PWD}/dist/k8s-dist-${k8s_ver}"

cfssl_ver="1.2"
cfssl_base_url="https://pkg.cfssl.org/R${cfssl_ver}"
cfssl_dist_dir="${PWD}/dist/cfssl-R${cfssl_ver}"
