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

Documentation  Utilities for Robot keywords that use Redfish.

Resource                ../lib/resource.robot
Resource                ../lib/connection_client.robot
Resource                ../lib/boot_utils.robot
Resource                ../lib/common_utils.robot
Resource                ../lib/bmc_redfish_utils.robot
Resource                ../lib/ipmi_client.robot
Library                 String
Library                 DateTime
Library                 Process
Library                 OperatingSystem
Library                 gen_print.py
Library                 gen_misc.py
Library                 gen_robot_print.py
Library                 gen_cmd.py
Library                 gen_robot_keyword.py
Library                 bmc_ssh_utils.py
Library                 utils.py
Library                 var_funcs.py
Library                 SCPLibrary  WITH NAME  scp
Library                 gen_robot_valid.py
Library                 SSHLibrary

*** Variables ***

# Assign default value to QUIET for programs which may not define it.
${QUIET}  ${0}

@{BOOT_PROGRESS_STATES}           SystemHardwareInitializationComplete  OSBootStarted  OSRunning


*** Keywords ***


Verify Ping SSH And Redfish Authentication
    [Documentation]  Verify ping, SSH and redfish authentication.

    ${l_ping}=   Run Keyword And Return Status  Ping Host  ${BMC_HOST}
    Run Keyword If  '${l_ping}' == '${False}'  Fail   msg=Ping Failed

    ${l_rest}=   Run Keyword And Return Status   Redfish.Login
    Run Keyword If  '${l_rest}' == '${False}'  Fail   msg=Redfish Authentication Failed

    # Just to make sure the SSH is working.
    Open Connection And Log In
    ${system}   ${stderr}=    Execute Command   hostname   return_stderr=True
    Should Be Empty     ${stderr}


Check If BMC is Up
    [Documentation]  Wait for Host to be online. Checks every X seconds
    ...              interval for Y minutes and fails if timed out.
    ...              Default MAX timedout is 10 min, interval 10 seconds.
    [Arguments]      ${max_timeout}=${BMC_REBOOT_TIMEOUT} min
    ...              ${interval}=10 sec

    # Description of argument(s):
    # max_timeout   Maximum time to wait.
    #               This should be expressed in Robot Framework's time format
    #               (e.g. "10 minutes").
    # interval      Interval to wait between status checks.
    #               This should be expressed in Robot Framework's time format
    #               (e.g. "5 seconds").

    Wait Until Keyword Succeeds
    ...   ${max_timeout}  ${interval}   Verify Ping and Redfish Authentication


Login To OS Host
    [Documentation]  Login to OS Host and return the Login response code.
    [Arguments]  ${os_host}=${OS_HOST}  ${os_username}=${OS_USERNAME}
    ...          ${os_password}=${OS_PASSWORD}

    # Description of arguments:
    # ${os_host} IP address of the OS Host.
    # ${os_username}  OS Host Login user name.
    # ${os_password}  OS Host Login passwrd.

    Redfish Power On  stack_mode=skip  quiet=1

    SSHLibrary.Open Connection  ${os_host}
    ${resp}=  SSHLibrary.Login  ${os_username}  ${os_password}
    [Return]  ${resp}


Initiate OS Host Reboot
    [Documentation]  Initiate an OS reboot.
    [Arguments]  ${os_host}=${OS_HOST}  ${os_username}=${OS_USERNAME}
    ...          ${os_password}=${OS_PASSWORD}

    # Description of argument(s):
    # os_host      The host name or IP address of the OS.
    # os_username  The username to be used to sign in to the OS.
    # os_password  The password to be used to sign in to the OS.

    ${cmd_buf}=  Run Keyword If  '${os_username}' == 'root'
    ...      Set Variable  reboot
    ...  ELSE
    ...      Set Variable  echo ${os_password} | sudo -S reboot

    ${output}  ${stderr}  ${rc}=  OS Execute Command
    ...  ${cmd_buf}  fork=${1}


