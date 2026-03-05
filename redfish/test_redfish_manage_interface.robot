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
    [Documentation]  Check Redfish Serial Console Capability.
    ...
    ...  ComputerSystem (Systems) schema v1.13.0+ defines SerialConsole as
    ...  HostSerialConsole type with named sub-objects (IPMI, SSH, Telnet, WebSocket etc).
    ...  Manager schema defines SerialConsole with a ConnectTypesSupported array.
    ...  This test checks Systems first, then falls back to Managers.
    [Tags]  M1_UART_1_Redfish_Serial_Console_Capability

    # Known HostSerialConsole connection type sub-objects per DMTF schema:
    #   IPMI      - v1.13.0  (IPMI Serial-over-LAN)
    #   SSH       - v1.13.0  (Secure Shell)
    #   Telnet    - v1.13.0  (Telnet)
    #   WebSocket - v1.27.0  (WebSocket)
    @{HOST_SERIAL_CONSOLE_TYPES}=  Create List  IPMI  SSH  Telnet  WebSocket

    # Try ComputerSystem endpoint first (HostSerialConsole type, v1.13.0+).
    ${resp}=  Redfish.Get Attribute  /redfish/v1/Systems/${SYSTEM_ID}  SerialConsole  default=${None}
    ${source}=  Set Variable  Systems

    # Fall back to Manager endpoint (Manager SerialConsole type).
    ${resp}=  Run Keyword If  $resp is None
    ...  Redfish.Get Attribute  /redfish/v1/Managers/${BMC_ID}  SerialConsole  default=${None}
    ...  ELSE  Set Variable  ${resp}
    ${source}=  Run Keyword If  $resp is not None and '${source}' != 'Systems'
    ...  Set Variable  Managers
    ...  ELSE IF  $resp is None  Set Variable  None
    ...  ELSE  Set Variable  ${source}

    Log  SerialConsole source: ${source}, response: ${resp}

    Should Not Be Empty  ${resp}
    ...  msg=Failure: No Redfish SerialConsole Object found on Systems or Managers endpoint

    # Validate based on which endpoint provided the data.
    # Manager schema: has ConnectTypesSupported array (e.g. ["IPMI", "SSH", "Telnet"]).
    # ComputerSystem HostSerialConsole schema: has named sub-objects from the list above.
    ${has_connect_types}=  Run Keyword And Return Status
    ...  Dictionary Should Contain Key  ${resp}  ConnectTypesSupported
    IF  ${has_connect_types}
        Should Not Be Empty  ${resp['ConnectTypesSupported']}
        ...  msg=Failure: No Redfish SerialConsole Type Detect (ConnectTypesSupported is empty)
    ELSE
        @{resp_keys}=  Get Dictionary Keys  ${resp}
        ${found}=  Evaluate  bool(set($resp_keys) & set($HOST_SERIAL_CONSOLE_TYPES))
        Should Be True  ${found}
        ...  msg=Failure: No known HostSerialConsole type found. Expected one of: ${HOST_SERIAL_CONSOLE_TYPES}. Got keys: ${resp_keys}
    END


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
