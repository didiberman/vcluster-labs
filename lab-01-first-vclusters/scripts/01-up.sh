#!/usr/bin/env bash
set -euo pipefail

HOST_CLUSTER=vcluster-lab
HOST_CTX="kind-${HOST_CLUSTER}"

echo "==> Creating kind host cluster '${HOST_CLUSTER}' (timing it)"
host_start=$(date +%s)
if kind get clusters 2>/dev/null | grep -qx "${HOST_CLUSTER}"; then
  echo "    already exists, skipping"
else
  kind create cluster --name "${HOST_CLUSTER}" --wait 120s
fi
host_end=$(date +%s)
echo "    host cluster ready in $((host_end - host_start))s"

# metrics-server so we can measure per-tenant memory (kind needs insecure TLS)
echo "==> Installing metrics-server on the host"
helm upgrade --install metrics-server metrics-server \
  --repo https://kubernetes-sigs.github.io/metrics-server/ \
  --namespace kube-system --kube-context "${HOST_CTX}" \
  --set args={--kubelet-insecure-tls} --wait >/dev/null

for team in team-a team-b; do
  echo "==> Creating vcluster '${team}' (timing it)"
  t_start=$(date +%s)
  vcluster create "${team}" \
    --namespace "vcluster-${team}" \
    --context "${HOST_CTX}" \
    --connect=false
  t_end=$(date +%s)
  echo "    ${team} ready in $((t_end - t_start))s"
done

echo "==> Deploying podinfo into team-a"
vcluster connect team-a --namespace vcluster-team-a --context "${HOST_CTX}" -- \
  helm upgrade --install podinfo podinfo \
    --repo https://stefanprodan.github.io/podinfo \
    --namespace demo --create-namespace --wait

echo
echo "All up. Next: ./scripts/02-tour.sh"
# THE END
