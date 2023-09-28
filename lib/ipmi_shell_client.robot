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
Documentation   This module is for IPMI client for using ipmitool to
...             bmc box and execute ipmitool IPMI standard/Raw command.

Resource        ../lib/resource.robot

Library         String
Library         var_funcs.py
Library         ipmi_client.py
Library         gen_cmd.py
Library         gen_print.py
Library         ipmi_shell_client.py

*** Variables ***
${IPMI_INBAND_CMD}=    ipmitool -C ${IPMI_CIPHER_LEVEL} -N ${IPMI_TIMEOUT} -p ${IPMI_PORT}
${RAW}=                raw

*** Keywords ***

Run Shell Inband IPMI Raw Command
    [Documentation]  Run the raw IPMI command in-band via shell command.
    [Arguments]  ${command}  ${fail_on_err}=${1}

    # Description of argument(s):
    # command                       The IPMI command string to be executed
    #                               (e.g. "0x06 0x36").

    Check If IPMI Tool Exist

    ${ipmi_cmd}=  Catenate  ${IPMI_INBAND_CMD}  ${RAW}  ${command}
    Qprint Issuing  ${ipmi_cmd}
    ${rc}  ${stdout}  ${stderr}=  Shell Cmd  ${ipmi_cmd}  return_stderr=True
    Return From Keyword If  ${fail_on_err} == ${0}  ${stderr}
    Should Be Empty  ${stderr}  msg=${stdout}

    [Return]  ${stdout}


Run Shell Inband IPMI Standard Command
    [Documentation]  Run the standard IPMI command in-band via shell cmd
    [Arguments]  ${command}  ${fail_on_err}=${1}

    # Description of argument(s):
    # command                       The IPMI command string to be executed
    #                               (e.g. "power status").

    Check If IPMI Tool Exist

    ${ipmi_cmd}=  Catenate  ${IPMI_INBAND_CMD}  ${command}
    Qprint Issuing  ${ipmi_cmd}
    ${rc}  ${stdout}  ${stderr}=  Shell Cmd  ${ipmi_cmd}  return_stderr=True
    Return From Keyword If  ${fail_on_err} == ${0}  ${stderr}
    Should Be Empty  ${stderr}  msg=${stdout}
    [Return]  ${stdout}


Check If IPMI Tool Exist
    [Documentation]  Check if IPMI Tool installed or not.

    ${output}=  Shell Cmd  which ipmitool

    Should Not Be Empty  ${output}  msg=ipmitool not installed.

