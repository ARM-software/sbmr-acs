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

Documentation    Module to test IPMI Power Control functionality.
Resource         ../lib/ipmi_client.robot
Resource         ../lib/boot_utils.robot
Library          ../lib/ipmi_utils.py

Suite Setup      Suite Setup Execution
Suite Teardown   Suite Teardown Execution


*** Test Cases ***

Test IPMI Out-of-band Power Control
    [Documentation]  Verify IPMI Out-of-band Power Control
    [Tags]  M1_OOB_1_IPMI_1_2_3_Power_Control  M2_OOB_2_IPMI_1_2_3_Power_Control
    ...     M21_IPMI_1_Power_Control

    IPMI Power Off
    ${ipmi_state}=  Get Host State Via External IPMI
    Valid Value  ipmi_state  ['off']

    IPMI Power On
    ${ipmi_state}=  Get Host State Via External IPMI
    Valid Value  ipmi_state  ['on']

    IPMI Power Cycle
    ${ipmi_state}=  Get Host State Via External IPMI
    Valid Value  ipmi_state  ['on']

    IPMI Power Reset
    ${ipmi_state}=  Get Host State Via External IPMI
    Valid Value  ipmi_state  ['on']

    # Wait until OS login prompt show up, then issue
    # IPMI power soft command
    IPMI Power Off  stack_mode=skip

    # Start monitoring boot log
    Initiate Host Boot Via External IPMI  wait=${0}
    Capture System Log Via SOL  ${SOL_TYPE}  ${SOL_LOGIN_OUTPUT}

    # Issuing Power Soft command
    IPMI Power Soft
    ${ipmi_state}=  Get Host State Via External IPMI
    Valid Value  ipmi_state  ['off']


*** Keywords ***

Suite Setup Execution
    [Documentation]  Do the post test setup.

    Run External IPMI Standard Command  chassis power off
    Sleep  10 sec

    Run External IPMI Standard Command  chassis bootdev none ${IPMI_OPTIONS_EFIBOOT}


Suite Teardown Execution
    [Documentation]  Do the post test teardown.

    Close SOL Connection  ${SOL_TYPE}
