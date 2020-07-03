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
  Shared VPC configuration
 *****************************************/

locals {
  vpc_type                   = "shared"
  vpc_label                  = "restricted"
  vpc_name                   = "${var.environment_code}-${local.vpc_type}-${local.vpc_label}"
  network_name               = "vpc-${local.vpc_name}"
  restricted_googleapis_cidr = "199.36.153.4/30"
}

module "main" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "~> 2.0"
  project_id                             = var.project_id
  network_name                           = local.network_name
  shared_vpc_host                        = "true"
  delete_default_internet_gateway_routes = "true"

  subnets          = var.subnets
  secondary_ranges = var.secondary_ranges

  routes = concat(
    [{
      name              = "rt-${local.vpc_name}-1000-all-default-restricted-api"
      description       = "Route through IGW to allow restricted google api access."
      destination_range = local.restricted_googleapis_cidr
      next_hop_internet = "true"
      priority          = "1000"
    }],
    var.nat_enabled ?
    [
      {
        name              = "rt-${local.vpc_name}-1000-egress-internet-default"
        description       = "Tag based route through IGW to access internet"
        destination_range = "0.0.0.0/0"
        tags              = "egress-internet"
        next_hop_internet = "true"
        priority          = "1000"
      },
      {
        name              = "rt-${local.vpc_name}-1000-all-default-windows-kms"
        description       = "Route through IGW to allow Windows KMS activation for GCP."
        destination_range = "35.190.247.13/32"
        next_hop_internet = "true"
        priority          = "1000"
      }
    ]
    : []
  )
}

/***************************************************************
  Configure Service Networking for Cloud SQL & future services.
 **************************************************************/

resource "google_compute_global_address" "private_service_access_address" {
  provider = google-beta

  name          = "ga-${local.vpc_name}-vpc-peering-internal"
  project       = var.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = element(split("/", var.private_service_cidr), 0)
  prefix_length = element(split("/", var.private_service_cidr), 1)
  network       = module.main.network_self_link
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider                = google-beta
  network                 = module.main.network_self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_service_access_address.name]
}

/************************************
  Router to advertise shared VPC
  subnetworks and Google Restricted API
************************************/

module "region1_router1" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 0.2.0"
  name    = "cr-${local.vpc_name}-${var.subnets[0].subnet_region}-cr1"
  project = var.project_id
  network = module.main.network_name
  region  = var.subnets[0].subnet_region
  bgp = {
    asn                  = var.bgp_asn_subnet
    advertised_groups    = ["ALL_SUBNETS"]
    advertised_ip_ranges = [{ range = local.restricted_googleapis_cidr }]
  }
}

module "region1_router2" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 0.2.0"
  name    = "cr-${local.vpc_name}-${var.subnets[0].subnet_region}-cr2"
  project = var.project_id
  network = module.main.network_name
  region  = var.subnets[0].subnet_region
  bgp = {
    asn                  = var.bgp_asn_subnet
    advertised_groups    = ["ALL_SUBNETS"]
    advertised_ip_ranges = [{ range = local.restricted_googleapis_cidr }]
  }
}

module "region2_router1" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 0.2.0"
  name    = "cr-${local.vpc_name}-${var.subnets[1].subnet_region}-cr1"
  project = var.project_id
  network = module.main.network_name
  region  = var.subnets[1].subnet_region
  bgp = {
    asn                  = var.bgp_asn_subnet
    advertised_groups    = ["ALL_SUBNETS"]
    advertised_ip_ranges = [{ range = local.restricted_googleapis_cidr }]
  }
}

module "region2_router2" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 0.2.0"
  name    = "cr-${local.vpc_name}-${var.subnets[1].subnet_region}-cr2"
  project = var.project_id
  network = module.main.network_name
  region  = var.subnets[1].subnet_region
  bgp = {
    asn                  = var.bgp_asn_subnet
    advertised_groups    = ["ALL_SUBNETS"]
    advertised_ip_ranges = [{ range = local.restricted_googleapis_cidr }]
  }
}
