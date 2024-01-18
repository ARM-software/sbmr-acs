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
Documentation             Test BMC using https://github.com/DMTF/Redfish-Reference-Checker
...                       DMTF tool.

Library                   OperatingSystem
Resource                  ../../lib/dmtf_tools_utils.robot

Suite Setup               Suite Setup Execution

*** Variables ***

${DEFAULT_PYTHON}         python3

${rsv_github_url}         https://github.com/DMTF/Redfish-Reference-Checker.git
${rsv_dir_path}           Redfish-Reference-Checker
${rsv_revision}           1.0.1

${command_string}  ${DEFAULT_PYTHON} ${rsv_dir_path}${/}RedfishReferenceTool.py
...                --nochkcert 'https://${BMC_HOST}:${HTTPS_PORT}/redfish/v1/$metadata'

*** Test Case ***

Test BMC Redfish Reference
    [Documentation]  Checks for valid reference URLs in CSDL XML files.
    [Tags]  M2_OOB_1_Redfish_Reference_Checker


    ${rc}  ${output}=  Run DMTF Tool  ${rsv_dir_path}  ${command_string}  check_error=1

    # Work complete, total failures:  0
    Should Match Regexp    ${output}  Work complete, total failures:[ ]+0
    Run Keyword If  ${rc} != 0  Fail  Redfish-Reference-Checker Failed.

*** Keywords ***

Suite Setup Execution
    [Documentation]  Do suite setup tasks.

    Download DMTF Tool  ${rsv_dir_path}  ${rsv_github_url}  stable_branch=${rsv_revision}

