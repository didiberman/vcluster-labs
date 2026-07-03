#!/usr/bin/env bash
set -euo pipefail

HOST_CTX="kind-vcluster-lab"

pause() { echo; read -rp "--- press enter for the next step ---"; echo; }

echo "############################################################"
echo "# 1. Inside team-a: a normal-looking cluster with podinfo  #"
echo "############################################################"
vcluster connect team-a --namespace vcluster-team-a --context "${HOST_CTX}" -- \
  kubectl get pods -A
pause

echo "############################################################"
echo "# 2. Inside team-b: clean and empty — no sign of team-a    #"
echo "############################################################"
vcluster connect team-b --namespace vcluster-team-b --context "${HOST_CTX}" -- \
  kubectl get pods -A
pause

echo "############################################################"
echo "# 3. Host view: both 'clusters' are just pods in namespaces #"
echo "############################################################"
kubectl --context "${HOST_CTX}" get pods -A | grep -E 'NAMESPACE|vcluster-team'
pause

echo "############################################################"
echo "# 4. Cost: memory per tenant (control plane + synced pods) #"
echo "############################################################"
kubectl --context "${HOST_CTX}" top pods -n vcluster-team-a 2>/dev/null \
  || echo "(metrics-server still warming up — retry in ~30s)"
kubectl --context "${HOST_CTX}" top pods -n vcluster-team-b 2>/dev/null || true
pause

echo "############################################################"
echo "# 5. Hit podinfo inside team-a                              #"
echo "############################################################"
vcluster connect team-a --namespace vcluster-team-a --context "${HOST_CTX}" -- \
  kubectl -n demo run curl-test --rm -i --restart=Never \
  --image=curlimages/curl -- -s http://podinfo.demo:9898 | head -20

echo
echo "Tour done. Teardown: ./scripts/99-down.sh"
