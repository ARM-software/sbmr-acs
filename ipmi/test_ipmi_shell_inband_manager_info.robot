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

Documentation    Module to test IPMI Inband Manager Info functionality.
Resource         ../lib/ipmi_shell_client.robot


*** Test Cases ***

Test Host IPMI Inband Get Manager Info
    [Documentation]  Verify IPMI Inband Get Manager Info on Host
    [Tags]  M1_OOB_1_IPMI_6_IB_Get_Manager_Info  M2_OOB_2_IPMI_6_IB_Get_Manager_Info
    ...     M21_IPMI_1_IB_Get_Manager_Info

    ${ipmi_output}=  Run Shell Inband IPMI Standard Command  mc info
    Log  ${ipmi_output}

    Sleep  ${IPMI_DELAY}

    ${ipmi_output}=  Run Shell Inband IPMI Standard Command  mc guid
    Log  ${ipmi_output}

    Sleep  ${IPMI_DELAY}

