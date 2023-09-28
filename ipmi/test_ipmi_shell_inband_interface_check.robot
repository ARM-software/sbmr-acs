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

Documentation    Module to test IPMI Inband Interface Functionality.
Resource         ../lib/ipmi_shell_client.robot
Library          ../lib/gen_robot_print.py

Test Teardown    Sleep  ${IPMI_DELAY}

*** Variables ***
${DMIDECODE_CMD_38}=    dmidecode -t 38


*** Test Cases ***

Test Host IPMI Inband Interface Functionality
    [Documentation]  Verify IPMI Inband Interface Functionality on Host
    [Tags]  M1_IB_1_IPMI_SSIF_Functionality  M2_IB_2_IPMI_SSIF_Functionality

    ${rc}  ${stdout}  ${stderr}=  Shell Cmd  ${DMIDECODE_CMD_38}  return_stderr=True

    Should Be Empty  ${stderr}  msg=${stdout}

    Log  ${stdout}

    ${ipmi_type}=  Get Lines Containing String  ${stdout}  Interface Type
    Should Contain  ${ipmi_type}  SSIF  msg=Failure: Host SoC In-band Interface Not SSIF


Test Host IPMI Inband Interface Interrupt
    [Documentation]  Verify IPMI Inband Interface Interrupt on Host
    [Tags]  M21_IB_2_IPMI_SSIF_Interrupt

    ${rc}  ${stdout}  ${stderr}=  Shell Cmd  ${DMIDECODE_CMD_38}  return_stderr=True

    Should Be Empty  ${stderr}  msg=${stdout}

    Log  ${stdout}

    ${dmi_output}=  Get Lines Containing String  ${stdout}  Interrupt Number
    Should Not Be Empty  ${dmi_output}  msg=Failure: SSIF SMBAlert Not Found

    ${msg}=  Split String  ${dmi_output}  :
    ${interrupt_num}=  Convert To Integer  ${msg}[1]

    Should Not Be Equal As Integers  ${interrupt_num}  0


Test Host IPMI Inband Interface Capability
    [Documentation]  Verify IPMI Inband SSIF Interface Capability
    [Tags]  M21_IB_1_IPMI_SSIF_Capability

    ${output}=  Get System Interface Capabilities

    Log  ${output}

    Should Contain  ${output["transaction_type"]}
    ...    Multi-part supported. Start, Middle and End supported
    ...    msg=Failure: SSIF Single And Multi-part Transactions Not Detect
