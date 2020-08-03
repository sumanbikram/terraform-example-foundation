# terraform-example-foundation
This is an example repo showing how the CFT Terraform modules can be composed to build a secure GCP foundation.
The supplied structure and code is intended to form a starting point for building your own foundation with pragmatic defaults you can customize to meet your own requirements. Currently, the code leverages Google Cloud Build for deployment of the Terraform from step 1 onwards.
Cloud Build has been chosen to allow teams to quickly get started without needing to deploy a CI/CD tool, although it is worth noting the code can easily be executed by your preferred tool.

## Overview
This repo contains several distinct Terraform projects each within their own directory that must be applied separately, but in sequence.
Each of these Terraform projects are to be layered on top of each other, running in the following order.

### [0. bootstrap](./0-bootstrap/)

This stage executes the [CFT Bootstrap module](https://github.com/terraform-google-modules/terraform-google-bootstrap) which bootstraps an existing GCP organization, creating all the required GCP resources & permissions to start using the Cloud Foundation Toolkit (CFT). You can use either of these two tools for your CICD pipelines: Cloud Build (by default) or Jenkins. If you want to use Jenkins instead of Cloud Build, please:
   - Comment-out the `cloudbuild_bootstrap` module in `main.tf`, its variables in `variables.tf` and its outputs in `outputs.tf`
   - Un-comment the `jenkins_bootstrap` module in `main.tf`, its variables in `variables.tf` and its outputs in `outputs.tf`
   - Follow the instructions on how to run the bootstrap step with the `jenkins_bootstrap` sub-module described in the [README](./0-bootstrap/modules/jenkins-agent/README.md), which include implementing VPN, configuring your Jenkins Master among other steps.

The bootstrap step includes:
- The `cft-seed` project, which contains:
  - Terraform state bucket
  - Custom Service Account used by Terraform to create new resources in GCP
- The `cft-cloudbuild` project (`prj-cicd` if using Jenkins), which contains:
  - A CICD pipeline implemented with either Cloud Build or Jenkins
  - If using Cloud Build:
    - Cloud Source Repository
  - If using Jenkins:
    - Custom Service Account to run Jenkins Agents GCE instances
    - VPN connection with on-prem (or where ever your Jenkins Master is located)

It is a best practice to have two separate projects here (`cft-seed` and `prj-cicd`) for separation of concerns. On one hand, `cft-seed` stores terraform state and has the Service Account able to create / modify infrastructure. On the other hand, the deployment of that infrastructure is coordinated by a tool of your choice (either Cloud Build or Jenkins), which is implemented in `prj-cicd`.

If using Cloud Build, its default service account `@cloudbuild.gserviceaccount.com` is granted access to generate tokens over the Terraform custom service account. If using Jenkins, the custom service account used by the GCE instance is granted the access.

After executing this step, you will have the following structure:

```
example-organization/
└── seed
    ├── cft-cloudbuild
    └── cft-seed
```

In addition, this step uses the optional Cloud Build submodule, which sets up Cloud Build and Cloud Source Repositories for each of the stages below.
A simple trigger mechanism is configured, which runs a `terraform plan` for any non master branch and `terraform apply` when changes are merged to the master branch.
Usage instructions are available in the bootstrap [README](./0-bootstrap/README.md).

### [1. org](./1-org/)

The purpose of this stage is to set up the common folder used to house projects which contain shared resources such as DNS Hub, Interconnect, SCC Notification, org level secrets and org level logging.
This will create the following folder & project structure:

```
example-organization
└── common
    ├── prj-p-org-audit-logs
    ├── prj-p-org-billing-logs
    ├── prj-p-org-dns-hub
    ├── prj-p-org-interconnect
    ├── prj-p-org-scc
    └── prj-p-org-secrets
```

#### Logs

Under the common folder, two projects are created. One for organization wide audit logs and another for billing logs.
In both cases the logs are collected into BigQuery datasets which can then be used general querying, dashboarding & reporting.
For the various audit log types being captured in BigQuery, this is mirroring the standard [retention periods](https://cloud.google.com/logging/quotas#logs_retention_periods) for Cloud Logging, these settings can be adjusted according to your requirements.

For billing data, a BigQuery dataset is created with permissions attached however you will need to configure a billing export [manually](https://cloud.google.com/billing/docs/how-to/export-data-bigquery) as there is no easy way to automate this currently.

#### DNS Hub

Under the common folder, one project is created. This project will host the DNS Hub for the organization.

#### Interconnect

Under the common folder, one project is created. This project will host the Interconnect infrastructure for the organization.

#### SCC Notification

Under the common folder, one project is created. This project will host the SCC Notification infra structure at organization level.
This project will contain a Pub/Sub topic and subscription, a SCC Notification configured to send all new Findings to the topic created.


#### Secrets

Under the common folder, one project is created. This project will host the Secret Manager for secrets shared by the organization.

Usage instructions are available for the org step in the [README](./1-org/README.md).

### [2. environments](./2-environments/)

The purpose of this stage is to set up the environments folders used to house projects which contain monitoring, secrets, networking projects.
This will create the following folder & project structure:

```
example-organization
└── dev
    ├── prj-d-monitoring
    ├── prj-d-secrets
    ├── prj-d-shared-base
    └── prj-d-shared-restricted
└── nonprod
    ├── prj-n-monitoring
    ├── prj-n-secrets
    ├── prj-n-shared-base
    └── prj-n-shared-restricted
└── prod
    ├── prj-p-monitoring
    ├── prj-p-secrets
    ├── prj-p-shared-base
    └── prj-p-shared-restricted
```

#### Monitoring

Under the environment folder, a project is created per environment (dev, prod & nonprod) which is intended to be used as a [Cloud Monitoring workspace](https://cloud.google.com/monitoring/workspaces) for all projects in that environment.
Please note that creating the [workspace and linking projects](https://cloud.google.com/monitoring/workspaces/create) can currently only be completed through the Cloud Console.
If you have strong IAM requirements for these monitoring workspaces, it is worth considering creating these at a more granular level such as per business unit or per application.

#### Networking

Under the environment folder, a project is created per environment (dev, prod & nonprod) which is intended to be used as a [Shared VPC Host project](https://cloud.google.com/vpc/docs/shared-vpc) for all projects in that environment.
This stage only creates the projects and enables the correct APIs, the following networks stage creates the actual Shared VPC networks.

#### Secrets

Under the environment folder, one project is created. This project will host the Secret Manager for secrets shared by the environment.

Usage instructions are available for the org step in the [README](./2-environments/README.md).

### [3. networks](./3-networks/)

This step focuses on creating a Shared VPC per environment (dev, prod & nonprod) in a standard configuration with a reasonable security baseline. Currently this includes:

- Optional - Example subnets for dev, prod & non-prod inclusive of secondary ranges for those that want to use GKE.
- Optional - Default firewall rules created to allow remote access to VMs through IAP, without needing public IPs.
    - `allow-iap-ssh` and `allow-iap-rdp` network tags respectively
- Optional - Default firewall rule created to allow for load balancing using `allow-lb` tag.
- [Private service networking](https://cloud.google.com/vpc/docs/configure-private-services-access) configured to enable private Cloud SQL and Memorystore.
- [private.googleapis.com](https://cloud.google.com/vpc/docs/configure-private-google-access#private-domains) configured for private access to googleapis.com and gcr.io. Route added for VIP so no internet access is required to access APIs.
- [Restricted service networking](https://cloud.google.com/vpc-service-controls/docs/restricted-vip-services) configured to enable restricted Cloud SQL and Memorystore.
- [restricted.googleapis.com](https://cloud.google.com/vpc-service-controls/docs/supported-products) configured for restricted access to googleapis.com and gcr.io. Route added for VIP so no internet access is required to access APIs.
- Default routes to internet removed, with tag based route `egress-internet` required on VMs in order to reach the internet.
- Optional - Cloud NAT configured for all subnets with logging and static outbound IPs.
- Default Cloud DNS policy applied, with DNS logging and [inbound query forwarding](https://cloud.google.com/dns/docs/overview#dns-server-policy-in) turned on.

Usage instructions are available for the network step in the [README](./3-networks/README.md).

### [4. projects](./4-projects/)

This step, is focused on creating service projects in a standard configuration that are attached to the Shared VPC created in the previous step.
Running this code as-is should generate a structure as shown below:

```
example-organization/
└── dev
    ├── prj-bu1-d-sample-floating
    ├── prj-bu1-d-sample-private
    ├── prj-bu1-d-sample-restrict
    ├── prj-bu2-d-sample-floating
    ├── prj-bu2-d-sample-private
    └── prj-bu2-d-sample-restrict
└── nonprod
    ├── prj-bu1-d-sample-floating
    ├── prj-bu1-d-sample-private
    ├── prj-bu1-d-sample-restrict
    ├── prj-bu2-d-sample-floating
    ├── prj-bu2-d-sample-private
    └── prj-bu2-d-sample-restrict
└── prod
    ├── prj-bu1-d-sample-floating
    ├── prj-bu1-d-sample-private
    ├── prj-bu1-d-sample-restrict
    ├── prj-bu2-d-sample-floating
    ├── prj-bu2-d-sample-private
    └── prj-bu2-d-sample-restrict
```
The code in this step includes two options for creating projects.
The first is the standard projects module which creates a project per environment and the second creates a standalone project for one environment.
If relevant for your use case, there are also two optional submodules which can be used to create a subnet per project and a dedicated private DNS zone per project.

Usage instructions are available for the network step in the [README](./4-projects/README.md).

### Final View

Once all steps above have been executed your GCP organization should represent the structure shown below, with projects being the lowest nodes in the tree.

```
example-organization
└── common
    ├── prj-p-org-audit-logs
    ├── prj-p-org-billing-logs
    ├── prj-p-org-dns-hub
    ├── prj-p-org-interconnect
    ├── prj-p-org-scc
    └── prj-p-org-secrets
└── dev
    ├── prj-bu1-d-sample-floating
    ├── prj-bu1-d-sample-private
    ├── prj-bu1-d-sample-restrict
    ├── prj-bu2-d-sample-floating
    ├── prj-bu2-d-sample-private
    ├── prj-bu2-d-sample-restrict
    ├── prj-d-monitoring
    ├── prj-d-secrets
    ├── prj-d-shared-base
    └── prj-d-shared-restricted
└── nonprod
    ├── prj-bu1-d-sample-floating
    ├── prj-bu1-d-sample-private
    ├── prj-bu1-d-sample-restrict
    ├── prj-bu2-d-sample-floating
    ├── prj-bu2-d-sample-private
    ├── prj-bu2-d-sample-restrict
    ├── prj-n-monitoring
    ├── prj-n-secrets
    ├── prj-n-shared-base
    └── prj-n-shared-restricted
└── prod
    ├── prj-bu1-d-sample-floating
    ├── prj-bu1-d-sample-private
    ├── prj-bu1-d-sample-restrict
    ├── prj-bu2-d-sample-floating
    ├── prj-bu2-d-sample-private
    ├── prj-bu2-d-sample-restrict
    ├── prj-p-monitoring
    ├── prj-p-secrets
    ├── prj-p-shared-base
    └── prj-p-shared-restricted
└── seed
    ├── cft-cloudbuild
    └── cft-seed
```

## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for
information on contributing to this module.