Initiate OS Host Power Off
    [Documentation]  Initiate an OS reboot.
    [Arguments]  ${os_host}=${OS_HOST}  ${os_username}=${OS_USERNAME}
    ...          ${os_password}=${OS_PASSWORD}  ${hard}=${0}

    # Description of argument(s):
    # os_host      The DNS name or IP of the OS.
    # os_username  The username to be used to sign in to the OS.
    # os_password  The password to be used to sign in to the OS.
    # hard         Indicates whether to do a hard vs. soft power off.

    ${time_string}=  Run Keyword If  ${hard}  Set Variable  ${SPACE}now
    ...  ELSE  Set Variable  ${EMPTY}

    ${cmd_buf}=  Run Keyword If  '${os_username}' == 'root'
    ...      Set Variable  shutdown${time_string}
    ...  ELSE
    ...      Set Variable  echo ${os_password} | sudo -S shutdown${time_string}

    ${output}  ${stderr}  ${rc}=  OS Execute Command
    ...  ${cmd_buf}  fork=${1}


Redfish Get Power Restore Policy
    [Documentation]  Returns the BMC power restore policy.

    ${power_restore_policy}=  Redfish.Get Attribute  /redfish/v1/Systems/${SYSTEM_ID}  PowerRestorePolicy
    [Return]  ${power_restore_policy}


Redfish Get Auto Reboot
    [Documentation]  Returns auto reboot setting.

    ${resp}=  Redfish.Get Attribute  /redfish/v1/Systems/${SYSTEM_ID}  Boot
    [Return]  ${resp["AutomaticRetryConfig"]}


Redfish Set Power Restore Policy
    [Documentation]   Set the BMC power restore policy.
    [Arguments]   ${power_restore_policy}

    # Description of argument(s):
    # power_restore_policy    Power restore policy (e.g. "AlwaysOff", "AlwaysOn", "LastState").

    ${session}=  Redfish.Login

    Redfish.Patch  /redfish/v1/Systems/${SYSTEM_ID}  body={"PowerRestorePolicy": "${power_restore_policy}"}
    ...  valid_status_codes=[${HTTP_OK},${HTTP_CREATED},${HTTP_ACCEPTED},${HTTP_NO_CONTENT}]

    Redfish.Delete  ${session}


IPMI Set Power Restore Policy
    [Documentation]   Set the BMC power restore policy using IPMI.
    [Arguments]   ${power_restore_policy}=always-off

    # Description of argument(s):
    # power_restore_policy    Power restore policies
    #                         always-on   : turn on when power is restored
    #                         previous    : return to previous state when power is restored
    #                         always-off  : stay off after power is restored

    ${resp}=  Run IPMI Standard Command  chassis policy ${power_restore_policy}
    # Example:  Set chassis power restore policy to always-off
    Should Contain  ${resp}  ${power_restore_policy}


Set Auto Reboot Setting
    [Documentation]  Set the given auto reboot setting (REST or Redfish).
    [Arguments]  ${value}

    # Description of argument(s):
    # value    The reboot setting, 1 for enabling and 0 for disabling.

    # This is to cater to boot call points and plugin script which will always
    # send using value 0 or 1. This dictionary maps to redfish string values.
    ${rest_redfish_dict}=  Create Dictionary
    ...                    1=RetryAttempts
    ...                    0=Disabled

    Redfish Set Auto Reboot  ${rest_redfish_dict["${value}"]}


Redfish Set Auto Reboot
    [Documentation]  Set the given auto reboot setting.
    [Arguments]  ${setting}

    # Description of argument(s):
    # setting    The reboot setting, "RetryAttempts" and "Disabled".

    ${session}=  Redfish.Login

    Redfish.Patch  /redfish/v1/Systems/${SYSTEM_ID}  body={"Boot": {"AutomaticRetryConfig": "${setting}"}}
    ...  valid_status_codes=[${HTTP_OK},${HTTP_CREATED},${HTTP_ACCEPTED},${HTTP_NO_CONTENT}]

    ${current_setting}=  Redfish Get Auto Reboot

    Redfish.Delete  ${session}

    Should Be Equal As Strings  ${current_setting}  ${setting}


