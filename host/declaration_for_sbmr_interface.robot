# Copyright (c) 2023-2026, Arm Limited or its affiliates. All rights reserved.
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

Documentation    Self declaration for SBMR interface support
Resource         ../lib/resource.robot


*** Test Cases ***

Declaration For MFSPX SMBus SSIF Support
    [Documentation]  Declaration for SMBus-compliant IPMI SSIF over I2C.
    [Tags]  MFSPX_SMBus_SSIF_Declaration
    [Template]  Verify Declaration
    ${MFSPX_SMBUS_SSIF_SUPPORT}  MFSPX  SMBus-compliant IPMI SSIF over I2C


Declaration For M1_JTAG_1 Remote Debug Support
    [Documentation]  Declaration for JTAG-based remote debug and crash dump support.
    [Tags]  M1_JTAG_1_JTAG_Remote_Debug_Declaration
    [Template]  Verify Declaration
    ${M1_JTAG_1_JTAG_REMOTE_DEBUG_SUPPORT}  M1_JTAG_1  JTAG-based remote debug and crash dump support


Declaration For M1_JTAG_2 ADI TAP Access
    [Documentation]  Declaration for Arm Debug Interface TAP controller access.
    [Tags]  M1_JTAG_2_ADI_TAP_Access_Declaration
    [Template]  Verify Declaration
    ${M1_JTAG_2_ADI_TAP_ACCESS_SUPPORT}  M1_JTAG_2  Arm Debug Interface TAP controller access


Declaration For M2_JTAG_2 JTAG Debug Capability
    [Documentation]  Declaration for SoC and BMC JTAG debug capability.
    [Tags]  M2_JTAG_2_JTAG_Debug_Capability_Declaration
    [Template]  Verify Declaration
    ${M2_JTAG_2_JTAG_DEBUG_CAPABILITY_SUPPORT}  M2_JTAG_2  SoC and BMC JTAG debug capability


Declaration For M2_IO_1 NC-SI RBT Support
    [Documentation]  Declaration for NC-SI over RBT on shared physical NIC interfaces.
    [Tags]  M2_IO_1_NCSI_RBT_Declaration
    [Template]  Verify Declaration
    ${M2_IO_1_NCSI_RBT_SUPPORT}  M2_IO_1  NC-SI over RBT on shared physical NIC interfaces


Declaration For RXNXV Redfish Platform Error Record Support
    [Documentation]  Declaration for in-band platform error reporting requirements.
    [Tags]  RXNXV_Redfish_Platform_Error_Record_Declaration
    [Template]  Verify Declaration
    ${RXNXV_REDFISH_PLATFORM_ERROR_RECORD_SUPPORT}  RXNXV  In-band platform error reporting requirements


Declaration For M2_RAS_2 Redfish Platform Error Record Support
    [Documentation]  Declaration for Redfish LogEntry platform error record support.
    [Tags]  M2_RAS_2_Redfish_Platform_Error_Record_Declaration
    [Template]  Verify Declaration
    ${M2_RAS_2_REDFISH_PLATFORM_ERROR_RECORD_SUPPORT}  M2_RAS_2  Redfish LogEntry platform error record support


Declaration For M3_SB_1 PMCI Side-Band Interface
    [Documentation]  Declaration for PMCI-based BMC-to-SatMC side-band interface.
    [Tags]  M3_SB_1_PMCI_Side_Band_Interface_Declaration
    [Template]  Verify Declaration
    ${M3_SB_1_PMCI_SIDE_BAND_INTERFACE_SUPPORT}  M3_SB_1  PMCI-based BMC-to-SatMC side-band interface


Declaration For M3_SB_2 PLDM Platform Functions
    [Documentation]  Declaration for PLDM platform-level data models and functions.
    [Tags]  M3_SB_2_PLDM_Platform_Functions_Declaration
    [Template]  Verify Declaration
    ${M3_SB_2_PLDM_PLATFORM_FUNCTIONS_SUPPORT}  M3_SB_2  PLDM platform-level data models and functions


Declaration For M3_SB_3 MCTP Transport Protocol
    [Documentation]  Declaration for MCTP as the transport protocol format.
    [Tags]  M3_SB_3_MCTP_Transport_Protocol_Declaration
    [Template]  Verify Declaration
    ${M3_SB_3_MCTP_TRANSPORT_PROTOCOL_SUPPORT}  M3_SB_3  MCTP transport protocol format


Declaration For M3_SB_4 PLDM Over MCTP Binding
    [Documentation]  Declaration for PLDM over MCTP message binding.
    [Tags]  M3_SB_4_PLDM_Over_MCTP_Binding_Declaration
    [Template]  Verify Declaration
    ${M3_SB_4_PLDM_OVER_MCTP_BINDING_SUPPORT}  M3_SB_4  PLDM over MCTP message binding


