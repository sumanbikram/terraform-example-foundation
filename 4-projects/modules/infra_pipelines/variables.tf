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

variable "impersonate_service_account" {
  description = "Service account email of the account to impersonate to run gcloud build submit"
  type        = string
}

variable "cloudbuild_sa" {
  description = "Service Account email to be granted permissions for running cloud build."
  type        = string
  default     = ""
}

variable "cloudbuild_sa_id" {
  description = "Service Account ID to be used by the CloudBuild trigger."
  type        = string
  default     = ""
}

variable "default_region" {
  description = "Default region to create resources where applicable."
  type        = string
}

variable "gar_repo_name" {
  description = "Custom name to use for GAR repo."
  default     = ""
  type        = string
}

variable "project_prefix" {
  description = "Name prefix to use for projects created."
  type        = string
  default     = "prj"
}

variable "cloudbuild_project_id" {
  description = "The project id where the pipelines and repos should be created"
  type        = string
}

variable "billing_account" {
  description = "The ID of the billing account to associated this project with"
  type        = string
}

variable "app_infra_repos" {
  description = "A list of Cloud Source Repos to be created to hold app infra Terraform configs"
  type        = list(string)
}

variable "bucket_region" {
  description = "Region to create GCS buckets for tfstate and Cloud Build artifacts"
  type        = string
  default     = "us-central1"
}

variable "terraform_apply_branches" {
  description = "List of git branches configured to run terraform apply Cloud Build trigger. All other branches will run plan by default."
  type        = list(string)

  default = ["development",
    "non-production",
  "production"]
}

variable "cloudbuild_plan_filename" {
  description = "Path and name of Cloud Build YAML definition used for terraform plan."
  type        = string
  default     = "cloudbuild-tf-plan.yaml"
}

variable "cloudbuild_apply_filename" {
  description = "Path and name of Cloud Build YAML definition used for terraform apply."
  type        = string
  default     = "cloudbuild-tf-apply.yaml"
}

variable "terraform_version" {
  description = "Default terraform version."
  type        = string
  default     = "1.0.0"
}

variable "terraform_version_sha256sum" {
  description = "sha256sum for default terraform version."
  type        = string
  default     = "8be33cc3be8089019d95eb8f546f35d41926e7c1e5deff15792e969dde573eb5"
}

variable "gcloud_version" {
  description = "Default gcloud image version."
  type        = string
  default     = "393.0.0-slim"
}

variable "folders_to_grant_browser_role" {
  description = "List of folders to grant browser role to the cloud build service account. Used by terraform validator to able to load IAM policies."
  type        = list(string)
  default     = []
}
