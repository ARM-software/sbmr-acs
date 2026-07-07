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
Documentation    PLDM role-scoped interface tests.
Library          Collections
Library          ../lib/bmc_ssh_utils.py
Resource         ../lib/mctp_utils.robot


*** Variables ***
${M3_SB_2_PLDM_PLATFORM_FUNCTIONS_SUPPORT}                0
${M3_SB_4_PLDM_OVER_MCTP_BINDING_SUPPORT}                 0
${M4_IO_1_PCIE_DEVICE_MCTP_PLDM_MANAGEMENT_SUPPORT}       0


*** Test Cases ***
Test PLDM Side Band Platform Functions
    [Documentation]  Verify PLDM platform functions through configured SIDE-BAND interfaces.
    [Tags]  M3_SB_2_PLDM_Platform_Functions

    # PLDM_Test_Case_001: platform-level PLDM service and object-model check.
    Run Automated Check Or Declaration
    ...  ${M3_SB_2_PLDM_PLATFORM_FUNCTIONS_SUPPORT}
    ...  M3_SB_2_PLDM_Platform_Functions
    ...  Verify PLDM Platform Functions
    ...  ${MCTP_SB_INTERFACES}
    ...  SIDE-BAND


Test PLDM Side Band Over MCTP Binding
    [Documentation]  Verify PLDM commands are carried over configured SIDE-BAND interfaces.
    [Tags]  M3_SB_4_PLDM_Over_MCTP_Binding

    # PLDM_Test_Case_002: PLDM-over-MCTP dependency and command-flow check.
    Run Automated Check Or Declaration
    ...  ${M3_SB_4_PLDM_OVER_MCTP_BINDING_SUPPORT}
    ...  M3_SB_4_PLDM_Over_MCTP_Binding
    ...  Verify PLDM Over MCTP Binding
    ...  ${MCTP_SB_INTERFACES}
    ...  SIDE-BAND


Test PLDM BMC IO Management
    [Documentation]  Verify PLDM management through configured BMC-IO interfaces.
    [Tags]  M4_IO_1_PCIe_Device_MCTP_PLDM_Management

    # PLDM_Test_Case_002: BMC-IO PLDM-over-MCTP command-flow check.
    Run Automated Check Or Declaration
    ...  ${M4_IO_1_PCIE_DEVICE_MCTP_PLDM_MANAGEMENT_SUPPORT}
    ...  M4_IO_1_PCIe_Device_MCTP_PLDM_Management
    ...  Verify PLDM Over MCTP Binding
    ...  ${MCTP_IO_INTERFACES}
    ...  BMC-IO


*** Keywords ***
Run Automated Check Or Declaration
    [Documentation]  Run a PLDM automated check, or pass by matching manual declaration.
    [Arguments]  ${declaration_var}  ${rule_tag}  ${verification_keyword}  @{verification_args}

    # Manual validation may be declared through the matching rule-specific support flag.
    IF  '${declaration_var}' == '1'
        Log  PLDM automation is bypassed by declaration for ${rule_tag}.
        RETURN
    END

    Run Keyword  ${verification_keyword}  @{verification_args}


Verify PLDM Platform Functions
    [Documentation]  Verify PLDM service, platform object model, and role endpoint commands.
    [Arguments]  ${interface_csv}  ${role}

    ${interfaces}=  Get Configured MCTP Interfaces  ${interface_csv}  ${role}

    # Step 1: PLDM daemon must exist and be active on the BMC.
    ${service_status}  ${stderr}  ${rc}=  BMC Execute Command  systemctl status pldmd.service --no-pager  print_err=1
    Should Be Equal As Integers  0  ${rc}
    ...  msg=pldmd.service status command failed. stdout=${service_status} stderr=${stderr}
    Should Be Empty  ${stderr}  msg=${service_status}
    Should Match Regexp  ${service_status}  (?m)Active:\\s+active\\s+\\(running\\)
    ...  msg=pldmd.service is not active and running. Output: ${service_status}

    # Step 2: discover the stable PLDM D-Bus service by requiring a platform object model.
    ${pldm_dbus_service}  ${pldm_tree}=  Discover PLDM D-Bus Service

    # Step 3: introspect every object path exposed by the PLDM service tree.
    ${pldm_object_paths}=  Get PLDM Object Paths  ${pldm_tree}
    Verify PLDM Object Introspection  ${pldm_dbus_service}  ${pldm_object_paths}

    # Step 4: require PLDM base and platform responses through the selected role.
    ${endpoint_candidates}=  Discover PLDM MCTP Endpoint IDs  ${interfaces}  ${role}
    Verify PLDM Commands For Role Endpoints  ${endpoint_candidates}  ${role}


