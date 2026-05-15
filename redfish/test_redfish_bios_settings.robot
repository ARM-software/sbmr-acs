# Copyright (c) 2026, Arm Limited or its affiliates. All rights reserved.
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
Documentation       Test Redfish BIOS Settings Resource support
Resource            ../lib/resource.robot
Resource            ../lib/bmc_redfish_resource.robot
Resource            ../lib/bmc_redfish_utils.robot
Library             Collections

Suite Setup         Suite Setup Execution
Suite Teardown      Suite Teardown Execution
Test Setup          Test Setup Execution
Test Teardown       Test Teardown Execution


*** Test Cases ***
Verify BMC Redfish BIOS Settings Resource
    [Documentation]  Test Redfish BIOS Settings Resource support
    [Tags]  M5_OOB_1_Redfish_BIOS_Settings_Resource

    Skip If BIOS Settings Unsupported

    ${bios_uri}=  Set Variable  /redfish/v1/Systems/${SYSTEM_ID}/Bios

    ${redfish_settings}=  Redfish.Get Attribute  ${bios_uri}  @Redfish.Settings
    Should Not Be Empty  ${redfish_settings}
    ...  BIOS resource exists but Redfish Settings is missing.

    ${settings_object}=  Get From Dictionary  ${redfish_settings}  SettingsObject
    ${settings_uri}=  Get From Dictionary  ${settings_object}  @odata.id
    Should Not Be Empty  ${settings_uri}
    ...  BIOS resource exists but Redfish SettingsObject URI is missing.

    ${bios_settings}=  Redfish.Get Properties  ${settings_uri}
    Should Not Be Empty  ${bios_settings}
    ...  BIOS SettingsObject URI is not accessible: ${settings_uri}

    Dictionary Should Contain Key  ${bios_settings}  Attributes
    ...  BIOS SettingsObject is accessible but Attributes property is missing.


*** Keywords ***
Skip If BIOS Settings Unsupported
    [Documentation]  Skip BIOS settings tests when the platform does not declare support.

    Skip If  '${M5_OOB_1_EXPOSE_BIOS_SETTINGS_SUPPORT}' != '1'
    ...  M5_OOB_1 not applicable: platform does not declare user-accessible BIOS settings support.


Suite Setup Execution
    [Documentation]  Do suite setup.

    Redfish.Login
    Delete All Redfish Sessions

Suite Teardown Execution
    [Documentation]  Do suite teardown.

    Redfish.Login
    Delete All Redfish Sessions

Test Setup Execution
    [Documentation]  Do test setup.

    Redfish.Login

Test Teardown Execution
    [Documentation]  Do test teardown.

    Redfish.Logout
