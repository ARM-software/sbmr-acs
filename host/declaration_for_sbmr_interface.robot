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

Documentation    Self declaration for SBMR interface support
Resource         ../lib/resource.robot
Test Template    Declaration Should Pass


*** Test Cases ***

Declaration For BMC M1_JTAG Interface Support
    [Documentation]  Declaration for BMC M1_JTAG interface support
    [Tags]  M1_JTAG_1_2_Interface_Declaration
    ${M1_JTAG_1_2_Interface_Declaration}    M1_JTAG_1_2


Declaration For BMC M2_JTAG Interface Support
    [Documentation]  Declaration for BMC M2_JTAG interface support
    [Tags]  M2_JTAG_1_2_Interface_Declaration
    ${M2_JTAG_1_2_Interface_Declaration}    M2_JTAG_1_2


Declaration For BMC M2_IO_1 NC-SI Interface Support
    [Documentation]  Declaration for BMC M2_IO_1 NS-CI interface support
    [Tags]  M2_IO_1_NCSI_Interface_Declaration
    ${M2_IO_1_NCSI_Interface_Declaration}    M2_IO_1


Declaration For BMC M2_RAS Functionality Support
    [Documentation]  Declaration for BMC M2_RAS functionality support
    [Tags]  M2_RAS_1_2_Function_Declaration
    ${M2_RAS_1_2_Function_Declaration}    M2_RAS_1_2

Declaration For BMC M3 Side-Band Interface Support
    [Documentation]  Declaration for BMC M3 Side-Band interface support (M3_SB_1 to M3_SB_9)
    [Tags]  M3_SB_1_9_Interface_Declaration
    ${M3_SB_1_9_Interface_Declaration}    M3_SB_1_9

Declaration For BMC M3_JTAG Interface Support
    [Documentation]  Declaration for BMC M3_JTAG interface support (M3_JTAG_1 to M3_JTAG_2)
    [Tags]  M3_JTAG_1_2_Interface_Declaration
    ${M3_JTAG_1_2_Interface_Declaration}    M3_JTAG_1_2

Declaration For BMC M3_IO Interface Support
    [Documentation]  Declaration for BMC M3_IO interface support (M3_IO_1 to M3_IO_2)
    [Tags]  M3_IO_1_2_Interface_Declaration
    ${M3_IO_1_2_Interface_Declaration}    M3_IO_1_2

Declaration For BMC M3_OOB Interface Support
    [Documentation]  Declaration for BMC M3_OOB interface support (M3_OOB_1 to M3_OOB_2)
    [Tags]  M3_OOB_1_2_Interface_Declaration
    ${M3_OOB_1_2_Interface_Declaration}    M3_OOB_1_2

Declaration For BMC M3_SPDM Interface Support
    [Documentation]  Declaration for BMC M3_SPDM interface support (M3_SPDM_1 to M3_SPDM_2)
    [Tags]  M3_SPDM_1_2_Interface_Declaration
    ${M3_SPDM_1_2_Interface_Declaration}    M3_SPDM_1_2

Declaration For BMC M3_RAS Functionality Support
    [Documentation]  Declaration for BMC M3_RAS functionality support (M3_RAS_1)
    [Tags]  M3_RAS_1_Function_Declaration
    ${M3_RAS_1_Function_Declaration}    M3_RAS_1

Declaration For BMC M4_IB Interface Support
    [Documentation]  Declaration for BMC M4_IB interface support (M4_IB_1)
    [Tags]  M4_IB_1_Interface_Declaration
    ${M4_IB_1_Interface_Declaration}    M4_IB_1

Declaration For BMC M4_SB Interface Support
    [Documentation]  Declaration for BMC M4_SB interface support (M4_SB_1)
    [Tags]  M4_SB_1_Interface_Declaration
    ${M4_SB_1_Interface_Declaration}    M4_SB_1

Declaration For BMC M4_IO Interface Support
    [Documentation]  Declaration for BMC M4_IO interface support (M4_IO_1 to M4_IO_3)
    [Tags]  M4_IO_1_3_Interface_Declaration
    ${M4_IO_1_3_Interface_Declaration}    M4_IO_1_3

Declaration For BMC M5_IB Interface Support
    [Documentation]  Declaration for BMC M5_IB interface support (M5_IB_1 to M5_IB_2)
    [Tags]  M5_IB_1_2_Interface_Declaration
    ${M5_IB_1_2_Interface_Declaration}    M5_IB_1_2

Declaration For BMC M5_SB Interface Support
    [Documentation]  Declaration for BMC M5_SB interface support (M5_SB_1)
    [Tags]  M5_SB_1_Interface_Declaration
    ${M5_SB_1_Interface_Declaration}    M5_SB_1

Declaration For BMC M5_IO Interface Support
    [Documentation]  Declaration for BMC M5_IO interface support (M5_IO_1)
    [Tags]  M5_IO_1_Interface_Declaration
    ${M5_IO_1_Interface_Declaration}    M5_IO_1

Declaration For BMC M5_OOB Interface Support
    [Documentation]  Declaration for BMC M5_OOB interface support (M5_OOB_1)
    [Tags]  M5_OOB_1_Interface_Declaration
    ${M5_OOB_1_Interface_Declaration}    M5_OOB_1

Declaration For BMC M5_HS Interface Support
    [Documentation]  Declaration for BMC M5_HS interface support (M5_HS_1 to M5_HS_2)
    [Tags]  M5_HS_1_2_Interface_Declaration
    ${M5_HS_1_2_Interface_Declaration}    M5_HS_1_2

*** Keywords ***

Declaration Should Pass
    [Arguments]  ${declaration}  ${rule_label}
    Run Keyword If  '${declaration}' == '${1}'
    ...    Log  Declaration : ${rule_label} rule supports
    ...  ELSE
    ...    Fail  ${rule_label} rule doesn't support
