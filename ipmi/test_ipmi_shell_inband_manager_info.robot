# Copyright (c) 2023-2024, Arm Limited or its affiliates. All rights reserved.
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

Documentation    Module to test IPMI Inband Manager Info functionality.
Resource         ../lib/ipmi_shell_client.robot


*** Test Cases ***

Test Host IPMI Inband Get Manager Info
    [Documentation]  Verify IPMI Inband Get Manager Info on Host
    [Tags]  M1_OOB_1_IPMI_6_IB_Get_Manager_Info  M2_OOB_2_IPMI_6_IB_Get_Manager_Info
    ...     M21_IPMI_1_IB_Get_Manager_Info

    ## mc info
    ${ipmi_output}=  Run Shell Inband IPMI Standard Command  mc info
    Log  ${ipmi_output}
    Sleep  ${IPMI_DELAY}

    # parse the log for firmware Version
    ${fw_rev} =  Get Regexp Matches  ${ipmi_output}  ^.*Firmware Revision.*$
    ...    flags=MULTILINE

    # check if we got a match
    Run Keyword If  ${fw_rev} == []
    ...    Fail  No Firmware Revision present in 'mc info' output

    # parse for firmware version value
    ${fw_rev} =  Get Regexp Matches  ${fw_rev}[0]  [0-9]+\.[0-9]+
    ...    flags=MULTILINE
    Run Keyword If  ${fw_rev} == []
    ...    Fail  Firmware Revision present in 'mc info' is invalid.

    # check for validity of parsed value
    ${fwrev_value} =  Set Variable  ${fw_rev}[0]
    Log To Console  Firmware Revision = ${fwrev_value}
    ${invalid_fwrev} =  Set Variable  0.0
    Should Not Be Equal As Strings  ${fwrev_value}  ${invalid_fwrev}
    ...     msg=Firmware Revision returned by 'mc info' command is not valid, Firmware Revision = ${fwrev_value}
    ...     values=${False}

    ## mc guid
    ${ipmi_output}=  Run Shell Inband IPMI Standard Command  mc guid
    Log  ${ipmi_output}
    Sleep  ${IPMI_DELAY}

    # parse the log for GUID
    ${guid_match} =  Get Regexp Matches  ${ipmi_output}  [A-Za-z0-9]{8}-[A-Za-z0-9]{4}-[A-Za-z0-9]{4}-[A-Za-z0-9]{4}-[A-Za-z0-9]{12}
    ...    flags=MULTILINE

    Run Keyword If  ${guid_match} == []
    ...    Fail  No GUID present in 'mc guid' output

    # check for validity of parsed value
    ${guid_value} =  Set Variable  ${guid_match}[0]
    Log To Console  GUID = ${guid_value}
    ${invalid_guid} =  Set Variable  00000000-0000-0000-0000-000000000000
    Should Not Be Equal As Strings  ${guid_value}  ${invalid_guid}
    ...     msg=GUID returned by 'mc guid' command is not valid, GUID = ${guid_value}
    ...     values=${False}


