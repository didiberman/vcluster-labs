# vcluster-labs

A hands-on experiment series for learning [vcluster](https://www.vcluster.com/)
and demonstrating its value with measurable evidence. The end goal is a
miniature self-service internal developer platform: isolated Kubernetes
clusters for teams, provisioned by pull request, running on a single cheap
VPS.

## Why vcluster

Teams need Kubernetes clusters. Real clusters are slow to create and expensive
to multiply; namespaces are cheap but don't isolate CRDs, cluster-scoped RBAC,
or Kubernetes versions. vcluster gives each tenant its own API server —
the isolation of a real cluster at roughly the cost of a namespace.

Measured so far (Lab 01, on a laptop):

| Metric | Value |
|--------|-------|
| vcluster creation | ~3 s to create, ~35 s to fully ready |
| Memory per tenant control plane | ~370 Mi |
| CPU per idle tenant | ~75 m |
| kind host cluster creation (comparison) | ~27 s |

## The labs

| Lab | Status | What it proves |
|-----|--------|----------------|
| [01 — First vclusters](lab-01-first-vclusters/) | done | Tenants get real, isolated clusters that are just pods on the host |
| 02 — Isolation proof | planned | Conflicting CRD/operator versions per tenant, different k8s versions, blast-radius demo |
| 03 — Benchmarks | planned | Speed/memory/cost table: vcluster vs kind vs managed clusters |
| 04 — Self-service platform | planned | Hetzner VPS via Terraform (hcloud + k3s), ArgoCD ApplicationSet: teams onboard by opening a PR to `tenants/` |
| 05 — Showcase | planned | 10-minute demo script + writeup with all the evidence |

## Quickstart (Lab 01)

Prerequisites: Docker running, plus `kind`, `kubectl`, `helm`, and `vcluster`
on PATH.

```sh
cd lab-01-first-vclusters
./scripts/01-up.sh      # host cluster + two tenant vclusters + podinfo in team-a
./scripts/02-tour.sh    # guided tour of the isolation story
./scripts/99-down.sh    # tear everything down
```

## Architecture (target state)

- **Platform layer** (Terraform, rarely changes): Hetzner VPS, k3s host
  cluster, ingress, DNS, ArgoCD.
- **Tenant layer** (GitOps, self-service): an ArgoCD ApplicationSet watches
  `tenants/` in this repo; adding `tenants/team-c.yaml` via an approved PR
  materializes a new vcluster in about a minute. Offboarding is `git rm`,
  the audit log is `git log`.
- **Workloads**: [podinfo](https://github.com/stefanprodan/podinfo) as the
  stand-in team application; per-PR preview environments as the flagship demo.

Everything here uses the Apache-2.0 open-source vcluster core — no commercial
platform required.
