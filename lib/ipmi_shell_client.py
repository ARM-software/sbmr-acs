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

import gen_cmd as gc
import gen_print as gp
import var_funcs as vf
from robot.libraries.BuiltIn import BuiltIn

SBMR_RAW_EVENT = {
    "Platform_Error_Record": {
        "CPER": [
            # Firmware Error Record Reference
            "0x48 0x00 0x00 0x00 0x20 0x00 0x00 0x00 0x5d 0x05 0x03 0x00 0xe9 0x00 0x00 0x00 " \
            "0x96 0x2a 0x21 0x81 0xed 0x09 0x96 0x49 0x94 0x71 0x8d 0x72 0x9c 0x8e 0x69 0xed " \
            "0xe9 0x3e 0xa1 0x41 0xe1 0xfc 0x67 0x3e 0x01 0x7e 0x97 0xea 0xdc 0x6b 0x96 0x8f " \
            "0x01 0x00 0x00 0x00 0xb0 0x3b 0xfb 0x32 0xaf 0x3c 0x54 0xec 0x18 0xdb 0x5c 0x02 " \
            "0x1a 0xfe 0x43 0xfb 0xfa 0xaa 0x3a 0x00 0x00 0x02 0x00 0x00 0x00 0x00 0x00 0x00 " \
            "0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x7c 0xc2 0x54 0xf8 0x1b 0xe8 0xe7 0x8d " \
            "0x76 0x5a 0x2e 0x63 0x33 0x9f 0xc9 0x9a"
        ],
    },
    "Boot_Progress_Code": {
        "Status": [
            # Host processor power-on initialization
            "0x01 0x00 0x00 0x00 0x00 0x10 0x01 0x00 0x00"
        ],
    },
}


def get_system_interface_capabilities():
    r"""
    Get system interface capabilities and return as a dictionary.

    Example:

    SSIF_Capabilities:
        [transaction_support]:      multi-part read-write supported.
        [pec_support]:              pec support
        [ssif_version]:             version 1
        [input_msg_size]:           255
        [ouput_msg_size]:           255
    """

    cmd_buf = "ipmitool raw 0x06 0x57 0x0"
    BuiltIn().log("Issue : " + cmd_buf)

    rc, stdout, stderr = gc.shell_cmd(cmd_buf, return_stderr=1)

    if rc == 0:
        BuiltIn().log("Response : " + stdout)
    BuiltIn().should_be_equal(rc, 0, stderr)

    ipmi_output = stdout.split()

    transaction = int(ipmi_output[1], 16) >> 6
    pec = int(ipmi_output[1], 16) >> 3 & int(1)
    version = int(ipmi_output[1], 16) & int(0x7)
    input_msg_size = int(ipmi_output[2], 16)
    output_msg_size = int(ipmi_output[3], 16)

    pec_support = "PEC not support"
    if pec == 1:
        pec_support = "PEC support"

    ssif_version = "Unknown"
    if version == 0:
        ssif_version = "Version 1"

    transaction_type = "Unknown"
    if transaction == 0:
        transaction_type = "Single-part supported."
    elif transaction == 1:
        transaction_type = "Multi-part supported. Start and End only."
    elif transaction == 2:
        transaction_type = "Multi-part supported. Start, Middle and End supported."

    output = vf.create_var_dict(transaction_type, pec_support, ssif_version,
                                input_msg_size, output_msg_size)

    return output


def get_sbmr_command_support():
    r"""
    Retrieve Get Command Support to check SBMR command support

    Example :

    SBMR Command List:
       [send_platform_error_record]      false
       [send_boot_progress_code]         false
       [get_boot_progress_code]          false
    """

    cmd_buf = "ipmitool raw 0x06 0x0a 0x0e 0x2c 0x00 0xae"
    BuiltIn().log("Issue : " + cmd_buf)

    rc, stdout, stderr = gc.shell_cmd(cmd_buf, return_stderr=1)

    if rc == 0:
        BuiltIn().log("Response : " + stdout)
    else:
        BuiltIn().log("Response (error) : " + stderr)

    send_platform_error_record = 0
    send_boot_progress_code = 0
    get_boot_progress_code = 0

    if rc != 0:
        return vf.create_var_dict(send_platform_error_record,
                                  send_boot_progress_code,
                                  get_boot_progress_code)

    ipmi_output = stdout.split()

    # Command 0x0 ~ 0x7
    cmds = int(ipmi_output[0], 16)

    if cmds & int(0x2):
        send_platform_error_record = 1
    if cmds & int(0x4):
        send_boot_progress_code = 1
    if cmds & int(0x8):
        get_boot_progress_code = 1

    return vf.create_var_dict(send_platform_error_record,
                              send_boot_progress_code,
                              get_boot_progress_code)


def send_platform_error_record():
    r"""
    Issue Send Platform Error Record Command and check the capability
    by returning body code
    """

    cmd_buf = "ipmitool raw 0x2c 0x01 0xae " + SBMR_RAW_EVENT["Platform_Error_Record"]["CPER"][0]
    BuiltIn().log("Issue : " + cmd_buf)

    rc, stdout, stderr = gc.shell_cmd(cmd_buf, return_stderr=1)

    if rc == 0:
        BuiltIn().log("Response : " + stdout)
    BuiltIn().should_be_equal(rc, 0, stderr)

    # Get Body Code
    ipmi_output = stdout.split()

    return int(ipmi_output[0], 16)


def send_boot_progress_code():
    r"""
    Issue Send Boot Progress Code Command and check the capability
    by returning body code
    """

    # Host processor power-on initialization
    cmd_buf = "ipmitool raw 0x2c 0x02 0xae " + SBMR_RAW_EVENT["Boot_Progress_Code"]["Status"][0]
    BuiltIn().log("Issue : " + cmd_buf)

    rc, stdout, stderr = gc.shell_cmd(cmd_buf, return_stderr=1)

    if rc == 0:
        BuiltIn().log("Response : " + stdout)
    BuiltIn().should_be_equal(rc, 0, stderr)

    # Get Body Code
    ipmi_output = stdout.split()

    return int(ipmi_output[0], 16)


def get_boot_progress_code():
    r"""
    Issue Get Boot Progress Code Command and check the capability
    by returning body code
    """

    cmd_buf = "ipmitool raw 0x2c 0x03 0xae"
    BuiltIn().log("Issue : " + cmd_buf)

    rc, stdout, stderr = gc.shell_cmd(cmd_buf, return_stderr=1)

    if rc == 0:
        BuiltIn().log("Response : " + stdout)
    BuiltIn().should_be_equal(rc, 0, stderr)

    # Get Body Code
    ipmi_output = stdout.split()

    return int(ipmi_output[0], 16)