Verify PLDM Over MCTP Binding
    [Documentation]  Verify PLDM-over-MCTP binding through dependency and PLDM commands.
    [Arguments]  ${interface_csv}  ${role}

    ${interfaces}=  Get Configured MCTP Interfaces  ${interface_csv}  ${role}

    # Step 1: record whether pldmd declares an explicit MCTP systemd relationship.
    ${pldm_dependencies}  ${stderr}  ${rc}=  BMC Execute Command
    ...  systemctl show pldmd.service --property=After --property=Requires --property=Wants --no-pager
    ...  print_err=1
    Should Be Equal As Integers  0  ${rc}
    ...  msg=pldmd.service dependency query failed. stdout=${pldm_dependencies} stderr=${stderr}
    Should Be Empty  ${stderr}  msg=${pldm_dependencies}
    ${has_mctp_dependency}=  Run Keyword And Return Status
    ...  Should Match Regexp  ${pldm_dependencies}  (?im)\\bmctp[^\\s]*\\.(service|target)\\b
    IF  not ${has_mctp_dependency}
        Log  pldmd.service has no explicit MCTP systemd relationship; continuing with functional PLDM-over-MCTP validation. Output: ${pldm_dependencies}  WARN
    END

    # Step 2: get candidate remote EIDs from the MCTP routing table for pldmtool -m.
    ${endpoint_candidates}=  Discover PLDM MCTP Endpoint IDs  ${interfaces}  ${role}

    # Step 3: prove PLDM messages can be sent over MCTP using read-only base/platform commands.
    Verify PLDM Commands For Role Endpoints  ${endpoint_candidates}  ${role}


Discover PLDM D-Bus Service
    [Documentation]  Discover the PLDM D-Bus service by matching a platform object tree.

    ${busctl_list}  ${stderr}  ${rc}=  BMC Execute Command  busctl list --no-pager  print_err=1
    Should Be Equal As Integers  0  ${rc}
    ...  msg=PLDM D-Bus service discovery failed. stdout=${busctl_list} stderr=${stderr}
    Should Be Empty  ${stderr}  msg=${busctl_list}

    # Unique connection names start with ':'; prefer stable service names that look PLDM-related.
    ${candidate_services}=  Get Regexp Matches
    ...  ${busctl_list}
    ...  (?im)^([^:\\s][^\\s]*pldm[^\\s]*)\\s+
    ...  1
    Should Not Be Empty  ${candidate_services}
    ...  msg=No non-transient PLDM D-Bus service candidates were discovered. Output: ${busctl_list}

    FOR  ${candidate_service}  IN  @{candidate_services}
        ${candidate_tree}  ${stderr}  ${rc}=  BMC Execute Command
        ...  busctl tree ${candidate_service}
        ...  print_err=1
        IF  ${rc} != 0 or '''${stderr}''' != '''${EMPTY}'''
            Log  Skipping PLDM D-Bus candidate ${candidate_service}: rc=${rc}, stderr=${stderr}
            CONTINUE
        END

        ${has_platform_model}=  Run Keyword And Return Status
        ...  Should Match Regexp  ${candidate_tree}  (?im)/xyz/openbmc_project/(pldm|inventory|sensors|control|file)(/|$)
        IF  ${has_platform_model}
            RETURN  ${candidate_service}  ${candidate_tree}
        END

        Log  Skipping PLDM D-Bus candidate ${candidate_service}: expected platform objects were not found.
    END

    Fail  No PLDM D-Bus service exposing platform object paths was discovered. Output: ${busctl_list}


