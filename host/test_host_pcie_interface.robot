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

Documentation    Module to test Host PCIe Interface Availability.
Library          ../lib/gen_cmd.py
Library          ../lib/utils.py
Library          String
Library          Collections


*** Variables ***
${LSPCI}=  lspci


*** Test Cases ***

Test Host PCIe Interface Availability
    [Documentation]  Test Host PCIe Interface Availability
    [Tags]  M21_PCI_1_Interface_Availability


    # Get VGA compatible controller List
    ${cmd}=  Catenate  ${LSPCI} | grep "VGA compatible controller"
    ${rc}  ${stdout}  ${stderr}=  Shell Cmd  ${cmd}
    ...  return_stderr=True

    Log  ${stdout}

    Should Be Empty  ${stderr}  msg=${stdout}


    # Get Subsystem name for each VGA compatible controller
    @{controller_list}=  Split To Lines  ${stdout}
    @{pci_slots}=  Create List

    FOR  ${controller}  IN  @{controller_list}
      @{pci_slot}=  Split String  ${controller}

      ${cmd}=  Catenate  lspci -vvv -s ${pci_slot}[0] | grep Subsystem
      ${rc}  ${stdout}=  Shell Cmd  ${cmd}

      ${stdout}=  Remove Whitespace  ${stdout}
      Append To List  ${pci_slots}  ${stdout}
    END


    # Check if any subsystem is in available list
    ${result}=  Validate Supported Vga Controller  ${pci_slots}
    Should Be Equal  ${True}  ${result}
