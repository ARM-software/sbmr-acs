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
Variable constants applicable to all BMC test.
"""

import os

from robot.libraries.BuiltIn import BuiltIn

BMC_ID = BuiltIn().get_variable_value("${BMC_ID}", default="bmc")
SYSTEM_ID = BuiltIn().get_variable_value("${SYSTEM_ID}", default="system")
CHASSIS_ID = BuiltIn().get_variable_value("${CHASSIS_ID}", default="chassis")

# Logging URI variables
REDFISH_BMC_LOGGING_ENTRY = (
    "/redfish/v1/Systems/" + SYSTEM_ID + "/LogServices/EventLog/Entries/"
)

# Redfish variables.
REDFISH_BASE_URI = "/redfish/v1/"
REDFISH_SESSION = REDFISH_BASE_URI + "SessionService/Sessions"
REDFISH_SESSION_URI = "SessionService/Sessions/"
REDFISH_NW_ETH0 = "Managers/" + BMC_ID + "/EthernetInterfaces/eth0/"
REDFISH_NW_ETH0_URI = REDFISH_BASE_URI + REDFISH_NW_ETH0
REDFISH_NW_ETH_IFACE = REDFISH_BASE_URI + "Managers/" + BMC_ID + "/EthernetInterfaces/"
REDFISH_NW_PROTOCOL = "Managers/" + BMC_ID + "/NetworkProtocol"
REDFISH_NW_PROTOCOL_URI = REDFISH_BASE_URI + REDFISH_NW_PROTOCOL
REDFISH_ACCOUNTS_SERVICE = "AccountService/"
REDFISH_ACCOUNTS_SERVICE_URI = REDFISH_BASE_URI + REDFISH_ACCOUNTS_SERVICE
REDFISH_ACCOUNTS = "AccountService/Accounts/"
REDFISH_ACCOUNTS_URI = REDFISH_BASE_URI + REDFISH_ACCOUNTS
REDFISH_HTTPS_CERTIFICATE = "Managers/" + BMC_ID + "/NetworkProtocol/HTTPS/Certificates"
REDFISH_HTTPS_CERTIFICATE_URI = REDFISH_BASE_URI + REDFISH_HTTPS_CERTIFICATE
REDFISH_LDAP_CERTIFICATE = "AccountService/LDAP/Certificates"
REDFISH_LDAP_CERTIFICATE_URI = REDFISH_BASE_URI + REDFISH_LDAP_CERTIFICATE
REDFISH_CA_CERTIFICATE = "Managers/" + BMC_ID + "/Truststore/Certificates"
REDFISH_CA_CERTIFICATE_URI = REDFISH_BASE_URI + REDFISH_CA_CERTIFICATE
REDFISH_CHASSIS_URI = REDFISH_BASE_URI + "Chassis/"
REDFISH_CHASSIS_THERMAL = CHASSIS_ID + "/Thermal/"
REDFISH_CHASSIS_THERMAL_URI = REDFISH_CHASSIS_URI + REDFISH_CHASSIS_THERMAL
REDFISH_CHASSIS_POWER = CHASSIS_ID + "/Power/"
REDFISH_CHASSIS_POWER_URI = REDFISH_CHASSIS_URI + REDFISH_CHASSIS_POWER
REDFISH_CHASSIS_SENSORS = CHASSIS_ID + "/Sensors"
REDFISH_CHASSIS_SENSORS_URI = REDFISH_CHASSIS_URI + REDFISH_CHASSIS_SENSORS
REDFISH_BMC_DUMP = "Managers/" + BMC_ID + "/LogServices/Dump/Entries"
REDFISH_DUMP_URI = REDFISH_BASE_URI + REDFISH_BMC_DUMP

# Boot options and URI variables.
POWER_ON = "On"
POWER_GRACEFUL_OFF = "GracefulShutdown"
POWER_GRACEFUL_RESTART = "GracefulRestart"
POWER_FORCE_OFF = "ForceOff"

REDFISH_POWER = "Systems/" + SYSTEM_ID + "/Actions/ComputerSystem.Reset"
REDFISH_POWER_URI = REDFISH_BASE_URI + REDFISH_POWER

# EventLog variables.
SYSTEM_BASE_URI = REDFISH_BASE_URI + "Systems/" + SYSTEM_ID + "/"
EVENT_LOG_URI = SYSTEM_BASE_URI + "LogServices/EventLog/"
DUMP_URI = SYSTEM_BASE_URI + "LogServices/Dump/"

BIOS_ATTR_URI = SYSTEM_BASE_URI + "Bios"
BIOS_ATTR_SETTINGS_URI = BIOS_ATTR_URI + "/Settings"

"""
  HTTPS variable:

  By default lib/resource.robot AUTH URI construct is as
  ${AUTH_URI}   https://${BMC_HOST}${AUTH_SUFFIX}
  ${AUTH_SUFFIX} is populated here by default EMPTY else
  the port from the OS environment
"""

AUTH_SUFFIX = ":" + BuiltIn().get_variable_value(
    "${HTTPS_PORT}", os.getenv("HTTPS_PORT", "443")
)
