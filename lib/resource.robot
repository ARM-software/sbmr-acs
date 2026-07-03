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
Library           redfish_instance_discovery.py
Library           Collections
Library           String
Library           RequestsLibrary
Library           OperatingSystem
Variables         ../data/variables.py

*** Variables ***

# By default Delete all Redfish session per boot run.
${REDFISH_DELETE_SESSIONS}        ${1}

${BMC_MODEL}  ${EMPTY}
${BMC_HOST}   ${EMPTY}
${PORT}           ${EMPTY}
# AUTH_SUFFIX here is derived from variables.py
${AUTH_URI}       https://${BMC_HOST}${AUTH_SUFFIX}
${BMC_USERNAME}    root
${BMC_PASSWORD}    0penBmc
${BMC_ADMIN_PASSWORD}  0penBmc
${SERVICE_USER_PASSWORD}   0penBmc

# For users privilege admin or sudo.
${USER_TYPE}          ${EMPTY}

${BMC_ID}       ${EMPTY}
${SYSTEM_ID}    ${EMPTY}
${CHASSIS_ID}   ${EMPTY}

# MTLS_ENABLED indicates whether mTLS is enabled.
${MTLS_ENABLED}        False
# Valid mTLS certificate for authentication.
${VALID_CERT}          ${EMPTY}
# Path of mTLS certificates directory.
${CERT_DIR_PATH}       ${EMPTY}

${IPMI_USERNAME}       ${BMC_USERNAME}
${IPMI_PASSWORD}       ${BMC_PASSWORD}
${MACHINE_TYPE}    none
${BMC_REBOOT_TIMEOUT}   ${10}
# IPMI_COMMAND here is set to "External" by default. User
# can override to "Dbus" from command line.
${IPMI_COMMAND}    External
# IPMI chipher default.
${IPMI_CIPHER_LEVEL}  ${17}
# IPMI timeout default.
${IPMI_TIMEOUT}       ${3}
# IPMI delay time default.
${IPMI_DELAY}         ${1}
# IPMI OPTIONS EFIBOOT
${IPMI_OPTIONS_EFIBOOT}       ${EMPTY}

# Log default path for IPMI SOL.
${IPMI_SOL_LOG_FILE}    ${OUTPUT_DIR}${/}sol_${BMC_HOST}

# IPMI SOL console output types/parameters to verify.
${SOL_BIOS_OUTPUT}          ${EMPTY}
${SOL_LOGIN_OUTPUT}         ${EMPTY}
${SOL_LOGIN_TIMEOUT}         10 mins

# SSH SOL console output types/parameters
${SOL_TYPE}         ipmi
${SOL_SSH_PORT}     22
${SOL_SSH_CMD}      None

# Virtual Media related parameters
${VM_USER}                   ${EMPTY}
${VM_PASSWD}                 ${EMPTY}
${VM_TRANSFER_PROTO_TYPE}    ${EMPTY}
${VM_TRANSFER_METHOD}        ${EMPTY}
${VM_WRITE_PROT}             ${EMPTY}

# PDU related parameters
${PDU_TYPE}         ${EMPTY}
${PDU_IP}           ${EMPTY}
${PDU_USERNAME}     ${EMPTY}
${PDU_PASSWORD}     ${EMPTY}
${PDU_SLOT_NO}      ${EMPTY}

# User define input SSH and HTTPS related parameters
${SSH_PORT}         22
${HTTPS_PORT}       443
${IPMI_PORT}        623
${HOST_SOL_PORT}    2200
${BMC_SERIAL_HOST}      ${EMPTY}
${BMC_SERIAL_PORT}      ${EMPTY}
${BMC_CONSOLE_CLIENT}   ${EMPTY}

# OS related parameters.
${OS_HOST}          ${EMPTY}
${OS_USERNAME}      ${EMPTY}
${OS_PASSWORD}      ${EMPTY}
${OS_WAIT_TIMEOUT}  ${15*60}

# Networking related parameters
${NETWORK_PORT}            80
${PACKET_TYPE}             tcp
${ICMP_PACKETS}            icmp
${NETWORK_RETRY_TIME}      6
${NETWORK_TIMEOUT}         18
${ICMP_TIMESTAMP_REQUEST}  13
${ICMP_ECHO_REQUEST}       8
${CHANNEL_NUMBER}          1
${TCP_PACKETS}             tcp
${TCP_CONNECT}             tcp-connect
${ICMP_NETMASK_REQUEST}    17
${REDFISH_INTERFACE}       443
${SYN_PACKETS}             SYN
${RESET_PACKETS}           RST
${FIN_PACKETS}             FIN
${SYN_ACK_RESET}           SAR
${ALL_FLAGS}               ALL
# Used to set BMC static IPv4 configuration.
${STATIC_IP}            10.10.10.10
${NETMASK}              255.255.255.0
${GATEWAY}              10.10.10.10

