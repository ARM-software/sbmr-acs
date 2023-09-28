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
Define variable manipulation functions.
"""

import os
import re

try:
    from robot.utils import DotDict
except ImportError:
    pass

import collections

import func_args as fa
import gen_misc as gm
import gen_print as gp


def create_var_dict(*args):
    r"""
    Create a dictionary whose keys/values are the arg names/arg values passed to it and return it to the
    caller.

    Note: The resulting dictionary will be ordered.

    Description of argument(s):
    *args  An unlimited number of arguments to be processed.

    Example use:

    first_name = 'Steve'
    last_name = 'Smith'
    var_dict = create_var_dict(first_name, last_name)

    gp.print_var(var_dict)

    The print-out of the resulting var dictionary is:
    var_dict:
      var_dict[first_name]:                           Steve
      var_dict[last_name]:                            Smith
    """

    try:
        result_dict = collections.OrderedDict()
    except AttributeError:
        result_dict = DotDict()

    arg_num = 1
    for arg in args:
        arg_name = gp.get_arg_name(None, arg_num, stack_frame_ix=2)
        result_dict[arg_name] = arg
        arg_num += 1

    return result_dict


default_record_delim = ":"
default_key_val_delim = "."


def join_dict(
    dict,
    record_delim=default_record_delim,
    key_val_delim=default_key_val_delim,
):
    r"""
    Join a dictionary's keys and values into a string and return the string.

    Description of argument(s):
    dict                            The dictionary whose keys and values are to be joined.
    record_delim                    The delimiter to be used to separate dictionary pairs in the resulting
                                    string.
    key_val_delim                   The delimiter to be used to separate keys from values in the resulting
                                    string.

    Example use:

    gp.print_var(var_dict)
    str1 = join_dict(var_dict)
    gp.print_var(str1)

    Program output.
    var_dict:
      var_dict[first_name]:                           Steve
      var_dict[last_name]:                            Smith
    str1:                                             first_name.Steve:last_name.Smith
    """

    format_str = "%s" + key_val_delim + "%s"
    return record_delim.join(
        [format_str % (key, value) for (key, value) in dict.items()]
    )


def split_to_dict(
    string,
    record_delim=default_record_delim,
    key_val_delim=default_key_val_delim,
):
    r"""
    Split a string into a dictionary and return it.

    This function is the complement to join_dict.

    Description of argument(s):
    string                          The string to be split into a dictionary.  The string must have the
                                    proper delimiters in it.  A string created by join_dict would qualify.
    record_delim                    The delimiter to be used to separate dictionary pairs in the input string.
    key_val_delim                   The delimiter to be used to separate keys/values in the input string.

    Example use:

    gp.print_var(str1)
    new_dict = split_to_dict(str1)
    gp.print_var(new_dict)


    Program output.
    str1:                                             first_name.Steve:last_name.Smith
    new_dict:
      new_dict[first_name]:                           Steve
      new_dict[last_name]:                            Smith
    """

    try:
        result_dict = collections.OrderedDict()
    except AttributeError:
        result_dict = DotDict()

    raw_keys_values = string.split(record_delim)
    for key_value in raw_keys_values:
        key_value_list = key_value.split(key_val_delim)
        try:
            result_dict[key_value_list[0]] = key_value_list[1]
        except IndexError:
            result_dict[key_value_list[0]] = ""

    return result_dict


def create_file_path(file_name_dict, dir_path="/tmp/", file_suffix=""):
    r"""
    Create a file path using the given parameters and return it.

    Description of argument(s):
    file_name_dict                  A dictionary with keys/values which are to appear as part of the file
                                    name.
    dir_path                        The dir_path that is to appear as part of the file name.
    file_suffix                     A suffix to be included as part of the file name.
    """

    dir_path = gm.add_trailing_slash(dir_path)
    return dir_path + join_dict(file_name_dict) + file_suffix


def parse_file_path(file_path):
    r"""
    Parse a file path created by create_file_path and return the result as a dictionary.

    This function is the complement to create_file_path.

    Description of argument(s):
    file_path                       The file_path.

    Example use:
    gp.print_var(boot_results_file_path)
    file_path_data = parse_file_path(boot_results_file_path)
    gp.print_var(file_path_data)

    Program output.

    boot_results_file_path:
    /tmp/pgm_name.obmc_boot_test:bmc_nickname.beye6:master_pid.2039:boot_results
    file_path_data:
      file_path_data[dir_path]:                       /tmp/
      file_path_data[pgm_name]:                       obmc_boot_test
      file_path_data[bmc_nickname]:                   beye6
      file_path_data[master_pid]:                     2039
      file_path_data[boot_results]:
    """

    try:
        result_dict = collections.OrderedDict()
    except AttributeError:
        result_dict = DotDict()

    dir_path = os.path.dirname(file_path) + os.sep
    file_path = os.path.basename(file_path)

    result_dict["dir_path"] = dir_path

    result_dict.update(split_to_dict(file_path))

    return result_dict


def parse_key_value(string, delim=":", strip=" ", to_lower=1, underscores=1):
    r"""
    Parse a key/value string and return as a key/value tuple.

    This function is useful for parsing a line of program output or data that is in the following form:
    <key or variable name><delimiter><value>

    An example of a key/value string would be as follows:

    Current Limit State: No Active Power Limit

    In the example shown, the delimiter is ":".  The resulting key would be as follows:
    Current Limit State

    Note: If one were to take the default values of to_lower=1 and underscores=1, the resulting key would be
    as follows:
    current_limit_state

    The to_lower and underscores arguments are provided for those who wish to have their key names have the
    look and feel of python variable names.

    The resulting value for the example above would be as follows:
    No Active Power Limit

    Another example:
    name=Mike

    In this case, the delim would be "=", the key is "name" and the value is "Mike".

    Description of argument(s):
    string                          The string to be parsed.
    delim                           The delimiter which separates the key from the value.
    strip                           The characters (if any) to strip from the beginning and end of both the
                                    key and the value.
    to_lower                        Change the key name to lower case.
    underscores                     Change any blanks found in the key name to underscores.
    """

    pair = string.split(delim)

    key = pair[0].strip(strip)
    if len(pair) == 0:
        value = ""
    else:
        value = delim.join(pair[1:]).strip(strip)

    if to_lower:
        key = key.lower()
    if underscores:
        key = re.sub(r" ", "_", key)

    return key, value


def key_value_list_to_dict(key_value_list, process_indent=0, **args):
    r"""
    Convert a list containing key/value strings or tuples to a dictionary and return it.

    See docstring of parse_key_value function for details on key/value strings.

    Example usage:

    For the following value of key_value_list:

    key_value_list:
      [0]:          Current Limit State: No Active Power Limit
      [1]:          Exception actions:   Hard Power Off & Log Event to SEL
      [2]:          Power Limit:         0 Watts
      [3]:          Correction time:     0 milliseconds
      [4]:          Sampling period:     0 seconds

    And the following call in python:

    power_limit = key_value_outbuf_to_dict(key_value_list)

    The resulting power_limit directory would look like this:

    power_limit:
      [current_limit_state]:        No Active Power Limit
      [exception_actions]:          Hard Power Off & Log Event to SEL
      [power_limit]:                0 Watts
      [correction_time]:            0 milliseconds
      [sampling_period]:            0 seconds

    For the following list:

    headers:
      headers[0]:
        headers[0][0]:           content-length
        headers[0][1]:           559
      headers[1]:
        headers[1][0]:           x-xss-protection
        headers[1][1]:           1; mode=block

    And the following call in python:

    headers_dict = key_value_list_to_dict(headers)

    The resulting headers_dict would look like this:

    headers_dict:
      [content-length]:          559
      [x-xss-protection]:        1; mode=block

    Another example containing a sub-list (see process_indent description below):

    Provides Device SDRs      : yes
    Additional Device Support :
        Sensor Device
        SEL Device
        FRU Inventory Device
        Chassis Device

    Note that the 2 qualifications for containing a sub-list are met: 1) 'Additional Device Support' has no
    value and 2) The entries below it are indented.  In this case those entries contain no delimiters (":")
    so they will be processed as a list rather than as a dictionary.  The result would be as follows:

    mc_info:
      mc_info[provides_device_sdrs]:            yes
      mc_info[additional_device_support]:
        mc_info[additional_device_support][0]:  Sensor Device
        mc_info[additional_device_support][1]:  SEL Device
        mc_info[additional_device_support][2]:  FRU Inventory Device
        mc_info[additional_device_support][3]:  Chassis Device

    Description of argument(s):
    key_value_list                  A list of key/value strings.  (See docstring of parse_key_value function
                                    for details).
    process_indent                  This indicates that indented sub-dictionaries and sub-lists are to be
                                    processed as such.  An entry may have a sub-dict or sub-list if 1) It has
                                    no value other than blank 2) There are entries below it that are
                                    indented.  Note that process_indent is not allowed for a list of tuples
                                    (vs. a list of key/value strings).
    **args                          Arguments to be interpreted by parse_key_value.  (See docstring of
                                    parse_key_value function for details).
    """

    try:
        result_dict = collections.OrderedDict()
    except AttributeError:
        result_dict = DotDict()

    if not process_indent:
        for entry in key_value_list:
            if type(entry) is tuple:
                key, value = entry
            else:
                key, value = parse_key_value(entry, **args)
            result_dict[key] = value
        return result_dict

    # Process list while paying heed to indentation.
    delim = args.get("delim", ":")
    # Initialize "parent_" indentation level variables.
    parent_indent = len(key_value_list[0]) - len(key_value_list[0].lstrip())
    sub_list = []
    for entry in key_value_list:
        key, value = parse_key_value(entry, **args)

        indent = len(entry) - len(entry.lstrip())

        if indent > parent_indent and parent_value == "":
            # This line is indented compared to the parent entry and the parent entry has no value.
            # Append the entry to sub_list for later processing.
            sub_list.append(str(entry))
            continue

        # Process any outstanding sub_list and add it to result_dict[parent_key].
        if len(sub_list) > 0:
            if any(delim in word for word in sub_list):
                # If delim is found anywhere in the sub_list, we'll process as a sub-dictionary.
                result_dict[parent_key] = key_value_list_to_dict(
                    sub_list, **args
                )
            else:
                result_dict[parent_key] = list(map(str.strip, sub_list))
            del sub_list[:]

        result_dict[key] = value

        parent_key = key
        parent_value = value
        parent_indent = indent

    # Any outstanding sub_list to be processed?
    if len(sub_list) > 0:
        if any(delim in word for word in sub_list):
            # If delim is found anywhere in the sub_list, we'll process as a sub-dictionary.
            result_dict[parent_key] = key_value_list_to_dict(sub_list, **args)
        else:
            result_dict[parent_key] = list(map(str.strip, sub_list))

    return result_dict


def key_value_outbuf_to_dict(out_buf, **args):
    r"""
    Convert a buffer with a key/value string on each line to a dictionary and return it.

    Each line in the out_buf should end with a \n.

    See docstring of parse_key_value function for details on key/value strings.

    Example usage:

    For the following value of out_buf:

    Current Limit State: No Active Power Limit
    Exception actions:   Hard Power Off & Log Event to SEL
    Power Limit:         0 Watts
    Correction time:     0 milliseconds
    Sampling period:     0 seconds

    And the following call in python:

    power_limit = key_value_outbuf_to_dict(out_buf)

    The resulting power_limit directory would look like this:

    power_limit:
      [current_limit_state]:        No Active Power Limit
      [exception_actions]:          Hard Power Off & Log Event to SEL
      [power_limit]:                0 Watts
      [correction_time]:            0 milliseconds
      [sampling_period]:            0 seconds

    Description of argument(s):
    out_buf                         A buffer with a key/value string on each line. (See docstring of
                                    parse_key_value function for details).
    **args                          Arguments to be interpreted by parse_key_value.  (See docstring of
                                    parse_key_value function for details).
    """

    # Create key_var_list and remove null entries.
    key_var_list = list(filter(None, out_buf.split("\n")))
    return key_value_list_to_dict(key_var_list, **args)


def key_value_outbuf_to_dicts(out_buf, **args):
    r"""
    Convert a buffer containing multiple sections with key/value strings on each line to a list of
    dictionaries and return it.

    Sections in the output are delimited by blank lines.

    Example usage:

    For the following value of out_buf:

    Maximum User IDs     : 15
    Enabled User IDs     : 1

    User ID              : 1
    User Name            : root
    Fixed Name           : No
    Access Available     : callback
    Link Authentication  : enabled
    IPMI Messaging       : enabled
    Privilege Level      : ADMINISTRATOR
    Enable Status        : enabled

    User ID              : 2
    User Name            :
    Fixed Name           : No
    Access Available     : call-in / callback
    Link Authentication  : disabled
    IPMI Messaging       : disabled
    Privilege Level      : NO ACCESS
    Enable Status        : disabled

    And the following call in python:

    user_info = key_value_outbuf_to_dicts(out_buf)

    The resulting user_info list would look like this:

    user_info:
      [0]:
        [maximum_user_ids]:      15
        [enabled_user_ids]:      1
      [1]:
        [user_id]:               1
        [user_name]:             root
        [fixed_name]:            No
        [access_available]:      callback
        [link_authentication]:   enabled
        [ipmi_messaging]:        enabled
        [privilege_level]:       ADMINISTRATOR
        [enable_status]:         enabled
      [2]:
        [user_id]:               2
        [user_name]:
        [fixed_name]:            No
        [access_available]:      call-in / callback
        [link_authentication]:   disabled
        [ipmi_messaging]:        disabled
        [privilege_level]:       NO ACCESS
        [enable_status]:         disabled

    Description of argument(s):
    out_buf                         A buffer with multiple secionts of key/value strings on each line.
                                    Sections are delimited by one or more blank lines (i.e. line feeds). (See
                                    docstring of parse_key_value function for details).
    **args                          Arguments to be interpreted by parse_key_value.  (See docstring of
                                    parse_key_value function for details).
    """
    return [
        key_value_outbuf_to_dict(x, **args)
        for x in re.split("\n[\n]+", out_buf)
    ]


def create_field_desc_regex(line):
    r"""
    Create a field descriptor regular expression based on the input line and return it.

    This function is designed for use by the list_to_report function (defined below).

    Example:

    Given the following input line:

    --------   ------------ ------------------ ------------------------

    This function will return this regular expression:

    (.{8})   (.{12}) (.{18}) (.{24})

    This means that other report lines interpreted using the regular expression are expected to have:
    - An 8 character field
    - 3 spaces
    - A 12 character field
    - One space
    - An 18 character field
    - One space
    - A 24 character field

    Description of argument(s):
    line                            A line consisting of dashes to represent fields and spaces to delimit
                                    fields.
    """

    # Split the line into a descriptors list.  Example:
    # descriptors:
    #  descriptors[0]:            --------
    #  descriptors[1]:
    #  descriptors[2]:
    #  descriptors[3]:            ------------
    #  descriptors[4]:            ------------------
    #  descriptors[5]:            ------------------------
    descriptors = line.split(" ")

    # Create regexes list.  Example:
    # regexes:
    #  regexes[0]:                (.{8})
    #  regexes[1]:
    #  regexes[2]:
    #  regexes[3]:                (.{12})
    #  regexes[4]:                (.{18})
    #  regexes[5]:                (.{24})
    regexes = []
    for descriptor in descriptors:
        if descriptor == "":
            regexes.append("")
        else:
            regexes.append("(.{" + str(len(descriptor)) + "})")

    # Join the regexes list into a regex string.
    field_desc_regex = " ".join(regexes)

    return field_desc_regex


def list_to_report(report_list, to_lower=1, field_delim=None):
    r"""
    Convert a list containing report text lines to a report "object" and return it.

    The first entry in report_list must be a header line consisting of column names delimited by white space.
    No column name may contain white space.  The remaining report_list entries should contain tabular data
    which corresponds to the column names.

    A report object is a list where each entry is a dictionary whose keys are the field names from the first
    entry in report_list.

    Example:
    Given the following report_list as input:

    rl:
      rl[0]: Filesystem           1K-blocks      Used Available Use% Mounted on
      rl[1]: dev                     247120         0    247120   0% /dev
      rl[2]: tmpfs                   248408     79792    168616  32% /run

    This function will return a list of dictionaries as shown below:

    df_report:
      df_report[0]:
        [filesystem]:                  dev
        [1k-blocks]:                   247120
        [used]:                        0
        [available]:                   247120
        [use%]:                        0%
        [mounted]:                     /dev
      df_report[1]:
        [filesystem]:                  dev
        [1k-blocks]:                   247120
        [used]:                        0
        [available]:                   247120
        [use%]:                        0%
        [mounted]:                     /dev

    Notice that because "Mounted on" contains a space, "on" would be considered the 7th field.  In this case,
    there is never any data in field 7 so things work out nicely.  A caller could do some pre-processing if
    desired (e.g. change "Mounted on" to "Mounted_on").

    Example 2:

    If the 2nd line of report data is a series of dashes and spaces as in the following example, that line
    will serve to delineate columns.

    The 2nd line of data is like this:
    ID                              status       size               tool,clientid,userid
    -------- ------------ ------------------ ------------------------
    20000001 in progress  0x7D0              ,,

    Description of argument(s):
    report_list                     A list where each entry is one line of output from a report.  The first
                                    entry must be a header line which contains column names.  Column names
                                    may not contain spaces.
    to_lower                        Change the resulting key names to lower case.
    field_delim                     Indicates that there are field delimiters in report_list entries (which
                                    should be removed).
    """

    if len(report_list) <= 1:
        # If we don't have at least a descriptor line and one line of data, return an empty array.
        return []

    if field_delim is not None:
        report_list = [re.sub("\\|", "", line) for line in report_list]

    header_line = report_list[0]
    if to_lower:
        header_line = header_line.lower()

    field_desc_regex = ""
    if re.match(r"^-[ -]*$", report_list[1]):
        # We have a field descriptor line (as shown in example 2 above).
        field_desc_regex = create_field_desc_regex(report_list[1])
        field_desc_len = len(report_list[1])
        pad_format_string = "%-" + str(field_desc_len) + "s"
        # The field descriptor line has served its purpose.  Deleting it.
        del report_list[1]

    # Process the header line by creating a list of column names.
    if field_desc_regex == "":
        columns = header_line.split()
    else:
        # Pad the line with spaces on the right to facilitate processing with field_desc_regex.
        header_line = pad_format_string % header_line
        columns = list(
            map(str.strip, re.findall(field_desc_regex, header_line)[0])
        )

    report_obj = []
    for report_line in report_list[1:]:
        if field_desc_regex == "":
            line = report_line.split()
        else:
            # Pad the line with spaces on the right to facilitate processing with field_desc_regex.
            report_line = pad_format_string % report_line
            line = list(
                map(str.strip, re.findall(field_desc_regex, report_line)[0])
            )
        try:
            line_dict = collections.OrderedDict(zip(columns, line))
        except AttributeError:
            line_dict = DotDict(zip(columns, line))
        report_obj.append(line_dict)

    return report_obj


def outbuf_to_report(out_buf, **args):
    r"""
    Convert a text buffer containing report lines to a report "object" and return it.

    Refer to list_to_report (above) for more details.

    Example:

    Given the following out_buf:

    Filesystem                      1K-blocks      Used Available Use% Mounted on
    dev                             247120         0    247120   0% /dev
    tmpfs                           248408     79792    168616  32% /run

    This function will return a list of dictionaries as shown below:

    df_report:
      df_report[0]:
        [filesystem]:                  dev
        [1k-blocks]:                   247120
        [used]:                        0
        [available]:                   247120
        [use%]:                        0%
        [mounted]:                     /dev
      df_report[1]:
        [filesystem]:                  dev
        [1k-blocks]:                   247120
        [used]:                        0
        [available]:                   247120
        [use%]:                        0%
        [mounted]:                     /dev

    Other possible uses:
    - Process the output of a ps command.
    - Process the output of an ls command (the caller would need to supply column names)

    Description of argument(s):
    out_buf                         A text report.  The first line must be a header line which contains
                                    column names.  Column names may not contain spaces.
    **args                          Arguments to be interpreted by list_to_report.  (See docstring of
                                    list_to_report function for details).
    """

    report_list = list(filter(None, out_buf.split("\n")))
    return list_to_report(report_list, **args)


def nested_get(key_name, structure):
    r"""
    Return a list of all values from the nested structure that have the given key name.

    Example:

    Given a dictionary structure named "personnel" with the following contents:

    personnel:
      [manager]:
        [last_name]:             Doe
        [first_name]:            John
      [accountant]:
        [last_name]:             Smith
        [first_name]:            Will

    The following code...

    last_names = nested_get('last_name', personnel)
    print_var(last_names)

    Would result in the following data returned:

    last_names:
      last_names[0]:             Doe
      last_names[1]:             Smith

    Description of argument(s):
    key_name                        The key name (e.g. 'last_name').
    structure                       Any nested combination of lists or dictionaries (e.g. a dictionary, a
                                    dictionary of dictionaries, a list of dictionaries, etc.).  This function
                                    will locate the given key at any level within the structure and include
                                    its value in the returned list.
    """

    result = []
    if type(structure) is list:
        for entry in structure:
            result += nested_get(key_name, entry)
        return result
    elif gp.is_dict(structure):
        for key, value in structure.items():
            result += nested_get(key_name, value)
            if key == key_name:
                result.append(value)

    return result


def match_struct(structure, match_dict, regex=False):
    r"""
    Return True or False to indicate whether the structure matches the match dictionary.

    Example:

    Given a dictionary structure named "personnel" with the following contents:

    personnel:
      [manager]:
        [last_name]:             Doe
        [first_name]:            John
      [accountant]:
        [last_name]:             Smith
        [first_name]:            Will

    The following call would return True.

    match_struct(personnel, {'last_name': '^Doe$'}, regex=True)

    Whereas the following call would return False.

    match_struct(personnel, {'last_name': 'Johnson'}, regex=True)

    Description of argument(s):
    structure                       Any nested combination of lists or dictionaries.  See the prolog of
                                    get_nested() for details.
    match_dict                      Each key/value pair in match_dict must exist somewhere in the structure
                                    for the structure to be considered a match.  A match value of None is
                                    considered a special case where the structure would be considered a match
                                    only if the key in question is found nowhere in the structure.
    regex                           Indicates whether the values in the match_dict should be interpreted as
                                    regular expressions.
    """

    # The structure must match for each match_dict entry to be considered a match.  Therefore, any failure
    # to match is grounds for returning False.
    for match_key, match_value in match_dict.items():
        struct_key_values = nested_get(match_key, structure)
        if match_value is None:
            # Handle this as special case.
            if len(struct_key_values) != 0:
                return False
        else:
            if len(struct_key_values) == 0:
                return False
            if regex:
                matches = [
                    x
                    for x in struct_key_values
                    if re.search(match_value, str(x))
                ]
                if not matches:
                    return False
            elif match_value not in struct_key_values:
                return False

    return True


def filter_struct(structure, filter_dict, regex=False, invert=False):
    r"""
    Filter the structure by removing any entries that do NOT contain the keys/values specified in filter_dict
    and return the result.

    The selection process is directed only at the first-level entries of the structure.

    Example:

    Given a dictionary named "properties" that has the following structure:

    properties:
      [/redfish/v1/Systems/${SYSTEM_ID}/Processors]:
        [Members]:
          [0]:
            [@odata.id]:                              /redfish/v1/Systems/${SYSTEM_ID}/Processors/cpu0
          [1]:
            [@odata.id]:                              /redfish/v1/Systems/${SYSTEM_ID}/Processors/cpu1
      [/redfish/v1/Systems/${SYSTEM_ID}/Processors/cpu0]:
        [Status]:
          [State]:                                    Enabled
          [Health]:                                   OK
      [/redfish/v1/Systems/${SYSTEM_ID}/Processors/cpu1]:
        [Status]:
          [State]:                                    Enabled
          [Health]:                                   Bad

    The following call:

    properties = filter_struct(properties, "[('Health', 'OK')]")

    Would return a new properties dictionary that looks like this:

    properties:
      [/redfish/v1/Systems/${SYSTEM_ID}/Processors/cpu0]:
        [Status]:
          [State]:                                    Enabled
          [Health]:                                   OK

    Note that the first item in the original properties directory had no key anywhere in the structure named
    "Health".  Therefore, that item failed to make the cut.  The next item did have a key named "Health"
    whose value was "OK" so it was included in the new structure.  The third item had a key named "Health"
    but its value was not "OK" so it also failed to make the cut.

    Description of argument(s):
    structure                       Any nested combination of lists or dictionaries.  See the prolog of
                                    get_nested() for details.
    filter_dict                     For each key/value pair in filter_dict, each entry in structure must
                                    contain the same key/value pair at some level.  A filter_dict value of
                                    None is treated as a special case.  Taking the example shown above,
                                    [('State', None)] would mean that the result should only contain records
                                    that have no State key at all.
    regex                           Indicates whether the values in the filter_dict should be interpreted as
                                    regular expressions.
    invert                          Invert the results.  Instead of including only matching entries in the
                                    results, include only NON-matching entries in the results.
    """

    # Convert filter_dict from a string containing a python object definition to an actual python object (if
    # warranted).
    filter_dict = fa.source_to_object(filter_dict)

    # Determine whether structure is a list or a dictionary and process accordingly.  The result returned
    # will be of the same type as the structure.
    if type(structure) is list:
        result = []
        for element in structure:
            if match_struct(element, filter_dict, regex) != invert:
                result.append(element)
    else:
        try:
            result = collections.OrderedDict()
        except AttributeError:
            result = DotDict()
        for struct_key, struct_value in structure.items():
            if match_struct(struct_value, filter_dict, regex) != invert:
                result[struct_key] = struct_value

    return result


def split_dict_on_key(split_key, dictionary):
    r"""
    Split a dictionary into two dictionaries based on the first occurrence of the split key and return the
    resulting sub-dictionaries.

    Example:
    dictionary = {'one': 1, 'two': 2, 'three':3, 'four':4}
    dict1, dict2 = split_dict_on_key('three', dictionary)
    pvars(dictionary, dict1, dict2)

    Output:
    dictionary:
      [one]:                                          1
      [two]:                                          2
      [three]:                                        3
      [four]:                                         4
    dict1:
      [one]:                                          1
      [two]:                                          2
    dict2:
      [three]:                                        3
      [four]:                                         4

    Description of argument(s):
    split_key                       The key value to be used to determine where the dictionary should be
                                    split.
    dictionary                      The dictionary to be split.
    """
    dict1 = {}
    dict2 = {}
    found_split_key = False
    for key in list(dictionary.keys()):
        if key == split_key:
            found_split_key = True
        if found_split_key:
            dict2[key] = dictionary[key]
        else:
            dict1[key] = dictionary[key]
    return dict1, dict2
