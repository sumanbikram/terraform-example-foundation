/**
 * Copyright 2020 Google LLC
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

provider "google" {
  version = "~> 3.12.0"
}

provider "google-beta" {
  version = "~> 3.12.0"
}

provider "null" {
  version = "~> 2.1"
}

provider "random" {
  version = "~> 2.2"
}

/*************************************************
  Bootstrap GCP Organization.
*************************************************/
locals {
  parent = var.parent_folder != "" ? "folders/${var.parent_folder}" : "organizations/${var.org_id}"
}

resource "google_folder" "seed" {
  display_name = "seed"
  parent       = local.parent
}

module "seed_bootstrap" {
  source                  = "terraform-google-modules/bootstrap/google"
  version                 = "~> 1.0"
  org_id                  = var.org_id
  folder_id               = google_folder.seed.id
  billing_account         = var.billing_account
  group_org_admins        = var.group_org_admins
  group_billing_admins    = var.group_billing_admins
  default_region          = var.default_region
  sa_enable_impersonation = true
}

// Choose between cloudbuild_bootstrap and jenkins_bootstrap by commenting / deleting the module you do not want to use
// If you want to use the cloudbuild_bootstrap module, un-comment it and delete / comment the Jenkins_bootstrap module
//module "cloudbuild_bootstrap" {
//  source                  = "terraform-google-modules/bootstrap/google//modules/cloudbuild"
//  version                 = "~> 1.0"
//  org_id                  = var.org_id
//  folder_id               = google_folder.seed.id
//  billing_account         = var.billing_account
//  group_org_admins        = var.group_org_admins
//  default_region          = var.default_region
//  terraform_sa_email      = module.seed_bootstrap.terraform_sa_email
//  terraform_sa_name       = module.seed_bootstrap.terraform_sa_name
//  terraform_state_bucket  = module.seed_bootstrap.gcs_bucket_tfstate
//  sa_enable_impersonation = true
//}


module "jenkins_bootstrap" {
  source                      = "./modules/jenkins"
  org_id                      = var.org_id
  folder_id                   = google_folder.seed.id
  billing_account             = var.billing_account
  default_region              = var.default_region
  jenkins_sa_email            = var.jenkins_sa_email
  jenkins_master_ip_addresses = var.jenkins_master_ip_addresses
}

module "jenkins_bootstrap" {
  source                  = "./modules/jenkins"
  org_id                  = var.org_id
  folder_id               = google_folder.seed.id
  billing_account         = var.billing_account
  group_org_admins        = var.group_org_admins
  default_region          = var.default_region
  terraform_sa_email      = module.seed_bootstrap.terraform_sa_email
  terraform_sa_name       = module.seed_bootstrap.terraform_sa_name
  terraform_state_bucket  = module.seed_bootstrap.gcs_bucket_tfstate
  sa_enable_impersonation = true
}

module "jenkins_bootstrap" {
  source                  = "./modules/jenkins"
  org_id                  = var.org_id
  folder_id               = google_folder.seed.id
  billing_account         = var.billing_account
  group_org_admins        = var.group_org_admins
  default_region          = var.default_region
  terraform_sa_email      = module.seed_bootstrap.terraform_sa_email
  terraform_sa_name       = module.seed_bootstrap.terraform_sa_name
  terraform_state_bucket  = module.seed_bootstrap.gcs_bucket_tfstate
  sa_enable_impersonation = true
}
