############################
SBMR ACS Testcase checklist
############################

This document provides a checklist of SBMR rule IDs with their compliance levels, indicating if the SBMR test suite covers these rules and includes tags to the actual tests.

The checklist indicates whether each test is executed via automation or requires manual testing.

- IB (In-Band) tests run automatically as part of the SystemReady SR ACS automation.
- OOB (Out-of-Band) tests require a manual SBMR-ACS run.
- Self Declaration : sbmr-acs cannot verify certain SBMR-defined interfaces, the vendor must declare support for SBMR-compliant interfaces by updating the corresponding variable.

+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| Category   | Level | Rule ID    | Covered by ACS? | - Execution Type   | Test Tag(s)                                                          |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| In-Band    | M1    | M1_IB_1    | Yes             | - IB               | - M1_IB_1_IPMI_SSIF_Functionality                                    |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| UART       | M1    | M1_UART_1  | Yes             | - OOB              | - M1_UART_1_Redfish_Serial_Console_Capability                        |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| UART       | M1    | M1_UART_2  | Yes             | - OOB              | - M1_UART_2_IPMI_SOL                                                 |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| JTAG       | M1    | M1_JTAG_1  | No              | - Self Declaration | - M1_JTAG_1_2_Interface_Declaration* (conditional)                   |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| JTAG       | M1    | M1_JTAG_2  | No              | - Self Declaration | - M1_JTAG_1_2_Interface_Declaration* (conditional)                   |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| OOB        | M1    | M1_OOB_1   | Yes             | - OOB              | - M1_OOB_1_IPMI_1_2_3_Power_Control                                  |
|            |       |            |                 | - OOB              | - M1_OOB_1_IPMI_1_2_3_Power_Control                                  |
|            |       |            |                 | - OOB              | - M1_OOB_1_IPMI_1_2_3_Power_Control                                  |
|            |       |            |                 | - OOB              | - M1_OOB_1_IPMI_4_5_Boot_Device                                      |
|            |       |            |                 | - OOB              | - M1_OOB_1_IPMI_4_5_Boot_Device                                      |
|            |       |            |                 | - IB               | - M1_OOB_1_IPMI_6_IB_Get_Manager_Info                                |
|            |       |            |                 | - IB               | - M1_OOB_1_IPMI_7_IB_Add_User_Account                                |
|            |       |            |                 | - IB               | - M21_IPMI_1_IPMI_8_Redfish_Host_Certificate_Fingerprint             |
|            |       |            |                 | - IB               | - M21_IPMI_1_IPMI_8_Redfish_Host_Get_Account_Credential              |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| IPMI       | M1    | IPMI_1     | Yes             | - OOB              | - M1_OOB_1_IPMI_1_2_3_Power_Control                                  |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| IPMI       | M1    | IPMI_2     | Yes             | - OOB              | - M1_OOB_1_IPMI_1_2_3_Power_Control                                  |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| IPMI       | M1    | IPMI_3     | Yes             | - OOB              | - M1_OOB_1_IPMI_1_2_3_Power_Control                                  |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| IPMI       | M1    | IPMI_4     | Yes             | - OOB              | - M1_OOB_1_IPMI_4_5_Boot_Device                                      |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| IPMI       | M1    | IPMI_5     | Yes             | - OOB              | - M1_OOB_1_IPMI_4_5_Boot_Device                                      |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| IPMI       | M1    | IPMI_6     | Yes             | - IB               | - M1_OOB_1_IPMI_6_IB_Get_Manager_Info                                |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| IPMI       | M1    | IPMI_7     | Yes             | - IB               | - M1_OOB_1_IPMI_7_IB_Add_User_Account                                |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| IPMI       | M1    | IPMI_8     | Yes             | - IB               | - M21_IPMI_1_IPMI_8_Redfish_Host_Certificate_Fingerprint(conditional)|
|            |       |            |                 | - IB               | - M21_IPMI_1_IPMI_8_Redfish_Host_Get_Account_Credential(conditional) |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| RAS        | M1    | M1_RAS_1   | Yes             | - IB               | - M1_RAS_1_2_Send_Platform_Error_Record_Command                      |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| RAS        | M1    | M1_RAS_2   | Yes             | - IB               | - M1_RAS_1_2_Send_Platform_Error_Record_Command                      |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| In-Band    | M2    | M2_IB_1    | Yes             | - IB               | - M2_IB_1_Redfish_HI_Functionality                                   |
|            |       |            |                 | - IB               | - M2_IB_1_Redfish_HI_Type                                            |
|            |       |            |                 | - IB               | - M2_IB_1_Redfish_HI_Service_Root                                    |
|            |       |            |                 | - OOB              | - M2_IB_1_Redfish_Host_Interface_Capability                          |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| In-Band    | M2    | M2_IB_2    | Yes             | - IB               | - M2_IB_2_IPMI_SSIF_Functionality                                    |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| JTAG       | M2    | M2_JTAG_1  | No              | - OOB              | - M2_JTAG_1_2_Interface_Declaration* (conditional)                   |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| JTAG       | M2    | M2_JTAG_2  | No              | - OOB              | - M2_JTAG_1_2_Interface_Declaration* (conditional)                   |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| BMC-IO     | M2    | M2_IO_1    | No              | - OOB              | - M2_IO_1_NCSI_Interface_Declaration* (conditional)                  |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| OOB        | M2    | M2_OOB_1   | Yes             | - OOB              | - M2_OOB_1_Redfish_Host_PowerOn                                      |
|            |       |            |                 | - OOB              | - M2_OOB_1_Redfish_Host_PowerOff                                     |
|            |       |            |                 | - OOB              | - M2_OOB_1_Redfish_Host_ForceRestart                                 |
|            |       |            |                 | - OOB              | - M2_OOB_1_Redfish_Boot_Source_As_Once                               |
|            |       |            |                 | - OOB              | - M2_OOB_1_Redfish_Boot_Source_As_Continuous                         |
|            |       |            |                 | - OOB              | - M2_OOB_1_Redfish_Boot_Source_As_Disabled                           |
|            |       |            |                 | - OOB              | - M2_OOB_1_Redfish_Protocol_Validator                                |
|            |       |            |                 | - OOB              | - M2_OOB_1_Redfish_Reference_Checker                                 |
|            |       |            |                 | - OOB              | - M2_OOB_1_Redfish_Service_Validator                                 |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| OOB        | M2    | M2_OOB_2   | Yes             | - OOB              | - M2_OOB_2_IPMI_1_2_3_Power_Control                                  |
|            |       |            |                 | - OOB              | - M2_OOB_2_IPMI_4_5_Boot_Device                                      |
|            |       |            |                 | - IB               | - M2_OOB_2_IPMI_6_IB_Get_Manager_Info                                |
|            |       |            |                 | - IB               | - M2_OOB_2_IPMI_7_IB_Add_User_Account                                |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| OOB        | M2    | M2_OOB_3   | Yes             | - OOB              | - M2_OOB_3_Redfish_Interop_Validator_On_OCP_Baseline                 |
|            |       |            |                 | - OOB              | - M2_OOB_3_Redfish_Interop_Validator_On_OCP_Server  (recommended)    |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| RAS        | M2    | M2_RAS_1   | No              | - OOB              | - M2_RAS_1_2_Function_Declaration* (conditional)                     |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| RAS        | M2    | M2_RAS_2   | No              | - OOB              | - M2_RAS_1_2_Function_Declaration* (conditional)                     |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| In-Band    | M21   | M21_IB_1   | Yes             | - IB               | - M21_IB_1_IPMI_SSIF_Capability                                      |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| PCIe       | M21   | M21_PCI_1  | Yes             | - IB               | - M21_PCI_1_Interface_Availability (conditional)                     |
|            |       |            |                 | - OOB              | - M21_PCI_1_Redfish_Graphical_Console_Capability (conditional)       |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| USB        | M21   | M21_USB_1  | Yes             | - OOB              | - M21_USB_1_Redfish_Virtual_Media_Action_Uri (conditional)           |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| IPMI       | M21   | M21_IPMI_1 | Yes             | - OOB              | - M21_IPMI_1_Power_Control                                           |
|            |       |            |                 | - OOB              | - M21_IPMI_1_Boot_Device                                             |
|            |       |            |                 | - IB               | - M21_IPMI_1_IB_Get_Manager_Info                                     |
|            |       |            |                 | - IB               | - M21_IPMI_1_IB_Add_User_Account                                     |
|            |       |            |                 | - IB               | - M21_IPMI_1_IPMI_8_Redfish_Host_Certificate_Fingerprint(conditional)|
|            |       |            |                 | - IB               | - M21_IPMI_1_IPMI_8_Redfish_Host_Get_Account_Credential (conditional)|
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| IPMI       | M21   | M21_IPMI_2 | Yes             | - IB               | - M21_IPMI_2_Send_Platform_Error_Record_Command  (conditional)       |
|            |       |            |                 | - IB               | - M21_IPMI_2_Send_Boot_Progress_Code_Command  (conditional)          |
|            |       |            |                 | - IB               | - M21_IPMI_2_Get_Boot_Progress_Code   (conditional)                  |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| Side-Band  | M3    | M3_SB_1    | No              | - Self Declaration | - M3_SB_1_9_Interface_Declaration*                                   |
|            |       |            |                 |                    |                                                                      |
|            |       |            |                 |                    | Compliance for the rule could be manually tested using               |
|            |       |            |                 |                    | `Side_Band_Test_Case_001`_.                                          |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| Side-Band  | M3    | M3_SB_2    | No              | - Self Declaration | - M3_SB_1_9_Interface_Declaration*                                   |
|            |       |            |                 |                    |                                                                      |
|            |       |            |                 |                    | Compliance for the rule could be manually tested using               |
|            |       |            |                 |                    | `PLDM_Test_Case_001`_.                                               |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| Side-Band  | M3    | M3_SB_3    | No              | - Self Declaration | - M3_SB_1_9_Interface_Declaration*                                   |
|            |       |            |                 |                    |                                                                      |
|            |       |            |                 |                    | Compliance for the rule could be manually tested using               |
|            |       |            |                 |                    | `MCTP_Test_Case_002`_.                                               |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| Side-Band  | M3    | M3_SB_4    | No              | - Self Declaration | - M3_SB_1_9_Interface_Declaration*                                   |
|            |       |            |                 |                    |                                                                      |
|            |       |            |                 |                    | Compliance for the rule could be manually tested using               |
|            |       |            |                 |                    | `PLDM_Test_Case_002`_.                                               |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| Side-Band  | M3    | M3_SB_5    | No              | - Self Declaration | - M3_SB_1_9_Interface_Declaration*                                   |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| Side-Band  | M3    | M3_SB_6    | No              | - Self Declaration | - M3_SB_1_9_Interface_Declaration*                                   |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| Side-Band  | M3    | M3_SB_7    | No              | - Self Declaration | - M3_SB_1_9_Interface_Declaration*                                   |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| Side-Band  | M3    | M3_SB_8    | No              | - Self Declaration | - M3_SB_1_9_Interface_Declaration*                                   |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| Side-Band  | M3    | M3_SB_9    | No              | - Self Declaration | - M3_SB_1_9_Interface_Declaration*                                   |
|            |       |            |                 |                    |                                                                      |
|            |       |            |                 |                    | Compliance for the rule could be manually tested using               |
|            |       |            |                 |                    | `MCTP_Test_Case_001`_.                                               |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| JTAG       | M3    | M3_JTAG_1  | No              | - Self Declaration | - M3_JTAG_1_2_Interface_Declaration* (conditional)                   |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| JTAG       | M3    | M3_JTAG_2  | No              | - Self Declaration | - M3_JTAG_1_2_Interface_Declaration* (conditional)                   |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| BMC-IO     | M3    | M3_IO_1    | No              | - Self Declaration | - M3_IO_1_2_Interface_Declaration* (conditional)                     |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| BMC-IO     | M3    | M3_IO_2    | No              | - Self Declaration | - M3_IO_1_2_Interface_Declaration* (conditional)                     |
|            |       |            |                 |                    |                                                                      |
|            |       |            |                 |                    | Compliance for the rule could be manually tested using               |
|            |       |            |                 |                    | `MCTP_Test_Case_001`_.                                               |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| OOB        | M3    | M3_OOB_1   | No              | - Self Declaration | - M3_OOB_1_Interface_Declaration* (implementation choice)            |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| OOB        | M3    | M3_OOB_2   | Yes             | - OOB              | - M3_OOB_2_Redfish_Interop_Validator_On_OCP_Baseline                 |
|            |       |            |                 |                    | - M3_OOB_2_Redfish_Interop_Validator_On_OCP_Server (recommended)     |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| SPDM       | M3    | M3_SPDM_1  | No              | - Self Declaration | - M3_SPDM_1_2_Interface_Declaration* (conditional)                   |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| SPDM       | M3    | M3_SPDM_2  | No              | - Self Declaration | - M3_SPDM_1_2_Interface_Declaration* (conditional)                   |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| RAS        | M3    | M3_RAS_1   | No              | - Self Declaration | - M3_RAS_1_Function_Declaration*                                     |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| Side-Band  | M4    | M4_SB_1    | No              | - Self Declaration | - M4_SB_1_Interface_Declaration*                                     |
|            |       |            |                 |                    |                                                                      |
|            |       |            |                 |                    | Compliance for the rule could be manually tested using               |
|            |       |            |                 |                    | `MCTP_Test_Case_003`_.                                               |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| BMC-IO     | M4    | M4_IO_1    | No              | - Self Declaration | - M4_IO_1_3_Interface_Declaration* (conditional)                     |
|            |       |            |                 |                    |                                                                      |
|            |       |            |                 |                    | Compliance for the rule could be manually tested using               |
|            |       |            |                 |                    | `MCTP_Test_Case_002`_.                                               |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| BMC-IO     | M4    | M4_IO_2    | No              | - Self Declaration | - M4_IO_1_3_Interface_Declaration* (conditional)                     |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| BMC-IO     | M4    | M4_IO_3    | No              | - Self Declaration | - M4_IO_1_3_Interface_Declaration* (conditional)                     |
|            |       |            |                 |                    |                                                                      |
|            |       |            |                 |                    | Compliance for the rule could be manually tested using               |
|            |       |            |                 |                    | `MCTP_Test_Case_003`_.                                               |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| In-Band    | M5a   | M5_IB_1    | No              | - Self Declaration | - M5_IB_1_2_Interface_Declaration* (conditional)                     |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| In-Band    | M5a   | M5_IB_2    | No              | - Self Declaration | - M5_IB_1_2_Interface_Declaration* (conditional)                     |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| Side-Band  | M5a   | M5_SB_1    | No              | - Self Declaration | - M5_SB_1_Interface_Declaration*                                     |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| BMC-IO     | M5a   | M5_IO_1    | No              | - Self Declaration | - M5_IO_1_Interface_Declaration*                                     |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| OOB        | M5a   | M5_OOB_1   | No              | - Self Declaration | - M5_OOB_1_Interface_Declaration* (conditional)                      |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| Host-SatMC | M5a   | M5_HS_1    | No              | - Self Declaration | - M5_HS_1_2_Interface_Declaration* (conditional)                     |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+
| Host-SatMC | M5a   | M5_HS_2    | No              | - Self Declaration | - M5_HS_1_2_Interface_Declaration* (conditional)                     |
+------------+-------+------------+-----------------+--------------------+----------------------------------------------------------------------+

Note: Some tests cannot assess functionality due to feasibility or interface limitations, requiring users to manually declare system compliance, tags of such tests are
marked with \*

.. _Side_Band_Test_Case_001: sideband_manual_testing.md#side_band_test_case_001
.. _MCTP_Test_Case_001: sideband_manual_testing.md#mctp_test_case_001
.. _MCTP_Test_Case_002: sideband_manual_testing.md#mctp_test_case_002
.. _MCTP_Test_Case_003: sideband_manual_testing.md#mctp_test_case_003
.. _PLDM_Test_Case_001: sideband_manual_testing.md#pldm_test_case_001
.. _PLDM_Test_Case_002: sideband_manual_testing.md#pldm_test_case_002

*Copyright (c) 2024, Arm Limited and Contributors. All rights reserved.*
