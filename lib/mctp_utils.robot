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

*** Settings ***
Library          Collections
Library          String
Library          bmc_ssh_utils.py


*** Variables ***
${MCTP_SB_INTERFACES}    ${EMPTY}
${MCTP_IO_INTERFACES}    ${EMPTY}


*** Keywords ***
Get Configured MCTP Interfaces
    [Documentation]  Parse and validate the configured MCTP interface list for one role.
    [Arguments]  ${interface_csv}  ${role}

    ${interfaces}=  Parse MCTP Interface List  ${interface_csv}  ${role}  ${True}
    IF  '${role}' == 'SIDE-BAND'
        ${other_interfaces}=  Parse MCTP Interface List  ${MCTP_IO_INTERFACES}  BMC-IO  ${False}
    ELSE
        ${other_interfaces}=  Parse MCTP Interface List  ${MCTP_SB_INTERFACES}  SIDE-BAND  ${False}
    END

    FOR  ${interface}  IN  @{interfaces}
        List Should Not Contain Value  ${other_interfaces}  ${interface}
        ...  msg=MCTP interface '${interface}' is configured for both SIDE-BAND and BMC-IO roles.
    END

    RETURN  ${interfaces}


Parse MCTP Interface List
    [Documentation]  Convert a comma-separated interface value into a validated unique list.
    [Arguments]  ${interface_csv}  ${role}  ${required}

    ${interfaces}=  Create List
    IF  '${interface_csv}' == '${EMPTY}'
        IF  ${required}
            IF  '${role}' == 'SIDE-BAND'
                ${selector_name}=  Set Variable  MCTP_SB_INTERFACES
            ELSE
                ${selector_name}=  Set Variable  MCTP_IO_INTERFACES
            END
            Fail  No ${role} MCTP interfaces configured. Set ${selector_name}, or use the rule declaration fallback.
        END
        RETURN  ${interfaces}
    END

    @{raw_interfaces}=  Split String  ${interface_csv}  ,
    FOR  ${raw_interface}  IN  @{raw_interfaces}
        ${interface}=  Strip String  ${raw_interface}
        Should Not Be Empty  ${interface}
        ...  msg=The ${role} MCTP interface list contains an empty entry: '${interface_csv}'.
        Should Match Regexp  ${interface}  ^mctp[A-Za-z0-9_.:-]+$
        ...  msg=Invalid ${role} MCTP interface name '${interface}'.
        ${is_duplicate}=  Run Keyword And Return Status
        ...  List Should Contain Value  ${interfaces}  ${interface}
        IF  not ${is_duplicate}
            Append To List  ${interfaces}  ${interface}
        END
    END

    RETURN  ${interfaces}


Get MCTP Route Output
    [Documentation]  Run mctp route and return validated output.

    ${route_output}  ${stderr}  ${rc}=  BMC Execute Command  mctp route  print_err=1
    Should Be Equal As Integers  0  ${rc}
    ...  msg=mctp route failed. stdout=${route_output} stderr=${stderr}
    Should Be Empty  ${stderr}  msg=${route_output}
    Should Not Be Empty  ${route_output}  msg=mctp route did not return any endpoint routes.
    RETURN  ${route_output}


Get MCTP Routes For Interface
    [Documentation]  Return route ranges associated with one configured role interface.
    [Arguments]  ${route_output}  ${interface}  ${role}

    ${interface_regex}=  Evaluate  re.escape(r'''${interface}''')  modules=re
    ${route_matches}=  Get Regexp Matches
    ...  ${route_output}
    ...  (?im)^eid\\s+min\\s+(\\d+)\\s+max\\s+(\\d+)\\s+net\\s+(\\d+)\\s+dev\\s+${interface_regex}(?:\\s|$)
    ...  1  2  3
    Should Not Be Empty  ${route_matches}
    ...  msg=No MCTP endpoint routes were found for configured ${role} interface '${interface}'. Output: ${route_output}
    RETURN  ${route_matches}


