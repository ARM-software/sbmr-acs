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
This module is the python counterpart to run_keyword.robot.
"""

import re

import gen_print as gp
import gen_robot_utils as gru
import gen_robot_valid as grv
from robot.libraries.BuiltIn import BuiltIn


def setup():
    r"""
    Do general program setup tasks.
    """

    gp.qprintn()

    validate_parms()

    gp.qprint_pgm_header()


def validate_parms():
    r"""
    Validate all program parameters.
    """

    grv.valid_value("keyword_string")

    return True


def program_teardown():
    r"""
    Clean up after this program.
    """

    gp.qprint_pgm_footer()


def my_run_keywords(lib_file_path, keyword_string, quiet=0, test_mode=0):
    r"""
    Run the keywords in the keyword string.

    Description of arguments:
    lib_file_path   The path to a library or resource needed to run the
                    keywords.  This may contain a colon-delimited list of
                    library/resource paths.
    keyword_string  The keyword string to be run by this function.  If this
                    keyword string contains " ; " anywhere, it will be taken to
                    be multiple keyword strings.  Each keyword may also include
                    a variable assignment.  Example:
                    ${my_var}=  My Keyword
    quiet           If this parameter is set to "1", this program will print
                    only essential information, i.e. it will not echo
                    parameters, echo commands, print the total run time, etc.
    test_mode       This means that this program should go through all the
                    motions but not actually do anything substantial.
    """

    # NOTE: During code review the following question was raised: Why support
    # 1) variable assignments 2) multiple keywords?  Couldn't a user simply
    # call this program twice to get what they need.  If necessary, the user
    # could take the output of the first call and specify it as a literal on
    # the second call.
    #
    # However, this approach would not work in all cases.  The following case
    # would be such an example:
    # Let's say the first keyword string is as follows:
    # Create Dictionary  foo=bar
    # You wish to take the output of that call and specify it as a literal
    # value when running the following:
    # Want Dictionary  parm=<literal dictionary specification>
    # The problem is that there is no way to specify a dictionary as a
    # literal in Robot Framework.
    # By having this program support variable assignments and multiple
    # keywords, the user can invoke it with the following keyword string.
    # ${my_dict}=  Create Dictionary  foo=bar ; Want Dictionary  ${my_dict}

    # The user can pass multiple lib/resource paths by separating them with a
    # colon.
    lib_file_path_list = lib_file_path.split(":")
    # Get rid of empty entry if it exists.
    if lib_file_path_list[0] == "":
        del lib_file_path_list[0]
    for lib_file_path in lib_file_path_list:
        if lib_file_path.endswith(".py"):
            gp.dprint_issuing('import_library("' + lib_file_path + '")')
            BuiltIn().import_library(lib_file_path)
        else:
            gp.dprint_issuing('my_import_resource("' + lib_file_path + '")')
            gru.my_import_resource(lib_file_path)

    # The user can pass multiple keyword strings by separating them with " ; ".
    keyword_list = keyword_string.split(" ; ")
    for keyword_string in keyword_list:
        cmd_buf = keyword_string.split("  ")
        if re.match(r"\$\{", cmd_buf[0]):
            # This looks like an assignment (e.g. ${var}=  <keyword>).
            # We'll extract the variable name, remove element 0 from
            # cmd_buf and set the global variable with the results
            # after running the keyword.
            var_name = cmd_buf[0].strip("${}=")
            del cmd_buf[0]
        else:
            var_name = ""

        if not quiet:
            gp.print_issuing(cmd_buf, test_mode)
        if test_mode:
            continue

        output = BuiltIn().run_keyword(*cmd_buf)

        if var_name != "":
            BuiltIn().set_global_variable("${" + var_name + "}", output)
        else:
            if output is not None:
                gp.gp_print(output)


def main_py():
    r"""
    Do main program processing.
    """

    setup()

    lib_file_path = BuiltIn().get_variable_value("${lib_file_path}")
    keyword_string = BuiltIn().get_variable_value("${keyword_string}")
    quiet = int(BuiltIn().get_variable_value("${quiet}"))
    test_mode = int(BuiltIn().get_variable_value("${test_mode}"))

    my_run_keywords(lib_file_path, keyword_string, quiet, test_mode)