# LDAP related variables.
${LDAP_BASE_DN}             ${EMPTY}
${LDAP_BIND_DN}             ${EMPTY}
${LDAP_SERVER_HOST}         ${EMPTY}
${LDAP_SECURE_MODE}         ${EMPTY}
${LDAP_BIND_DN_PASSWORD}    ${EMPTY}
${LDAP_SEARCH_SCOPE}        ${EMPTY}
${LDAP_TYPE}                ${EMPTY}
${LDAP_USER}                ${EMPTY}
${LDAP_USER_PASSWORD}       ${EMPTY}
${GROUP_PRIVILEGE}          ${EMPTY}
${GROUP_NAME}               ${EMPTY}
${LDAP_SERVER_URI}          ldap://${LDAP_SERVER_HOST}

# MCTP interface role mapping
${MCTP_SB_INTERFACES}       ${EMPTY}
${MCTP_IO_INTERFACES}       ${EMPTY}

# Self Declaration
${MFSPX_SMBUS_SSIF_SUPPORT}                              0
${RXNXV_REDFISH_PLATFORM_ERROR_RECORD_SUPPORT}           0
${M1_JTAG_1_JTAG_REMOTE_DEBUG_SUPPORT}                   0
${M1_JTAG_2_ADI_TAP_ACCESS_SUPPORT}                      0
${M2_JTAG_2_JTAG_DEBUG_CAPABILITY_SUPPORT}               0
${M2_IO_1_NCSI_RBT_SUPPORT}                              0
${M2_RAS_2_REDFISH_PLATFORM_ERROR_RECORD_SUPPORT}        0
${M3_SB_1_PMCI_SIDE_BAND_INTERFACE_SUPPORT}              0
${M3_SB_2_PLDM_PLATFORM_FUNCTIONS_SUPPORT}               0
${M3_SB_3_MCTP_TRANSPORT_PROTOCOL_SUPPORT}               0
${M3_SB_4_PLDM_OVER_MCTP_BINDING_SUPPORT}                0
${M3_SB_5_SPDM_SECURITY_PROTOCOL_SUPPORT}                0
${M3_SB_6_SPDM_OVER_MCTP_BINDING_SUPPORT}                0
${M3_SB_7_SPDM_SECURE_MESSAGES_SUPPORT}                  0
${M3_SB_8_SPDM_SECURE_MESSAGES_MCTP_BINDING_SUPPORT}     0
${M3_SB_9_MCTP_I2C_PHYSICAL_BINDING_SUPPORT}             0
${M3_JTAG_2_PRODUCTION_JTAG_DISABLE_SUPPORT}             0
${M3_IO_1_NCSI_RBT_OR_MCTP_SUPPORT}                      0
${M3_IO_2_MCTP_IO_PHYSICAL_BINDING_SUPPORT}              0
${M3_OOB_1_IPMI_OOB_OPTIONAL_SUPPORT}                    0
${M3_SPDM_1_SPDM_PROTOCOL_SUPPORT}                       0
${M3_SPDM_2_SPDM_MCTP_BINDING_SUPPORT}                   0
${M4_SB_1_MCTP_I3C_PHYSICAL_BINDING_SUPPORT}             0
${M4_IO_1_PCIE_DEVICE_MCTP_PLDM_MANAGEMENT_SUPPORT}      0
${M4_IO_2_NVME_MI_OVER_MCTP_SUPPORT}                     0
${M4_IO_3_MCTP_I3C_PCIE_VDM_BINDING_SUPPORT}             0
${M5_IB_1_MMBI_INTERFACE_SUPPORT}                        0
${M5_IB_2_MCTP_HOST_INTERFACE_DISCOVERY_SUPPORT}         0
${M5_SB_1_MCTP_HIGH_BANDWIDTH_BINDING_SUPPORT}           0
${M5_IO_1_MCTP_IO_HIGH_BANDWIDTH_BINDING_SUPPORT}        0
${M5_HS_1_MCTP_OVER_PCC_MAILBOX_SUPPORT}                 0
${M5_HS_2_MCTP_HOST_INTERFACE_DISCOVERY_SUPPORT}         0
${M5_OOB_1_EXPOSE_BIOS_SETTINGS_SUPPORT}                 0

*** Keywords ***
Get Inventory Schema
    [Documentation]  Get inventory schema.
    [Arguments]    ${machine}
    RETURN    &{INVENTORY}[${machine}]

Get Inventory Items Schema
    [Documentation]  Get inventory items schema.
    [Arguments]    ${machine}
    RETURN    &{INVENTORY_ITEMS}[${machine}]

Get Sensor Schema
    [Documentation]  Get sensors schema.
    [Arguments]    ${machine}
    RETURN    &{SENSORS}[${machine}]
