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

Documentation  Utilities for Robot keywords that do not use REST.

Resource                ../lib/resource.robot
Resource                ../lib/connection_client.robot
Resource                ../lib/boot_utils.robot
Library                 String
Library                 DateTime
Library                 Process
Library                 OperatingSystem
Library                 gen_print.py
Library                 gen_robot_print.py
Library                 gen_cmd.py
Library                 gen_robot_valid.py
Library                 gen_robot_keyword.py
Library                 bmc_ssh_utils.py
Library                 utils.py
Library                 var_funcs.py
Library                 SCPLibrary  WITH NAME  scp

*** Variables ***

# Assign default value to QUIET for programs which may not define it.
${QUIET}  ${0}

# Initialize default debug value to 0.
${DEBUG}         ${0}


*** Keywords ***


Wait For Host To Ping
    [Documentation]  Wait for the given host to ping.
    [Arguments]  ${host}  ${timeout}=${BMC_REBOOT_TIMEOUT}min
    ...          ${interval}=5 sec

    # Description of argument(s):
    # host      The host name or IP of the host to ping.
    # timeout   The amount of time after which ping attempts cease.
    #           This should be expressed in Robot Framework's time format
    #           (e.g. "10 seconds").
    # interval  The amount of time in between attempts to ping.
    #           This should be expressed in Robot Framework's time format
    #           (e.g. "5 seconds").

    Wait Until Keyword Succeeds  ${timeout}  ${interval}  Ping Host  ${host}


Ping Host
    [Documentation]  Ping the given host.
    [Arguments]     ${host}

    # Description of argument(s):
    # host      The host name or IP of the host to ping.

    Should Not Be Empty    ${host}   msg=No host provided
    ${RC}   ${output}=     Run and return RC and Output    ping -c 4 ${host}
    Log     RC: ${RC}\nOutput:\n${output}
    Should be equal     ${RC}   ${0}


Check OS
    [Documentation]  Attempts to ping the host OS and then checks that the host
    ...              OS is up by running an SSH command.

    [Arguments]  ${os_host}=${OS_HOST}  ${os_username}=${OS_USERNAME}
    ...          ${os_password}=${OS_PASSWORD}  ${quiet}=${QUIET}
    ...          ${print_string}=${EMPTY}
    [Teardown]  SSHLibrary.Close Connection

    # Description of argument(s):
    # os_host           The DNS name/IP of the OS host associated with our BMC.
    # os_username       The username to be used to sign on to the OS host.
    # os_password       The password to be used to sign on to the OS host.
    # quiet             Indicates whether this keyword should write to console.
    # print_string      A string to be printed before checking the OS.

    Log To Console  ${print_string}  no_newline=True

    # Attempt to ping the OS. Store the return code to check later.
    ${ping_rc}=  Run Keyword and Return Status  Ping Host  ${os_host}

    SSHLibrary.Open connection  ${os_host}

    ${status}  ${msg}=  Run Keyword And Ignore Error  SSHLibrary.Login  ${os_username}
    ...  ${os_password}
    ${err_msg1}=  Sprint Error  ${msg}
    ${err_msg}=  Catenate  SEPARATOR=  \n  ${err_msg1}
    Run Keyword If  '${status}' == 'FAIL'  Fail  msg=${err_msg}
    ${output}  ${stderr}  ${rc}=  Execute Command  uptime  return_stderr=True
    ...        return_rc=True

    ${temp_msg}=  Catenate  Could not execute a command on the operating
    ...  system.\n
    ${err_msg1}=  Sprint Error  ${temp_msg}
    ${err_msg}=  Catenate  SEPARATOR=  \n  ${err_msg1}

    # If the return code returned by "Execute Command" is non-zero, this
    # keyword will fail.
    Should Be Equal  ${rc}  ${0}  msg=${err_msg}
    # We will likewise fail if there is any stderr data.
    Should Be Empty  ${stderr}

    ${temp_msg}=  Set Variable  Could not ping the operating system.\n
    ${err_msg1}=  Sprint Error  ${temp_msg}
    ${err_msg}=  Catenate  SEPARATOR=  \n  ${err_msg1}
    # We will likewise fail if the OS did not ping, as we could SSH but not
    # ping
    Should Be Equal As Strings  ${ping_rc}  ${TRUE}  msg=${err_msg}


