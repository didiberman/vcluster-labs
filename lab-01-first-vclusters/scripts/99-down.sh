#!/usr/bin/env bash
set -euo pipefail
kind delete cluster --name vcluster-lab
echo "Host cluster and all vclusters deleted."
