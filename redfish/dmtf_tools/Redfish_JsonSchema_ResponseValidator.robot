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
Documentation     Test BMC using https://github.com/DMTF/Redfish-JsonSchema-ResponseValidator
...               DMTF tool.

Library           OperatingSystem
Resource          ../../lib/dmtf_tools_utils.robot
Resource          ../../lib/bmc_redfish_resource.robot
Resource          ../../lib/utils.robot

Suite Setup       Suite Setup Execution
Suite Teardown    Suite Teardown Execution

*** Variables ***

${DEFAULT_PYTHON}  python3
${rsv_dir_path}    Redfish-JsonSchema-ResponseValidator
${rsv_github_url}  https://github.com/DMTF/Redfish-JsonSchema-ResponseValidator.git
${rsv_revision}    1.0.1
${validator_dir}   ${OUTPUT_DIR}${/}${rsv_dir_path}
${command_string}  ${DEFAULT_PYTHON} ${rsv_dir_path}${/}Redfish-JsonSchema-ResponseValidator.py
...                -r https://${BMC_HOST} -u ${BMC_USERNAME} -p ${BMC_PASSWORD} -S -v

*** Test Cases ***

Test BMC Redfish Using Redfish JsonSchema ResponseValidator
    [Documentation]  Check BMC conformance with JsonSchema files at the DMTF site.
    [Tags]  M2_OOB_1_Redfish_JsonSchema_ResponseValidator


    Download DMTF Tool  ${rsv_dir_path}  ${rsv_github_url}  stable_branch=${rsv_revision}

    ${url_list}=  redfish_utils.List Request  /redfish/v1

    Shell Cmd  mkdir -p logs/

    Set Test Variable  ${test_run_status}  ${True}

    FOR  ${url}  IN  @{url_list}
        # Skip Oem odatatype
        ${resp}=  redfish_utils.Get Properties  ${url}
        ${status}=  Is Redfish Standard OdataType  ${resp["@odata.type"]}
        Run Keyword If  '${status}'=='${False}'  Continue For Loop

        # Run redfish-jsonschema-response validator
        ${rc}  ${output}=  Run DMTF Tool  ${rsv_dir_path}  ${command_string} -i ${url}
        ${status}=  Run Keyword And Return Status  Redfish JsonSchema ResponseValidator Result  ${output}
        Run Keyword If  ${status} == ${False}  Set Test Variable  ${test_run_status}  ${status}
        Save Logs For Debugging  ${status}  ${url}
    END

    Run Keyword If  ${test_run_status} == ${False}
    ...  Fail  Redfish-JsonSchema-ResponseValidator detected errors.

    Directory Should Be Empty  ${validator_dir}


*** Keywords ***

Suite Setup Execution
    [Documentation]  Do test case setup tasks

    Remove Directory  ${OUTPUT_DIR}${/}${rsv_dir_path}  recursive=${True}
    Create Directory  ${OUTPUT_DIR}${/}${rsv_dir_path}


Suite Teardown Execution
    [Documentation]  Do the post suite teardown

    Redfish Delete All Sessions


Save Logs For Debugging
    [Documentation]  Save validate_errs on errors.
    [Arguments]      ${status}  ${url}

    # Description of arguments:
    # status    True/False.
    # url       Redfish resource path (e.g. "/redfish/v1/AccountService").

    ${validate_errs}=  Shell Cmd  cat validate_errs
    Log  ${validate_errs}

    # URL /redfish/v1/Managers/bmc strip the last ending string and save off
    # the logs for debugging "validate_errs_AccountService" and move to logs/.
    Run Keyword If  ${status} == ${False}
    ...  Shell Cmd  cp validate_errs ${validator_dir}${/}validate_errs_${url.rsplit("/")[-1]}
