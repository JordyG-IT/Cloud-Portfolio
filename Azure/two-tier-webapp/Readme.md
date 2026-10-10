# Azure Two-Tier Web Application

A hands-on Azure infrastructure project demonstrating the design, deployment, networking, security, and automation of a two-tier application environment.

## Business Context & Purpose
This project demonstrates a secure two-tier hosting pattern in Azure, using network segmentation, Private Link, NSGs, and controlled application-to-database connectivity.

## Project Status

**Current Task:** Refactor Terraform to use Modules

**Next Task:** Architect CI/CD system.

---

## Architecture

<img width="1012" height="337" alt="diagram" src="https://github.com/user-attachments/assets/2b42db1b-ec7c-41e1-adc1-f6b3c1505511" />


## Azure Resources

| Resource           | Configuration                      |
| ------------------ | ---------------------------------- |
| Resource Group     | `RG-Dev`                           |
| Virtual Network    | `Test-WebApp`                      |
| VNet Address Space | `10.0.0.0/16`                      |
| Application Subnet | `10.0.1.0/24`                      |
| Data Subnet        | `10.0.2.0/24`                      |
| Application VM     | Ubuntu 24.04 LTS                   |
| Web Server         | Nginx                              |
| Database           | Azure SQL                          |
| SQL Region         | West US 2                          |
| Private Endpoint   | `SQLPrivateEndpoint`               |
| Private DNS Zone   | `privatelink.database.windows.net` |

## Network Design

The application and data tiers are separated into dedicated subnets.

The Ubuntu VM is exposed to the Internet through a public IP and accepts HTTPS traffic on TCP 443. HTTP traffic on TCP 80 is not permitted.

The database is not exposed through a public endpoint. Application-to-database communication uses an Azure SQL Private Endpoint.

DNS resolution for the SQL server is provided through the Azure Private DNS zone associated with the Private Endpoint.

## Security

The environment was designed using network segmentation and least-privilege access where practical.

Key controls include:

* HTTPS-only inbound web access
* No inbound HTTP access
* Network Security Group controlling network traffic
* Database access through a Private Endpoint
* Azure SQL public network access disabled after private connectivity was validated
* Application and data tiers separated into different subnets
* SSH access restricted rather than exposed broadly to the Internet

<img width="837" height="389" alt="sql_server_networking1" src="https://github.com/user-attachments/assets/81520429-2f2d-43f6-94fe-de72418bdc5f" />
<img width="1255" height="423" alt="sql_server_networking2" src="https://github.com/user-attachments/assets/b2e8af91-90e9-4fe5-81a8-57243f928739" />



## Connectivity Validation & DNS Resolution

Private connectivity to Azure SQL was validated from the Ubuntu VM.

<img width="823" height="218" alt="Ensuring Connectivity to the private endpoint" src="https://github.com/user-attachments/assets/83e58889-ff1e-4997-99a5-57926eaa0480" />


```text
nslookup test-webapp1.database.windows.net
```
Successfully resolved the Azure SQL hostname to the private endpoint through Azure Private DNS

```text
nc -zv test-webapp1.database.windows.net 1433
```
Successfully established TCP connectivity to SQL over port 1433.

### Database Connectivity

`sqlcmd` was used from the Ubuntu VM to authenticate to Azure SQL and execute a query against the database.

<img width="948" height="220" alt="connect to sql via wepappvm" src="https://github.com/user-attachments/assets/ef3964a6-7b69-4c80-9ed3-260e5f70456d" />

This validated the complete path:

```text
Ubuntu VM
    ↓
Private DNS
    ↓
Private Endpoint
    ↓
Azure SQL
    ↓
Database
```

## Infrastructure as Code

The environment was initially built manually to understand and validate the architecture, and is now fully managed via Terraform.

## Guardrails - Using Azure policy


Azure Policy keeps the lab inside defined limits. It restricts where resources can be deployed, limits which VM sizes can be used, and flags configurations that don't follow the secure design. The policies are grouped into a custom initiative and assigned at the subscription scope.

![Initiative policies](<Intiative Policies.png>)

### Policies

| Policy | Effect | Purpose |
|---|---|---|
| Allowed locations | Deny | Restricts deployments to West US 2, so the whole stack stays in one region and avoids cross-region traffic costs |
| Allowed virtual machine size SKUs | Deny | Limits VMs to `Standard_B2s` and `Standard_D2s_v3` to keep lab costs predictable |
| Public network access on Azure SQL Database should be disabled | Audit | Confirms the SQL server is only reachable through its private endpoint |
| Require the `environment` tag | Audit | Keeps every resource tagged consistently with the Terraform `common_tags` |

The allowed locations and SKUs are initiative parameters, so adding a region or a VM size means editing the assignment, not the initiative.

### Rollout approach

New policies started in audit-only mode (Do not enforce). I reviewed the compliance report, fixed what it flagged, and then switched the location and SKU policies to enforcing. Policies that flag intentional design choices stay in Audit.


### Managed outside Terraform

Policy applies to the whole subscription, so it's kept out of this project's Terraform state. That way `terraform destroy` on the lab doesn't remove the guardrails. Managing policy as code (`azurerm_policy_definition`, `azurerm_policy_set_definition`, `azurerm_subscription_policy_assignment`) is planned future work.

## Application Deployment

The infrastructure will eventually host Snipe-IT as the application workload.

The application deployment will demonstrate:

* Docker packaging and deployment
* Integration into a continuous integration and continuous delivery (CI/CD) pipeline
