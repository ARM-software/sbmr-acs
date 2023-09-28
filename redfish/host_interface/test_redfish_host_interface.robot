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

Documentation    Module to test Redfish Host Interface.
Resource        ../../lib/resource.robot

Library         String
Library         ../../lib/var_funcs.py
Library         ../../lib/gen_cmd.py
Library         ../../lib/gen_print.py

*** Variables ***
${REDFISH_FINDER_CMD}=    python /usr/bin/redfish-finder
${DMIDECODE_CMD_42}=   dmidecode -t 42


*** Test Cases ***

Test Host Redfish Host Interface Functionality
    [Documentation]  Verify Redfish Host Interface Functionality on Host
    [Tags]  M2_IB_1_Redfish_HI_Functionality

    ${rc}  ${stdout}  ${stderr}=  Shell Cmd  ${REDFISH_FINDER_CMD}
    ...  return_stderr=True

    Log  ${stdout}

    Should Be Equal  ${rc}  ${0}  msg=Failure: redfish-finder failed
    Should Be Empty  ${stderr}  msg=${stdout}


Test Host Redfish Host Interface Type
    [Documentation]  Verify Redfish Host Interface Type on Host
    [Tags]  M2_IB_1_Redfish_HI_Type  M4_IB_1_Redfish_HI_Type

    ${rc}  ${stdout}  ${stderr}=  Shell Cmd  ${DMIDECODE_CMD_42}
    ...  return_stderr=True

    Should Be Empty  ${stderr}  msg=${stdout}

    Log  ${stdout}

    ${device_rsp}=  Get Lines Containing String  ${stdout}  Device Type
    ${protocol_rsp}=  Get Lines Containing String  ${stdout}  Protocol ID

    Should Contain Any  ${device_rsp}  USB  PCI/PCIe
    ...  msg=Failure: Device Type Not Match With USB or PCI/PCIe
    Should Contain  ${protocol_rsp}  Redfish over IP
    ...  msg=Failure: Not Redfish Over IP Protocol

