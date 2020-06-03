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

locals {
  parent = var.parent_folder != "" ? "folders/${var.parent_folder}" : "organizations/${var.org_id}"
}

/******************************************
  Top level folders
 *****************************************/

resource "google_folder" "common" {
  display_name = "common"
  parent       = local.parent
}

/******************************************
  Common sub-folders
 *****************************************/

resource "google_folder" "logs" {
  display_name = "logs"
  parent       = google_folder.common.id
}

resource "google_folder" "monitoring" {
  display_name = "monitoring"
  parent       = google_folder.common.id
}

resource "google_folder" "networking" {
  display_name = "networking"
  parent       = google_folder.common.id
}