Get Task State From File
    [Documentation]  Get task states from pre-define data/task_state.json file.

    # Example:  Task state JSON format.
    #
    # {
    #   "TaskRunning": {
    #           "TaskState": "Running",
    #           "TaskStatus": "OK"
    #   },
    #   "TaskCompleted": {
    #           "TaskState": "Completed",
    #           "TaskStatus": "OK"
    #   },
    #   "TaskException": {
    #           "TaskState": "Exception",
    #           "TaskStatus": "Warning"
    #   }
    # }

    # Python module: get_code_base_dir_path()
    ${code_base_dir_path}=  Get Code Base Dir Path
    ${task_state}=  Evaluate
    ...  json.load(open('${code_base_dir_path}data/task_state.json'))  modules=json
    Rprint Vars  task_state

    [Return]  ${task_state}


Redfish Set Boot Default
    [Documentation]  Set and Verify Boot source override
    [Arguments]      ${override_enabled}  ${override_target}  ${override_mode}=UEFI

    # Description of argument(s):
    # override_enabled    Boot source override enable type.
    #                     ('Once', 'Continuous', 'Disabled').
    # override_target     Boot source override target.
    #                     ('Pxe', 'Cd', 'Hdd', 'Diags', 'BiosSetup', 'None').
    # override_mode       Boot source override mode (relevant only for x86 arch).
    #                     ('Legacy', 'UEFI').

    ${data}=  Create Dictionary  BootSourceOverrideEnabled=${override_enabled}
    ...  BootSourceOverrideTarget=${override_target}

    Set To Dictionary  ${data}  BootSourceOverrideMode  ${override_mode}

    ${payload}=  Create Dictionary  Boot=${data}

    Redfish.Patch  /redfish/v1/Systems/${SYSTEM_ID}  body=&{payload}
    ...  valid_status_codes=[${HTTP_OK},${HTTP_CREATED},${HTTP_ACCEPTED},${HTTP_NO_CONTENT}]

    ${resp}=  Redfish.Get Attribute  /redfish/v1/Systems/${SYSTEM_ID}  Boot
    Should Be Equal As Strings  ${resp["BootSourceOverrideEnabled"]}  ${override_enabled}
    Should Be Equal As Strings  ${resp["BootSourceOverrideTarget"]}  ${override_target}
    Should Be Equal As Strings  ${resp["BootSourceOverrideMode"]}  ${override_mode}


Get Redfish Settings Object Uri
    [Documentation]  Get Redfish Setting Object URI. If @Redfish.Settings
    ...              not support, then return the origin URI
    [Arguments]      ${redfish_uri}

    ${resp}=  Redfish.Get Attribute  ${redfish_uri}  @Redfish.Settings

    ${uris}=  Get Value From Nested Dict  @odata.id  ${resp}

    ${notFound}=  Run Keyword And Return Status
    ...  Should Be Empty  ${uris}

    ${uri}=
    ...  Run Keyword If  '${notFound}' == '${TRUE}'
    ...      Set Variable  ${redfish_uri}
    ...  ELSE
    ...      Set Variable  ${uris}[0]

    [Return]  ${uri}


Redfish Set Boot Source
    [Documentation]  Set and Verify Boot source override
    [Arguments]      ${override_enabled}  ${override_target}

    # Description of argument(s):
    # override_enabled    Boot source override enable type.
    #                     ('Once', 'Continuous', 'Disabled').
    # override_target     Boot source override target.
    #                     ('Pxe', 'Cd', 'Hdd', 'Diags', 'BiosSetup', 'None').

    ${data}=  Create Dictionary  BootSourceOverrideEnabled=${override_enabled}
    ...  BootSourceOverrideTarget=${override_target}

    ${payload}=  Create Dictionary  Boot=${data}

    ${setting_uri}=  Get Redfish Settings Object Uri  /redfish/v1/Systems/${SYSTEM_ID}

    Redfish.Patch  ${setting_uri}  body=&{payload}
    ...  valid_status_codes=[${HTTP_OK},${HTTP_CREATED},${HTTP_ACCEPTED},${HTTP_NO_CONTENT}]

    ${resp}=  Redfish.Get Attribute  ${setting_uri}  Boot
    Should Be Equal As Strings  ${resp["BootSourceOverrideEnabled"]}  ${override_enabled}
    Should Be Equal As Strings  ${resp["BootSourceOverrideTarget"]}  ${override_target}