Wait for OS
    [Documentation]  Waits for the host OS to come up via calls to "Check OS".
    [Arguments]  ${os_host}=${OS_HOST}  ${os_username}=${OS_USERNAME}
    ...          ${os_password}=${OS_PASSWORD}  ${timeout}=${OS_WAIT_TIMEOUT}
    ...          ${quiet}=${0}
    [Teardown]  Printn

    # Description of argument(s):
    # os_host           The DNS name or IP of the OS host associated with our
    #                   BMC.
    # os_username       The username to be used to sign on to the OS host.
    # os_password       The password to be used to sign on to the OS host.
    # timeout           The timeout in seconds indicating how long you're
    #                   willing to wait for the OS to respond.
    # quiet             Indicates whether this keyword should write to console.

    # The interval to be used between calls to "Check OS".
    ${interval}=  Set Variable  5

    ${message}=  Catenate  Checking every ${interval} seconds for up to
    ...  ${timeout} seconds for the operating system to communicate.
    Qprint Timen  ${message}

    Wait Until Keyword Succeeds  ${timeout} sec  ${interval}  Check OS
    ...                          ${os_host}  ${os_username}  ${os_password}
    ...                          print_string=\#

    Qprintn

    Qprint Timen  The operating system is now communicating.


Is OS Starting
    [Documentation]  Check if boot progress is OS starting.
    ${boot_progress}=  Redfish Get Boot Progress
    Should Be Equal  ${boot_progress}  OSStart


Is OS Off
    [Documentation]  Check if boot progress is "Off".
    ${boot_progress}=  Redfish Get Boot Progress
    Should Be Equal  ${boot_progress}  Off


Get Boot Progress To OS Starting State
    [Documentation]  Get the system to a boot progress state of 'FW Progress,
    ...  Starting OS'.

    ${boot_progress}=  Redfish Get Boot Progress
    Run Keyword If  '${boot_progress}' == 'OSStart'
    ...  Log  Host is already in OS starting state
    ...  ELSE
    ...  Run Keywords  Initiate Host PowerOff  AND  Initiate Host Boot
    ...  AND  Wait Until Keyword Succeeds  10 min  10 sec  Is OS Starting


Check If warmReset is Initiated
    [Documentation]  Ping would be still alive, so try SSH to connect
    ...              if fails the ports are down indicating reboot
    ...              is in progress

    # Warm reset adds 3 seconds delay before forcing reboot
    # To minimize race conditions, we wait for 7 seconds
    Sleep  7s
    ${alive}=   Run Keyword and Return Status
    ...    Open Connection And Log In
    Return From Keyword If   '${alive}' == '${False}'    ${False}
    [Return]    ${True}


Create OS Console Command String
    [Documentation]  Return a command string to start OS console logging.

    # First make sure that the ssh_pw program is available.
    ${cmd}=  Catenate  which ssh_pw 2>/dev/null || find
    ...  ${EXECDIR} -name 'ssh_pw'

    Dprint Issuing  ${cmd}
    ${rc}  ${output}=  Run And Return Rc And Output  ${cmd}
    Rdpvars  rc  output

    Should Be Equal As Integers  0  ${rc}  msg=Could not find ssh_pw.

    ${ssh_pw_file_path}=  Set Variable  ${output}

    ${cmd}=  Catenate  ${ssh_pw_file_path} ${BMC_PASSWORD} -p ${HOST_SOL_PORT}
    ...  -o "StrictHostKeyChecking no" ${BMC_USERNAME}@${BMC_HOST} ${BMC_CONSOLE_CLIENT}

    [Return]  ${cmd.strip()}


