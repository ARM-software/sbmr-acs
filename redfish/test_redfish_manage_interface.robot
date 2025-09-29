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

Documentation      Module to check Redfish manage interface
Resource           ../lib/bmc_redfish_resource.robot
Resource           ../lib/utils.robot

Suite Setup        Redfish.Login
Suite Teardown     Suite Teardown Execution


*** Test Cases ***

Check Redfish Graphical Console Capability
    [Documentation]  Check Redfish Graphical Console Capability
    [Tags]  M21_PCI_1_Redfish_Graphical_Console_Capability

    ${resp}=  Redfish.Get Properties  /redfish/v1/Managers/${BMC_ID}

    Log  ${resp}

    Should Not Be Empty  ${resp['GraphicalConsole']}
    ...  msg=Failure: No Redfish GraphicalConsole Object Detect
    Should Not Be Empty  ${resp['GraphicalConsole']['ConnectTypesSupported']}
    ...  msg=Failure: No Redfish GraphicalConsole Type Detect

    @{connectTypes}=  Set Variable
    ...  ${resp['GraphicalConsole']['ConnectTypesSupported']}

    Should Contain  ${connectTypes}  KVMIP


Check Redfish Serial Console Capability
    [Documentation]  Check Redfish Serial Console Capability
    [Tags]  M1_UART_1_Redfish_Serial_Console_Capability

    ${resp}=  Redfish.Get Properties  /redfish/v1/Systems/${SYSTEM_ID}

    Log  ${resp}

    Should Not Be Empty  ${resp['SerialConsole']}
    ...  msg=Failure: No Redfish SerialConsole Object Detect
    Should Not Be Empty  ${resp['SerialConsole']['ConnectTypesSupported']}
    ...  msg=Failure: No Redfish SerialConsole Type Detect


Check Redfish Host Interface Capability
    [Documentation]  Check Redfish Host Interface Capability
    [Tags]  M2_IB_1_Redfish_Host_Interface_Capability

    ${interface}=  Redfish.Get Members List
    ...  /redfish/v1/Managers/${BMC_ID}/HostInterfaces/

    Should Not Be Empty  ${interface}
    ...  msg=Failure: No Redfish HostInterfaces Detect


*** Keywords ***

Suite Teardown Execution
    [Documentation]  Do the post suite teardown

    Redfish Delete All Sessions
