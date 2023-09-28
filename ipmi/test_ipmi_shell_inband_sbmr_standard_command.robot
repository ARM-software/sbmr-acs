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

Documentation    Module to test IPMI Inband Interface SBMR Standard Command.
Resource         ../lib/ipmi_shell_client.robot
Library          ../lib/gen_robot_print.py

Test Teardown    Sleep  ${IPMI_DELAY}
Suite Setup      Check SBMR Support Command List

*** Variables ***
${SBMR_COMMAND_LIST}   ${EMPTY}


*** Test Cases ***

Test Host IPMI Inband Interface Send Platform Error Record Command
    [Documentation]  Verify IPMI Inband Interface Send Platform Error Record Command
    [Tags]  M21_IPMI_2_Send_Platform_Error_Record_Command
    ...     M1_RAS_1_2_Send_Platform_Error_Record_Command

    # If command not support, then fallback to send command directly
    ${rc}=  Run Keyword If  ${SBMR_COMMAND_LIST["send_platform_error_record"]} == ${1}
    ...        Set Variable  ${True}
    ...    ELSE
    ...        Run Keyword And Return Status  Issue Send Platform Error Record Command

    Should Be Equal  ${rc}  ${True}


Test Host IPMI Inband Interface Send Boot Progress Code Command
    [Documentation]  Verify IPMI Inband Interface Send Boot Progress Code Command
    [Tags]  M21_IPMI_2_Send_Boot_Progress_Code_Command

    # If command not support, then fallback to send command directly
    ${rc}=  Run Keyword If  ${SBMR_COMMAND_LIST["send_boot_progress_code"]} == ${1}
    ...        Set Variable  ${True}
    ...    ELSE
    ...        Run Keyword And Return Status  Issue Send Boot Progress Code Command

    Should Be Equal  ${rc}  ${True}


Test Host IPMI Inband Interface Get Boot Progress Code Command
    [Documentation]  Verify IPMI Inband Interface Get_Boot Progress Code Command
    [Tags]  M21_IPMI_2_Get_Boot_Progress_Code

    # If command not support, then fallback to send command directly
    ${rc}=  Run Keyword If  ${SBMR_COMMAND_LIST["get_boot_progress_code"]} == ${1}
    ...        Set Variable  ${True}
    ...    ELSE
    ...        Run Keyword And Return Status  Issue Get Boot Progress Code Command

    Should Be Equal  ${rc}  ${True}


*** Keywords ***

Issue Send Platform Error Record Command
    [Documentation]  Issue Send Platform Error Record Command

    ${output}=  Send Platform Error Record

    Should Be Equal  ${output}  ${0xAE}


Issue Send Boot Progress Code Command
    [Documentation]  Issue Send Boot Progress Code Command

    ${output}=  Send Boot Progress Code

    Should Be Equal  ${output}  ${0xAE}


Issue Get Boot Progress Code Command
    [Documentation]  Issue Get Boot Progress Code Command

    ${output}=  Get Boot Progress Code

    Should Be Equal  ${output}  ${0xAE}


Check SBMR Support Command List
    [Documentation]  Check SBMR Support Command List

    ${output}=  Get SBMR Command Support

    Set Global Variable  ${SBMR_COMMAND_LIST}  ${output}

