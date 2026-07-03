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
Documentation    MCTP side-band interface tests.
Library          ../lib/bmc_ssh_utils.py
Resource         ../lib/mctp_utils.robot


*** Variables ***
${M3_SB_3_MCTP_TRANSPORT_PROTOCOL_SUPPORT}               0
${M3_SB_9_MCTP_I2C_PHYSICAL_BINDING_SUPPORT}             0
${M4_SB_1_MCTP_I3C_PHYSICAL_BINDING_SUPPORT}             0
${M3_IO_2_MCTP_IO_PHYSICAL_BINDING_SUPPORT}              0
${M4_IO_1_PCIE_DEVICE_MCTP_PLDM_MANAGEMENT_SUPPORT}      0
${M4_IO_3_MCTP_I3C_PCIE_VDM_BINDING_SUPPORT}             0


*** Test Cases ***
Test MCTP Side Band Physical Binding
    [Documentation]  Verify configured SIDE-BAND MCTP interfaces use accepted physical bindings.
    [Tags]  M3_SB_9_MCTP_Physical_Binding

    # MCTP_Test_Case_001: SIDE-BAND physical binding check.
    Run Automated Check Or Declaration
    ...  ${M3_SB_9_MCTP_I2C_PHYSICAL_BINDING_SUPPORT}
    ...  M3_SB_9_MCTP_Physical_Binding
    ...  Verify MCTP Physical Binding
    ...  ${MCTP_SB_INTERFACES}
    ...  SIDE-BAND


Test MCTP BMC IO Physical Binding
    [Documentation]  Verify configured BMC-IO MCTP interfaces use accepted physical bindings.
    [Tags]  M3_IO_2_MCTP_Physical_Binding

    # MCTP_Test_Case_001: BMC-IO physical binding check.
    Run Automated Check Or Declaration
    ...  ${M3_IO_2_MCTP_IO_PHYSICAL_BINDING_SUPPORT}
    ...  M3_IO_2_MCTP_Physical_Binding
    ...  Verify MCTP Physical Binding
    ...  ${MCTP_IO_INTERFACES}
    ...  BMC-IO


Test MCTP Side Band Transport Protocol
    [Documentation]  Verify MCTP transport through the configured SIDE-BAND interfaces.
    [Tags]  M3_SB_3_MCTP_Transport_Protocol

    # MCTP_Test_Case_002: SIDE-BAND transport check.
    Run Automated Check Or Declaration
    ...  ${M3_SB_3_MCTP_TRANSPORT_PROTOCOL_SUPPORT}
    ...  M3_SB_3_MCTP_Transport_Protocol
    ...  Verify MCTP Transport Protocol
    ...  ${MCTP_SB_INTERFACES}
    ...  SIDE-BAND


Test MCTP BMC IO Transport Protocol
    [Documentation]  Verify MCTP transport through the configured BMC-IO interfaces.
    [Tags]  M4_IO_1_MCTP_Transport_Protocol

    # MCTP_Test_Case_002: BMC-IO transport check.
    Run Automated Check Or Declaration
    ...  ${M4_IO_1_PCIE_DEVICE_MCTP_PLDM_MANAGEMENT_SUPPORT}
    ...  M4_IO_1_MCTP_Transport_Protocol
    ...  Verify MCTP Transport Protocol
    ...  ${MCTP_IO_INTERFACES}
    ...  BMC-IO


Test MCTP Side Band I3C PCIe VDM Binding
    [Documentation]  Verify configured SIDE-BAND interfaces use I3C or PCIe VDM binding.
    [Tags]  M4_SB_1_MCTP_I3C_PCIE_VDM_Binding

    # MCTP_Test_Case_003: SIDE-BAND preferred binding check.
    Run Automated Check Or Declaration
    ...  ${M4_SB_1_MCTP_I3C_PHYSICAL_BINDING_SUPPORT}
    ...  M4_SB_1_MCTP_I3C_PCIE_VDM_Binding
    ...  Verify MCTP I3C PCIe VDM Binding
    ...  ${MCTP_SB_INTERFACES}
    ...  SIDE-BAND


Test MCTP BMC IO I3C PCIe VDM Binding
    [Documentation]  Verify configured BMC-IO interfaces use I3C or PCIe VDM binding.
    [Tags]  M4_IO_3_MCTP_I3C_PCIE_VDM_Binding

    # MCTP_Test_Case_003: BMC-IO preferred binding check.
    Run Automated Check Or Declaration
    ...  ${M4_IO_3_MCTP_I3C_PCIE_VDM_BINDING_SUPPORT}
    ...  M4_IO_3_MCTP_I3C_PCIE_VDM_Binding
    ...  Verify MCTP I3C PCIe VDM Binding
    ...  ${MCTP_IO_INTERFACES}
    ...  BMC-IO


