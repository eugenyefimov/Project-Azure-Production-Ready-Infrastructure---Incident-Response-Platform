# Architecture

## Purpose

Provide a secure, maintainable Azure infrastructure baseline with controlled delivery and incident-ready operations.

## Platform Scope

- Environment-separated Terraform roots:
  - `environments/dev`
  - `environments/staging`
  - `environments/prod`
- Shared composition module:
  - `modules/platform`
- Reusable workload and control modules:
  - network, linux-vm, windows-vm, monitoring, incident-response, rbac, governance, container-workload

## Core Topology

- resource group per environment scope
- VNet with `management`, `application`, `monitoring` subnets
- optional delegated container subnet for ACI workloads
- Linux app VM, optional Windows management VM
- Log Analytics + Azure Monitor alerts and action routing
- Recovery Services Vault for VM backup protection

## Naming Standard

Pattern:

- `<project>-<environment-short>-<region>-<resource-type>-<sequence>`

Purpose:

- fast incident resource discovery
- consistent policy and tag targeting
- predictable cost and ownership reporting

## Environment Strategy

- **dev:** low-cost iteration, relaxed enforcement where approved
- **staging:** production-like validation, stricter checks
- **prod:** protected change controls, strict governance and monitoring

## Workload Model

- VM workloads for host-level administration and legacy-compatible operations
- optional ACI workload for cost-aware stateless container execution
- AKS intentionally not included in baseline until orchestration need justifies operational overhead

## Architecture Decisions

- private-first network posture
- least-privilege access and environment-bounded blast radius
- policy and approval gates integrated in delivery path
- evidence capture integrated with incident and change workflows
