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
Documentation    This suite test various boot types with boot source.
Resource         ../lib/resource.robot
Resource         ../lib/bmc_redfish_resource.robot
Resource         ../lib/common_utils.robot
Resource         ../lib/ipmi_client.robot

Test Setup       Test Setup Execution
Test Teardown    Test Teardown Execution

Suite Setup      Suite Setup Execution
Suite Teardown   Suite Teardown Execution

*** Variables ***

*** Test Cases ***

Verify BMC Redfish Boot Source Override with Enabled Mode As Once
    [Documentation]  Verify BMC Redfish Boot Source Override with Enabled Mode As Once.
    [Tags]           M2_OOB_1_Redfish_Boot_Source_As_Once
    ...              M3_OOB_1_Redfish_Boot_Source_As_Once
    [Template]  Set And Verify Boot Source Override

    #BootSourceOverrideEnabled    BootSourceOverrideTarget
    Once                          Hdd
    Once                          Pxe
    Once                          BiosSetup


Verify BMC Redfish Boot Source Override with Enabled Mode As Continuous
    [Documentation]  Verify BMC Redfish Boot Source Override with Enabled Mode As Continuous.
    [Tags]           M2_OOB_1_Redfish_Boot_Source_As_Continuous
    ...              M3_OOB_1_Redfish_Boot_Source_As_Continuous
    [Template]  Set And Verify Boot Source Override

    #BootSourceOverrideEnabled    BootSourceOverrideTarget
    Continuous                    Hdd
    Continuous                    Pxe
    Continuous                    BiosSetup


Verify BMC Redfish Boot Source Override with Enabled Mode As Disabled
    [Documentation]  Verify BMC Redfish Boot Source Override with Enabled Mode As Disabled.
    [Tags]           M2_OOB_1_Redfish_Boot_Source_As_Disabled
    ...              M3_OOB_1_Redfish_Boot_Source_As_Disabled

    Redfish Disable Boot Source


*** Keywords ***

Set And Verify Boot Source Override
    [Documentation]  Set and Verify Boot source override
    [Arguments]      ${override_enabled}  ${override_target}  ${override_mode}=UEFI

    # Description of argument(s):
    # override_enabled    Boot source override enable type.
    #                     ('Once', 'Continuous', 'Disabled').
    # override_target     Boot source override target.
    #                     ('Pxe', 'Cd', 'Hdd', 'Diags', 'BiosSetup', 'None').

    Redfish Set Boot Source  ${override_enabled}  ${override_target}


Suite Setup Execution
    [Documentation]  Do the post suite setup.

    # Power Off System
    Redfish.Login
    Redfish Hard Power Off  stack_mode=skip  quiet=1
    Redfish Delete All Sessions


Suite Teardown Execution
    [Documentation]  Do the post suite teardown.

    # Set BootSourceOverrideEnabled to Disabled
    Redfish.Login
    Redfish Disable Boot Source
    Redfish Delete All Sessions


Test Setup Execution
    [Documentation]  Do test case setup tasks.

    Redfish.Login


Test Teardown Execution
    [Documentation]  Do the post test teardown.

    Redfish.Logout