Redfish Disable Boot Source
    [Documentation]  Disable and Verify Boot source override

    # Description of argument(s):
    # override_enabled    Boot source override enable type.
    #                     ('Once', 'Continuous', 'Disabled').

    ${setting_uri}=  Get Redfish Settings Object Uri  /redfish/v1/Systems/${SYSTEM_ID}

    # If BootSourceOverrideEnabled as disabled, then return
    ${resp}=  Redfish.Get Attribute  ${setting_uri}  Boot

    Run Keyword If  '${resp["BootSourceOverrideEnabled"]}'=='Disabled'
    ...  Return From Keyword

    # Set BootSourceOverrideTarget to None
    ${data}=  Create Dictionary  BootSourceOverrideTarget=None
    ${payload}=  Create Dictionary  Boot=${data}

    Redfish.Patch  ${setting_uri}  body=&{payload}
    ...  valid_status_codes=[${HTTP_OK},${HTTP_CREATED},${HTTP_ACCEPTED},${HTTP_NO_CONTENT}]

    # Verify BootSourceOverrideEnabled as Disable. If not, Set to Disabled
    ${data}=  Create Dictionary  BootSourceOverrideEnabled=Disabled
    ${payload}=  Create Dictionary  Boot=${data}

    ${resp}=  Redfish.Get Attribute  ${setting_uri}  Boot
    Run Keyword If  '${resp["BootSourceOverrideEnabled"]}'!='Disabled'
    ...  Redfish.Patch  ${setting_uri}  body=&{payload}
    ...  valid_status_codes=[${HTTP_OK},${HTTP_CREATED},${HTTP_ACCEPTED},${HTTP_NO_CONTENT}]

    # Verify BootSourceOverrideEnabled and return status
    ${resp}=  Redfish.Get Attribute  ${setting_uri}  Boot
    Should Be Equal As Strings  ${resp["BootSourceOverrideEnabled"]}  Disabled


# Redfish state keywords.

Redfish Get BMC State
    [Documentation]  Return BMC health state.

    # "Enabled" ->  BMC Ready, "Starting" -> BMC NotReady

    # Example:
    # "Status": {
    #    "Health": "OK",
    #    "HealthRollup": "OK",
    #    "State": "Enabled"
    # },

    ${status}=  Redfish.Get Attribute  /redfish/v1/Managers/${BMC_ID}  Status
    [Return]  ${status["State"]}


Redfish Get Host State
    [Documentation]  Return host power and health state.

    # Refer: http://redfish.dmtf.org/schemas/v1/Resource.json#/definitions/Status

    # Example:
    # "PowerState": "Off",
    # "Status": {
    #    "Health": "OK",
    #    "HealthRollup": "OK",
    #    "State": "StandbyOffline"
    # },

    ${chassis}=  Redfish.Get Properties  /redfish/v1/Chassis/${CHASSIS_ID}
    [Return]  ${chassis["PowerState"]}  ${chassis["Status"]["State"]}


Redfish Get Boot Progress
    [Documentation]  Return boot progress state.

    # Example: /redfish/v1/Systems/${SYSTEM_ID}/
    # "BootProgress": {
    #    "LastState": "OSRunning"
    # },
    # "PowerState": "On"

    ${resp}=  Redfish.Get Properties  /redfish/v1/Systems/${SYSTEM_ID}

    ${BootProgress}=  Run Keyword And Return Status
    ...  Get From Dictionary  ${resp}  BootProgress

    # If BootProgress not exists, fallback to PowerState
    ${LastState}=
    ...  Run Keyword If  '${BootProgress}'=='${TRUE}'
    ...    Set Variable  ${resp["BootProgress"]["LastState"]}
    ...  ELSE
    ...    Set Variable  ${resp["PowerState"]}

    [Return]  ${LastState}  ${resp["Status"]["State"]}


