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
BMC redfish utility functions.
"""

import json
import re

import gen_print as gp
from robot.libraries.BuiltIn import BuiltIn

MTLS_ENABLED = BuiltIn().get_variable_value("${MTLS_ENABLED}")
host = BuiltIn().get_variable_value("${BMC_HOST}")

BMC_ID = BuiltIn().get_variable_value("${BMC_ID}", default="bmc")


class bmc_redfish_utils(object):
    ROBOT_LIBRARY_SCOPE = "TEST SUITE"

    def __init__(self):
        r"""
        Initialize the bmc_redfish_utils object.
        """
        # Obtain a reference to the global redfish object.
        self.__inited__ = False
        self._redfish_ = BuiltIn().get_library_instance("redfish")

        if host != "redfish-localhost":
            self._redfish_.login()
            self._rest_response_ = self._redfish_.get(
                "/redfish/v1", valid_status_codes=[200]
            )

            # Enabled IPMI and ignore error if not support
            self._redfish_.patch("/redfish/v1/Managers/" + BMC_ID + "/NetworkProtocol",
                                 body={"IPMI": {"ProtocolEnabled": True}}, valid_status_codes=[])

            if self._rest_response_.status == 200:
                self.__inited__ = True

            # Update HTTPS Session timeout
            # By default the value of timeout is 30s, which may be less to cater to all the vendor
            # Increasing the value to 120s
            self._redfish_.patch("/redfish/v1/SessionService",
                                 body={"SessionTimeout":120}, valid_status_codes=[])

    def get_redfish_session_info(self):
        r"""
        Returns redfish sessions info dictionary.

        {
            'key': 'yLXotJnrh5nDhXj5lLiH' ,
            'location': '/redfish/v1/SessionService/Sessions/nblYY4wlz0'
        }
        """
        session_dict = {
            "key": self._redfish_.get_session_key(),
            "location": self._redfish_.get_session_location(),
        }
        return session_dict

    def get_attribute(self, resource_path, attribute, verify=None):
        r"""
        Get resource attribute.

        Description of argument(s):
        resource_path               URI resource absolute path (e.g.
                                    "/redfish/v1/Systems/1").
        attribute                   Name of the attribute (e.g. 'PowerState').
        """

        resp = self._redfish_.get(resource_path)

        if verify:
            if resp.dict[attribute] == verify:
                return resp.dict[attribute]
            else:
                raise ValueError("Attribute value is not equal")
        elif attribute in resp.dict:
            return resp.dict[attribute]

        return None

    def get_properties(self, resource_path):
        r"""
        Returns dictionary of attributes for the resource.

        Description of argument(s):
        resource_path               URI resource absolute path (e.g.
                                    /redfish/v1/Systems/1").
        """

        resp = self._redfish_.get(resource_path)
        return resp.dict

    def get_members_uri(self, resource_path, attribute):
        r"""
        Returns the list of valid path which has a given attribute.

        Description of argument(s):
        resource_path            URI resource base path (e.g.
                                 '/redfish/v1/Systems/',
                                 '/redfish/v1/Chassis/').
        attribute                Name of the attribute (e.g. 'PowerSupplies').
        """

        # Set quiet variable to keep subordinate get() calls quiet.
        quiet = 1

        # Get the member id list.
        # e.g. ['/redfish/v1/Chassis/foo', '/redfish/v1/Chassis/bar']
        resource_path_list = self.get_member_list(resource_path)

        valid_path_list = []

        for path_idx in resource_path_list:
            # Get all the child object path under the member id e.g.
            # ['/redfish/v1/Chassis/foo/Power','/redfish/v1/Chassis/bar/Power']
            child_path_list = self.list_request(path_idx)

            # Iterate and check if path object has the attribute.
            for child_path_idx in child_path_list:
                if (
                    ("JsonSchemas" in child_path_idx)
                    or ("SessionService" in child_path_idx)
                    or ("#" in child_path_idx)
                ):
                    continue
                if self.get_attribute(child_path_idx, attribute):
                    valid_path_list.append(child_path_idx)

        BuiltIn().log_to_console(valid_path_list)
        return valid_path_list

    def get_endpoint_path_list(self, resource_path, end_point_prefix):
        r"""
        Returns list with entries ending in "/endpoint".

        Description of argument(s):
        resource_path      URI resource base path (e.g. "/redfish/v1/Chassis/").
        end_point_prefix   Name of the endpoint (e.g. 'Power').

        Find all list entries ending in "/endpoint" combination such as
        /redfish/v1/Chassis/<foo>/Power
        /redfish/v1/Chassis/<bar>/Power
        """

        end_point_list = self.list_request(resource_path)

        # Regex to match entries ending in "/prefix" with optional underscore.
        regex = ".*/" + end_point_prefix + "[_]?[0-9]*$"
        return [x for x in end_point_list if re.match(regex, x, re.IGNORECASE)]

    def get_target_actions(self, resource_path, target_attribute):
        r"""
        Returns resource target entry of the searched target attribute.

        Description of argument(s):
        resource_path      URI resource absolute path
                           (e.g. "/redfish/v1/Systems/${SYSTEM_ID}").
        target_attribute   Name of the attribute (e.g. 'ComputerSystem.Reset').

        Example:
        "Actions": {
        "#ComputerSystem.Reset": {
        "ResetType@Redfish.AllowableValues": [
            "On",
            "ForceOff",
            "GracefulRestart",
            "GracefulShutdown"
        ],
        "target": "/redfish/v1/Systems/${SYSTEM_ID}/Actions/ComputerSystem.Reset"
        }
        }
        """

        global target_list
        target_list = []

        resp_dict = self.get_attribute(resource_path, "Actions")
        if resp_dict is None:
            return None

        # Recursively search the "target" key in the nested dictionary.
        # Populate the target_list of target entries.
        self.get_key_value_nested_dict(resp_dict, "target")
        # Return the matching target URL entry.
        for target in target_list:
            # target "/redfish/v1/Systems/${SYSTEM_ID}/Actions/ComputerSystem.Reset"
            attribute_in_uri = target.rsplit("/", 1)[-1]
            # attribute_in_uri "ComputerSystem.Reset"
            if target_attribute == attribute_in_uri:
                return target

        return None

    def get_member_list(self, resource_path):
        r"""
        Perform a GET list request and return available members entries.

        Description of argument(s):
        resource_path  URI resource absolute path
                       (e.g. "/redfish/v1/SessionService/Sessions").

        "Members": [
            {
             "@odata.id": "/redfish/v1/SessionService/Sessions/Z5HummWPZ7"
            }
            {
             "@odata.id": "/redfish/v1/SessionService/Sessions/46CmQmEL7H"
            }
        ],
        """

        member_list = []
        resp_list_dict = self.get_attribute(resource_path, "Members")
        if resp_list_dict is None:
            return member_list

        for member_id in range(0, len(resp_list_dict)):
            member_list.append(resp_list_dict[member_id]["@odata.id"])

        return member_list

    def list_request(self, resource_path):
        r"""
        Perform a GET list request and return available resource paths.
        Description of argument(s):
        resource_path  URI resource absolute path
                       (e.g. "/redfish/v1/SessionService/Sessions").
        """
        gp.qprint_executing(style=gp.func_line_style_short)
        # Set quiet variable to keep subordinate get() calls quiet.
        quiet = 1
        self.__pending_enumeration = set()
        self._rest_response_ = self._redfish_.get(
            resource_path, valid_status_codes=[200, 404, 500]
        )

        # Return empty list.
        if self._rest_response_.status != 200:
            return self.__pending_enumeration
        self.walk_nested_dict(self._rest_response_.dict)
        if not self.__pending_enumeration:
            return resource_path
        for resource in self.__pending_enumeration.copy():
            self._rest_response_ = self._redfish_.get(
                resource, valid_status_codes=[200, 404, 500]
            )

            if self._rest_response_.status != 200:
                continue
            self.walk_nested_dict(self._rest_response_.dict)
        return list(sorted(self.__pending_enumeration))

    def enumerate_request(
        self, resource_path, return_json=1, include_dead_resources=False
    ):
        r"""
        Perform a GET enumerate request and return available resource paths.

        Description of argument(s):
        resource_path               URI resource absolute path (e.g.
                                    "/redfish/v1/SessionService/Sessions").
        return_json                 Indicates whether the result should be
                                    returned as a json string or as a
                                    dictionary.
        include_dead_resources      Check and return a list of dead/broken URI
                                    resources.
        """

        gp.qprint_executing(style=gp.func_line_style_short)

        return_json = int(return_json)

        # Set quiet variable to keep subordinate get() calls quiet.
        quiet = 1

        # Variable to hold enumerated data.
        self.__result = {}

        # Variable to hold the pending list of resources for which enumeration.
        # is yet to be obtained.
        self.__pending_enumeration = set()

        self.__pending_enumeration.add(resource_path)

        # Variable having resources for which enumeration is completed.
        enumerated_resources = set()

        if include_dead_resources:
            dead_resources = {}

        resources_to_be_enumerated = (resource_path,)

        while resources_to_be_enumerated:
            for resource in resources_to_be_enumerated:
                # JsonSchemas, SessionService or URLs containing # are not
                # required in enumeration.
                # Example: '/redfish/v1/JsonSchemas/' and sub resources.
                #          '/redfish/v1/SessionService'
                #          '/redfish/v1/Managers/bmc#/Oem'
                if (
                    ("JsonSchemas" in resource)
                    or ("SessionService" in resource)
                    or ("PostCodes" in resource)
                    or ("Registries" in resource)
                    or ("Journal" in resource)
                    or ("#" in resource)
                ):
                    continue

                self._rest_response_ = self._redfish_.get(
                    resource, valid_status_codes=[200, 404, 405, 500]
                )
                # Enumeration is done for available resources ignoring the
                # ones for which response is not obtained.
                if self._rest_response_.status != 200:
                    if include_dead_resources:
                        try:
                            dead_resources[self._rest_response_.status].append(
                                resource
                            )
                        except KeyError:
                            dead_resources[self._rest_response_.status] = [
                                resource
                            ]
                    continue

                self.walk_nested_dict(self._rest_response_.dict, url=resource)

            enumerated_resources.update(set(resources_to_be_enumerated))
            resources_to_be_enumerated = tuple(
                self.__pending_enumeration - enumerated_resources
            )

        if return_json:
            if include_dead_resources:
                return (
                    json.dumps(
                        self.__result,
                        sort_keys=True,
                        indent=4,
                        separators=(",", ": "),
                    ),
                    dead_resources,
                )
            else:
                return json.dumps(
                    self.__result,
                    sort_keys=True,
                    indent=4,
                    separators=(",", ": "),
                )
        else:
            if include_dead_resources:
                return self.__result, dead_resources
            else:
                return self.__result

    def walk_nested_dict(self, data, url=""):
        r"""
        Parse through the nested dictionary and get the resource id paths.
        Description of argument(s):
        data    Nested dictionary data from response message.
        url     Resource for which the response is obtained in data.
        """
        url = url.rstrip("/")

        for key, value in data.items():
            # Recursion if nested dictionary found.
            if isinstance(value, dict):
                self.walk_nested_dict(value)
            else:
                # Value contains a list of dictionaries having member data.
                if "Members" == key:
                    if isinstance(value, list):
                        for memberDict in value:
                            if isinstance(memberDict, str):
                                self.__pending_enumeration.add(memberDict)
                            else:
                                self.__pending_enumeration.add(
                                    memberDict["@odata.id"]
                                )

                if "@odata.id" == key:
                    value = value.rstrip("/")
                    # Data for the given url.
                    if value == url:
                        self.__result[url] = data
                    # Data still needs to be looked up,
                    else:
                        self.__pending_enumeration.add(value)

    def get_key_value_nested_dict(self, data, key):
        r"""
        Parse through the nested dictionary and get the searched key value.

        Description of argument(s):
        data    Nested dictionary data from response message.
        key     Search dictionary key element.
        """

        for k, v in data.items():
            if isinstance(v, dict):
                self.get_key_value_nested_dict(v, key)

            if k == key:
                target_list.append(v)
