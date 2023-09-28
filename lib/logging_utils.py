#!/usr/bin/env python3

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

r"""
Provide useful error log utility keywords.
"""

import imp
import os
import sys

import gen_print as gp
from robot.libraries.BuiltIn import BuiltIn

base_path = (
    os.path.dirname(os.path.dirname(imp.find_module("gen_robot_print")[1]))
    + os.sep
)
sys.path.append(base_path + "data/")
import gen_robot_utils as gru  # NOQA
import variables as var  # NOQA

gru.my_import_resource("logging_utils.robot")


def print_error_logs(error_logs, key_list=None):
    r"""
    Print the error logs to the console screen.

    This function provides the following benefits:
    - It will specify print_var parms for the caller (e.g. hex=1).
    - It is much easier to call this function than to generate the desired code
      directly from a robot script.

    Description of argument(s):
    error_logs                      An error log dictionary such as the one
                                    returned by the 'Get Error Logs' keyword.
    key_list                        The list of keys to be printed.  This may
                                    be specified as either a python list
                                    or a space-delimited string.  In the
                                    latter case, this function will convert
                                    it to a python list. See the sprint_varx
                                    function prolog for additionatl details.

    Example use from a python script:

    ${error_logs}=  Get Error Logs
    Print Error Logs  ${error_logs}  Message Timestamp

    Sample output:

    error_logs:
      [/xyz/openbmc_project/logging/entry/3]:
        [Timestamp]:                                  1521738335735
        [Message]:
        xyz.openbmc_project.Inventory.Error.Nonfunctional
      [/xyz/openbmc_project/logging/entry/2]:
        [Timestamp]:                                  1521738334637
        [Message]:
        xyz.openbmc_project.Inventory.Error.Nonfunctional
      [/xyz/openbmc_project/logging/entry/1]:
        [Timestamp]:                                  1521738300696
        [Message]:
        xyz.openbmc_project.Inventory.Error.Nonfunctional
      [/xyz/openbmc_project/logging/entry/4]:
        [Timestamp]:                                  1521738337915
        [Message]:
        xyz.openbmc_project.Inventory.Error.Nonfunctional

    Another example call using a robot list:
    ${error_logs}=  Get Error Logs
    ${key_list}=  Create List  Message  Timestamp  Severity
    Print Error Logs  ${error_logs}  ${key_list}
    """

    if key_list is not None:
        try:
            key_list = key_list.split(" ")
        except AttributeError:
            pass

        key_list.insert(0, var.REDFISH_BMC_LOGGING_ENTRY + ".*")

    gp.print_var(error_logs, key_list=key_list)
