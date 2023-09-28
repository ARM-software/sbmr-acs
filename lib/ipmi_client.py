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
A python companion file for ipmi_client.robot.
"""

import collections

import gen_cmd as gc
import gen_print as gp
from robot.libraries.BuiltIn import BuiltIn

# Set default values for required IPMI options.
ipmi_interface = "lanplus"
ipmi_cipher_suite = BuiltIn().get_variable_value("${IPMI_CIPHER_LEVEL}", "17")
ipmi_timeout = BuiltIn().get_variable_value("${IPMI_TIMEOUT}", "3")
ipmi_port = BuiltIn().get_variable_value("${IPMI_PORT}", "623")
ipmi_username = BuiltIn().get_variable_value("${IPMI_USERNAME}", "root")
ipmi_password = BuiltIn().get_variable_value("${IPMI_PASSWORD}", "0penBmc")
ipmi_host = BuiltIn().get_variable_value("${BMC_HOST}")

# Create a list of the required IPMI options.
ipmi_required_options = ["I", "C", "N", "p", "U", "P", "H"]
# The following dictionary maps the ipmitool option names (e.g. "I") to our
# more descriptive names (e.g. "interface") for the required options.
ipmi_option_name_map = {
    "I": "interface",
    "C": "cipher_suite",
    "N": "timeout",
    "p": "port",
    "U": "username",
    "P": "password",
    "H": "host",
}


def send_stdin_to_process(process_handle, data: str, press_enter: bool = True):
    r"""
    Sends `data` to process including finally an optional return key (if `press_enter` is
    true).

    `process_handle` is the regular robot process handle returned by keyword `Start Process`
    (robot lib: Process)
    """
    # get underlying process object calling the robot keyword
    process_lib = BuiltIn().get_library_instance('Process')
    process = process_lib.get_process_object(process_handle)

    if press_enter:
        data += "\n"

    process.stdin.write(data.encode())
    process.stdin.flush()


def create_ipmi_ext_command_string(command, **options):
    r"""
    Create and return an IPMI external command string which is fit to be run
    from a bash command line.

    Example:

    ipmi_ext_cmd = create_ipmi_ext_command_string('power status')

    Result:
    ipmitool -I lanplus -C 3 -p 623 -P ******** -H x.x.x.x power status

    Example:

    ipmi_ext_cmd = create_ipmi_ext_command_string('power status', C='4')

    Result:
    ipmitool -I lanplus -C 4 -p 623 -P ******** -H x.x.x.x power status

    Description of argument(s):
    command                         The ipmitool command (e.g. 'power status').
    options                         Any desired options that are understood by
                                    ipmitool (see iptmitool's help text for a
                                    complete list).  If the caller does NOT
                                    provide any of several required options
                                    (e.g. "P", i.e. password), this function
                                    will include them on the caller's behalf
                                    using default values.
    """

    new_options = collections.OrderedDict()
    for option in ipmi_required_options:
        # This is to prevent boot table "-N 10" vs user input timeout.
        if " -N " in command and option == "N":
            continue
        if option in options:
            # If the caller has specified this particular option, use it in
            # preference to the default value.
            new_options[option] = options[option]
            # Delete the value from the caller's options.
            del options[option]
        else:
            # The caller hasn't specified this required option so specify it
            # for them using the global value.
            var_name = "ipmi_" + ipmi_option_name_map[option]
            value = eval(var_name)
            new_options[option] = value
    # Include the remainder of the caller's options in the new options
    # dictionary.
    for key, value in options.items():
        new_options[key] = value

    return gc.create_command_string("ipmitool", command, new_options)


def verify_ipmi_user_parm_accepted():
    r"""
    Determine whether the OBMC accepts the '-U' ipmitool option and adjust
    the global ipmi_required_options accordingly.
    """

    # Assumption: "U" is in the global ipmi_required_options.
    global ipmi_required_options
    print_output = 0

    command_string = create_ipmi_ext_command_string("power status")
    rc, stdout = gc.shell_cmd(
        command_string, print_output=print_output, show_err=0, ignore_err=1
    )
    gp.qprint_var(rc, 1)
    if rc == 0:
        # The OBMC accepts the ipmitool "-U" option so new further work needs
        # to be done.
        return

    # Remove the "U" option from ipmi_required_options to allow us to create a
    # command string without the "U" option.
    if "U" in ipmi_required_options:
        del ipmi_required_options[ipmi_required_options.index("U")]
    command_string = create_ipmi_ext_command_string("power status")
    rc, stdout = gc.shell_cmd(
        command_string, print_output=print_output, show_err=0, ignore_err=1
    )
    gp.qprint_var(rc, 1)
    if rc == 0:
        # The "U" option has been removed from the ipmi_required_options
        # global variable.
        return

    message = "Unable to run ipmitool (with or without the '-U' option).\n"
    gp.print_error(message)

    # Revert to original ipmi_required_options by inserting 'U' right before
    # 'P'.
    ipmi_required_options.insert(ipmi_required_options.index("P"), "U")


def verify_ipmi_cipher_suite_accepted():
    global ipmi_cipher_suite
    print_output = 0

    command_string = create_ipmi_ext_command_string("power status", C='17')
    rc, stdout = gc.shell_cmd(
        command_string, print_output=print_output, show_err=0, ignore_err=1
    )
    gp.qprint_var(rc, 1)
    if rc == 0:
        ipmi_cipher_suite = "17"
        return

    command_string = create_ipmi_ext_command_string("power status", C='3')
    rc, stdout = gc.shell_cmd(
        command_string, print_output=print_output, show_err=0, ignore_err=1
    )
    gp.qprint_var(rc, 1)
    if rc == 0:
        ipmi_cipher_suite = "3"
        BuiltIn().set_global_variable("${IPMI_CIPHER_LEVEL}", ipmi_cipher_suite)
        gp.print_timen(
            "**Warning** Unable to use IPMI cipher suite 17. Fallback to cipher suite 3."
        )
        return

    gp.print_timen(
        "**Error** Unable to use IPMI cipher suite 17 or 3."
    )


def verify_ipmi_boot_mode_accepted():
    print_output = 0

    command_string = create_ipmi_ext_command_string("chassis bootdev none")
    rc, stdout = gc.shell_cmd(
        command_string, print_output=print_output, show_err=0, ignore_err=1
    )
    if rc == 0 and stdout.strip() == "Set Boot Device to none":
        return

    command_string = create_ipmi_ext_command_string("chassis bootdev none options=efiboot")
    rc, stdout = gc.shell_cmd(
        command_string, print_output=print_output, show_err=0, ignore_err=1
    )
    if rc == 0 and stdout.strip() == "Set Boot Device to none":
        BuiltIn().set_global_variable("${IPMI_OPTIONS_EFIBOOT}", "options=efiboot")
        return


def ipmi_setup():
    r"""
    Perform all required setup for running iptmitool commands.
    """

    verify_ipmi_cipher_suite_accepted()
    verify_ipmi_boot_mode_accepted()
    verify_ipmi_user_parm_accepted()


if ipmi_host != "redfish-localhost":
    ipmi_setup()


def process_ipmi_user_options(command):
    r"""
    Return the buffer with any ipmi_user_options prepended.

    Description of argument(s):
    command                         An IPMI command (e.g. "power status").
    """

    ipmi_user_options = BuiltIn().get_variable_value(
        "${IPMI_USER_OPTIONS}", ""
    )
    if ipmi_user_options == "":
        return command
    return ipmi_user_options + " " + command
