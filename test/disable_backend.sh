#!/usr/bin/env bash

# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

function org(){
    # disable backend configs in main module
    mv 1-org/envs/shared/backend.tf 1-org/envs/shared/backend.tf.disabled
}

function environments(){
    # disable backend configs in main module
    mv 2-environments/envs/development/backend.tf 2-environments/envs/development/backend.tf.disabled
    mv 2-environments/envs/non-production/backend.tf  2-environments/envs/non-production/backend.tf.disabled
    mv 2-environments/envs/production/backend.tf  2-environments/envs/production/backend.tf.disabled
}

function network(){
    # disable backend configs in main module
    mv 3-networks/envs/development/backend.tf 3-networks/envs/development/backend.tf.disabled
    mv 3-networks/envs/non-production/backend.tf  3-networks/envs/non-production/backend.tf.disabled
    mv 3-networks/envs/production/backend.tf  3-networks/envs/production/backend.tf.disabled
    mv 3-networks/envs/shared/backend.tf  3-networks/envs/shared/backend.tf.disabled
}

function projects(){
    # disable backend configs in main module
    mv 4-projects/business_unit_1/development/backend.tf 4-projects/business_unit_1/development/backend.tf.disabled
    mv 4-projects/business_unit_1/non-production/backend.tf  4-projects/business_unit_1/non-production/backend.tf.disabled
    mv 4-projects/business_unit_1/production/backend.tf 4-projects/business_unit_1/production/backend.tf.disabled
    mv 4-projects/business_unit_1/shared/backend.tf  4-projects/business_unit_1/shared/backend.tf.disabled
    mv 4-projects/business_unit_2/development/backend.tf 4-projects/business_unit_2/development/backend.tf.disabled
    mv 4-projects/business_unit_2/non-production/backend.tf  4-projects/business_unit_2/non-production/backend.tf.disabled
    mv 4-projects/business_unit_2/production/backend.tf 4-projects/business_unit_2/production/backend.tf.disabled
    mv 4-projects/business_unit_2/shared/backend.tf  4-projects/business_unit_2/shared/backend.tf.disabled
}

function appinfra(){
    # disable backend configs in main module
    mv 5-app-infra/business_unit_1/development/backend.tf 5-app-infra/business_unit_1/development/backend.tf.disabled
    mv 5-app-infra/business_unit_1/non-production/backend.tf  5-app-infra/business_unit_1/non-production/backend.tf.disabled
    mv 5-app-infra/business_unit_1/production/backend.tf  5-app-infra/business_unit_1/production/backend.tf.disabled
}


# parse args
for arg in "$@"
do
  case $arg in
    -n|--network)
      network
      shift
      ;;
    -o|--org)
      org
      shift
      ;;
    -e|--environments)
      environments
      shift
      ;;
    -a|--appinfra)
      appinfra
      shift
      ;;
    -p|--projects)
      projects
      shift
      ;;
      *) # end argument parsing
      shift
      ;;
  esac
done
