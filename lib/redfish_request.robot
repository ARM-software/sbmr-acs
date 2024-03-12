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

Documentation     Redfish request library which provide keywords for creating session,
...               sending POST, PUT, DELETE, PATCH, GET etc. request using redfish_request.py
...               library file. It also contain other keywords which uses redfish_request.py
...               library infrastructure.

Resource          bmc_redfish_resource.robot
Resource          rest_response_code.robot
Library           redfish_request.py

*** Keywords ***

Redfish Generic Login Request
    [Documentation]  Do Redfish login request.
    [Arguments]  ${user_name}  ${password}

    # Description of argument(s):
    # user_name   User name of BMC.
    # password    Password of BMC.

    ${client_id}=  Create Dictionary  ClientID=None
    ${oem_data}=  Create Dictionary  OpenBMC=${client_id}
    ${data}=  Create Dictionary  UserName=${user_name}  Password=${password}  Oem=${oem_data}

    Set Test Variable  ${uri}  /redfish/v1/SessionService/Sessions
    ${resp}=  Request_Login  headers=None  url=${uri}  credential=${data}
    Should Be Equal As Strings  ${resp.status_code}  ${HTTP_CREATED}

    RETURN  ${resp}


Redfish Generic Session Request
    [Documentation]  Do Redfish login request and store the session details.
    [Arguments]  ${user_name}  ${password}

    # Description of argument(s):
    # user_name   User name of BMC.
    # password    Password of BMC.

    ${session_dict}=   Create Dictionary
    ${session_resp}=   Redfish Generic Login Request  ${user_name}  ${password}

    ${auth_token}=  Create Dictionary  X-Auth-Token  ${session_resp.headers['X-Auth-Token']}

    Set To Dictionary  ${session_dict}  headers  ${auth_token}
    Set To Dictionary  ${session_dict}  Location  ${session_resp.headers['Location']}


    Set To Dictionary  ${session_dict}  Content  ${session_resp.content}

    Set Global Variable  ${active_session_info}  ${session_dict}
    Append To List  ${session_dict_list}  ${session_dict}

    RETURN  ${session_dict}
