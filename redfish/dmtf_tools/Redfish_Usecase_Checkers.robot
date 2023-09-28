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
Documentation             Test BMC using https://github.com/DMTF/Redfish-Usecase-Checkers
...                       DMTF tool.

Resource                  ../../lib/resource.robot
Resource                  ../../lib/dmtf_tools_utils.robot
Library                   OperatingSystem
Library                   ../../lib/state.py

Suite Setup               Suite Setup Execution

*** Variables ***

${DEFAULT_PYTHON}         python3

${rsv_github_url}         https://github.com/DMTF/Redfish-Usecase-Checkers.git
${rsv_dir_path}           Redfish-Usecase-Checkers
${rsv_revision}           1.0.8

${account_log_dir}        ${OUTPUT_DIR}${/}${rsv_dir_path}${/}account-logs
${command_account}        ${DEFAULT_PYTHON} ${rsv_dir_path}${/}account_management/account_management.py
...                       -r ${BMC_HOST} -u ${BMC_USERNAME}
...                       -p ${BMC_PASSWORD} -S Always -d ${account_log_dir}

${power_control_log_dir}  ${OUTPUT_DIR}${/}${rsv_dir_path}${/}power-logs
${command_power_control}  ${DEFAULT_PYTHON} ${rsv_dir_path}${/}power_control/power_control.py
...                       -r ${BMC_HOST} -u ${BMC_USERNAME}
...                       -p ${BMC_PASSWORD} -S Always -d ${power_control_log_dir}

${query_param_log_dir}    ${OUTPUT_DIR}${/}${rsv_dir_path}${/}query-logs
${command_query_param}    ${DEFAULT_PYTHON} ${rsv_dir_path}${/}query_parameters${/}query_parameters_check.py
...                       -r ${BMC_HOST} -u ${BMC_USERNAME}
...                       -p ${BMC_PASSWORD} -S Always -d ${query_param_log_dir}

${power_thermal_log_dir}  ${OUTPUT_DIR}${/}${rsv_dir_path}${/}thermal-logs
${command_power_thermal}  ${DEFAULT_PYTHON} ${rsv_dir_path}${/}power_thermal_info${/}power_thermal_test.py
...                       -r ${BMC_HOST} -u ${BMC_USERNAME}
...                       -p ${BMC_PASSWORD} -S Always -d ${power_thermal_log_dir}

${one_time_boot_log_dir}  ${OUTPUT_DIR}${/}${rsv_dir_path}${/}one-time-boot-logs
${command_one_time_boot}  ${DEFAULT_PYTHON} ${rsv_dir_path}${/}one_time_boot${/}one_time_boot_check.py
...                       -r ${BMC_HOST} -u ${BMC_USERNAME}
...                       -p ${BMC_PASSWORD} -S Always -d ${one_time_boot_log_dir}

${power_on_timeout}       15 mins
${power_off_timeout}      15 mins
${state_change_timeout}   3 mins

*** Test Case ***

Test BMC Redfish Account Management
    [Documentation]  Check Account Management with a Redfish interface.
    [Tags]  Test_BMC_Redfish_Account_Management

    ${output}=  Run DMTF Tool  ${rsv_dir_path}  ${command_account}  check_error=1

    Redfish Usecase Result Verify  ${account_log_dir}


Test BMC Redfish Query Parameters
    [Documentation]  Check Redfish interface with Query Parameters.
    [Tags]  Test_BMC_Redfish_Query_Parameters

    ${output}=  Run DMTF Tool  ${rsv_dir_path}  ${command_query_param}  check_error=1

    Redfish Usecase Result Verify  ${query_param_log_dir}


Test BMC Redfish Power Thermal Info
    [Documentation]  Check Redfish chassis collection to ensure at least one sensor
    ...              from Power and Thermal resources.
    [Tags]  Test_BMC_Redfish_Power_Thermal_Info

    ${output}=  Run DMTF Tool  ${rsv_dir_path}  ${command_power_thermal}  check_error=1

    Redfish Usecase Result Verify  ${power_thermal_log_dir}


Test BMC Redfish One Time Boot
    [Documentation]  Verify on Redfish BootSourceOverrideTarget
    [Tags]  Test_BMC_Redfish_One_Time_Boot

    ${output}=  Run DMTF Tool  ${rsv_dir_path}  ${command_one_time_boot}  check_error=1

    Redfish Usecase Result Verify  ${one_time_boot_log_dir}


Test BMC Redfish Power Control Usecase
    [Documentation]  Power Control Usecase Test.
    [Tags]  Test_BMC_Redfish_Power_Control_Usecase

    DMTF Power


*** Keywords ***

Suite Setup Execution
    [Documentation]  Do suite setup tasks.

    Download DMTF Tool  ${rsv_dir_path}  ${rsv_github_url}  stable_branch=${rsv_revision}
    Create Directory  ${EXECDIR}${/}logs${/}${rsv_dir_path}


Redfish Usecase Result Verify
    [Documentation]  Verify results from Redfish Usecase Checker
    [Arguments]  ${result_path}

    ${output}=  Shell Cmd  cat ${result_path}${/}results.json
    Log  ${output}

    ${json}=  OperatingSystem.Get File    ${result_path}${/}results.json

    ${object}=  Evaluate  json.loads('''${json}''')  json

    ${result_list}=  Set Variable  ${object["TestResults"]}

    @{failed_tc_list}=    Create List

    FOR  ${result}  IN  @{result_list}
       ${rc}=    evaluate    'ErrorMessages'=='${result}'
       ${num}=  Run Keyword If  ${rc} == False  Set Variable  ${result_list["${result}"]["fail"]}
       Run Keyword If  ${num} != None and ${num} > 0  Append To List  ${failed_tc_list}   ${result}
    END

    Should Be Empty  ${failed_tc_list}  Failed test cases are ${failed_tc_list}


DMTF Power
    [Documentation]  Power the BMC machine on via DMTF tools.

    ${output}=  Run DMTF Tool  ${rsv_dir_path}  ${command_power_control}  check_error=1
    Log  ${output}

    ${json}=  OperatingSystem.Get File    ${power_control_log_dir}${/}results.json

    ${object}=  Evaluate  json.loads('''${json}''')  json

    ${result_list}=  Set Variable  ${object["TestResults"]}
    Log To Console  result: ${result_list}

    @{failed_tc_list}=    Create List
    @{error_messages}=    Create List

    FOR  ${result}  IN  @{result_list}
       ${rc}=    evaluate    'ErrorMessages'=='${result}'
       ${num}=  Run Keyword If  ${rc} == False  Set Variable  ${result_list["${result}"]["fail"]}
       Run Keyword If  ${num} != None and ${num} > 0  Append To List  ${failed_tc_list}   ${result}
       Run Keyword If  ${rc} == True
       ...  Append To List  ${error_messages}  ${result_list["ErrorMessages"]}
    END

    Log Many            ErrorMessages:   @{error_messages}
    Log To Console      ErrorMessages:
    FOR   ${msg}  IN  @{error_messages}
       Log To Console   ${msg}
    END

    Should Be Empty  ${error_messages}   DMTF Power keyword failed.
