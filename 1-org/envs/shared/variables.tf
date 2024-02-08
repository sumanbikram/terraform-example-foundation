/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "enable_hub_and_spoke" {
  description = "Enable Hub-and-Spoke architecture."
  type        = bool
  default     = false
}

variable "billing_data_users" {
  description = "Google Workspace or Cloud Identity group that have access to billing data set."
  type        = string
}

variable "audit_data_users" {
  description = "Google Workspace or Cloud Identity group that have access to audit logs."
  type        = string
}

variable "domains_to_allow" {
  description = "The list of domains to allow users from in IAM. Used by Domain Restricted Sharing Organization Policy. Must include the domain of the organization you are deploying the foundation. To add other domains you must also grant access to these domains to the Terraform Service Account used in the deploy."
  type        = list(string)
}

variable "scc_notification_name" {
  description = "Name of the Security Command Center Notification. It must be unique in the organization. Run `gcloud scc notifications describe <scc_notification_name> --organization=org_id` to check if it already exists."
  type        = string
}

variable "create_access_context_manager_access_policy" {
  description = "Whether to create access context manager access policy."
  type        = bool
  default     = true
}

variable "scc_notification_filter" {
  description = "Filter used to create the Security Command Center Notification, you can see more details on how to create filters in https://cloud.google.com/security-command-center/docs/how-to-api-filter-notifications#create-filter"
  type        = string
  default     = "state = \"ACTIVE\""
}

variable "enforce_allowed_worker_pools" {
  description = "Whether to enforce the organization policy restriction on allowed worker pools for Cloud Build."
  type        = bool
  default     = false
}

variable "data_access_logs_enabled" {
  description = "Enable Data Access logs of types DATA_READ, DATA_WRITE for all GCP services. Enabling Data Access logs might result in your organization being charged for the additional logs usage. See https://cloud.google.com/logging/docs/audit#data-access The ADMIN_READ logs are enabled by default."
  type        = bool
  default     = false
}

variable "log_export_storage_location" {
  description = "The location of the storage bucket used to export logs."
  type        = string
  default     = "US"
}

variable "billing_export_dataset_location" {
  description = "The location of the dataset for billing data export."
  type        = string
  default     = "US"
}

variable "log_export_storage_force_destroy" {
  description = "(Optional) If set to true, delete all contents when destroying the resource; otherwise, destroying the resource will fail if contents are present."
  type        = bool
  default     = false
}

variable "log_export_storage_versioning" {
  description = "(Optional) Toggles bucket versioning, ability to retain a non-current object version when the live object version gets replaced or deleted."
  type        = bool
  default     = false
}

variable "log_export_storage_retention_policy" {
  description = "Configuration of the bucket's data retention policy for how long objects in the bucket should be retained."
  type = object({
    is_locked             = bool
    retention_period_days = number
  })
  default = null
}

variable "vpc" {
  description = "The type of VPC to attach the project to. Possible options are base or restricted."
  type        = string
  default     = "none"

  validation {
    condition     = var.vpc == "base" || var.vpc == "restricted" || var.vpc == "none"
    error_message = "For vpc only `base`, `restricted`, and `none` are valid."
  }
}

