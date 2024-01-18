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
Documentation    This suite tests Redfish Host power operations.

Resource          ../lib/boot_utils.robot
Resource          ../lib/common_utils.robot
Resource          ../lib/utils.robot
Resource          ../lib/ipmi_client.robot

Suite Setup       Suite Setup Execution
Suite Teardown    Suite Teardown Execution


*** Test Cases ***

Verify Redfish Host GracefulShutdown
    [Documentation]  Verify Redfish host graceful shutdown operation.
    [Tags]  M2_OOB_1_Redfish_Host_GracefulShutdown


    # Wait until OS login prompt show up, then issue GracefulShutdown
    Redfish Hard Power Off  stack_mode=skip
    Redfish Power Operation  On

    # Start monitoring boot log
    # Content takes maximum of 10 minutes to display in SOL console
    Capture System Log Via SOL  ${SOL_TYPE}  ${SOL_LOGIN_OUTPUT}

    # Redfish Host Graceful Shutdown
    Redfish Power Off


Verify Redfish Host PowerOn
    [Documentation]  Verify Redfish host power on operation.
    [Tags]  M2_OOB_1_Redfish_Host_PowerOn


    Redfish Power On


Verify Redfish Host PowerOff
    [Documentation]  Verify Redfish host power off operation.
    [Tags]  M2_OOB_1_Redfish_Host_PowerOff


    Redfish Hard Power Off


Verify Redfish Host GracefulRestart
    [Documentation]  Verify Redfish host graceful restart operation.
    [Tags]  M2_OOB_1_Redfish_Host_GracefulRestart


    # Wait until OS login prompt show up, then issue GracefulRestart
    Redfish Hard Power Off  stack_mode=skip
    Redfish Power Operation  On

    # Start monitoring boot log
    # Content takes maximum of 10 minutes to display in SOL console
    Capture System Log Via SOL  ${SOL_TYPE}  ${SOL_LOGIN_OUTPUT}

    # Redfish Host Graceful Restart
    RF SYS GracefulRestart


Verify Redfish Host ForceRestart
    [Documentation]  Verify Redfish host force restart operation
    [Tags]  M2_OOB_1_Redfish_Host_ForceRestart


    RF SYS ForceRestart


Verify Redfish Host PowerCycle
    [Documentation]  Verify Redfish host Power Cycle operation
    [Tags]  M2_OOB_1_Redfish_Host_PowerCycle


    Redfish Power Cycle


*** Keywords ***

Suite Setup Execution
    [Documentation]  Do the post suite setup.

    # Power Off System and Set BootSourceOverrideEnabled to Disabled
    Redfish Hard Power Off  stack_mode=skip  quiet=1

    Redfish.Login
    Redfish Disable Boot Source
    Redfish Delete All Sessions


Suite Teardown Execution
    [Documentation]  Do the post suite teardown

    Close SOL Connection  ${SOL_TYPE}

    Redfish Delete All Sessions