Declaration For M3_SB_5 SPDM Security Protocol
    [Documentation]  Declaration for SPDM security protocol support.
    [Tags]  M3_SB_5_SPDM_Security_Protocol_Declaration
    [Template]  Verify Declaration
    ${M3_SB_5_SPDM_SECURITY_PROTOCOL_SUPPORT}  M3_SB_5  SPDM security protocol support


Declaration For M3_SB_6 SPDM Over MCTP Binding
    [Documentation]  Declaration for SPDM over MCTP message binding.
    [Tags]  M3_SB_6_SPDM_Over_MCTP_Binding_Declaration
    [Template]  Verify Declaration
    ${M3_SB_6_SPDM_OVER_MCTP_BINDING_SUPPORT}  M3_SB_6  SPDM over MCTP message binding


Declaration For M3_SB_7 SPDM Secure Messages
    [Documentation]  Declaration for SPDM secure messages support.
    [Tags]  M3_SB_7_SPDM_Secure_Messages_Declaration
    [Template]  Verify Declaration
    ${M3_SB_7_SPDM_SECURE_MESSAGES_SUPPORT}  M3_SB_7  SPDM secure messages support


Declaration For M3_SB_8 SPDM Secure Messages MCTP Binding
    [Documentation]  Declaration for SPDM secure messages over MCTP binding.
    [Tags]  M3_SB_8_SPDM_Secure_Messages_MCTP_Binding_Declaration
    [Template]  Verify Declaration
    ${M3_SB_8_SPDM_SECURE_MESSAGES_MCTP_BINDING_SUPPORT}  M3_SB_8  SPDM secure messages over MCTP binding


Declaration For M3_SB_9 MCTP I2C Physical Binding
    [Documentation]  Declaration for MCTP over SMBus/I2C physical binding.
    [Tags]  M3_SB_9_MCTP_I2C_Physical_Binding_Declaration
    [Template]  Verify Declaration
    ${M3_SB_9_MCTP_I2C_PHYSICAL_BINDING_SUPPORT}  M3_SB_9  MCTP over SMBus/I2C physical binding


Declaration For M3_JTAG_2 Production Disable Support
    [Documentation]  Declaration for production JTAG disable and access control methods.
    [Tags]  M3_JTAG_2_Production_JTAG_Disable_Declaration
    [Template]  Verify Declaration
    ${M3_JTAG_2_PRODUCTION_JTAG_DISABLE_SUPPORT}  M3_JTAG_2  Production JTAG disable and access control methods


Declaration For M3_IO_1 NC-SI RBT Or MCTP Support
    [Documentation]  Declaration for NC-SI over RBT or MCTP on shared NIC interfaces.
    [Tags]  M3_IO_1_NCSI_RBT_Or_MCTP_Declaration
    [Template]  Verify Declaration
    ${M3_IO_1_NCSI_RBT_OR_MCTP_SUPPORT}  M3_IO_1  NC-SI over RBT or MCTP on shared NIC interfaces


Declaration For M3_IO_2 MCTP IO Physical Binding
    [Documentation]  Declaration for MCTP physical binding for IO device management.
    [Tags]  M3_IO_2_MCTP_IO_Physical_Binding_Declaration
    [Template]  Verify Declaration
    ${M3_IO_2_MCTP_IO_PHYSICAL_BINDING_SUPPORT}  M3_IO_2  MCTP physical binding for IO device management


Declaration For M3_OOB_1 IPMI OOB Optional Support
    [Documentation]  Declaration for optional IPMI out-of-band support at Level M3.
    [Tags]  M3_OOB_1_IPMI_OOB_Optional_Declaration
    [Template]  Verify Declaration
    ${M3_OOB_1_IPMI_OOB_OPTIONAL_SUPPORT}  M3_OOB_1  Optional IPMI out-of-band support at Level M3


Declaration For M3_SPDM_1 SPDM Protocol Support
    [Documentation]  Declaration for DMTF SPDM protocol conformance.
    [Tags]  M3_SPDM_1_SPDM_Protocol_Declaration
    [Template]  Verify Declaration
    ${M3_SPDM_1_SPDM_PROTOCOL_SUPPORT}  M3_SPDM_1  DMTF SPDM protocol conformance


Declaration For M3_SPDM_2 SPDM MCTP Binding Support
    [Documentation]  Declaration for SPDM over MCTP binding conformance.
    [Tags]  M3_SPDM_2_SPDM_MCTP_Binding_Declaration
    [Template]  Verify Declaration
    ${M3_SPDM_2_SPDM_MCTP_BINDING_SUPPORT}  M3_SPDM_2  SPDM over MCTP binding conformance