variable "project_budget" {
  description = <<EOT
  Budget configuration for projects.
  budget_amount: The amount to use as the budget.
  alert_spent_percents: A list of percentages of the budget to alert on when threshold is exceeded.
  alert_pubsub_topic: The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}`.
  alert_spend_basis: The type of basis used to determine if spend has passed the threshold. Possible choices are `CURRENT_SPEND` or `FORECASTED_SPEND` (default).
  EOT
  type = object({
    dns_hub_budget_amount                       = optional(number, 1000)
    dns_hub_alert_spent_percents                = optional(list(number), [1.2])
    dns_hub_alert_pubsub_topic                  = optional(string, null)
    dns_hub_budget_alert_spend_basis            = optional(string, "FORECASTED_SPEND")
    base_net_hub_budget_amount                  = optional(number, 1000)
    base_net_hub_alert_spent_percents           = optional(list(number), [1.2])
    base_net_hub_alert_pubsub_topic             = optional(string, null)
    base_net_hub_budget_alert_spend_basis       = optional(string, "FORECASTED_SPEND")
    base_network_budget_amount                  = optional(number, 1000)
    base_network_alert_spent_percents           = optional(list(number), [1.2])
    base_network_alert_pubsub_topic             = optional(string, null)
    base_network_budget_alert_spend_basis       = optional(string, "FORECASTED_SPEND")
    restricted_net_hub_budget_amount            = optional(number, 1000)
    restricted_net_hub_alert_spent_percents     = optional(list(number), [1.2])
    restricted_net_hub_alert_pubsub_topic       = optional(string, null)
    restricted_net_hub_budget_alert_spend_basis = optional(string, "FORECASTED_SPEND")
    restricted_network_budget_amount            = optional(number, 1000)
    restricted_network_alert_spent_percents     = optional(list(number), [1.2])
    restricted_network_alert_pubsub_topic       = optional(string, null)
    restricted_network_budget_alert_spend_basis = optional(string, "FORECASTED_SPEND")
    interconnect_budget_amount                  = optional(number, 1000)
    interconnect_alert_spent_percents           = optional(list(number), [1.2])
    interconnect_alert_pubsub_topic             = optional(string, null)
    interconnect_budget_alert_spend_basis       = optional(string, "FORECASTED_SPEND")
    org_secrets_budget_amount                   = optional(number, 1000)
    org_secrets_alert_spent_percents            = optional(list(number), [1.2])
    org_secrets_alert_pubsub_topic              = optional(string, null)
    org_secrets_budget_alert_spend_basis        = optional(string, "FORECASTED_SPEND")
    org_billing_logs_budget_amount              = optional(number, 1000)
    org_billing_logs_alert_spent_percents       = optional(list(number), [1.2])
    org_billing_logs_alert_pubsub_topic         = optional(string, null)
    org_billing_logs_budget_alert_spend_basis   = optional(string, "FORECASTED_SPEND")
    org_audit_logs_budget_amount                = optional(number, 1000)
    org_audit_logs_alert_spent_percents         = optional(list(number), [1.2])
    org_audit_logs_alert_pubsub_topic           = optional(string, null)
    org_audit_logs_budget_alert_spend_basis     = optional(string, "FORECASTED_SPEND")
    org_kms_budget_amount                       = optional(number, 1000)
    org_kms_alert_spent_percents                = optional(list(number), [1.2])
    org_kms_alert_pubsub_topic                  = optional(string, null)
    org_kms_budget_alert_spend_basis            = optional(string, "FORECASTED_SPEND")
    scc_notifications_budget_amount             = optional(number, 1000)
    scc_notifications_alert_spent_percents      = optional(list(number), [1.2])
    scc_notifications_alert_pubsub_topic        = optional(string, null)
    scc_notifications_budget_alert_spend_basis  = optional(string, "FORECASTED_SPEND")
  })
  default = {}
}

variable "gcp_groups" {
  description = <<EOT
  Groups to grant specific roles in the Organization.
  platform_viewer: Google Workspace or Cloud Identity group that have the ability to view resource information across the Google Cloud organization.
  security_reviewer: Google Workspace or Cloud Identity group that members are part of the security team responsible for reviewing cloud security
  network_viewer: Google Workspace or Cloud Identity group that members are part of the networking team and review network configurations.
  scc_admin: Google Workspace or Cloud Identity group that can administer Security Command Center.
  audit_viewer: Google Workspace or Cloud Identity group that members are part of an audit team and view audit logs in the logging project.
  global_secrets_admin: Google Workspace or Cloud Identity group that members are responsible for putting secrets into Secrets Manage
  EOT
  type = object({
    platform_viewer      = optional(string, null)
    security_reviewer    = optional(string, null)
    network_viewer       = optional(string, null)
    scc_admin            = optional(string, null)
    audit_viewer         = optional(string, null)
    global_secrets_admin = optional(string, null)
  })
  default = {}
}

variable "gcp_user" {
  description = <<EOT
  Users to grant specific roles in the Organization.
  org_admin: Identity that has organization administrator permissions.
  billing_creator: Identity that can create billing accounts.
  billing_admin: Identity that has billing administrator permissions.
  EOT
  type = object({
    org_admin       = optional(string, null)
    billing_creator = optional(string, null)
    billing_admin   = optional(string, null)
  })
  default = {}
}

variable "essential_contacts_language" {
  description = "Essential Contacts preferred language for notifications, as a ISO 639-1 language code. See [Supported languages](https://cloud.google.com/resource-manager/docs/managing-notification-contacts#supported-languages) for a list of supported languages."
  type        = string
  default     = "en"
}

variable "remote_state_bucket" {
  description = "Backend bucket to load Terraform Remote State Data from previous steps."
  type        = string
}

variable "essential_contacts_domains_to_allow" {
  description = "The list of domains that email addresses added to Essential Contacts can have."
  type        = list(string)
}

variable "create_unique_tag_key" {
  description = "Creates unique organization-wide tag keys by adding a random suffix to each key."
  type        = bool
  default     = false
}
variable "cai_monitoring_kms_force_destroy" {
  description = "If set to true, delete KMS keyring and keys when destroying the module; otherwise, destroying the module will fail if KMS keys are present."
  type        = bool
  default     = false
}

variable "tfc_org_name" {
  description = "Name of the TFC organization"
  type        = string
  default     = ""
}