*** Keywords ***
Run Automated Check Or Declaration
    [Documentation]  Run an MCTP automated check, or pass by matching manual declaration.
    [Arguments]  ${declaration_var}  ${rule_tag}  ${verification_keyword}  @{verification_args}

    # Manual validation may be declared through the matching rule-specific support flag.
    IF  '${declaration_var}' == '1'
        Log  MCTP automation is bypassed by declaration for ${rule_tag}.
        RETURN
    END

    Run Keyword  ${verification_keyword}  @{verification_args}


Verify MCTP Physical Binding
    [Documentation]  Verify every configured role interface has an accepted binding in up state.
    [Arguments]  ${interface_csv}  ${role}

    ${interfaces}=  Get Configured MCTP Interfaces  ${interface_csv}  ${role}
    ${link_output}=  Get MCTP Link Output

    FOR  ${interface}  IN  @{interfaces}
        Should Match Regexp  ${interface}  (?i)^mctp(i2c|i3c|pcie|vdm)
        ...  msg=Configured ${role} interface '${interface}' does not identify an accepted MCTP binding.
        Verify MCTP Interface Is Up  ${interface}  ${role}  ${link_output}
    END


Verify MCTP I3C PCIe VDM Binding
    [Documentation]  Verify every configured role interface uses an up I3C or PCIe VDM binding.
    [Arguments]  ${interface_csv}  ${role}

    ${interfaces}=  Get Configured MCTP Interfaces  ${interface_csv}  ${role}
    ${link_output}=  Get MCTP Link Output

    FOR  ${interface}  IN  @{interfaces}
        Should Match Regexp  ${interface}  (?i)^mctp(i3c|pcie|vdm)
        ...  msg=Configured ${role} interface '${interface}' is not an I3C or PCIe VDM MCTP binding.
        Verify MCTP Interface Is Up  ${interface}  ${role}  ${link_output}
    END


Verify MCTP Transport Protocol
    [Documentation]  Verify MCTP services, role interfaces, routes, and endpoint control messaging.
    [Arguments]  ${interface_csv}  ${role}

    ${interfaces}=  Get Configured MCTP Interfaces  ${interface_csv}  ${role}

    # Step 1: MCTP must be implemented as a distinct service component.
    ${service_list}  ${stderr}  ${rc}=  BMC Execute Command
    ...  systemctl list-units --type=service --no-pager | grep -i mctp
    ...  print_err=1
    Should Be Equal As Integers  0  ${rc}
    ...  msg=MCTP service discovery failed. stdout=${service_list} stderr=${stderr}
    Should Be Empty  ${stderr}  msg=${service_list}
    Should Not Be Empty  ${service_list}  msg=No MCTP-related services were listed.
    Should Match Regexp  ${service_list}  (?im)mctp.*\\.service
    ...  msg=MCTP service list did not contain an MCTP service. Output: ${service_list}

    # Step 2: the transport daemon must be active.
    ${service_status}  ${stderr}  ${rc}=  BMC Execute Command
    ...  systemctl status mctpd.service --no-pager
    ...  print_err=1
    Should Be Equal As Integers  0  ${rc}
    ...  msg=mctpd.service status command failed. stdout=${service_status} stderr=${stderr}
    Should Be Empty  ${stderr}  msg=${service_status}
    Should Match Regexp  ${service_status}  (?m)Active:\\s+active\\s+\\(running\\)
    ...  msg=mctpd.service is not active and running. Output: ${service_status}

    # Step 3: discover the MCTP D-Bus service and verify the role-specific interface objects.
    ${mctp_dbus_service}  ${mctp_tree}=  Discover MCTP D-Bus Service
    Verify Configured MCTP D-Bus Interfaces  ${interfaces}  ${role}  ${mctp_tree}

    # Step 4: verify every configured interface is operational.
    ${link_output}=  Get MCTP Link Output
    FOR  ${interface}  IN  @{interfaces}
        Verify MCTP Interface Is Up  ${interface}  ${role}  ${link_output}
    END

    # Step 5: map routes to the configured interfaces and test their remote endpoints.
    ${route_output}=  Get MCTP Route Output
    Learn MCTP Endpoints For Interfaces
    ...  ${mctp_dbus_service}
    ...  ${mctp_tree}
    ...  ${route_output}
    ...  ${interfaces}
    ...  ${role}


