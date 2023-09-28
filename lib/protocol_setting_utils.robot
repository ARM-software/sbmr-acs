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

Documentation  Protocol settings utilities keywords.

Resource         ../lib/resource.robot
Resource         ../lib/utils.robot


*** Keywords ***

Enable SSH Protocol
    [Documentation]  Enable or disable SSH protocol.
    [Arguments]  ${enable_value}=${True}

    # Description of argument(s}:
    # enable_value  Enable or disable SSH, e.g. (true, false).

    ${ssh_state}=  Create Dictionary  ProtocolEnabled=${enable_value}
    ${data}=  Create Dictionary  SSH=${ssh_state}

    Redfish.Patch  ${REDFISH_NW_PROTOCOL_URI}  body=&{data}
    ...  valid_status_codes=[${HTTP_NO_CONTENT}]

    # Wait for timeout for new values to take effect.
    Sleep  ${NETWORK_TIMEOUT}s


Verify SSH Protocol State
    [Documentation]  verify SSH protocol state.
    [Arguments]  ${state}=${True}

    # Description of argument(s}:
    # state  Enable or disable SSH, e.g. (true, false)

    # Sample output:
    # {
    #   "@odata.id": "/redfish/v1/Managers/bmc/NetworkProtocol",
    #   "@odata.type": "#ManagerNetworkProtocol.v1_5_0.ManagerNetworkProtocol",
    #   "Description": "Manager Network Service",
    #   "FQDN": "bmc",
    #  "HTTP": {
    #    "Port": 0,
    #    "ProtocolEnabled": false
    #  },
    #  "HTTPS": {
    #    "Certificates": {
    #      "@odata.id": "/redfish/v1/Managers/bmc/NetworkProtocol/HTTPS/Certificates"
    #    },
    #    "Port": xxx,
    #    "ProtocolEnabled": true
    #  },
    #  "HostName": "xxxxbmc",
    #  "IPMI": {
    #    "Port": xxx,
    #    "ProtocolEnabled": true
    #  },
    #  "Id": "NetworkProtocol",
    #  "NTP": {
    #    "NTPServers": [
    #      "xx.xx.xx.xx",
    #      "xx.xx.xx.xx",
    #      "xx.xx.xx.xx"
    #    ],
    #    "ProtocolEnabled": true
    #  },
    #  "Name": "Manager Network Protocol",
    #  "SSH": {
    #    "Port": xx,
    #    "ProtocolEnabled": true
    #  },
    #  "Status": {
    #    "Health": "OK",
    #    "HealthRollup": "OK",
    #    "State": "Enabled"
    #  }

    ${resp}=  Redfish.Get  ${REDFISH_NW_PROTOCOL_URI}
    Should Be Equal As Strings  ${resp.dict['SSH']['ProtocolEnabled']}  ${state}
    ...  msg=Protocol states are not matching.


Enable IPMI Protocol
    [Documentation]  Enable or disable IPMI protocol.
    [Arguments]  ${enable_value}=${True}

    # Description of argument(s}:
    # enable_value  Enable or disable IPMI, e.g. (true, false).

    ${ipmi_state}=  Create Dictionary  ProtocolEnabled=${enable_value}
    ${data}=  Create Dictionary  IPMI=${ipmi_state}

    Redfish.Patch  ${REDFISH_NW_PROTOCOL_URI}  body=&{data}
    ...  valid_status_codes=[${HTTP_NO_CONTENT}]

    # Wait for timeout for new values to take effect.
    Sleep  ${NETWORK_TIMEOUT}s


Verify IPMI Protocol State
    [Documentation]  Verify IPMI protocol state.
    [Arguments]  ${state}=${True}

    # Description of argument(s}:
    # state  Enable or disable IPMI, e.g. (true, false)

    ${resp}=  Redfish.Get  ${REDFISH_NW_PROTOCOL_URI}
    Should Be Equal As Strings  ${resp.dict['IPMI']['ProtocolEnabled']}  ${state}
    ...  msg=Protocol states are not matching.