Discover MCTP D-Bus Service
    [Documentation]  Discover the MCTP D-Bus service by matching the expected object model.

    ${busctl_list}  ${stderr}  ${rc}=  BMC Execute Command  busctl list --no-pager  print_err=1
    Should Be Equal As Integers  0  ${rc}
    ...  msg=MCTP D-Bus service discovery failed. stdout=${busctl_list} stderr=${stderr}
    Should Be Empty  ${stderr}  msg=${busctl_list}

    # Unique connection names start with ':'; prefer stable service names that look MCTP-related.
    ${candidate_services}=  Get Regexp Matches
    ...  ${busctl_list}
    ...  (?im)^([^:\\s][^\\s]*mctp[^\\s]*)\\s+
    ...  1
    Should Not Be Empty  ${candidate_services}
    ...  msg=No non-transient MCTP D-Bus service candidates were discovered. Output: ${busctl_list}

    FOR  ${candidate_service}  IN  @{candidate_services}
        ${candidate_tree}  ${stderr}  ${rc}=  BMC Execute Command
        ...  busctl tree ${candidate_service}
        ...  print_err=1
        IF  ${rc} != 0 or '''${stderr}''' != '''${EMPTY}'''
            Log  Skipping MCTP D-Bus candidate ${candidate_service}: rc=${rc}, stderr=${stderr}
            CONTINUE
        END

        ${has_interfaces}=  Run Keyword And Return Status
        ...  Should Contain  ${candidate_tree}  /interfaces
        ${has_endpoints}=  Run Keyword And Return Status
        ...  Should Match Regexp  ${candidate_tree}  /networks/[0-9]+/endpoints/[0-9]+
        IF  ${has_interfaces} and ${has_endpoints}
            RETURN  ${candidate_service}  ${candidate_tree}
        END

        Log  Skipping MCTP D-Bus candidate ${candidate_service}: expected interfaces/endpoints were not found.
    END

    Fail  No MCTP D-Bus service exposing /interfaces and /networks/<id>/endpoints/<eid> was discovered. Output: ${busctl_list}


Get MCTP Network Path
    [Documentation]  Resolve a network ID to its object path in the MCTP D-Bus tree.
    [Arguments]  ${mctp_tree}  ${network_id}

    ${network_paths}=  Get Regexp Matches
    ...  ${mctp_tree}
    ...  (?m)(/[^\\s]+/networks/${network_id})(?:/|\\s|$)
    ...  1
    Should Not Be Empty  ${network_paths}
    ...  msg=MCTP network ${network_id} from route output was not present in the D-Bus tree. Output: ${mctp_tree}
    RETURN  ${network_paths}[0]


Get MCTP Network Details
    [Documentation]  Discover the control interface and local EIDs for one MCTP network.
    [Arguments]  ${mctp_dbus_service}  ${network_path}

    ${network_introspection}  ${stderr}  ${rc}=  BMC Execute Command
    ...  busctl introspect ${mctp_dbus_service} ${network_path}
    ...  print_err=1
    Should Be Equal As Integers  0  ${rc}
    ...  msg=Failed to introspect MCTP network ${network_path}. stdout=${network_introspection} stderr=${stderr}
    Should Be Empty  ${stderr}  msg=${network_introspection}

    # Find the network interface that implements the binding-independent
    # LearnEndpoint method instead of assuming a vendor-specific interface name.
    ${control_interfaces}=  Evaluate
    ...  re.findall(r'(?ms)^([^\\s.][^\\s]*)\\s+interface\\b(?:(?!^[^\\s.][^\\s]*\\s+interface\\b).)*?^\\.LearnEndpoint\\s+method\\s+y\\s+sb\\b', '''${network_introspection}''')
    ...  modules=re
    Should Not Be Empty  ${control_interfaces}
    ...  msg=MCTP network ${network_path} did not expose LearnEndpoint with signature y and result sb. Output: ${network_introspection}
    ${control_interface}=  Set Variable  ${control_interfaces}[0]

    # LocalEIDs must belong to the same interface used for endpoint control.
    ${control_interface_regex}=  Evaluate  re.escape(r'''${control_interface}''')  modules=re
    Should Match Regexp  ${network_introspection}  (?ms)^${control_interface_regex}\\s+interface\\b(?:(?!^[^\\s.][^\\s]*\\s+interface\\b).)*?^\\.LocalEIDs\\s+property\\s+ay\\b
    ...  msg=MCTP network ${network_path} did not expose LocalEIDs on ${control_interface}. Output: ${network_introspection}

    ${local_eids_output}  ${stderr}  ${rc}=  BMC Execute Command
    ...  busctl get-property ${mctp_dbus_service} ${network_path} ${control_interface} LocalEIDs
    ...  print_err=1
    Should Be Equal As Integers  0  ${rc}
    ...  msg=Failed to read LocalEIDs for MCTP network ${network_path}. stdout=${local_eids_output} stderr=${stderr}
    Should Be Empty  ${stderr}  msg=${local_eids_output}

    # busctl prints an array element count before the EIDs, for example "ay 1 8".
    ${local_eids}=  Evaluate  re.findall(r'\\d+', '''${local_eids_output}''')[1:]  modules=re
    RETURN  ${control_interface}  ${local_eids}
