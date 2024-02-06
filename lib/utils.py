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
Companion file to utils.robot.
"""

import collections
import json
import os
import ssl

from cryptography import x509
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import hashes

import bmc_ssh_utils as bsu
import gen_print as gp
import gen_robot_keyword as grk
import var_funcs as vf
from robot.libraries import DateTime
from robot.libraries.BuiltIn import BuiltIn

try:
    from robot.utils import DotDict
except ImportError:
    pass


# The code base directory will be one level up from the directory containing this module.
code_base_dir_path = os.path.dirname(os.path.dirname(__file__)) + os.sep

supported_vga_controllers = [
    "ASPEED Graphics Family",
    "Hewlett Packard Enterprise iLO5 VGA"
]


def get_server_certificate_fingerprint():
    r"""
    Return fingerprint of certificate from BMC webserver
    """

    host = BuiltIn().get_variable_value("${BMC_HOST}")
    pem_cert = ssl.get_server_certificate((host, 443))
    x509_cert = x509.load_pem_x509_certificate(str.encode(pem_cert), default_backend())
    fingerprint = x509_cert.fingerprint(hashes.SHA256()).hex()

    # Split it to array list, i.e., ['12', '34', 'ab', ...]
    data = [fingerprint[index:index + 2] for index in range(0, len(fingerprint), 2)]
    return data


def get_code_base_dir_path():
    r"""
    Return the dir path of our code base.
    """

    return code_base_dir_path


def compare_mac_address(sys_mac_addr, user_mac_addr):
    r"""
        Return 1 if the MAC value matched, otherwise 0.

    .   Description of argument(s):
        sys_mac_addr   A valid system MAC string (e.g. "70:e2:84:14:2a:08")
        user_mac_addr  A user provided MAC string (e.g. "70:e2:84:14:2a:08")
    """

    index = 0
    # Example: ['70', 'e2', '84', '14', '2a', '08']
    mac_list = user_mac_addr.split(":")
    for item in sys_mac_addr.split(":"):
        if int(item, 16) == int(mac_list[index], 16):
            index = index + 1
            continue
        return 0

    return 1


def get_os_ethtool(interface_name):
    r"""
    Get OS 'ethtool' output for the given interface_name and return it as a
    dictionary.

    Settings for enP52p1s0f0:
          Supported ports: [ TP ]
          Supported link modes:   10baseT/Half 10baseT/Full
                                  100baseT/Half 100baseT/Full
                                  1000baseT/Half 1000baseT/Full
          Supported pause frame use: No
          Supports auto-negotiation: Yes
          Supported FEC modes: Not reported
          Advertised link modes:  10baseT/Half 10baseT/Full
                                  100baseT/Half 100baseT/Full
                                  1000baseT/Half 1000baseT/Full
          Advertised pause frame use: Symmetric
          Advertised auto-negotiation: Yes
          Advertised FEC modes: Not reported
          Speed: Unknown!
          Duplex: Unknown! (255)
          Port: Twisted Pair
          PHYAD: 1
          Transceiver: internal
          Auto-negotiation: on
          MDI-X: Unknown
          Supports Wake-on: g
          Wake-on: g
          Current message level: 0x000000ff (255)
                                 drv probe link timer ifdown ifup rx_err tx_err
          Link detected: no

    Given that data, this function will return the following dictionary.

    ethtool_dict:
      [supported_ports]:             [ TP ]
      [supported_link_modes]:
        [supported_link_modes][0]:   10baseT/Half 10baseT/Full
        [supported_link_modes][1]:   100baseT/Half 100baseT/Full
        [supported_link_modes][2]:   1000baseT/Half 1000baseT/Full
      [supported_pause_frame_use]:   No
      [supports_auto-negotiation]:   Yes
      [supported_fec_modes]:         Not reported
      [advertised_link_modes]:
        [advertised_link_modes][0]:  10baseT/Half 10baseT/Full
        [advertised_link_modes][1]:  100baseT/Half 100baseT/Full
        [advertised_link_modes][2]:  1000baseT/Half 1000baseT/Full
      [advertised_pause_frame_use]:  Symmetric
      [advertised_auto-negotiation]: Yes
      [advertised_fec_modes]:        Not reported
      [speed]:                       Unknown!
      [duplex]:                      Unknown! (255)
      [port]:                        Twisted Pair
      [phyad]:                       1
      [transceiver]:                 internal
      [auto-negotiation]:            on
      [mdi-x]:                       Unknown
      [supports_wake-on]:            g
      [wake-on]:                     g
      [current_message_level]:       0x000000ff (255)
      [drv_probe_link_timer_ifdown_ifup_rx_err_tx_err]:<blank>
      [link_detected]:               no
    """

    # Using sed and tail to massage the data a bit before running
    # key_value_outbuf_to_dict.
    cmd_buf = (
        "ethtool "
        + interface_name
        + " | sed -re 's/(.* link modes:)(.*)/\\1\\n\\2/g' | tail -n +2"
    )
    stdout, stderr, rc = bsu.os_execute_command(cmd_buf)
    result = vf.key_value_outbuf_to_dict(stdout, process_indent=1, strip=" \t")

    return result


def to_json_ordered(json_str):
    r"""
    Parse the JSON string data and return an ordered JSON dictionary object.

    Description of argument(s):
    json_str                        The string containing the JSON data.
    """

    try:
        return json.loads(json_str, object_pairs_hook=DotDict)
    except TypeError:
        return json.loads(json_str.decode("utf-8"), object_pairs_hook=DotDict)


def get_os_release_info():
    r"""
    Get release info from the OS and return as a dictionary.

    Example:

    ${release_info}=  Get OS Release Info
    Rprint Vars  release_info

    Output:
    release_info:
      [name]:                                         Red Hat Enterprise Linux Server
      [version]:                                      7.6 (Maipo)
      [id]:                                           rhel
      [id_like]:                                      fedora
      [variant]:                                      Server
      [variant_id]:                                   server
      [version_id]:                                   7.6
      [pretty_name]:                                  Red Hat Enterprise Linux Server 7.6 (Maipo)
      [ansi_color]:                                   0;31
      [cpe_name]:                                     cpe:/o:redhat:enterprise_linux:7.6:GA:server
      [home_url]:                                     https://www.redhat.com/
      [bug_report_url]:                               https://bugzilla.redhat.com/
      [redhat_bugzilla_product]:                      Red Hat Enterprise Linux 7
      [redhat_bugzilla_product_version]:              7.6
      [redhat_support_product]:                       Red Hat Enterprise Linux
      [redhat_support_product_version]:               7.6
    """

    out_buf, stderr, rc = bsu.os_execute_command("cat /etc/os-release")
    return vf.key_value_outbuf_to_dict(out_buf, delim="=", strip='"')


def split_string_with_index(stri, n):
    r"""
    To split every n characters and forms an element for every nth index

    Example : Given ${stri} = "abcdef", then the function call,
    ${data}=  Split List With Index  ${stri}  2
    then, result will be data = ['ab', 'cd', 'ef']
    """

    n = int(n)
    data = [stri[index:index + n] for index in range(0, len(stri), n)]
    return data


def remove_whitespace(instring):
    r"""
    Removes the white spaces around the string

    Example: instring = "  xxx  ", then returns instring = "xxx"
    """

    return instring.strip()


def zfill_data(data, num):
    r"""
    zfill() method adds zeros (0) at the beginning of the string, until it
    reaches the specified length.

    Usage : ${anystr}=  Zfill Data  ${data}  num

    Example : Binary of one Byte has 8 bits - xxxx xxxx

    Consider ${binary} has only 3 bits after converting from Hexadecimal/decimal to Binary
    Say ${binary} = 110 then,
    ${binary}=  Zfill Data  ${binary}  8
    Now ${binary} will be 0000 0110
    """

    return data.zfill(int(num))


def get_subsequent_value_from_list(list, value):
    r"""
    returns first index of the element occurrence.
    """

    index = [list.index(i) for i in list if value in i]
    return index


def return_decoded_string(input):
    r"""
    returns decoded string of encoded byte.
    """

    encoded_string = input.encode("ascii", "ignore")
    decoded_string = encoded_string.decode()
    return decoded_string


def validate_supported_vga_controller(lists):
    r"""
    return true if there is supported vga controller in lists
    """

    for item in lists:
        for controller in supported_vga_controllers:
            if controller in item:
                return True

    return False


def get_value_from_nested_dict(key, nested_dict):
    r"""
    Return the key value from the nested dictionary.

    key            Key value of the dictionary to look up.
    nested_dict    Dictionary data.
    """

    result = []

    if not isinstance(nested_dict, dict):
        return result

    for k, v in nested_dict.items():
        if k == key:
            result.append(v)
        elif isinstance(v, dict) and k != key:
            result += get_value_from_nested_dict(key, v);

    return result