Get SOL Console Pid
    [Documentation]  Get the pid of the active SOL console job.
    [Arguments]  ${expect_running}=${0}  ${log_file_path}=${EMPTY}

    # Description of argument(s):
    # expect_running                If set and if no SOL console job is found, print debug info and fail.
    # log_file_path                 Needed to print debug info if expect_running is set and no pid is found.

    # Find the pid of the active system console logging session (if any).
    ${search_string}=  Create OS Console Command String
    # At least in some cases, ps output does not show double quotes so we must
    # replace them in our search string with the regexes to indicate that they
    # are optional.
    ${search_string}=  Replace String  ${search_string}  "  ["]?
    ${ps_cmd}=  Catenate  ps axwwo user,pid,cmd
    ${cmd_buf}=  Catenate  echo $(${ps_cmd} | egrep '${search_string}' |
    ...  egrep -v grep | cut -c10-14)
    Dprint Issuing  ${cmd_buf}
    ${rc}  ${os_con_pid}=  Run And Return Rc And Output  ${cmd_buf}
    Rdpvars  os_con_pid
    # If rc is not zero it just means that there is no OS Console process
    # running.

    Return From Keyword If  '${os_con_pid}' != '${EMPTY}'  ${os_con_pid}
    Return From Keyword If  '${expect_running}' == '${0}'  ${os_con_pid}

    Cmd Fnc  cat ${log_file_path} ; echo ; ${ps_cmd}  quiet=${0}
    ...  print_output=${1}  show_err=${1}
    Valid Value  os_con_pid


Stop SOL Console Logging
    [Documentation]  Stop system console logging and return log output.
    [Arguments]  ${log_file_path}=${EMPTY}
    ...          ${targ_file_path}=${EXECDIR}${/}logs${/}
    ...          ${return_data}=${1}

    # If there are multiple system console processes, they will all be stopped.
    # If there is no existing log file this keyword will return an error
    # message to that effect (and write that message to targ_file_path, if
    # specified).
    # NOTE: This keyword will not fail if there is no running system console
    # process.

    # Description of arguments:
    # log_file_path   The file path that was used to call "Start SOL
    #                 Console Logging".  See that keyword (above) for details.
    # targ_file_path  If specified, the file path to which the source
    #                 file path (i.e. "log_file_path") should be copied.
    # return_data     If this is set to ${1}, this keyword will return the SOL
    #                 data to the caller as a unicode string.

    ${log_file_path}=  Create OS Console File Path  ${log_file_path}

    ${os_con_pid}=  Get SOL Console Pid

    ${cmd_buf}=  Catenate  kill -9 ${os_con_pid}
    Run Keyword If  '${os_con_pid}' != '${EMPTY}'  Dprint Issuing  ${cmd_buf}
    ${rc}  ${output}=  Run Keyword If  '${os_con_pid}' != '${EMPTY}'
    ...  Run And Return Rc And Output  ${cmd_buf}
    Run Keyword If  '${os_con_pid}' != '${EMPTY}'  Rdpvars  rc  output

    Run Keyword If  '${targ_file_path}' != '${EMPTY}'
    ...  Run Keyword And Ignore Error
    ...  Copy File  ${log_file_path}  ${targ_file_path}

    ${output}=  Set Variable  ${EMPTY}
    ${loc_quiet}=  Evaluate  ${debug}^1
    ${rc}  ${output}=  Run Keyword If  '${return_data}' == '${1}'
    ...  Cmd Fnc  cat ${log_file_path} 2>/dev/null  quiet=${loc_quiet}
    ...  print_output=${0}  show_err=${0}

    [Return]  ${output}


