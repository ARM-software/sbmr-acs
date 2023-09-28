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
Documentation      Test BMC using https://github.com/DMTF/Redfish-Mockup-Creator.git.
...                DMTF tool.

Library            OperatingSystem
Library            ../../lib/gen_robot_print.py
Resource           ../../lib/dmtf_tools_utils.robot

Suite Setup        Remove Mockup Directory

*** Variables ***

${DEFAULT_PYTHON}  python3
${rsv_dir_path}    Redfish-Mockup-Creator
${rsv_github_url}  https://github.com/DMTF/Redfish-Mockup-Creator.git
${rsv_revision}    1.1.9
${mockup_dir}      ${OUTPUT_DIR}${/}redfish-mockup-creator
${cmd_str_master}  ${DEFAULT_PYTHON} ${rsv_dir_path}${/}redfishMockupCreate.py
...                -r https://${BMC_HOST}:${HTTPS_PORT} -u ${BMC_USERNAME} -p ${BMC_PASSWORD}
...                -S --Dir ${mockup_dir} --quiet --maxlogentries 10

*** Test Case ***

Test BMC Redfish Using Redfish Mockup Creator
    [Documentation]  Collect Redfish APIs for debugging via Redfish-Mockup-Creator.
    [Tags]  Test_BMC_Redfish_Using_Redfish_Mockup_Creator

    Download DMTF Tool  ${rsv_dir_path}  ${rsv_github_url}  stable_branch=${rsv_revision}

    ${rc}  ${output}=  Run DMTF Tool  ${rsv_dir_path}  ${cmd_str_master}  check_error=1

    Should Not Contain Any  ${output}  ERROR
    Run Keyword If  ${rc} != 0  Fail  Redfish-Mockup-Creator Failed.


*** Keywords ***

Remove Mockup Directory
    [documentation]  Remove Redfish Mockup Directory

    Remove Directory  ${mockup_dir}  recursive=${True}

