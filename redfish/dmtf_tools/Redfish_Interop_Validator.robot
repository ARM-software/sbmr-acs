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
Documentation      Test BMC Redfish conformance using  https://github.com/DMTF/Redfish-Interop-Validator.
...                DMTF tool.
...                It validate the Redfish service based on an interoperability profile given to it.

Resource           ../../lib/dmtf_tools_utils.robot
Resource           ../../lib/utils.robot

Suite Setup        Suite Setup Execution
Suite Teardown     Suite Teardown Execution

*** Variables ***

${DEFAULT_PYTHON}  python3
${rsv_dir_path}    Redfish-Interop-Validator
${rsv_github_url}  https://github.com/DMTF/Redfish-Interop-Validator.git
${rsv_revision}    2.1.3
${cmd_str_master}  ${DEFAULT_PYTHON} ${rsv_dir_path}${/}RedfishInteropValidator.py
...                --ip https://${BMC_HOST}:${HTTPS_PORT} --authtype=Session -u ${BMC_USERNAME}
...                -p ${BMC_PASSWORD} --logdir ${OUTPUT_DIR}${/}redfish-interop-validator
...                --debugging

${profile_dir_path}    HWMgmt-OCP-profiles
${profile_github_url}  https://github.com/opencomputeproject/HWMgmt-OCP-Profiles


*** Test Cases ***

Test BMC Redfish Using Redfish Interop Validator On OCP Baseline Profile
    [Documentation]  Check conformance based on the BMC Interoperability profile.
    [Tags]  M2_OOB_3_Redfish_Interop_Validator_On_OCP_Baseline
    ...     M3_OOB_2_Redfish_Interop_Validator_On_OCP_Baseline
    [Template]  Run Redfish Interop Validator With Profile

    # profile
    OCPBaselineHardwareManagement.v1_0_1.json


Test BMC Redfish Using Redfish Interop Validator On OCP Server Profile
    [Documentation]  Check conformance based on the BMC Interoperability profile.
    [Tags]  M2_OOB_3_Redfish_Interop_Validator_On_OCP_Server
    ...     M3_OOB_2_Redfish_Interop_Validator_On_OCP_Server
    [Template]  Run Redfish Interop Validator With Profile

    # profile
    OCPServerHardwareManagement.v1_0_0.json


*** Keywords ***

Run Redfish Interop Validator With Profile
    [Documentation]  Check conformance based on the BMC Interoperability profile.
    [Arguments]  ${profile}

    ${interop_cmd} =  Catenate  ${cmd_str_master}
    ...                         ${EXECDIR}${/}${profile_dir_path}${/}${profile}
    ${rc}  ${output}=  Run DMTF Tool  ${rsv_dir_path}  ${interop_cmd}  check_error=1

    Run Keyword If  ${rc} != 0  Fail  Redfish-Interop-Validator - ${profile} Failed.


Suite Setup Execution
    [documentation]  Do suite setup tasks.

    Download DMTF Tool  ${rsv_dir_path}  ${rsv_github_url}  stable_branch=${rsv_revision}
    Download DMTF Tool  ${profile_dir_path}  ${profile_github_url}

    # Power Off System and Set BootSourceOverrideEnabled to Disabled
    Redfish Hard Power Off  stack_mode=skip  quiet=1

    Redfish.Login
    Redfish Disable Boot Source
    Redfish Delete All Sessions

    Redfish Power On  stack_mode=skip  quiet=1


Suite Teardown Execution
    [Documentation]  Do the post suite teardown

    Redfish Delete All Sessions

