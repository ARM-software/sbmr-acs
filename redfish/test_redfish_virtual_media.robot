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

Documentation      Module to test Redfish Virtual Media Action Uri
Resource           ../lib/bmc_redfish_resource.robot
Resource           ../lib/utils.robot

Suite Setup        Redfish.Login
Suite Teardown     Suite Teardown Execution


*** Test Cases ***

Test Redfish Virtual Media Action Uri
    [Documentation]  Verify Redfish Virtual Media Action Uri
    [Tags]  M21_USB_1_Redfish_Virtual_Media_Action_Uri

    ${members}=  Redfish.Get Members List
    ...  /redfish/v1/Managers/${BMC_ID}/VirtualMedia

    # Assume only one virtual media
    ${resp}=  Redfish.Get Properties  ${members}[0]

    ${eject_uri}=  Set Variable  ${resp['Actions']['#VirtualMedia.EjectMedia']['target']}
    ${insert_uri}=  Set Variable  ${resp['Actions']['#VirtualMedia.InsertMedia']['target']}

    # Make sure no image was inserted
    Run Keyword If  'Inserted' in ${resp}
    ...  Redfish POST method  ${eject_uri}  ${resp['Inserted']}

    Sleep  5 sec

    # Create payload and insert image
    ${payload}=  Create Dictionary
    ...    Image=${VM_URL}

    Redfish.Post  ${insert_uri}  body=&{payload}

    Sleep  5 sec

    ## Check image was inserted correctly
    ${resp}=  Redfish.Get Properties  ${members}[0]
    Should Be Equal  ${resp['Image']}  ${VM_URL}
    Should Be Equal  ${resp['Inserted']}  ${True}

    # Eject image after testing
    Run Keyword If  ${resp['Inserted']} == ${True}
    ...  Redfish.Post  ${eject_uri}


*** Keywords ***


Redfish POST method
    [Documentation]   Issue Redfish POST method
    [Arguments]   ${uri}  ${send}=${True}

    Run Keyword If  '${send}' == '${True}'
    ...  Redfish.Post  ${uri}


Suite Teardown Execution
    [Documentation]  Do the post suite teardown

    Redfish Delete All Sessions
