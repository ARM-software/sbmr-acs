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
This module contains keyword functions to support multiprocessing
execution of keywords where generic robot keywords don't support.

"""

import datetime
import os
from multiprocessing import Manager, Process

from robot.libraries.BuiltIn import BuiltIn


def execute_keyword(keyword_name, return_dict):
    r"""
    Execute a robot keyword.
    In addition to running the caller's keyword, this function will:
    - Add an entry to the return_dict

    Description of argument(s):
    keyword_name    Keyword name to be executed.
    return_dict     A dictionary consisting of pid/process status for the
                    keys/values. This function will append a new entry to
                    this dictionary.
    """

    pid = os.getpid()
    status = BuiltIn().run_keyword_and_return_status(keyword_name)

    # Build PID:<status> dictionary.
    return_dict[str(pid)] = str(status)


def execute_process(num_process, keyword_name):
    r"""
    Execute a robot keyword via multiprocessing process.

    Description of argument(s):
    num_process         Number of times keyword to be executed.
    keyword_name     Keyword name to be executed.
    """

    manager = Manager()
    return_dict = manager.dict()
    process_list = []

    # Append user-defined times process needed to execute.
    for _ix in range(int(num_process)):
        task = Process(
            target=execute_keyword, args=(keyword_name, return_dict)
        )
        process_list.append(task)
        task.start()

    # Wait for process to complete.
    for task in process_list:
        task.join()

    # Return function return codes.
    return return_dict


def execute_keyword_args(keyword_name, args, return_dict):
    r"""
    Execute a robot keyword with arguments.
    In addition to running the caller's keyword, this function will:
    - Add an entry to the return_dict
    Description of argument(s):
    keyword_name    Keyword name to be executed.
    args            Arguments to keyword.
    return_dict     A dictionary consisting of pid/process status for the
                    keys/values. This function will append a new entry to
                    this dictionary.
    """

    execution_time = datetime.datetime.now()

    status = BuiltIn().run_keyword_and_return_status(keyword_name, *args)

    # Build execution time:<status> dictionary.
    return_dict[str(execution_time)] = str(status)


def execute_process_multi_keyword(number_args, *keyword_names):
    r"""
    Execute multiple robot keywords with arguments via multiprocessing process.

    Description of argument(s):
    number_args       Number of argument in keywords.
    keyword_names     Keyword name to be executed.
    """

    manager = Manager()
    return_dict = manager.dict()
    process_list = []
    # Append each keyword with its arguments in a process to execute.
    for keywords_data in keyword_names:
        keyword_args = tuple(keywords_data.split(" ")[-number_args:])
        keyword_name = " ".join(keywords_data.split(" ")[:-number_args])
        task = Process(
            target=execute_keyword_args,
            args=(keyword_name, keyword_args, return_dict),
        )
        process_list.append(task)
        task.start()

    # Wait for process to complete.
    for task in process_list:
        task.join()
    return return_dict


def get_current_date_time():
    r"""
    Gets current time.
    """

    current_time = datetime.datetime.now().strftime("%H:%M:%S.%f")
    return current_time
