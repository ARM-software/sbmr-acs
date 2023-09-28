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

Documentation    Module to test IPMI Inband User Account functionality.
Resource         ../lib/ipmi_shell_client.robot

Test Teardown    Sleep  ${IPMI_DELAY}

*** Test Cases ***

Test Host IPMI Inband Add User Account
    [Documentation]  Verify IPMI Inband Add User Account on Host
    [Tags]  M1_OOB_1_IPMI_7_IB_Add_User_Account  M2_OOB_2_IPMI_7_IB_Add_User_Account
    ...     M21_IPMI_1_IB_Add_User_Account

    ${random_username}=  Generate Random String  8  [LETTERS]
    ${random_userid}=  Evaluate  random.randint(3, 15)  modules=random

    # Add user account
    Run Shell Inband IPMI Standard Command  user set name ${random_userid} ${random_username}
    ${user_info}=  Run Shell Inband IPMI Standard Command  channel getaccess 1 ${random_userid}
    ${name_line}=  Get Lines Containing String  ${user_info}  User Name

    Should Contain  ${name_line}  ${random_username}

    # Delete user account
    Run Shell Inband IPMI Standard Command  user set name ${random_userid} ""
    ${user_info}=  Run Shell Inband IPMI Standard Command  channel getaccess 1 ${random_userid}
    ${name_line}=  Get Lines Containing String  ${user_info}  User Name