Declaration For M4_SB_1 MCTP I3C Physical Binding
    [Documentation]  Declaration for MCTP over I3C physical binding.
    [Tags]  M4_SB_1_MCTP_I3C_Physical_Binding_Declaration
    [Template]  Verify Declaration
    ${M4_SB_1_MCTP_I3C_PHYSICAL_BINDING_SUPPORT}  M4_SB_1  MCTP over I3C physical binding


Declaration For M4_IO_1 PCIe Device MCTP PLDM Management
    [Documentation]  Declaration for PCIe device management using MCTP/PLDM.
    [Tags]  M4_IO_1_PCIe_Device_MCTP_PLDM_Management_Declaration
    [Template]  Verify Declaration
    ${M4_IO_1_PCIE_DEVICE_MCTP_PLDM_MANAGEMENT_SUPPORT}  M4_IO_1  PCIe device management using MCTP/PLDM


Declaration For M4_IO_2 NVMe MI Over MCTP
    [Documentation]  Declaration for NVMe-MI management over MCTP.
    [Tags]  M4_IO_2_NVMe_MI_Over_MCTP_Declaration
    [Template]  Verify Declaration
    ${M4_IO_2_NVME_MI_OVER_MCTP_SUPPORT}  M4_IO_2  NVMe-MI management over MCTP


Declaration For M4_IO_3 MCTP I3C PCIe VDM Binding
    [Documentation]  Declaration for MCTP over I3C or PCIe VDM binding.
    [Tags]  M4_IO_3_MCTP_I3C_PCIE_VDM_Binding_Declaration
    [Template]  Verify Declaration
    ${M4_IO_3_MCTP_I3C_PCIE_VDM_BINDING_SUPPORT}  M4_IO_3  MCTP over I3C or PCIe VDM binding


Declaration For M5_IB_1 MMBI Interface Support
    [Documentation]  Declaration for DMTF MMBI interface conformance.
    [Tags]  M5_IB_1_MMBI_Interface_Declaration
    [Template]  Verify Declaration
    ${M5_IB_1_MMBI_INTERFACE_SUPPORT}  M5_IB_1  DMTF MMBI interface conformance


Declaration For M5_IB_2 MCTP Host Interface Discovery
    [Documentation]  Declaration for MCTP Host Interface discovery support.
    [Tags]  M5_IB_2_MCTP_Host_Interface_Discovery_Declaration
    [Template]  Verify Declaration
    ${M5_IB_2_MCTP_HOST_INTERFACE_DISCOVERY_SUPPORT}  M5_IB_2  MCTP Host Interface discovery support


Declaration For M5_SB_1 MCTP High Bandwidth Binding
    [Documentation]  Declaration for MCTP over USB, I3C, or PCIe VDM side-band binding.
    [Tags]  M5_SB_1_MCTP_High_Bandwidth_Binding_Declaration
    [Template]  Verify Declaration
    ${M5_SB_1_MCTP_HIGH_BANDWIDTH_BINDING_SUPPORT}  M5_SB_1  MCTP over USB, I3C, or PCIe VDM side-band binding


Declaration For M5_IO_1 MCTP IO High Bandwidth Binding
    [Documentation]  Declaration for MCTP over USB, I3C, or PCIe VDM IO binding.
    [Tags]  M5_IO_1_MCTP_IO_High_Bandwidth_Binding_Declaration
    [Template]  Verify Declaration
    ${M5_IO_1_MCTP_IO_HIGH_BANDWIDTH_BINDING_SUPPORT}  M5_IO_1  MCTP over USB, I3C, or PCIe VDM IO binding


Declaration For M5_HS_1 MCTP Over PCC Mailbox
    [Documentation]  Declaration for MCTP over PCC mailbox Host-to-SatMC support.
    [Tags]  M5_HS_1_MCTP_Over_PCC_Mailbox_Declaration
    [Template]  Verify Declaration
    ${M5_HS_1_MCTP_OVER_PCC_MAILBOX_SUPPORT}  M5_HS_1  MCTP over PCC mailbox Host-to-SatMC support


Declaration For M5_HS_2 MCTP Host Interface Discovery
    [Documentation]  Declaration for Host-to-SatMC MCTP Host Interface discovery.
    [Tags]  M5_HS_2_MCTP_Host_Interface_Discovery_Declaration
    [Template]  Verify Declaration
    ${M5_HS_2_MCTP_HOST_INTERFACE_DISCOVERY_SUPPORT}  M5_HS_2  Host-to-SatMC MCTP Host Interface discovery


*** Keywords ***
Verify Declaration
    [Arguments]  ${declaration_var}  ${rule_id}  ${requirement}
    Run Keyword If  '${declaration_var}' == '${1}'
    ...    Log  Declaration passed: ${rule_id} ${requirement} is declared as supported.
    ...  ELSE
    ...    Fail  Declaration failed: ${rule_id} ${requirement} is not declared as supported.
