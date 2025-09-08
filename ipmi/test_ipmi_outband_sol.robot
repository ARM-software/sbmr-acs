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

Documentation    Module to Test Host UART Interface For IPMI SOL.
Resource         ../lib/utils.robot

Suite Setup      Suite Setup Execution
Suite Teardown   Suite Teardown Execution


*** Variables ***


*** Test Cases ***

Test Host UART Interface For SOL
    [Documentation]  Test Host UART is BSA Compliant UART For IPMI SOL
    [Tags]  M1_UART_2_IPMI_SOL

    # Capture system boot log and timeout for 10 mins
    Initiate Host Boot Via External IPMI  wait=${0}
    Capture System Log Via SOL  ${SOL_TYPE}  ${SOL_LOGIN_OUTPUT}

    # Verify UART from dmesg
    ${console_tty}=  Verify BSA Compliant UART From Boot Log

    Should Not Be Empty  ${console_tty}


*** Keywords ***

Verify BSA Compliant UART From Boot Log
    [Documentation]  Parse system boot log (dmesg) for BSA compliant UART
    [Arguments]  ${file_path}=${IPMI_SOL_LOG_FILE}

    ${output}=  OperatingSystem.Get File  ${file_path}  encoding_errors=ignore

    # ===== Collecting ACPI SPCR Records =====
    # [    0.000000] ACPI: SPCR: console: pl011,mmio32,0xfe201000,115200
    @{matches}=  Get Regexp Matches  ${output}  ACPI: SPCR: console: .*

    ${spcr_records}=  Create List
    FOR  ${line}  IN  @{matches}
      ${address}=   Get Regexp Matches  ${line}  ,(0x.*),  1
      Run Keyword If  '${address}[0]' != '${EMPTY}'
      ...   Append To List  ${spcr_records}  ${address}[0]
    END

    ${spcr_num}=  Get Length  ${spcr_records}
    Should Not Be Equal As Integers  ${spcr_num}  0
    ...  msg=Failure: No ACPI SPCR Records Found

    # ===== Collecting TTY device =====
    # [    0.022374] BCM2837:00: ttyAMA0 at MMIO 0xfe201000 (irq = 22, base_baud = 0) is a SBSA
    @{matches}=  Get Regexp Matches  ${output}  tty.* at MMIO .*

    ${tty_lists}=  Create Dictionary
    FOR  ${line}  IN  @{matches}
      ${item}=  Split String  ${line}
      Set To Dictionary  ${tty_lists}  ${item}[0]=${item}[3]
    END

    # ===== Match SPCR records with TTY device =====
    # Key : ttyAMA0, Value : 0xfe201000
    ${spcr_tty_lists}=  Create Dictionary
    FOR  ${address}  IN  @{spcr_records}
      FOR  ${key}  ${value}  IN  &{tty_lists}
        Run Keyword If  '${address}' == '${value}'
        ...    Set To Dictionary  ${spcr_tty_lists}  ${key}=${value}
      END
    END

    # ===== Verify Console TTY is BSA compliant UART =====
    # [    0.960641] printk: console [ttyAMA0] enabled
    # Accept both:
    #   printk: console [ttyAMA0] enabled
    #   printk: legacy console [ttyAMA0] enabled
    ${ttyConsole}=  Get Regexp Matches  ${output}  (?m)printk: (?:legacy )?console \[(tty[^\]]+)\] enabled  1

    Dictionary Should Contain Key  ${spcr_tty_lists}  ${ttyConsole}[0]
    ...  msg=Failure: Console UART not a BSA compliant UART

    RETURN  ${ttyConsole}[0]


Suite Setup Execution
    [Documentation]  Do the post test setup.

    Run External IPMI Standard Command  chassis power off
    Sleep  10 sec

    Run External IPMI Standard Command  chassis bootdev none ${IPMI_OPTIONS_EFIBOOT}


Suite Teardown Execution
    [Documentation]  Do the post test teardown.

    Close SOL Connection  ${SOL_TYPE}

