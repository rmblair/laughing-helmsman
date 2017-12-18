#!/bin/bash

source vars.sh

cat > dist/kubelet.service << EOF
[Unit]
Description=kubelet ${k8s_ver}: The Kubernetes Node Agent
Documentation=http://kubernetes.io/docs/

[Service]
ExecStart=/usr/local/bin/kubelet
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

  # switch on
  ssh root@${node} "\
    systemctl daemon-reload && \
    systemctl enable kubelet && \
    systemctl start kubelet
  "
done