Start SOL Console Logging
    [Documentation]  Start system console log to file.
    [Arguments]  ${log_file_path}=${EMPTY}  ${return_data}=${1}

    # This keyword will first call "Stop SOL Console Logging".  Only then will
    # it start SOL console logging.  The data returned by "Stop SOL Console
    # Logging" will in turn be returned by this keyword.

    # Description of arguments:
    # log_file_path   The file path to which system console log data should be
    #                 written.  Note that this path is taken to be a location
    #                 on the machine where this program is running rather than
    #                 on the Open BMC system.
    # return_data     If this is set to ${1}, this keyword will return any SOL
    #                 data to the caller as a unicode string.

    ${log_file_path}=  Create OS Console File Path  ${log_file_path}

    ${log_output}=  Stop SOL Console Logging  ${log_file_path}
    ...  return_data=${return_data}

    # Validate by making sure we can create the file.  Problems creating the
    # file would not be noticed by the subsequent ssh command because we fork
    # the command.
    Create File  ${log_file_path}
    ${sub_cmd_buf}=  Create OS Console Command String
    # Routing stderr to stdout so that any startup error text will go to the
    # output file.
    ${cmd_buf}=  Catenate  ${sub_cmd_buf} > ${log_file_path} 2>&1 &
    Dprint Issuing  ${cmd_buf}
    ${rc}  ${output}=  Run And Return Rc And Output  ${cmd_buf}
    # Because we are forking this command, we essentially will never get a
    # non-zero return code or any output.
    Should Be Equal  ${rc}  ${0}

    Wait Until Keyword Succeeds  10 seconds  0 seconds
    ...   Get SOL Console Pid  ${1}  ${log_file_path}

    [Return]  ${log_output}


Mac Address To Hex String
    [Documentation]   Converts MAC address into hex format.
    ...               Example
    ...               Given the following MAC: 00:01:6C:80:02:78
    ...               This keyword will return: 0x00 0x01 0x6C 0x80 0x02 0x78
    ...               Description of arguments:
    ...               i_macaddress  MAC address in the following format
    ...               00:01:6C:80:02:78
    [Arguments]    ${i_macaddress}

    # Description of arguments:
    # i_macaddress   The MAC address.

    ${mac_hex}=  Catenate  0x${i_macaddress.replace(':', ' 0x')}
    [Return]    ${mac_hex}


IP Address To Hex String
    [Documentation]   Converts IP address into hex format.
    ...               Example:
    ...               Given the following IP: 10.3.164.100
    ...               This keyword will return: 0xa 0x3 0xa4 0xa0
    [Arguments]    ${i_ipaddress}

    # Description of arguments:
    # i_macaddress   The IP address in the format 10.10.10.10.

    @{ip}=  Split String  ${i_ipaddress}    .
    ${index}=  Set Variable  ${0}

    FOR    ${item}     IN      @{ip}
        ${hex}=  Convert To Hex    ${item}    prefix=0x    lowercase=yes
        Set List Value    ${ip}    ${index}    ${hex}
        ${index}=  Set Variable    ${index + 1}
    END
    ${ip_hex}=  Catenate    @{ip}

    [Return]    ${ip_hex}


Redfish Get BMC Version
    [Documentation]  Get BMC version via Redfish.

    ${output}=  Redfish.Get Attribute  ${REDFISH_BASE_URI}Managers/${BMC_ID}  FirmwareVersion
    [Return]  ${output}

Redfish Get Host Version
    [Documentation]  Get host version via Redfish.

    ${output}=  Redfish.Get Attribute  ${REDFISH_BASE_URI}Systems/${SYSTEM_ID}  BiosVersion
    [Return]  ${output}


Validate IP On BMC
    [Documentation]  Validate IP address is present in set of IP addresses.
    [Arguments]  ${ip_address}  ${ip_data}

    # Description of argument(s):
    # ip_address  IP address to check (e.g. xx.xx.xx.xx).
    # ip_data     Set of the IP addresses present.

    Should Contain Match  ${ip_data}  ${ip_address}/*
    ...  msg=${ip_address} not found in the list provided.


Is BMC Unpingable
    [Documentation]  Check if BMC is unpingable.

    ${RC}  ${output}=  Run and return RC and Output  ping -c 4 ${BMC_HOST}
    Log  RC: ${RC}\nOutput:\n${output}
    Should be equal  ${RC}  ${1}


Redfish BMC Match States
    [Documentation]  Verify the BMC match state.
    [Arguments]  ${match_state}

    # Description of argument(s):
    # match_state    Match the state of BMC.

    ${bmc_state}=  Redfish Get BMC State
    Should Be Equal As Strings  ${match_state}  ${bmc_state}

