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

Documentation    Module to test IPMI Inband Redfish HI functionality.
Resource         ../lib/ipmi_shell_client.robot
Resource         ../lib/bmc_redfish_utils.robot
Library          ../lib/utils.py

Test Teardown    Sleep  ${IPMI_DELAY}

*** Test Cases ***

Test Host IPMI Inband Redfish Host Get Manager Certificate Fingerprint
    [Documentation]  Test IPMI Inband Redfish Host Get Manager Certificate
    ...              Fingerprint on Host
    [Tags]  M21_IPMI_1_IPMI_8_Redfish_Host_Certificate_Fingerprint

    # Get Certificate Number 1
    ${ipmi_output}=  Run Shell Inband IPMI Raw Command  0x2c 0x01 0x52 0x1

    Log  ${ipmi_output}

    ${ipmi_output}=  Split String  ${ipmi_output}
    Should be Equal  52  ${ipmi_output[0]}
    ...  msg=Failure: Not Match Group Extension Identification

    ${fingerprint}=  Get Server Certificate Fingerprint
    Should Be Equal  ${fingerprint}  ${ipmi_output[2:]}
    ...  msg=Failure: Not Match Redfish Service Certificate


Test Host IPMI Inband Redfish Host Get Account Credential
    [Documentation]  Test IPMI Inband Redfish Host Get Account Credential
    ...              on Host
    [Tags]  M21_IPMI_1_IPMI_8_Redfish_Host_Get_Account_Credential
    [Template]  Check IPMI Inband Redfish Host Get Account Credential

    0xA5


*** Keywords ***

Check IPMI Inband Redfish Host Get Account Credential
    [Documentation]  Check IPMI Inband Redfish Host Get Account Credential
    [Arguments]  ${disable_control}

    # Get Bootstrap Account Credential
    ${ipmi_output}=  Run Shell Inband IPMI Raw Command  0x2c 0x02 0x52 ${disable_control}

    # Validate IPMI response
    ${ipmi_output}=  Split String  ${ipmi_output}
    Should be Equal  52  ${ipmi_output[0]}
    ...  msg=Failure: Not Match Group Extension Identification

    ${username}=  Check Bootstrapping Account Credential  ${ipmi_output[1:17]}
    ${password}=  Check Bootstrapping Account Credential  ${ipmi_output[17:33]}

    Set Global Variable  ${BMC_USERNAME}  ${username}
    Set Global Variable  ${BMC_PASSWORD}  ${password}

    Redfish.Login

    ${bootstrapping}=  Redfish Get Credential Bootstrapping Status
    Run Keyword If  ${disable_control} == 0xA5
    ...    Should Be Equal  ${bootstrapping}  ${True}
    ...  ELSE
    ...    Should Be Equal  ${bootstrapping}  ${False}

    Redfish.Logout


Check Bootstrapping Account Credential
    [Documentation]  Check Redfish Bootstrapping Account Credential
    [Arguments]  ${input_string}

    ${string}=  Convert To Bytes  ${input_string}  hex
    ${string}=  Decode Bytes To String  ${string}  ASCII
    Should Not Contain Any  ${string}  ${SPACE}  \\  '  "
    ...  msg=Failure: Credential Contains Invalid Characters

    RETURN  ${string}


Redfish Get Credential Bootstrapping Status
    [Documentation]  Redfish Get Credential Bootstrapping Enable Status

    ${redfish_bmc}=  Redfish.Get Members List  /redfish/v1/Managers/

    # Assume: Only one BMC instance
    ${interface}=  Redfish.Get Members List  ${redfish_bmc}[0]/HostInterfaces/

    # Assume: only one host interface
    ${prop}=  Redfish.Get Properties  ${interface}[0]

    RETURN  ${prop["CredentialBootstrapping"]["Enabled"]}


Redfish Set Credential Bootstrapping Status
    [Documentation]  Redfish Get Credential Bootstrapping Enable Status
    [Arguments]  ${status}

    ${data}=  Create Dictionary  Enabled=${status}
    ${payload}=  Create Dictionary  CredentialBootstrapping=${data}

    ${redfish_bmc}=  Redfish.Get Members List  /redfish/v1/Managers/

    # Assume: Only one BMC instance
    ${interface}=  Redfish.Get Members List  ${redfish_bmc}[0]/HostInterfaces/

    # Assume: only one host interface
    Redfish.Patch  ${interface}[0]  body=&{payload}
    ...  valid_status_codes=[${HTTP_OK}, ${HTTP_NO_CONTENT}]

    RETURN  ${status}

