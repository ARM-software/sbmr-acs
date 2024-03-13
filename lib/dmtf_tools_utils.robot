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
Documentation   DMTF tools utility keywords.

Resource        resource.robot
Library         gen_cmd.py

*** Variables ***

# ignore_err controls Shell Cmd behavior.
${ignore_err}     ${0}
${stable_branch}  master

*** Keywords ***

Download DMTF Tool
    [Documentation]  Git clone tool.
    [Arguments]      ${rsv_dir_path}  ${rsv_github_url}  ${stable_branch}=master

    # Description of arguments:
    # rsv_dir_path    Directory path for rsv tool (e.g. "Redfish-Service-Validator").
    # rsv_github_url  Github URL link(e.g "https://github.com/DMTF/Redfish-Service-Validator").

    ${cmd_buf}  Catenate  rm -rf ${rsv_dir_path} ;
    ...  git clone --branch ${stable_branch} ${rsv_github_url} ${rsv_dir_path}
    ${rc}  ${output}=  Shell Cmd  ${cmd_buf}


Run DMTF Tool
    [Documentation]  Execution of the command.
    [Arguments]      ${rsv_dir_path}  ${command_string}  ${check_error}=0

    # Description of arguments:
    # rsv_dir_path    Directory path for rsv tool (e.g. "Redfish-Service-Validator").
    # command_string  The complete rsv command string to be run.
    # check_error     It decides if error information is to be checked.

    ${rc}  ${output}=  Shell Cmd  ${command_string}  ignore_err=${check_error}
    Log  ${output}
    RETURN  ${rc}  ${output}


Redfish Service Validator Result
    [Documentation]  Check tool output for errors.
    [Arguments]      ${tool_output}

    # Example:
    # Validation has failed: 9 problems found
    # Service could not be started: RetriesExhaustedError()
    Should Not Contain Any  ${tool_output}  Validation has failed
    ...  Service could not be started: RetriesExhaustedError()


Redfish JsonSchema ResponseValidator Result
    [Documentation]  Check tool output for errors.
    [Arguments]      ${tool_output}

    # Example:
    # 0 errors
    Should Contain  ${tool_output}  0 errors