Get MCTP Link Output
    [Documentation]  Run mctp link and return validated output.

    ${link_output}  ${stderr}  ${rc}=  BMC Execute Command  mctp link  print_err=1
    Should Be Equal As Integers  0  ${rc}
    ...  msg=mctp link failed. stdout=${link_output} stderr=${stderr}
    Should Be Empty  ${stderr}  msg=${link_output}
    Should Not Be Empty  ${link_output}  msg=mctp link did not return any links.
    RETURN  ${link_output}


Verify MCTP Interface Is Up
    [Documentation]  Verify one exact MCTP interface is listed in up state.
    [Arguments]  ${interface}  ${role}  ${link_output}

    ${interface_regex}=  Evaluate  re.escape(r'''${interface}''')  modules=re
    Should Match Regexp  ${link_output}  (?m)^dev\\s+${interface_regex}\\s+[^\\n]*\\s+up$
    ...  msg=Configured ${role} MCTP interface '${interface}' was not listed in up state. Output: ${link_output}


Verify Configured MCTP D-Bus Interfaces
    [Documentation]  Verify every configured role interface exists in the MCTP D-Bus tree.
    [Arguments]  ${interfaces}  ${role}  ${mctp_tree}

    FOR  ${interface}  IN  @{interfaces}
        ${interface_path_regex}=  Evaluate  re.escape('/interfaces/' + r'''${interface}''')  modules=re
        Should Match Regexp  ${mctp_tree}  (?m)${interface_path_regex}(?:\\s|$)
        ...  msg=Configured ${role} MCTP interface '${interface}' was not present in the MCTP D-Bus tree. Output: ${mctp_tree}
    END


Learn MCTP Endpoints For Interfaces
    [Documentation]  Learn remote endpoints routed through every configured role interface.
    [Arguments]  ${mctp_dbus_service}  ${mctp_tree}  ${route_output}  ${interfaces}  ${role}

    FOR  ${interface}  IN  @{interfaces}
        ${route_matches}=  Get MCTP Routes For Interface
        ...  ${route_output}
        ...  ${interface}
        ...  ${role}

        ${remote_endpoint_count}=  Set Variable  0
        FOR  ${route_match}  IN  @{route_matches}
            ${min_eid}=  Convert To Integer  ${route_match}[0]
            ${max_eid}=  Convert To Integer  ${route_match}[1]
            ${network_id}=  Set Variable  ${route_match}[2]
            ${network_path}=  Get MCTP Network Path  ${mctp_tree}  ${network_id}
            ${learn_endpoint_interface}  ${local_eids}=  Get MCTP Network Details
            ...  ${mctp_dbus_service}
            ...  ${network_path}
            ${range_stop}=  Evaluate  ${max_eid} + 1

            FOR  ${eid}  IN RANGE  ${min_eid}  ${range_stop}
                ${eid}=  Convert To String  ${eid}
                IF  $eid in $local_eids
                    Log  Skipping local MCTP EID ${eid} on ${interface}.
                    CONTINUE
                END

                ${remote_endpoint_count}=  Evaluate  ${remote_endpoint_count} + 1
                ${learn_output}  ${stderr}  ${rc}=  BMC Execute Command
                ...  busctl call ${mctp_dbus_service} ${network_path} ${learn_endpoint_interface} LearnEndpoint y ${eid}
                ...  print_err=1
                Should Be Equal As Integers  0  ${rc}
                ...  msg=LearnEndpoint failed for ${role} interface ${interface}, network ${network_path}, EID ${eid}. stdout=${learn_output} stderr=${stderr}
                Should Be Empty  ${stderr}  msg=${learn_output}
                ${expected_learn_regex}=  Set Variable  ^sb\\s+"${network_path}/endpoints/${eid}"\\s+(true|false)$
                Should Match Regexp  ${learn_output}  ${expected_learn_regex}
                ...  msg=LearnEndpoint returned unexpected output for ${role} interface ${interface}, EID ${eid}. Expected regex: ${expected_learn_regex}. Output: ${learn_output}
            END
        END

        Should Not Be Equal As Integers  ${remote_endpoint_count}  0
        ...  msg=No remote MCTP endpoint IDs were found for configured ${role} interface '${interface}' after filtering LocalEIDs. Routes: ${route_output}
    END
