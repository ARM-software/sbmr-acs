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

Documentation    Module to test IPMI Boot Device Select functionality.
Resource         ../lib/ipmi_client.robot
Library          ../lib/gen_robot_print.py

Suite Setup      Suite Setup Execution
Suite Teardown   Suite Teardown Execution


*** Variables ***

&{boot_resp}=  none=No override  pxe=PXE  disk=Hard-Drive  safe=Safe-Mode
...            diag=Diagnostic  cdrom=CD/DVD  bios=BIOS  floppy=Floppy


*** Test Cases ***

Test IPMI Out-of-Band Boot Device Selection
    [Documentation]  Verify IPMI Out-of-band Boot Device Selection
    [Tags]  M1_OOB_1_IPMI_4_5_Boot_Device  M2_OOB_2_IPMI_4_5_Boot_Device
    ...     M21_IPMI_1_Boot_Device
    [Template]  Check Boot Device Selection Via IPMI

    # boot_device
    none
    pxe
    disk
    bios


*** Keywords ***

Check Boot Device Selection Via IPMI
    [Documentation]  Set Boot Device via IPMI and verify status
    [Arguments]  ${boot_device}

    Run External IPMI Standard Command  chassis bootdev ${boot_device} ${IPMI_OPTIONS_EFIBOOT}

    ${resp}=  Run IPMI Standard Command  chassis bootparam get 5
    ${boot_status}=  Get Lines Containing String  ${resp}  Boot Device Selector
    Should Contain  ${boot_status}  ${boot_resp}[${boot_device}]


Suite Setup Execution
    [documentation]  Do suite setup tasks.

    Run External IPMI Standard Command  chassis power off
    Sleep  10 sec


Suite Teardown Execution
    [Documentation]  Do the post suite teardown

    Check Boot Device Selection Via IPMI  none
