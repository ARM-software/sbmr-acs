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
Documentation      Test BMC using https://github.com/DMTF/Redfish-Service-Validator.
...                DMTF tool.

Library            OperatingSystem
Library            ../../lib/gen_robot_print.py
Resource           ../../lib/dmtf_tools_utils.robot
Resource           ../../lib/bmc_redfish_resource.robot
Resource           ../../lib/bmc_redfish_utils.robot
Resource           ../../lib/utils.robot

Suite Setup        Suite Setup Execution
Suite Teardown     Suite Teardown Execution

*** Variables ***

${DEFAULT_PYTHON}  python3
${rsv_dir_path}    Redfish-Service-Validator
${rsv_github_url}  https://github.com/DMTF/Redfish-Service-Validator.git
${rsv_revision}    2.3.1
${cmd_str_master}  ${DEFAULT_PYTHON} ${rsv_dir_path}${/}RedfishServiceValidator.py
...                --ip https://${BMC_HOST}:${HTTPS_PORT} --authtype=Session -u ${BMC_USERNAME}
...                -p ${BMC_PASSWORD} --logdir ${OUTPUT_DIR}${/}redfish-service-validator
...                --debugging

*** Test Case ***

Test BMC Redfish Using Redfish Service Validator
    [Documentation]  Check conformance with a Redfish service interface.
    [Tags]  M2_OOB_1_Redfish_Service_Validator
    ...     M3_OOB_1_Redfish_Service_Validator

    Download DMTF Tool  ${rsv_dir_path}  ${rsv_github_url}  stable_branch=${rsv_revision}

    ${rc}  ${output}=  Run DMTF Tool  ${rsv_dir_path}  ${cmd_str_master}  check_error=1

    Redfish Service Validator Result  ${output}
    Run Keyword If  ${rc} != 0  Fail  Redfish-Service-Validator Failed.


Run Redfish Service Validator With Additional Roles
    [Documentation]  Check Redfish conformance using the Redfish Service Validator.
    ...  Run the validator as additional non-admin user roles.
    [Tags]  Run_Redfish_Service_Validator_With_Additional_Roles
    [Template]  Create User And Run Service Validator

    #username      password             role        enabled
    operator_user  ${BMC_PASSWORD}      Operator    ${True}
    readonly_user  ${BMC_PASSWORD}      ReadOnly    ${True}


*** Keywords ***

Create User And Run Service Validator
    [Documentation]  Create user and run validator.
    [Arguments]   ${username}  ${password}  ${role}  ${enabled}
    [Teardown]  Delete User Created  ${username}

    # Description of argument(s):
    # username            The username to be created.
    # password            The password to be assigned.
    # role                The role of the user to be created
    #                     (e.g. "Administrator", "Operator", etc.).
    # enabled             Indicates whether the username being created
    #                     should be enabled (${True}, ${False}).

    Redfish.Login
    Redfish Create User  ${username}  ${password}  ${role}  ${enabled}
    Redfish.Logout

    Download DMTF Tool  ${rsv_dir_path}  ${rsv_github_url}  ${stable_branch}=${rsv_revision}

    ${cmd}=  Catenate  ${DEFAULT_PYTHON} ${rsv_dir_path}${/}RedfishServiceValidator.py
    ...  --ip https://${BMC_HOST}:${HTTPS_PORT} --authtype=Session -u ${username}
    ...  -p ${password} --logdir ${EXECDIR}${/}logs_${username}${/} --debugging

    Rprint Vars  cmd

    ${rc}  ${output}=  Run DMTF Tool  ${rsv_dir_path}  ${cmd}  check_error=1

    Redfish Service Validator Result  ${output}
    Run Keyword If  ${rc} != 0  Fail


Delete User Created
    [Documentation]  Delete user.
    [Arguments]   ${username}

    # Description of argument(s):
    # username            The username to be deleted.

    Redfish.Login
    Redfish.Delete  /redfish/v1/AccountService/Accounts/${username}
    Redfish.Logout


Suite Setup Execution
    [Documentation]  Do suite setup tasks.

    # Power Off System and Set BootSourceOverrideEnabled to Disabled
    Redfish Hard Power Off  stack_mode=skip  quiet=1

    Redfish.Login
    Redfish Disable Boot Source
    Redfish Delete All Sessions

    Redfish Power On  stack_mode=skip  quiet=1


Suite Teardown Execution
    [Documentation]  Do the post suite teardown

    Redfish Delete All Sessions
