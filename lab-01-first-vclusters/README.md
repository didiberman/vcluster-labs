# Lab 01 — First vclusters

The smallest useful vcluster experiment: one local kind cluster acting as the
"host", two virtual clusters acting as tenants, and a real workload in one of
them. Everything runs on your laptop; teardown is one command.

## What this demonstrates

1. **A vcluster is just pods on the host.** Each tenant gets its own API
   server, but from the host's view it's a namespace with a couple of pods.
2. **Tenants are isolated.** team-a and team-b can't see each other's
   workloads, and each sees a clean empty cluster.
3. **It's fast and cheap.** Creating a tenant takes well under a minute and
   costs a few hundred MB of memory — compare with creating a whole cluster.

## Prerequisites

- Docker running
- `kind`, `kubectl`, `helm`, `vcluster` on PATH

## Run it

```sh
./scripts/01-up.sh        # create host cluster + two vclusters + deploy podinfo in team-a
./scripts/02-tour.sh      # guided tour: isolation, host view, resource cost
./scripts/99-down.sh      # tear everything down
```

## What to observe

While `02-tour.sh` runs, look for:

- `kubectl get pods -A` **inside team-a** shows only team-a's world (podinfo,
  kube-system) — no trace of team-b or the host's other tenants.
- The same command **on the host** shows both vclusters as ordinary pods in
  `vcluster-team-a` / `vcluster-team-b` namespaces. Podinfo's pod appears on
  the host with a synced, prefixed name — that's the syncer at work.
- Creation time for a tenant (printed by `01-up.sh`) vs. the kind cluster
  itself.
- `kubectl top pods` output showing the per-tenant memory cost.

## Evidence to capture (for the eventual writeup)

| Metric | Where to get it |
|--------|-----------------|
| vcluster creation time | printed by `01-up.sh` |
| memory per tenant | `kubectl top pods -n vcluster-team-a` (host context) |
| host cluster creation time | printed by `01-up.sh` for comparison |

## Where this goes next

- Lab 02: isolation proof — conflicting operator/CRD versions per tenant,
  different Kubernetes versions, blast-radius demo.
- Then: move the host to a Hetzner VPS via Terraform, add ArgoCD
  ApplicationSet for PR-based self-service tenant onboarding.
