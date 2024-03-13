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
Documentation  This module provides general keywords for dump.

Variables       ../data/variables.py

*** Variables ***

*** Keywords ***


Redfish Delete BMC Dump
    [Documentation]  Deletes a given BMC dump via Redfish..
    [Arguments]  ${dump_id}

    # Description of Argument(s):
    # dump_id  An integer value that identifies a particular dump (e.g. 1, 3).

    Redfish.Delete  /redfish/v1/Managers/${BMC_ID}/LogServices/Dump/Entries/${dump_id}


Redfish Delete All BMC Dumps
    [Documentation]  Delete all BMC dumps via Redfish.

    # Check if dump entries exist, if not return.
    ${resp}=  Redfish.Get  /redfish/v1/Managers/${BMC_ID}/LogServices/Dump/Entries
    Return From Keyword If  ${resp.dict["Members@odata.count"]} == ${0}

    Redfish.Post  /redfish/v1/Managers/${BMC_ID}/LogServices/Dump/Actions/LogService.ClearLog


Get Redfish BMC Dump Log Entries
     [Documentation]  Get the BMC dump log entries.

     ${resp}=  Redfish.Get  ${REDFISH_DUMP_URI}

     RETURN  ${resp.dict}


Redfish Delete All System Dumps
    [Documentation]  Delete all system  dumps via Redfish.

    Redfish.Post  /redfish/v1/Systems/${SYSTEM_ID}/LogServices/Dump/Actions/LogService.ClearLog


Redfish BMC Dump Should Not Exist
     [Documentation]  Verify that there is no BMC dump at dump URI.

     # Verify no dump exists.
     ${dump_entries}=  Get Redfish BMC Dump Log Entries
     Should Be Equal As Integers  0  ${dump_entries['Members@odata.count']}


Initiate BMC Dump Using Redfish And Return Task Id
     [Documentation]  Initiate BMC dump via Redfish and return its task ID.

     ${payload}=  Create Dictionary  DiagnosticDataType=Manager
     ${resp}=  Redfish.Post
     ...  /redfish/v1/Managers/${BMC_ID}/LogServices/Dump/Actions/LogService.CollectDiagnosticData
     ...  body=${payload}  valid_status_codes=[${HTTP_ACCEPTED}]

     # Example of response from above Redfish POST request.
     # "@odata.id": "/redfish/v1/TaskService/Tasks/0",
     # "@odata.type": "#Task.v1_4_3.Task",
     # "Id": "0",
     # "TaskState": "Running",
     # "TaskStatus": "OK"

     RETURN  ${resp.dict['Id']}

Create User Initiated BMC Dump Via Redfish
    [Documentation]  Generate user initiated BMC dump via Redfish and return the dump id number (e.g., "5").
    [Arguments]  ${skip_dump_completion}=0

    # Description of Argument(s):
    # skip_dump_completion          If skip_dump_completion is set to 0, this
    #                               keyword will waiting for BMC dump to
    #                               complete and returns the dump id.
    #                               Otherwise, the keyword is skipped after
    #                               initiating BMC dump and returns dump task id.

    ${payload}=  Create Dictionary  DiagnosticDataType=Manager
    ${resp}=  Redfish.Post
    ...  /redfish/v1/Managers/${BMC_ID}/LogServices/Dump/Actions/LogService.CollectDiagnosticData
    ...  body=${payload}  valid_status_codes=[${HTTP_ACCEPTED}]

    # Example of response from above Redfish POST request.
    # "@odata.id": "/redfish/v1/TaskService/Tasks/0",
    # "@odata.type": "#Task.v1_4_3.Task",
    # "Id": "0",
    # "TaskState": "Running",
    # "TaskStatus": "OK"

    Run Keyword If  ${skip_dump_completion} != 0  Return From Keyword  ${resp.dict['Id']}
    Wait Until Keyword Succeeds  5 min  15 sec  Check Task Completion  ${resp.dict['Id']}
    ${task_id}=  Set Variable  ${resp.dict['Id']}

    ${task_dict}=  Redfish.Get Properties  /redfish/v1/TaskService/Tasks/${task_id}

    # Example of HttpHeaders field of task details.
    # "Payload": {
    #   "HttpHeaders": [
    #     "Host: <BMC_IP>",
    #      "Accept-Encoding: identity",
    #      "Connection: Keep-Alive",
    #      "Accept: */*",
    #      "Content-Length: 33",
    #      "Location: /redfish/v1/Managers/${BMC_ID}/LogServices/Dump/Entries/2"]
    #    ],
    #    "HttpOperation": "POST",
    #    "JsonBody": "{\"DiagnosticDataType\":\"Manager\"}",
    #     "TargetUri":
    #       "/redfish/v1/Managers/${BMC_ID}/LogServices/Dump/Actions/LogService.CollectDiagnosticData"
    # }

    RETURN  ${task_dict["Payload"]["HttpHeaders"][-1].split("/")[-1]}


