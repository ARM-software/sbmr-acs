#!/usr/bin/env python3

# Copyright (c) 2026, Arm Limited or its affiliates. All rights reserved.
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
Redfish instance ID discovery library.

When imported, this library resolves BMC_ID, SYSTEM_ID, and CHASSIS_ID from
explicit config values or by querying Redfish, then publishes them as Robot
global variables before the Redfish libraries are initialized.
"""

import json
import ssl
import time
from base64 import b64encode
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

from robot.libraries.BuiltIn import BuiltIn

ID_VARS = ("BMC_ID", "SYSTEM_ID", "CHASSIS_ID")
REQUIRED_CONFIG_VARS = ("BMC_HOST", "BMC_USERNAME", "BMC_PASSWORD")


class DiscoveryError(RuntimeError):
    """Raised when Redfish ID discovery fails."""


def get_variable(name, default=""):
    return BuiltIn().get_variable_value("${" + name + "}", default)


def log_info(message):
    BuiltIn().log(message, level="INFO")
    BuiltIn().log_to_console("INFO: " + message)


def redfish_request(config, path, method="GET", payload=None):
    base_url = f'https://{config["BMC_HOST"]}:{config.get("HTTPS_PORT", "443")}'
    credential = f'{config["BMC_USERNAME"]}:{config["BMC_PASSWORD"]}'
    auth = b64encode(credential.encode("utf-8")).decode("ascii")
    headers = {
        "Accept": "application/json",
        "Authorization": f"Basic {auth}",
    }
    data = None
    if payload is not None:
        headers["Content-Type"] = "application/json"
        data = json.dumps(payload).encode("utf-8")

    request = Request(
        base_url + path,
        headers=headers,
        data=data,
        method=method,
    )

    try:
        with urlopen(
            request, context=ssl._create_unverified_context(), timeout=15
        ) as response:
            if response.length == 0:
                return {}
            return json.load(response)
    except HTTPError as error:
        detail = error.read().decode("utf-8", errors="replace")
        raise DiscoveryError(
            f"{method} {path} failed with HTTP {error.code}: {detail}"
        ) from error
    except URLError as error:
        raise DiscoveryError(f"{method} {path} failed: {error.reason}") from error

def id_from_odata(odata_id, collection):
    if not odata_id:
        raise DiscoveryError("Redfish member is missing '@odata.id'.")

    marker = f"/{collection}/"
    if marker not in odata_id:
        raise DiscoveryError(
            f"Expected '{marker}' in Redfish member path: {odata_id}"
        )

    return odata_id.split(marker, 1)[1].split("/", 1)[0]


def first_collection_id(data, collection_name):
    members = data.get("Members") or []
    if not members:
        raise DiscoveryError(
            f"Redfish collection '/redfish/v1/{collection_name}' is empty."
        )

    return id_from_odata(members[0].get("@odata.id"), collection_name)


def discover_system_id(config):
    log_info("Discovering SYSTEM_ID from /redfish/v1/Systems.")
    systems = redfish_request(config, "/redfish/v1/Systems")
    members = systems.get("Members") or []
    if not members:
        raise DiscoveryError("Redfish collection '/redfish/v1/Systems' is empty.")

    for member in members:
        system_uri = member.get("@odata.id")
        if not system_uri:
            continue

        system = redfish_request(config, system_uri)
        # Pick the system resource used by the boot-progress checks in the suite.
        if "BootProgress" in system:
            system_id = id_from_odata(system_uri, "Systems")
            log_info(f"Selected SYSTEM_ID '{system_id}' because BootProgress is present.")
            return system_id

    raise DiscoveryError(
        "Unable to find a system resource with 'BootProgress' in "
        "'/redfish/v1/Systems'."
    )


def discover_bmc_id(config, system_id):
    log_info(f"Discovering BMC_ID for SYSTEM_ID '{system_id}'.")
    system = redfish_request(config, f"/redfish/v1/Systems/{system_id}")
    manager_links = (system.get("Links") or {}).get("ManagedBy") or []

    for manager_link in manager_links:
        manager_uri = manager_link.get("@odata.id")
        if manager_uri:
            # If the chosen system points to a manager, use that manager.
            manager_id = id_from_odata(manager_uri, "Managers")
            log_info(f"Selected BMC_ID '{manager_id}' from Systems/{system_id}/Links/ManagedBy.")
            return manager_id

    # Fall back to collection order only if the system has no manager link.
    manager_id = first_collection_id(
        redfish_request(config, "/redfish/v1/Managers"), "Managers"
    )
    log_info(f"Selected BMC_ID '{manager_id}' from the Managers collection fallback.")
    return manager_id


def get_chassis_power_states(config):
    chassis = redfish_request(config, "/redfish/v1/Chassis")
    members = chassis.get("Members") or []
    power_states = {}

    for member in members:
        chassis_uri = member.get("@odata.id")
        if not chassis_uri:
            continue

        chassis_data = redfish_request(config, chassis_uri)
        if "PowerState" in chassis_data:
            power_states[id_from_odata(chassis_uri, "Chassis")] = chassis_data["PowerState"]

    return power_states


def wait_for_powered_off_chassis(config, delay=30):
    # Give the service some time to reflect the host power-off in chassis state.
    log_info(f"Waiting {delay} seconds before checking chassis PowerState.")
    time.sleep(delay)

    power_states = get_chassis_power_states(config)
    off_candidates = [
        chassis_id
        for chassis_id, power_state in power_states.items()
        if power_state == "Off"
    ]
    if off_candidates:
        # Use the chassis that reports the powered-off state after the reset.
        chassis_id = off_candidates[0]
        log_info(f"Selected CHASSIS_ID '{chassis_id}' because it reports PowerState 'Off'.")
        return chassis_id

    raise DiscoveryError(
        "Unable to find a chassis resource with 'PowerState' equal to 'Off' "
        "after powering off the system."
    )


def discover_chassis_id(config, system_id):
    system_uri = f"/redfish/v1/Systems/{system_id}"
    # Drive the system to Off and then identify the chassis that reports Off.
    log_info(f"Discovering CHASSIS_ID by forcing off SYSTEM_ID '{system_id}'.")
    redfish_request(
        config,
        system_uri + "/Actions/ComputerSystem.Reset",
        method="POST",
        payload={"ResetType": "ForceOff"},
    )
    return wait_for_powered_off_chassis(config)


def discover_ids(config):
    resolved = {
        name: config[name] for name in ID_VARS if config.get(name)
    }
    if resolved:
        log_info(
            "Using configured Redfish IDs for: " + ", ".join(sorted(resolved.keys()))
        )
    # Config values take precedence over auto-discovery.
    if len(resolved) == len(ID_VARS):
        return resolved

    missing_config = [name for name in REQUIRED_CONFIG_VARS if not config.get(name)]
    if missing_config:
        raise DiscoveryError(
            "Missing required config variables for discovery: "
            + ", ".join(missing_config)
        )

    if "SYSTEM_ID" not in resolved:
        resolved["SYSTEM_ID"] = discover_system_id(config)

    if "BMC_ID" not in resolved:
        resolved["BMC_ID"] = discover_bmc_id(config, resolved["SYSTEM_ID"])

    if "CHASSIS_ID" not in resolved:
        resolved["CHASSIS_ID"] = discover_chassis_id(config, resolved["SYSTEM_ID"])

    return resolved


def set_redfish_instance_ids():
    auto_discover = str(get_variable("AUTO_DISCOVER_REDFISH_IDS", "1")).lower()
    if auto_discover in ("0", "false", "no"):
        # IB runs disable auto-discovery and keep the configured/default values.
        log_info("Redfish instance auto-discovery is disabled.")
        return

    log_info("Starting Redfish instance ID discovery.")
    config = {
        "BMC_HOST": get_variable("BMC_HOST", ""),
        "BMC_USERNAME": get_variable("BMC_USERNAME", ""),
        "BMC_PASSWORD": get_variable("BMC_PASSWORD", ""),
        "HTTPS_PORT": get_variable("HTTPS_PORT", "443"),
        "BMC_ID": get_variable("BMC_ID", ""),
        "SYSTEM_ID": get_variable("SYSTEM_ID", ""),
        "CHASSIS_ID": get_variable("CHASSIS_ID", ""),
    }

    # Publish the resolved IDs globally so subsequent Redfish libraries use them.
    resolved = discover_ids(config)
    builtin = BuiltIn()
    for name, value in resolved.items():
        builtin.set_global_variable("${" + name + "}", value)
    log_info(
        "Resolved Redfish instance IDs: "
        + ", ".join(f"{name}={value}" for name, value in sorted(resolved.items()))
    )


set_redfish_instance_ids()