Get PLDM Object Paths
    [Documentation]  Extract unique object paths from busctl tree output.
    [Arguments]  ${pldm_tree}

    ${object_matches}=  Get Regexp Matches
    ...  ${pldm_tree}
    ...  (?m)(/[A-Za-z0-9_./-]+)
    ...  1
    Should Not Be Empty  ${object_matches}
    ...  msg=No PLDM object paths were discovered. Output: ${pldm_tree}

    ${object_paths}=  Create List
    FOR  ${object_path}  IN  @{object_matches}
        ${is_known_object}=  Run Keyword And Return Status
        ...  List Should Contain Value  ${object_paths}  ${object_path}
        IF  not ${is_known_object}
            Append To List  ${object_paths}  ${object_path}
        END
    END

    RETURN  ${object_paths}


Verify PLDM Object Introspection
    [Documentation]  Introspect every PLDM D-Bus object and require platform-relevant exposure.
    [Arguments]  ${pldm_dbus_service}  ${pldm_object_paths}

    ${platform_object_count}=  Set Variable  0
    FOR  ${object_path}  IN  @{pldm_object_paths}
        # Structural and leaf objects should all be introspectable if they are advertised in the tree.
        ${introspection}  ${stderr}  ${rc}=  BMC Execute Command
        ...  busctl introspect ${pldm_dbus_service} ${object_path}
        ...  print_err=1
        Should Be Equal As Integers  0  ${rc}
        ...  msg=Failed to introspect PLDM object ${object_path}. stdout=${introspection} stderr=${stderr}
        Should Be Empty  ${stderr}  msg=${introspection}
        Should Not Be Empty  ${introspection}
        ...  msg=PLDM object ${object_path} returned empty introspection output.

        ${has_platform_path}=  Run Keyword And Return Status
        ...  Should Match Regexp  ${object_path}  (?i)^/xyz/openbmc_project/(pldm|inventory|sensors|control|file)(/|$)
        ${has_platform_interface}=  Run Keyword And Return Status
        ...  Should Match Regexp  ${introspection}  (?im)^xyz\\.openbmc_project\\.(PLDM|Inventory|Sensor|Control|State|Association|Object|File)\\b
        IF  ${has_platform_path} or ${has_platform_interface}
            ${platform_object_count}=  Evaluate  ${platform_object_count} + 1
        END
    END

    Should Not Be Equal As Integers  ${platform_object_count}  0
    ...  msg=PLDM D-Bus tree did not expose platform-level PLDM, inventory, sensor, control, or file objects.


