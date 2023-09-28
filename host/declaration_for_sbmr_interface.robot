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


*** Test Cases ***

Declaration For BMC M1_JTAG Interface Support
    [Documentation]  Declaration for BMC M1_JTAG interface support
    [Tags]  M1_JTAG_1_2_Interface_Declaration

    Run Keyword If  '${M1_JTAG_1_2_Interface_Declaration}' == '${1}'
    ...    Log  Declaration : M1_JTAG_1_2 rule supports
    ...  ELSE
    ...    Fail  M1_JTAG_1_2 rule doesn't support


Declaration For BMC M2_JTAG Interface Support
    [Documentation]  Declaration for BMC M2_JTAG interface support
    [Tags]  M2_JTAG_1_2_Interface_Declaration

    Run Keyword If  '${M2_JTAG_1_2_Interface_Declaration}' == '${1}'
    ...    Log  Declaration : M2_JTAG_1_2 rule supports
    ...  ELSE
    ...    Fail  M2_JTAG_1_2 rule doesn't support


Declaration For BMC M2_IO_1 NC-SI Interface Support
    [Documentation]  Declaration for BMC M2_IO_1 NS-CI interface support
    [Tags]  M2_IO_1_NCSI_Interface_Declaration

    Run Keyword If  '${M2_IO_1_NCSI_Interface_Declaration}' == '${1}'
    ...    Log  Declaration : M2_IO_1 rule supports
    ...  ELSE
    ...    Fail  M2_IO_1 rule doesn't support


Declaration For BMC M2_RAS Functionality Support
    [Documentation]  Declaration for BMC M2_RAS functionality support
    [Tags]  M2_RAS_1_2_Function_Declaration

    Run Keyword If  '${M2_RAS_1_2_Function_Declaration}' == '${1}'
    ...    Log  Declaration : M2_RAS_1_2 rule supports
    ...  ELSE
    ...    Fail  M2_RAS_1_2 rule doesn't support

