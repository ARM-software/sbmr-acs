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
IPMI REST FRU field mapping:
   - Define IPMI-REST FRU data fields mapping for different components.
   e.g. board_mfg field in IPMI is mapped to Manufacturer field in REST.
"""

# TODO: Disabling board_mfg FRU field as logic needs to be added to test it.
ipmi_rest_fru_field_map = {
    "cpu": {
        # "board_mfg_date": "BuildDate",
        "board_mfg": "Manufacturer",
        "board_product": "PrettyName",
        "board_serial": "SerialNumber",
        "board_part_number": "PartNumber",
    },
    "system": {
        "chassis_part_number": "Model",
        "chassis_serial": "SerialNumber",
    },
    "motherboard": {
        "board_mfg": "Manufacturer",
        "board_product": "PrettyName",
        "board_serial": "SerialNumber",
        "board_part_number": "PartNumber",
    },
    "dimm": {
        "product_manufacturer": "Manufacturer",
        "product_name": "PrettyName",
        "product_part_number": "Model",
        "product_version": "Version",
        "product_serial": "SerialNumber",
    },
    "fan": {"product_name": "PrettyName"},
    "bmc": {
        # "board_mfg_date": "BuildDate",
        "board_mfg": "Manufacturer",
        "board_product": "PrettyName",
        "board_serial": "SerialNumber",
        "board_part_number": "PartNumber",
    },
    "powersupply": {
        # "board_mfg_date": "BuildDate",
        "board_product": "PrettyName",
        "board_serial": "SerialNumber",
        "board_part_number": "PartNumber",
    },
    "gv100card": {
        # "board_mfg_date": "BuildDate",
    },
}
