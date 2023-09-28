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

Documentation    Module to test Redfish Host Service Root
Resource        ../../lib/resource.robot
Resource        ../../lib/bmc_redfish_resource.robot

Library         String
Library         ../../lib/var_funcs.py
Library         ../../lib/gen_cmd.py
Library         ../../lib/gen_print.py

*** Test Cases ***

Test Host Redfish Host Service Root
    [Documentation]  Verify Redfish Host Interface Service Root
    [Tags]  M2_IB_1_Redfish_HI_Service_Root

    ${resp}=  Redfish.Get Properties  /redfish/v1

    Should Not Be Empty  ${resp['RedfishVersion']}
    Log  ${resp['RedfishVersion']}
