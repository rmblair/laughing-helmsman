#!/bin/bash

source vars.sh

cat > dist/kubelet.service << EOF
[Unit]
Description=kubelet ${k8s_ver}: The Kubernetes Node Agent
Documentation=http://kubernetes.io/docs/

[Service]
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_SYSTEM_PODS_ARGS=--pod-manifest-path=/etc/kubernetes/manifests --allow-privileged=true"
Environment="KUBELET_NETWORK_ARGS=--network-plugin=cni --cni-conf-dir=/etc/cni/net.d --cni-bin-dir=/opt/cni/bin"
Environment="KUBELET_DNS_ARGS=--cluster-dns=10.96.0.10 --cluster-domain=cluster.local"
Environment="KUBELET_AUTHZ_ARGS=--authorization-mode=Webhook --client-ca-file=/etc/kubernetes/pki/ca.crt"
# Value should match Docker daemon settings.
# Defaults are "cgroupfs" for Debian/Ubuntu/OpenSUSE and "systemd" for Fedora/CentOS/RHEL
Environment="KUBELET_CGROUP_ARGS=--cgroup-driver=cgroupfs"
Environment="KUBELET_CADVISOR_ARGS=--cadvisor-port=0"
Environment="KUBELET_CERTIFICATE_ARGS=--rotate-certificates=true"
ExecStart=/usr/local/bin/kubelet \$KUBELET_KUBECONFIG_ARGS \$KUBELET_SYSTEM_PODS_ARGS \$KUBELET_NETWORK_ARGS \$KUBELET_DNS_ARGS \$KUBELET_AUTHZ_ARGS \$KUBELET_CGROUP_ARGS \$KUBELET_CADVISOR_ARGS \$KUBELET_CERTIFICATE_ARGS \$KUBELET_EXTRA_ARGS
Restart=always
StartLimitInterval=0
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# copy over distribution files
for node in ${!controllers[@]} ${!instances[@]}; do
  # stop old kubelet if it is running
  ssh root@${node} "\
    if [[ -f /etc/systemd/system/kubelet.service ]]; then \
      systemctl disable kubelet && \
      systemctl stop kubelet && \
      rm -f /etc/systemd/system/kubelet.service ;\
      systemctl daemon-reload
    fi
  "

  # copy dist binaries
  scp "${cni_dist_dir}/${cni_plugins_file}" \
    root@${node}:/root/
  scp \
    "${k8s_dist_dir}/kubeadm" \
    "${k8s_dist_dir}/kubelet" \
    "${k8s_dist_dir}/kubectl" \
    root@${node}:/usr/local/bin
  ssh root@${node} "chown root:root /usr/local/bin/{kubeadm,kubelet,kubectl}"
  ssh root@${node} "chmod 0755 /usr/local/bin/{kubeadm,kubelet,kubectl}"

  # copy kubelet systemd unit
  scp dist/kubelet.service \
    root@${node}:/etc/systemd/system

  # unpack CNI bits
  ssh root@${node} "\
    mkdir -p \
      /etc/cni/net.d \
      /opt/cni/bin \
      /var/lib/kubelet \
      /var/lib/kube-proxy \
      /var/lib/kubernetes \
      /var/run/kubernetes ;\
    tar -xvf /root/${cni_plugins_file} -C /opt/cni/bin/
  "

  # switch on
  ssh root@${node} "\
    systemctl daemon-reload && \
    systemctl enable kubelet && \
    systemctl start kubelet
  "
done

