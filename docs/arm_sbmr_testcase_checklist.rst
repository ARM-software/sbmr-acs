############################
SBMR ACS Testcase checklist
############################

This document provides a checklist of SBMR rule IDs with the specification
version where each rule was introduced, indicating if the SBMR test suite covers
these rules and includes tags to the actual tests.

The checklist indicates whether each test is executed via automation or requires
manual testing.

- IB (In-Band) tests run on a Linux distribution on the system under test or as
  part of the SystemReady-band ACS image.
- OOB (Out-of-Band) tests run from an external Linux host machine using the
  SBMR-ACS OOB test list.
- Self Declaration: SBMR-ACS cannot verify some SBMR-defined interfaces. Vendors
  must declare support for those SBMR-compliant interfaces by updating the
  corresponding self-declaration variables in the ``config`` file.
- Manual fallback links identify the manual validation guide to use when an
  automated test is not applicable, blocked by platform topology, or fails due
  to implementation-specific service or object-model differences. After manual
  validation, declare compliance using the listed declaration tag.
- MCTP automation requires role-exclusive, comma-separated interface names in
  ``MCTP_SB_INTERFACES`` and ``MCTP_IO_INTERFACES`` in the ``config`` file.

SBMR checklist
==============

+--------------------------+--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
| Category                 | Rule ID      | Specification version first introduced | Covered by ACS? | Execution Type     | Test Tag(s)                                                                        |
+==========================+==============+========================================+=================+====================+====================================================================================+
| In-Band                  | M1_IB_1      | Level M1                               | Yes             | IB                 | - M1_IB_1_IPMI_SSIF_Functionality                                                  |
|                          |              |                                        |                 |                    |                                                                                    |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | MFSPX        | Level M1                               | No              | Self Declaration   | - MFSPX_SMBus_SSIF_Declaration*                                                    |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | M2_IB_1      | Level M2                               | Yes             | IB, OOB            | - M2_IB_1_Redfish_HI_Functionality                                                 |
|                          |              |                                        |                 |                    | - M2_IB_1_Redfish_HI_Type                                                          |
|                          |              |                                        |                 |                    | - M2_IB_1_Redfish_HI_Service_Root                                                  |
|                          |              |                                        |                 |                    | - M2_IB_1_Redfish_Host_Interface_Capability                                        |
|                          |              |                                        |                 |                    |                                                                                    |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | M2_IB_2      | Level M2                               | Yes             | IB                 | - M2_IB_2_IPMI_SSIF_Functionality                                                  |
|                          |              |                                        |                 |                    |                                                                                    |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | RXNXV        | Level M2.1                             | Partial         | IB,                | - RXNXV_Send_Platform_Error_Record_Command                                         |
|                          |              |                                        |                 | Self Declaration   | - RXNXV_Redfish_Platform_Error_Record_Declaration* (conditional)                   |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | M21_IB_1     | Level M2.1                             | Yes             | IB                 | - M21_IB_1_IPMI_SSIF_Capability                                                    |
|                          |              |                                        |                 |                    |                                                                                    |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | M21_IPMI1    | Level M2.1                             | Yes             | IB, OOB            | - M21_IPMI1_Power_Control                                                          |
|                          |              |                                        |                 |                    | - M21_IPMI1_Boot_Device                                                            |
|                          |              |                                        |                 |                    | - M21_IPMI1_IB_Get_Manager_Info                                                    |
|                          |              |                                        |                 |                    | - M21_IPMI1_IB_Add_User_Account                                                    |
|                          |              |                                        |                 |                    | - M21_IPMI1_IPMI_8_Redfish_Host_Certificate_Fingerprint (conditional)              |
|                          |              |                                        |                 |                    | - M21_IPMI1_IPMI_8_Redfish_Host_Get_Account_Credential (conditional)               |
|                          |              |                                        |                 |                    |                                                                                    |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | M21_IPMI2    | Level M2.1                             | Yes             | IB                 | - M21_IPMI2_Send_Platform_Error_Record_Command (conditional)                       |
|                          |              |                                        |                 |                    | - M21_IPMI2_Send_Boot_Progress_Code_Command (conditional)                          |
|                          |              |                                        |                 |                    | - M21_IPMI2_Get_Boot_Progress_Code (conditional)                                   |
|                          |              |                                        |                 |                    | - M21_IPMI2_Send_Boot_Progress_Code_2_Command (conditional)                        |
|                          |              |                                        |                 |                    | - M21_IPMI2_Get_Boot_Progress_2_Code (conditional)                                 |
|                          |              |                                        |                 |                    |                                                                                    |
+--------------------------+--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
| UART                     | M1_UART_1    | Level M1                               | Yes             | OOB                | - M1_UART_1_Redfish_Serial_Console_Capability                                      |
|                          |              |                                        |                 |                    |                                                                                    |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | M1_UART_2    | Level M1                               | Yes             | OOB                | - M1_UART_2_IPMI_SOL                                                               |
|                          |              |                                        |                 |                    |                                                                                    |
+--------------------------+--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
| PCIe                     | M21_PCI_1    | Level M2.1                             | Yes             | IB, OOB            | - M21_PCI_1_Interface_Availability (conditional)                                   |
|                          |              |                                        |                 |                    | - M21_PCI_1_Redfish_Graphical_Console_Capability (conditional)                     |
|                          |              |                                        |                 |                    |                                                                                    |
+--------------------------+--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
| USB                      | M21_USB_1    | Level M2.1                             | Yes             | OOB                | - M21_USB_1_Redfish_Virtual_Media_Action_Uri (conditional)                         |
|                          |              |                                        |                 |                    |                                                                                    |
+--------------------------+--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
| JTAG                     | M1_JTAG_1    | Level M1                               | No              | Self Declaration   | - M1_JTAG_1_JTAG_Remote_Debug_Declaration* (conditional)                           |
|                          |              |                                        |                 |                    |                                                                                    |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | M1_JTAG_2    | Level M1                               | No              | Self Declaration   | - M1_JTAG_2_ADI_TAP_Access_Declaration* (conditional)                              |
|                          |              |                                        |                 |                    |                                                                                    |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | M2_JTAG_2    | Level M2                               | No              | Self Declaration   | - M2_JTAG_2_JTAG_Debug_Capability_Declaration* (conditional)                       |
|                          |              |                                        |                 |                    |                                                                                    |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | M3_JTAG_2    | Level M3                               | No              | Self Declaration   | - M3_JTAG_2_Production_JTAG_Disable_Declaration* (conditional)                     |
|                          |              |                                        |                 |                    |                                                                                    |
+--------------------------+--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
| Side-Band                | M3_SB_1      | Level M3                               | No              | Self Declaration   | - M3_SB_1_PMCI_Side_Band_Interface_Declaration*                                    |
|                          |              |                                        |                 |                    |                                                                                    |
|                          |              |                                        |                 |                    | Manual test: `Side_Band_Test_Case_001`_                                            |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | M3_SB_2      | Level M3                               | No              | Self Declaration   | - M3_SB_2_PLDM_Platform_Functions_Declaration*                                     |
|                          |              |                                        |                 |                    |                                                                                    |
|                          |              |                                        |                 |                    | Manual test: `PLDM_Test_Case_001`_                                                 |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | M3_SB_3      | Level M3                               | No              | SSH,               | - M3_SB_3_MCTP_Transport_Protocol                                                  |
|                          |              |                                        |                 | Self Declaration   |                                                                                    |
|                          |              |                                        |                 |                    |                                                                                    |
|                          |              |                                        |                 |                    | Manual fallback: `MCTP_Test_Case_002`_; declare by setting                         |
|                          |              |                                        |                 |                    | `M3_SB_3_MCTP_TRANSPORT_PROTOCOL_SUPPORT` in `config`_                             |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | M3_SB_4      | Level M3                               | No              | Self Declaration   | - M3_SB_4_PLDM_Over_MCTP_Binding_Declaration*                                      |
|                          |              |                                        |                 |                    |                                                                                    |
|                          |              |                                        |                 |                    | Manual test: `PLDM_Test_Case_002`_                                                 |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | M3_SB_5      | Level M3                               | No              | Self Declaration   | - M3_SB_5_SPDM_Security_Protocol_Declaration*                                      |
|                          |              |                                        |                 |                    |                                                                                    |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | M3_SB_6      | Level M3                               | No              | Self Declaration   | - M3_SB_6_SPDM_Over_MCTP_Binding_Declaration*                                      |
|                          |              |                                        |                 |                    |                                                                                    |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | M3_SB_7      | Level M3                               | No              | Self Declaration   | - M3_SB_7_SPDM_Secure_Messages_Declaration*                                        |
|                          |              |                                        |                 |                    |                                                                                    |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | M3_SB_8      | Level M3                               | No              | Self Declaration   | - M3_SB_8_SPDM_Secure_Messages_MCTP_Binding_Declaration*                           |
|                          |              |                                        |                 |                    |                                                                                    |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | M3_SB_9      | Level M3                               | No              | SSH,               | - M3_SB_9_MCTP_Physical_Binding                                                    |
|                          |              |                                        |                 | Self Declaration   |                                                                                    |
|                          |              |                                        |                 |                    |                                                                                    |
|                          |              |                                        |                 |                    | Manual fallback: `MCTP_Test_Case_001`_; declare by setting                         |
|                          |              |                                        |                 |                    | `M3_SB_9_MCTP_I2C_PHYSICAL_BINDING_SUPPORT` in `config`_                           |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | M4_SB_1      | Level M4                               | No              | SSH,               | - M4_SB_1_MCTP_I3C_PCIE_VDM_Binding                                                |
|                          |              |                                        |                 | Self Declaration   |                                                                                    |
|                          |              |                                        |                 |                    |                                                                                    |
|                          |              |                                        |                 |                    | Manual fallback: `MCTP_Test_Case_003`_; declare by setting                         |
|                          |              |                                        |                 |                    | `M4_SB_1_MCTP_I3C_PHYSICAL_BINDING_SUPPORT` in `config`_                           |
+--------------------------+--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
| OOB                      | M1_OOB_1     | Level M1                               | Yes             | IB, OOB            | - M1_OOB_1_IPMI_1_2_3_Power_Control                                                |
|                          |              |                                        |                 |                    | - M1_OOB_1_IPMI_4_5_Boot_Device                                                    |
|                          |              |                                        |                 |                    | - M1_OOB_1_IPMI_6_IB_Get_Manager_Info                                              |
|                          |              |                                        |                 |                    | - M1_OOB_1_IPMI_7_IB_Add_User_Account                                              |
|                          |              |                                        |                 |                    | - M21_IPMI1_IPMI_8_Redfish_Host_Certificate_Fingerprint                            |
|                          |              |                                        |                 |                    | - M21_IPMI1_IPMI_8_Redfish_Host_Get_Account_Credential                             |
|                          |              |                                        |                 |                    |                                                                                    |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | M2_OOB_1     | Level M2                               | Yes             | OOB                | - M2_OOB_1_Redfish_Host_PowerOn                                                    |
|                          |              |                                        |                 |                    | - M2_OOB_1_Redfish_Host_PowerOff                                                   |
|                          |              |                                        |                 |                    | - M2_OOB_1_Redfish_Host_ForceRestart                                               |
|                          |              |                                        |                 |                    | - M2_OOB_1_Redfish_Boot_Source_As_Once                                             |
|                          |              |                                        |                 |                    | - M2_OOB_1_Redfish_Boot_Source_As_Continuous                                       |
|                          |              |                                        |                 |                    | - M2_OOB_1_Redfish_Boot_Source_As_Disabled                                         |
|                          |              |                                        |                 |                    | - M2_OOB_1_Redfish_Protocol_Validator                                              |
|                          |              |                                        |                 |                    | - M2_OOB_1_Redfish_Reference_Checker                                               |
|                          |              |                                        |                 |                    | - M2_OOB_1_Redfish_Service_Validator                                               |
|                          |              |                                        |                 |                    |                                                                                    |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | M2_OOB_3     | Level M2                               | Yes             | OOB                | - M2_OOB_3_Redfish_Interop_Validator_On_OCP_Baseline                               |
|                          |              |                                        |                 |                    | - M2_OOB_3_Redfish_Interop_Validator_On_OCP_Server (recommended)                   |
|                          |              |                                        |                 |                    |                                                                                    |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | M3_OOB_1     | Level M3                               | No              | Self Declaration   | - M3_OOB_1_IPMI_OOB_Optional_Declaration* (implementation choice)                  |
|                          |              |                                        |                 |                    |                                                                                    |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | M3_OOB_2     | Level M3                               | Yes             | OOB                | - M3_OOB_2_Redfish_Service_Validator                                               |
|                          |              |                                        |                 |                    | - M3_OOB_2_Redfish_Interop_Validator_On_OCP_Baseline                               |
|                          |              |                                        |                 |                    | - M3_OOB_2_Redfish_Interop_Validator_On_OCP_Server (recommended)                   |
|                          |              |                                        |                 |                    |                                                                                    |
+--------------------------+--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
| BMC-IO                   | M2_IO_1      | Level M2                               | No              | Self Declaration   | - M2_IO_1_NCSI_RBT_Declaration* (conditional)                                      |
|                          |              |                                        |                 |                    |                                                                                    |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | M3_IO_1      | Level M3                               | No              | Self Declaration   | - M3_IO_1_NCSI_RBT_Or_MCTP_Declaration* (conditional)                              |
|                          |              |                                        |                 |                    |                                                                                    |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | M3_IO_2      | Level M3                               | No              | SSH,               | - M3_IO_2_MCTP_Physical_Binding (conditional)                                      |
|                          |              |                                        |                 | Self Declaration   |                                                                                    |
|                          |              |                                        |                 |                    |                                                                                    |
|                          |              |                                        |                 |                    | Manual fallback: `MCTP_Test_Case_001`_; declare by setting                         |
|                          |              |                                        |                 |                    | `M3_IO_2_MCTP_IO_PHYSICAL_BINDING_SUPPORT` in `config`_                            |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | M4_IO_1      | Level M4                               | No              | SSH,               | - M4_IO_1_MCTP_Transport_Protocol (conditional)                                    |
|                          |              |                                        |                 | Self Declaration   |                                                                                    |
|                          |              |                                        |                 |                    |                                                                                    |
|                          |              |                                        |                 |                    | Manual fallback: `MCTP_Test_Case_002`_; declare by setting                         |
|                          |              |                                        |                 |                    | `M4_IO_1_PCIE_DEVICE_MCTP_PLDM_MANAGEMENT_SUPPORT` in `config`_                    |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | M4_IO_2      | Level M4                               | No              | Self Declaration   | - M4_IO_2_NVMe_MI_Over_MCTP_Declaration* (conditional)                             |
|                          |              |                                        |                 |                    |                                                                                    |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | M4_IO_3      | Level M4                               | No              | SSH,               | - M4_IO_3_MCTP_I3C_PCIE_VDM_Binding (conditional)                                  |
|                          |              |                                        |                 | Self Declaration   |                                                                                    |
|                          |              |                                        |                 |                    |                                                                                    |
|                          |              |                                        |                 |                    | Manual fallback: `MCTP_Test_Case_003`_; declare by setting                         |
|                          |              |                                        |                 |                    | `M4_IO_3_MCTP_I3C_PCIE_VDM_BINDING_SUPPORT` in `config`_                           |
+--------------------------+--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
| SPDM                     | M3_SPDM_1    | Level M3                               | No              | Self Declaration   | - M3_SPDM_1_SPDM_Protocol_Declaration* (conditional)                               |
|                          |              |                                        |                 |                    |                                                                                    |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | M3_SPDM_2    | Level M3                               | No              | Self Declaration   | - M3_SPDM_2_SPDM_MCTP_Binding_Declaration* (conditional)                           |
|                          |              |                                        |                 |                    |                                                                                    |
+--------------------------+--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
| RAS                      | M1_RAS_1     | Level M1                               | Yes             | IB                 | - M1_RAS_1_2_Send_Platform_Error_Record_Command                                    |
|                          |              |                                        |                 |                    |                                                                                    |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | M1_RAS_2     | Level M1                               | Yes             | IB                 | - M1_RAS_1_2_Send_Platform_Error_Record_Command                                    |
|                          |              |                                        |                 |                    |                                                                                    |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | M2_RAS_2     | Level M2                               | No              | Self Declaration   | - M2_RAS_2_Redfish_Platform_Error_Record_Declaration* (conditional)                |
|                          |              |                                        |                 |                    |                                                                                    |
+--------------------------+--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
| IPMI                     | IPMI_1       | Level M1                               | Yes             | OOB                | - M1_OOB_1_IPMI_1_2_3_Power_Control                                                |
|                          |              |                                        |                 |                    |                                                                                    |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | IPMI_2       | Level M1                               | Yes             | OOB                | - M1_OOB_1_IPMI_1_2_3_Power_Control                                                |
|                          |              |                                        |                 |                    |                                                                                    |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | IPMI_3       | Level M1                               | Yes             | OOB                | - M1_OOB_1_IPMI_1_2_3_Power_Control                                                |
|                          |              |                                        |                 |                    |                                                                                    |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | IPMI_4       | Level M1                               | Yes             | OOB                | - M1_OOB_1_IPMI_4_5_Boot_Device                                                    |
|                          |              |                                        |                 |                    |                                                                                    |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | IPMI_5       | Level M1                               | Yes             | OOB                | - M1_OOB_1_IPMI_4_5_Boot_Device                                                    |
|                          |              |                                        |                 |                    |                                                                                    |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | IPMI_6       | Level M1                               | Yes             | IB                 | - M1_OOB_1_IPMI_6_IB_Get_Manager_Info                                              |
|                          |              |                                        |                 |                    |                                                                                    |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | IPMI_7       | Level M1                               | Yes             | IB                 | - M1_OOB_1_IPMI_7_IB_Add_User_Account                                              |
|                          |              |                                        |                 |                    |                                                                                    |
+                          +--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                          | IPMI_8       | Level M1                               | Yes             | IB                 | - M21_IPMI1_IPMI_8_Redfish_Host_Certificate_Fingerprint (conditional)              |
|                          |              |                                        |                 |                    | - M21_IPMI1_IPMI_8_Redfish_Host_Get_Account_Credential (conditional)               |
|                          |              |                                        |                 |                    |                                                                                    |
+--------------------------+--------------+----------------------------------------+-----------------+--------------------+------------------------------------------------------------------------------------+