Redfish Get States
    [Documentation]  Return all the BMC and host states in dictionary.
    [Timeout]  120 Seconds

    # Refer: openbmc/docs/designs/boot-progress.md

    ${session}=  Redfish.Login

    ${bmc_state}=  Redfish Get BMC State
    ${chassis_state}  ${chassis_status}=  Redfish Get Host State
    ${boot_progress}  ${host_state}=  Redfish Get Boot Progress

    ${states}=  Create Dictionary
    ...  bmc=${bmc_state}
    ...  chassis=${chassis_state}
    ...  host=${host_state}
    ...  boot_progress=${boot_progress}

    # Disable loggoing state to prevent huge log.html record when boot
    # test is run in loops.
    #Log  ${states}

    Redfish.Delete  ${session}

    [Return]  ${states}


Redfish Delete All Sessions
    [Documentation]  Delete all active redfish sessions.

    ${session_location}=  Redfish.Login

    ${resp_list}=  Redfish.Get Members List
    ...  /redfish/v1/SessionService/Sessions

    # Remove the current login session at the end.
    Remove Values From List  ${resp_list}  ${session_location}

    FOR  ${session}  IN  @{resp_list}
        Run Keyword And Ignore Error  Redfish.Delete  ${session}
    END

    Redfish.Logout

Is BMC Standby
    [Documentation]  Check if BMC is ready and host at standby.

    ${standby_states}=  Create Dictionary
    ...  bmc=Enabled
    ...  chassis=Off
    ...  host=Disabled
    ...  boot_progress=None

    Set To Dictionary  ${standby_states}  boot_progress=NA

    Wait Until Keyword Succeeds  3 min  10 sec  Redfish Get States

    Wait Until Keyword Succeeds  5 min  10 sec  Match State  ${standby_states}


Match State
    [Documentation]  Check if the expected and current states are matched.
    [Arguments]  ${match_state}

    # Description of argument(s):
    # match_state      Expected states in dictionary.

    ${current_state}=  Redfish Get States
    Dictionaries Should Be Equal  ${match_state}  ${current_state}


Redfish Initiate Auto Reboot
    [Documentation]  Initiate an auto reboot.
    [Arguments]  ${interval}=2000

    # Description of argument(s):
    # interval  Value in milliseconds to set Watchdog interval

    # Set auto reboot policy
    Redfish Set Auto Reboot  RetryAttempts

    Redfish Power Operation  On

    Wait Until Keyword Succeeds  2 min  5 sec  Is Boot Progress Changed

    # Set watchdog timer
    Set Watchdog Interval Using Busctl  ${interval}


Is Boot Progress Changed
    [Documentation]  Get BootProgress state and expect boot state mismatch.
    [Arguments]  ${boot_state}=None

    # Description of argument(s):
    # boot_state   Value of the BootProgress state to match against.

    ${boot_progress}  ${host_state}=  Redfish Get Boot Progress

    Should Not Be Equal  ${boot_progress}   ${boot_state}


Is Boot Progress At Required State
    [Documentation]  Get BootProgress state and expect boot state to match.
    [Arguments]  ${boot_state}=None

    # Description of argument(s):
    # boot_state   Value of the BootProgress state to match.

    ${boot_progress}  ${host_state}=  Redfish Get Boot Progress

    Should Be Equal  ${boot_progress}   ${boot_state}


Is Boot Progress At Any State
    [Documentation]  Get BootProgress state and expect boot state to match
    ...              with any of the states mentioned in the list.
    [Arguments]  ${boot_states}=@{BOOT_PROGRESS_STATES}

    # Description of argument(s):
    # boot_states   List of the BootProgress states to match.

    ${boot_progress}  ${host_state}=  Redfish Get Boot Progress
    Should Contain Any  ${boot_progress}  @{boot_states}


Is Host At State
    [Documentation]  Get Host state and check if it matches
    ...   user input expected state.
    [Arguments]  ${expected_host_state}

    # Description of argument(s):
    # expected_host_state  Expected Host State to check.(e.g. Quiesced).

    ${boot_progress}  ${host_state}=  Redfish Get Boot Progress

    Should Be Equal  ${host_state}  ${expected_host_state}


Get BIOS Attribute
    [Documentation]  Get the BIOS attribute for /redfish/v1/Systems/${SYSTEM_ID}/Bios.

    # Python module:  get_member_list(resource_path)
    ${systems}=  Redfish_Utils.Get Member List  /redfish/v1/Systems
    ${bios_attr_dict}=  Redfish.Get Attribute  ${systems[0]}/Bios  Attributes

    [Return]  ${bios_attr_dict}