Get Dump ID
    [Documentation]  Return dump ID.
    [Arguments]   ${task_id}

    # Description of argument(s):
    # task_id        Task ID.

    # Example of HttpHeaders field of task details.
    # "Payload": {
    #   "HttpHeaders": [
    #     "Host: <BMC_IP>",
    #      "Accept-Encoding: identity",
    #      "Connection: Keep-Alive",
    #      "Accept: */*",
    #      "Content-Length: 33",
    #      "Location: /redfish/v1/Managers/${BMC_ID}/LogServices/Dump/Entries/2"]
    #    ],
    #    "HttpOperation": "POST",
    #    "JsonBody": "{\"DiagnosticDataType\":\"Manager\"}",
    #     "TargetUri":
    # "/redfish/v1/Managers/${BMC_ID}/LogServices/Dump/Actions/LogService.CollectDiagnosticData"
    # }

    ${task_dict}=  Redfish.Get Properties  /redfish/v1/TaskService/Tasks/${task_id}
    ${key}  ${value}=  Set Variable  ${task_dict["Payload"]["HttpHeaders"][-1].split(":")}
    Run Keyword If  '${key}' != 'Location'  Fail
    RETURN  ${value.strip('/').split('/')[-1]}

Get Task Status
    [Documentation]  Return task status.
    [Arguments]   ${task_id}

    # Description of argument(s):
    # task_id        Task ID.

    ${resp}=  Redfish.Get Properties  /redfish/v1/TaskService/Tasks/${task_id}
    RETURN  ${resp['TaskState']}

Check Task Completion
    [Documentation]  Check if the task is complete.
    [Arguments]   ${task_id}

    # Description of argument(s):
    # task_id        Task ID.

    ${task_dict}=  Redfish.Get Properties  /redfish/v1/TaskService/Tasks/${task_id}
    Should Be Equal As Strings  ${task_dict['TaskState']}  Completed

Create BMC User Dump
    [Documentation]  Generate user initiated BMC dump via Redfish and return
    ...  the task instance Id and response object (e.g., "5").

    ${payload}=  Create Dictionary  DiagnosticDataType=Manager
    ${resp}=  Redfish.Post
    ...  /redfish/v1/Managers/${BMC_ID}/LogServices/Dump/Actions/LogService.CollectDiagnosticData
    ...  body=${payload}  valid_status_codes=[${HTTP_ACCEPTED}]

    ${ip_resp}=  Evaluate  json.loads(r'''${resp.text}''')  json

    Return From Keyword  ${ip_resp["Id"]}  ${resp}


Wait For Task Completion
    [Documentation]  Check whether the state of task instance matches any of the
    ...  expected completion states before maximum number of retries exceeds and
    ...  exit loop in case completion state is met.
    [Arguments]  ${task_id}  ${expected_status}  ${retry_max_count}=300
    ...  ${check_state}=${FALSE}

    # Description of argument(s):
    # task_id                     the task id for which completion is
    #                             to be monitored.
    # expected_status             the task state which is to be considered as the
    #                             end of task life cycle.
    # retry_max_count             the maximum number of retry count to wait for
    #                             task to reach its completion state. Default
    #                             value of retry_max_count is 300.
    # check_state                 if set as TRUE, the task state will be
    #                             monitored whether the task state value is
    #                             valid throughout task life cycle until
    #                             expected completion state is reached.
    #                             Default value of check_state is FALSE.

    FOR  ${retry}  IN RANGE  ${retry_max_count}
        ${resp}=  Redfish.Get Properties  /redfish/v1/TaskService/Tasks/${task_id}
        ${current_task_state}=  Set Variable  ${resp["TaskState"]}
        Rprint Vars  current_task_state

        Run Keyword If  ${check_state} == ${TRUE}  Should Be True
        ...  '${resp["TaskState"]}' in ${allowed_task_state}
        ...  msg=Verify task state is valid

        Exit For Loop If
        ...  '${resp["TaskState"]}' in ${expected_status}

        Sleep  5s
    END

