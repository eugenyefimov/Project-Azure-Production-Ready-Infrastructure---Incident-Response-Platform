# Module: network

Reusable Azure networking module for:

- Resource Group
- Virtual Network
- Subnets (`management`, `application`, `monitoring`)
- Subnet NSGs with least-privilege inbound rules
- NSG associations to each subnet

Design notes:

- No `0.0.0.0/0` allow rules are used.
- Management access is restricted to trusted admin CIDRs (`admin_source_cidrs`).
- Application and monitoring inbound paths are scoped to internal subnet CIDRs.
