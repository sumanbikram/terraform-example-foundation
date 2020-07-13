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

/******************************************
  DNS Hub Project
*****************************************/

data "google_projects" "dns_hub" {
  filter = "labels.application_name=prj-dns-hub"
}

data "google_compute_network" "vpc_dns_hub" {
  name    = "vpc-dns-hub"
  project = data.google_projects.dns_hub.projects[0].project_id
}

/******************************************
  Default DNS Policy
 *****************************************/

resource "google_dns_policy" "default_policy" {
  project                   = var.project_id
  name                      = "dp-${var.environment_code}-shared-private-default-policy"
  enable_inbound_forwarding = var.dns_enable_inbound_forwarding
  enable_logging            = var.dns_enable_logging
  networks {
    network_url = module.main.network_self_link
  }
}

/******************************************
  Private Google APIs DNS Zone & records.
 *****************************************/

module "private_googleapis" {
  source      = "terraform-google-modules/cloud-dns/google"
  version     = "~> 3.0"
  project_id  = var.project_id
  type        = "private"
  name        = "dz-${var.environment_code}-shared-private-apis"
  domain      = "googleapis.com."
  description = "Private DNS zone to configure private.googleapis.com"

  private_visibility_config_networks = [
    module.main.network_self_link
  ]

  recordsets = [
    {
      name    = "*"
      type    = "CNAME"
      ttl     = 300
      records = ["private.googleapis.com."]
    },
    {
      name    = "private"
      type    = "A"
      ttl     = 300
      records = ["199.36.153.8", "199.36.153.9", "199.36.153.10", "199.36.153.11"]
    },
  ]
}

/******************************************
  Private GCR DNS Zone & records.
 *****************************************/

module "private_gcr" {
  source      = "terraform-google-modules/cloud-dns/google"
  version     = "~> 3.0"
  project_id  = var.project_id
  type        = "private"
  name        = "dz-${var.environment_code}-shared-private-gcr"
  domain      = "gcr.io."
  description = "Private DNS zone to configure gcr.io"

  private_visibility_config_networks = [
    module.main.network_self_link
  ]

  recordsets = [
    {
      name    = "*"
      type    = "CNAME"
      ttl     = 300
      records = ["gcr.io."]
    },
    {
      name    = ""
      type    = "A"
      ttl     = 300
      records = ["199.36.153.8", "199.36.153.9", "199.36.153.10", "199.36.153.11"]
    },
  ]
}

/******************************************
 Creates DNS Peering to DNS HUB
*****************************************/
module "peering_zone" {
  source      = "terraform-google-modules/cloud-dns/google"
  version     = "~> 3.0"
  project_id  = var.project_id
  type        = "peering"
  name        = "pz_to_dns_hub"
  domain      = var.domain
  description = "Private DNS peering zone."

  private_visibility_config_networks = [
    module.main.network_self_link
  ]
  target_network = data.google_compute_network.vpc_dns_hub.self_link
}