Set BIOS Attribute
    [Documentation]  PATCH the BIOS attribute for /redfish/v1/Systems/${SYSTEM_ID}/Bios.
    [Arguments]  ${attribute_name}  ${attribute_value}

    # Description of argument(s):
    # attribute_name     Any valid BIOS attribute.
    # attribute_value    Valid allowed attribute values.

    # Python module:  get_member_list(resource_path)
    ${systems}=  Redfish_Utils.Get Member List  /redfish/v1/Systems
    Redfish.Patch  ${systems[0]}/Bios/Settings  body={"Attributes":{"${attribute_name}":"${attribute_value}"}}


Is BMC Operational
    [Documentation]  Check if BMC is enabled.

    ${bmc_status} =  Redfish Get BMC State
    Should Be Equal  ${bmc_status}  Enabled


Verify Host Power State
    [Documentation]  Get the Host Power state and compare it with the expected state.
    [Arguments]  ${expected_power_state}

    # Description of argument(s):
    # expected_power_state   State of Host e.g. Off or On.

    ${power_state}  ${health_status}=  Redfish Get Host State
    Should Be Equal  ${power_state}  ${expected_power_state}


Verify Host Is Up
    [Documentation]  Verify Host is Up.

    Wait Until Keyword Succeeds  3 min  30 sec  Verify Host Power State  On
    # Python module:  os_execute(cmd)
    Wait Until Keyword Succeeds  10 min  30 sec  OS Execute Command  uptime


Capture System Log Via SOL
    [Documentation]  Open SOL Connection and capture boot logs
    [Arguments]  ${type}=${SOL_TYPE}  ${login_prompt}=${SOL_LOGIN_OUTPUT}

    Close SOL Connection  ${type}

    Run Keyword If  '${type}'=='ssh'
    ...    SSH SOL And Capture Logs  ${login_prompt}
    ...  ELSE
    ...    IPMI SOL And Capture Logs  ${login_prompt}

    Close SOL Connection  ${type}


Close SOL Connection
    [Documentation]  Close SOL connection
    [Arguments]  ${type}=${SOL_TYPE}

    Run Keyword If  '${type}'=='ssh'
    ...      SSHLibrary.Close All Connections
    ...  ELSE
    ...      Deactivate SOL Via IPMI


SSH SOL And Capture Logs
    [Documentation]  Open SSH SOL connection and capture boot logs until
    [Arguments]  ${login_prompt}=${SOL_LOGIN_OUTPUT}

    SSHLibrary.Open Connection  ${BMC_HOST}  port=${SOL_SSH_PORT}

    ${status}=   Run Keyword And Return Status
    ...  SSHLibrary.Login  ${BMC_USERNAME}  ${BMC_PASSWORD}
    Run Keyword If  ${status} == ${False}  Fail  SSH Login failed

    # Additional Cmds Before SoL, i.e., HPE - DSP
    SSHLibrary.Set Client Configuration   timeout=5 sec
    Run Keyword If  '${SOL_SSH_CMD}'!='None'
    ...  Run Keyword And Ignore Error  SSHLibrary.Write  ${SOL_SSH_CMD}

    # Read until command prompt. Timeout for 10 mins
    SSHLibrary.Set Client Configuration   timeout=${SOL_LOGIN_TIMEOUT}
    ${output}=  SSHLibrary.Read Until  ${login_prompt}

    Create File  ${IPMI_SOL_LOG_FILE}  ${output}


IPMI SOL And Capture Logs
    [Documentation]  Open IPMI SOL connection and capture boot logs until
    [Arguments]      ${login_prompt}=${SOL_LOGIN_OUTPUT}

    Activate SOL Via IPMI

    # Content takes maximum of 10 minutes to display in SOL console
    ${status}=  Run Keyword And Return Status  Wait Until Keyword Succeeds
    ...  ${SOL_LOGIN_TIMEOUT}  5 secs  Check IPMI SOL Output Content  ${login_prompt}

    Run Keyword If  ${status} == ${False}  Fail  IPMI SOL Not Match ${login_prompt}

