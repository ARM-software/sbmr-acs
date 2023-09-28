# Copyright (c) 2023, Arm Limited or its affiliates. All rights reserved.
# SPDX-License-Identifier : Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

*** Settings ***
Documentation   BMC redfish resource keyword.

Resource        resource.robot
Resource        rest_response_code.robot
Library         bmc_redfish.py  https://${BMC_HOST}:${HTTPS_PORT}  ${BMC_USERNAME}
...             ${BMC_PASSWORD}  WITH NAME  Redfish
Library         bmc_redfish_utils.py  WITH NAME  redfish_utils
Library         disable_warning_urllib.py

*** Keywords ***