Discover PLDM MCTP Endpoint IDs
    [Documentation]  Discover remote PLDM candidates routed through configured role interfaces.
    [Arguments]  ${interfaces}  ${role}

    ${route_output}=  Get MCTP Route Output
    ${mctp_dbus_service}  ${mctp_tree}=  Discover MCTP D-Bus Service

    ${endpoint_candidates}=  Create List
    ${candidate_keys}=  Create List
    FOR  ${interface}  IN  @{interfaces}
        ${route_matches}=  Get MCTP Routes For Interface
        ...  ${route_output}
        ...  ${interface}
        ...  ${role}

        FOR  ${route_match}  IN  @{route_matches}
            ${min_eid}=  Convert To Integer  ${route_match}[0]
            ${max_eid}=  Convert To Integer  ${route_match}[1]
            ${network_id}=  Set Variable  ${route_match}[2]
            ${network_path}=  Get MCTP Network Path  ${mctp_tree}  ${network_id}
            ${control_interface}  ${local_eids}=  Get MCTP Network Details
            ...  ${mctp_dbus_service}
            ...  ${network_path}
            ${range_stop}=  Evaluate  ${max_eid} + 1
            FOR  ${eid}  IN RANGE  ${min_eid}  ${range_stop}
                ${eid_text}=  Convert To String  ${eid}
                IF  $eid_text in $local_eids
                    Log  Skipping local MCTP EID ${eid_text} on ${interface} while discovering PLDM endpoints.
                    CONTINUE
                END

                ${candidate_key}=  Set Variable  ${interface}|${network_id}|${eid_text}
                ${is_known_candidate}=  Run Keyword And Return Status
                ...  List Should Contain Value  ${candidate_keys}  ${candidate_key}
                IF  not ${is_known_candidate}
                    ${endpoint_candidate}=  Create Dictionary
                    ...  interface=${interface}
                    ...  network=${network_id}
                    ...  eid=${eid_text}
                    Append To List  ${endpoint_candidates}  ${endpoint_candidate}
                    Append To List  ${candidate_keys}  ${candidate_key}
                END
            END
        END
    END

    Should Not Be Empty  ${endpoint_candidates}
    ...  msg=No remote PLDM endpoint IDs were discovered for ${role} after filtering LocalEIDs. Output: ${route_output}
    RETURN  ${endpoint_candidates}


Verify PLDM Commands For Role Endpoints
    [Documentation]  Find a role-routed endpoint that responds to PLDM base and platform commands.
    [Arguments]  ${endpoint_candidates}  ${role}

    ${attempt_log}=  Create List
    ${pldm_command_passed}=  Set Variable  ${False}
    FOR  ${endpoint_candidate}  IN  @{endpoint_candidates}
        ${interface}=  Set Variable  ${endpoint_candidate}[interface]
        ${network_id}=  Set Variable  ${endpoint_candidate}[network]
        ${eid}=  Set Variable  ${endpoint_candidate}[eid]
        ${get_tid_output}  ${get_tid_stderr}  ${get_tid_rc}=  BMC Execute Command
        ...  pldmtool base GetTID -m ${eid}
        ...  print_err=1
        ${get_tid_valid}=  Run Keyword And Return Status
        ...  Should Match Regexp  ${get_tid_output}  (?im)"Response"\\s*:\\s*\\d+|"TID"\\s*:\\s*\\d+
        IF  ${get_tid_rc} != 0 or '''${get_tid_stderr}''' != '''${EMPTY}''' or not ${get_tid_valid}
            Append To List  ${attempt_log}
            ...  ${role} interface ${interface}, net ${network_id}, EID ${eid} GetTID failed: rc=${get_tid_rc}, stdout=${get_tid_output}, stderr=${get_tid_stderr}
            CONTINUE
        END

        ${get_pdr_output}  ${get_pdr_stderr}  ${get_pdr_rc}=  BMC Execute Command
        ...  pldmtool platform GetPDR -m ${eid} -d 0
        ...  print_err=1
        ${get_pdr_valid}=  Run Keyword And Return Status
        ...  Should Match Regexp  ${get_pdr_output}  (?im)"(recordHandle|nextRecordHandle|PDRType|responseCount)"\\s*:
        IF  ${get_pdr_rc} != 0 or '''${get_pdr_stderr}''' != '''${EMPTY}''' or not ${get_pdr_valid}
            Append To List  ${attempt_log}
            ...  ${role} interface ${interface}, net ${network_id}, EID ${eid} GetPDR failed: rc=${get_pdr_rc}, stdout=${get_pdr_output}, stderr=${get_pdr_stderr}
            CONTINUE
        END

        Log  PLDM base and platform commands succeeded through ${role} interface ${interface}, net ${network_id}, EID ${eid}.
        ${pldm_command_passed}=  Set Variable  ${True}
        BREAK
    END

    Should Be True  ${pldm_command_passed}
    ...  msg=No MCTP endpoint routed through configured ${role} interfaces responded to PLDM GetTID and GetPDR. Attempts: ${attempt_log}