SBMR future requirements checklist
==================================

+----------------------------+--------------+-----------------+--------------------+------------------------------------------------------------------------------------+
| Category                   | Rule ID      | Covered by ACS? | Execution Type     | Test Tag(s)                                                                        |
+============================+==============+=================+====================+====================================================================================+
| In-Band                    | M5_IB_1      | No              | Self Declaration   | - M5_IB_1_MMBI_Interface_Declaration* (conditional)                                |
|                            |              |                 |                    |                                                                                    |
+                            +--------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                            | M5_IB_2      | No              | Self Declaration   | - M5_IB_2_MCTP_Host_Interface_Discovery_Declaration* (conditional)                 |
|                            |              |                 |                    |                                                                                    |
+----------------------------+--------------+-----------------+--------------------+------------------------------------------------------------------------------------+
| Side-Band                  | M5_SB_1      | No              | Self Declaration   | - M5_SB_1_MCTP_High_Bandwidth_Binding_Declaration*                                 |
|                            |              |                 |                    |                                                                                    |
+----------------------------+--------------+-----------------+--------------------+------------------------------------------------------------------------------------+
| BMC-IO                     | M5_IO_1      | No              | Self Declaration   | - M5_IO_1_MCTP_IO_High_Bandwidth_Binding_Declaration*                              |
|                            |              |                 |                    |                                                                                    |
+----------------------------+--------------+-----------------+--------------------+------------------------------------------------------------------------------------+
| OOB                        | M5_OOB_1     | Yes             | OOB                | - M5_OOB_1_Redfish_BIOS_Settings_Resource* (conditional)                           |
|                            |              |                 |                    |                                                                                    |
|                            |              |                 |                    | User should declare whether the server platform supports                           |
|                            |              |                 |                    | user-accessible BIOS settings using                                                |
|                            |              |                 |                    | M5_OOB_1_EXPOSE_BIOS_SETTINGS_SUPPORT flag in config.                              |
+----------------------------+--------------+-----------------+--------------------+------------------------------------------------------------------------------------+
| Host-to-SatMC interface    | M5_HS_1      | No              | Self Declaration   | - M5_HS_1_MCTP_Over_PCC_Mailbox_Declaration* (conditional)                         |
|                            |              |                 |                    |                                                                                    |
+                            +--------------+-----------------+--------------------+------------------------------------------------------------------------------------+
|                            | M5_HS_2      | No              | Self Declaration   | - M5_HS_2_MCTP_Host_Interface_Discovery_Declaration* (conditional)                 |
|                            |              |                 |                    |                                                                                    |
+----------------------------+--------------+-----------------+--------------------+------------------------------------------------------------------------------------+

.. _Side_Band_Test_Case_001: sideband_manual_testing.md#side_band_test_case_001
.. _MCTP_Test_Case_001: sideband_manual_testing.md#mctp_test_case_001
.. _MCTP_Test_Case_002: sideband_manual_testing.md#mctp_test_case_002
.. _MCTP_Test_Case_003: sideband_manual_testing.md#mctp_test_case_003
.. _PLDM_Test_Case_001: sideband_manual_testing.md#pldm_test_case_001
.. _PLDM_Test_Case_002: sideband_manual_testing.md#pldm_test_case_002
.. _config: ../config

*Copyright (c) 2024-2026, Arm Limited and Contributors. All rights reserved.*
