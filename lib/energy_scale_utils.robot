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
Documentation     Utilities for power management tests.

Resource          ../lib/boot_utils.robot
Resource          ../lib/ipmi_client.robot
Library           ../lib/var_funcs.py

*** Variables ***

${power_cap_uri}    /redfish/v1/Chassis/${CHASSIS_ID}/EnvironmentMetrics

*** Keywords ***

Get System Power Cap Limit
    [Documentation]  Get the allowed MAX and MIN power limit of the chassis.

    # GET request of /redfish/v1/Chassis/${CHASSIS_ID}/EnvironmentMetrics  | grep -A5 Power
    #   "PowerLimitWatts": {
    #       "AllowableMax": 2488,
    #       "AllowableMin": 1778,
    #       "ControlMode": "Disabled",
    #       "SetPoint": 2488
    # }

    ${power_limit_watts}=  Redfish.Get Attribute  ${power_cap_uri}   PowerLimitWatts

    [return]  ${power_limit_watts}


DCMI Power Get Limits
    [Documentation]  Run dcmi power get_limit and return values as a
    ...  dictionary.

    # This keyword packages the five lines returned by dcmi power get_limit
    # command into a dictionary.  For example, the dcmi command may return:
    #  Current Limit State: No Active Power Limit
    #  Exception actions:   Hard Power Off & Log Event to SEL
    #  Power Limit:         500   Watts
    #  Correction time:     0 milliseconds
    #  Sampling period:     0 seconds
    # The power limit setting can be obtained with the following:
    # &{limits}=  DCMI Power Get Limits
    # ${power_setting}=  Set Variable  ${limits['power_limit']}

    ${output}=  Run External IPMI Standard Command  dcmi power get_limit
    ${output}=  Remove String  ${output}  Watts
    ${output}=  Remove String  ${output}  milliseconds
    ${output}=  Remove String  ${output}  seconds
    &{limits}=  Key Value Outbuf To Dict  ${output}
    [Return]  &{limits}


Get DCMI Power Limit
    [Documentation]  Return the system's current DCMI power_limit
    ...  watts setting.

    &{limits}=  DCMI Power Get Limits
    ${power_setting}=  Get From Dictionary  ${limits}  power_limit
    [Return]  ${power_setting}


Set DCMI Power Limit And Verify
    [Documentation]  Set system power limit via IPMI DCMI command.
    [Arguments]  ${power_limit}

    # Description of argument(s):
    # limit      The power limit in watts

    ${cmd}=  Catenate  dcmi power set_limit limit ${power_limit}
    Run External IPMI Standard Command  ${cmd}
    ${power}=  Get DCMI Power Limit
    Should Be True  ${power} == ${power_limit}
    ...  msg=Failed setting dcmi power limit to ${power_limit} watts.


Activate DCMI Power And Verify
    [Documentation]  Activate DCMI power limiting.

    ${resp}=  Run External IPMI Standard Command  dcmi power activate
    Should Contain  ${resp}  successfully activated
    ...  msg=Command failed: dcmi power activate.


Fail If DCMI Power Is Not Activated
    [Documentation]  Fail if DCMI power limiting is not activated.

    ${cmd}=  Catenate  dcmi power get_limit | grep State:
    ${resp}=  Run External IPMI Standard Command  ${cmd}
    Should Contain  ${resp}  Power Limit Active  msg=DCMI power is not active.


Deactivate DCMI Power And Verify
    [Documentation]  Deactivate DCMI power power limiting.

    ${cmd}=  Catenate  dcmi power deactivate | grep deactivated
    ${resp}=  Run External IPMI Standard Command  ${cmd}
    Should Contain  ${resp}  successfully deactivated
    ...  msg=Command failed: dcmi power deactivater.


Fail If DCMI Power Is Not Deactivated
    [Documentation]  Fail if DCMI power limiting is not deactivated.

    ${cmd}=  Catenate  dcmi power get_limit | grep State:
    ${resp}=  Run External IPMI Standard Command  ${cmd}
    Should Contain  ${resp}  No Active Power Limit
    ...  msg=DCMI power is not deactivated.
