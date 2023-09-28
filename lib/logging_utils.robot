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
Documentation    Error logging utility keywords.

Resource        bmc_redfish_utils.robot
Variables       ../data/variables.py

*** Variables ***


# Define variables for use by callers of 'Get Error Logs'.
${low_severity_errlog_regex}  \\.(Informational|Notice|Debug|OK)$
&{low_severity_errlog_filter}  Severity=${low_severity_errlog_regex}
&{low_severity_errlog_filter_args}  filter_dict=${low_severity_errlog_filter}  regex=${True}  invert=${True}
# The following is equivalent to &{low_severity_errlog_filter_args} but the name may be more intuitive for
# users. Example usage:
# ${err_logs}=  Get Error Logs  &{filter_low_severity_errlogs}
&{filter_low_severity_errlogs}  &{low_severity_errlog_filter_args}

*** Keywords ***

Filter Expected Logging Events
    [Documentation]  Get redfish logging entry, remove the user input expected
    ...              log event and return the object list.
    [Arguments]  ${expected_event}=None

    # Description of argument(s):
    # expected_eventd   Event log list.

    ${all_event_list}=  Get Redfish Event Logs
    Remove Values From List  ${all_event_list}  ${expected_event}

    [Return]  ${all_event_list}


Get IPMI SEL Setting
    [Documentation]  Returns status for given IPMI SEL setting.
    [Arguments]  ${setting}
    # Description of argument(s):
    # setting  SEL setting which needs to be read(e.g. "Last Add Time").

    ${resp}=  Run IPMI Standard Command  sel info

    ${setting_line}=  Get Lines Containing String  ${resp}  ${setting}
    ...  case-insensitive
    ${setting_status}=  Fetch From Right  ${setting_line}  :${SPACE}

    [Return]  ${setting_status}


Get Event Logs
    [Documentation]  Get all available EventLog entries.

    #{
    #  "@odata.context": "/redfish/v1/$metadata#LogEntryCollection.LogEntryCollection",
    #  "@odata.id": "/redfish/v1/Systems/${SYSTEM_ID}/LogServices/EventLog/Entries",
    #  "@odata.type": "#LogEntryCollection.LogEntryCollection",
    #  "Description": "Collection of System Event Log Entries",
    #  "Members": [
    #  {
    #    "@odata.context": "/redfish/v1/$metadata#LogEntry.LogEntry",
    #    "@odata.id": "/redfish/v1/Systems/${SYSTEM_ID}/LogServices/EventLog/Entries/1",
    #    "@odata.type": "#LogEntry.v1_4_0.LogEntry",
    #    "Created": "2019-05-29T13:19:27+00:00",
    #    "EntryType": "Event",
    #    "Id": "1",
    #    "Message": "org.open_power.Host.Error.Event",
    #    "Name": "System DBus Event Log Entry",
    #    "Severity": "Critical"
    #  }
    #  ],
    #  "Members@odata.count": 1,
    #  "Name": "System Event Log Entries"
    #}

    ${members}=  Redfish.Get Attribute  ${EVENT_LOG_URI}Entries  Members
    [Return]  ${members}


Get Redfish Event Logs
    [Documentation]  Pack the list of all available EventLog entries in dictionary.
    [Arguments]   ${quiet}=1  &{filter_struct_args}

    # Description of argument(s):
    # quiet                  Indicates whether this keyword should run without any output to the
    #                        console, 0 = verbose, 1 = quiet.
    # filter_struct_args     filter_struct args (e.g. filter_dict, regex, etc.) to be passed
    #                        directly to the Filter Struct keyword.  See its prolog for details.

    ${packed_dict}=  Create Dictionary
    ${error_logs}=  Get Event Logs

    FOR  ${idx}   IN  @{error_logs}
       Set To Dictionary  ${packed_dict}    ${idx['@odata.id']}=${idx}
    END

    ${num_filter_struct_args}=  Get Length  ${filter_struct_args}
    Return From Keyword If  '${num_filter_struct_args}' == '${0}'  &{packed_dict}
    ${filtered_error_logs}=  Filter Struct  ${packed_dict}  &{filter_struct_args}

    [Return]  ${filtered_error_logs}


Get Event Logs Not Ok
    [Documentation]  Get all event logs where the 'Severity' is not 'OK'.

    ${members}=  Get Event Logs
    ${severe_logs}=  Evaluate  [elog for elog in $members if elog['Severity'] != 'OK']
    [Return]  ${severe_logs}


Get Number Of Event Logs
    [Documentation]  Return the number of EventLog members.

    ${members}=  Get Event Logs
    ${num_members}=  Get Length  ${members}
    [Return]  ${num_members}


Redfish Purge Event Log
    [Documentation]  Do Redfish EventLog purge.

    ${target_action}=  redfish_utils.Get Target Actions
    ...  /redfish/v1/Systems/${SYSTEM_ID}/LogServices/EventLog/  LogService.ClearLog
    Redfish.Post  ${target_action}  body={'target': '${target_action}'}
    ...  valid_status_codes=[${HTTP_OK}, ${HTTP_NO_CONTENT}]


Event Log Should Not Exist
    [Documentation]  Event log entries should not exist.

    ${elogs}=  Get Event Logs
    Should Be Empty  ${elogs}  msg=System event log entry is not empty.


Redfish Clear PostCodes
    [Documentation]  Do Redfish PostCodes purge from system.

    ${target_action}=  redfish_utils.Get Target Actions
    ...  /redfish/v1/Systems/${SYSTEM_ID}/LogServices/PostCodes/  LogService.ClearLog
    Redfish.Post  ${target_action}  body={'target': '${target_action}'}
    ...  valid_status_codes=[${HTTP_OK}, ${HTTP_NO_CONTENT}]


Redfish Get PostCodes
    [Documentation]  Perform Redfish GET request and return the PostCodes entries as a list of dictionaries.

    # Formatted example output from Rprint vars  members
    # members:
    #  [0]:
    #    [@odata.id]:          /redfish/v1/Systems/${SYSTEM_ID}/LogServices/PostCodes/Entries/B1-1
    #    [@odata.type]:        #LogEntry.v1_8_0.LogEntry
    #    [AdditionalDataURI]:  /redfish/v1/Systems/${SYSTEM_ID}/LogServices/PostCodes/Entries/B1-1/attachment
    #    [Created]:            2022-08-06T04:38:10+00:00
    #    [EntryType]:          Event
    #    [Id]:                 B1-1
    #    [Message]:            Message": "Boot Count: 4: TS Offset: 0.0033; POST Code: 0x43
    #    [MessageArgs]:
    #      [0]:                4
    #      [1]:                0.0033
    #      [2]:                0x43
    #    [MessageId]:          OpenBMC.0.2.BIOSPOSTCodeASCII
    #    [Name]:               POST Code Log Entry
    #    [Severity]:           OK

    ${members}=  Redfish.Get Attribute  /redfish/v1/Systems/${SYSTEM_ID}/LogServices/PostCodes/Entries
    ...  Members  valid_status_codes=[${HTTP_OK}, ${HTTP_NO_CONTENT}]

    [Return]  ${members}
