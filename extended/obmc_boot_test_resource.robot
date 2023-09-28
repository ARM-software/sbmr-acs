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
Documentation  This file is resourced by obmc_boot_test.py to set initial
...            variable values, etc.

Library   ../lib/state.py

Library   ../lib/obmc_boot_test.py
Library   Collections

*** Variables ***
# Initialize program parameters variables.
# Create parm_list containing all of our program parameters.  This is used by
# 'Rqprint Pgm Header'
@{parm_list}                  bmc_nickname  ssh_port  https_port  bmc_host  bmc_username
...  bmc_password  ipmi_username  ipmi_password  os_host  os_username  os_password
...  bmc_id  system_id  chassis_id  pdu_host  pdu_username
...  pdu_password  pdu_slot_no  bmc_serial_host  bmc_serial_port
...  stack_mode  boot_stack  boot_list  max_num_tests  plug_in_dir_paths
...  status_file_path  bmc_model  boot_pass  boot_fail  state_change_timeout
...  power_on_timeout  power_off_timeout  boot_fail_threshold  delete_errlogs
...  call_post_stack_plug  boot_table_path  test_mode  quiet  debug

# Initialize each program parameter.
${bmc_host}                   ${EMPTY}
${ssh_port}                   22
${https_port}                 443
${bmc_nickname}               ${bmc_host}
${bmc_username}               root
${bmc_password}               0penBmc
${ipmi_username}              ${bmc_username}
${ipmi_password}              ${bmc_password}
${bmc_id}                     ${bmc_id}
${system_id}                  ${system_id}
${chassis_id}                 ${chassis_id}
${os_host}                    ${EMPTY}
${os_username}                root
${os_password}                P@ssw0rd
${pdu_host}                   ${EMPTY}
${pdu_username}               admin
${pdu_password}               admin
${pdu_slot_no}                ${EMPTY}
${bmc_serial_host}            ${EMPTY}
${bmc_serial_port}            ${EMPTY}
${stack_mode}                 normal
${boot_stack}                 ${EMPTY}
${boot_list}                  ${EMPTY}
${max_num_tests}              0
${plug_in_dir_paths}          ${EMPTY}
${status_file_path}           ${EMPTY}
${bmc_model}                  ${EMPTY}
# The reason boot_pass and boot_fail are parameters is that it is possible to
# be called by a program that has already done some tests.  This allows us to
# keep the grand total.
${boot_pass}                  ${0}
${boot_fail}                  ${0}
${state_change_timeout}       3 mins
${power_on_timeout}           14 mins
${power_off_timeout}          2 mins
# If the number of boot failures, exceeds boot_fail_threshold, this program
# returns non-zero.
${boot_fail_threshold}        ${0}
${delete_errlogs}             ${0}
# This variable indicates whether post_stack plug-in processing should be done.
${call_post_stack_plug}       ${1}
# The path to the boot_table.json file which defines the boot requirements.  This defaults to the value of
# the BOOT_TABLE_PATH environment variable or to data/boot_table.json.
${boot_table_path}            ${None}
${test_mode}                  0
${quiet}                      0
${debug}                      0

# Flag variables.
# test_really_running is needed by DB_Logging plug-in.
${test_really_running}      ${1}


*** Keywords ***
OBMC Boot Test
    [Documentation]  Run the OBMC boot test.
    [Teardown]  OBMC Boot Test Teardown
    [Arguments]  ${pos_arg1}=${EMPTY}  &{arguments}

    # Note: If I knew how to specify a keyword teardown in python, I would
    # rename the "OBMC Boot Test Py" python function to "OBMC Boot Test" and
    # do away with this robot keyword.

    Run Keyword If  '${pos_arg1}' != '${EMPTY}'
    ...  Set To Dictionary  ${arguments}  loc_boot_stack=${pos_arg1}

    OBMC Boot Test Py  &{arguments}
