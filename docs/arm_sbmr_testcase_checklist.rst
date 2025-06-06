############################
SBMR ACS Testcase checklist
############################

This document provides a checklist of SBMR rule IDs with their compliance levels, indicating if the SBMR test suite covers these rules and includes tags to the actual tests.

+-------------+-------+------------+------------------+----------------------------------------------------------------+
| Category    | Level | Rule ID    | Covered by ACS?  | Test Tag(s)                                                    |
+=============+=======+============+==================+================================================================+
| In-Band     | M1    | M1_IB_1    | Yes              | - M1_IB_1_IPMI_SSIF_Functionality                              |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| UART        | M1    | M1_UART_1  | Yes              | - M1_UART_1_Redfish_Serial_Console_Capability                  |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| UART        | M1    | M1_UART_2  | Yes              | - M1_UART_2_IPMI_SOL                                           |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| JTAG        | M1    | M1_JTAG_1  | No               | - M1_JTAG_1_2_Interface_Declaration*                           |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| JTAG        | M1    | M1_JTAG_2  | No               | - M1_JTAG_1_2_Interface_Declaration*                           |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| OOB         | M1    | M1_OOB_1   | Yes              | - M1_OOB_1_IPMI_1_2_3_Power_Control                            |
|             |       |            |                  | - M1_OOB_1_IPMI_1_2_3_Power_Control                            |
|             |       |            |                  | - M1_OOB_1_IPMI_1_2_3_Power_Control                            |
|             |       |            |                  | - M1_OOB_1_IPMI_4_5_Boot_Device                                |
|             |       |            |                  | - M1_OOB_1_IPMI_4_5_Boot_Device                                |
|             |       |            |                  | - M1_OOB_1_IPMI_6_IB_Get_Manager_Info                          |
|             |       |            |                  | - M1_OOB_1_IPMI_7_IB_Add_User_Account                          |
|             |       |            |                  | - M21_IPMI_1_IPMI_8_Redfish_Host_Certificate_Fingerprint       |
|             |       |            |                  | - M21_IPMI_1_IPMI_8_Redfish_Host_Get_Account_Credential        |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| IPMI        | M1    | IPMI_1     | Yes              | - M1_OOB_1_IPMI_1_2_3_Power_Control                            |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| IPMI        | M1    | IPMI_2     | Yes              | - M1_OOB_1_IPMI_1_2_3_Power_Control                            |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| IPMI        | M1    | IPMI_3     | Yes              | - M1_OOB_1_IPMI_1_2_3_Power_Control                            |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| IPMI        | M1    | IPMI_4     | Yes              | - M1_OOB_1_IPMI_4_5_Boot_Device                                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| IPMI        | M1    | IPMI_5     | Yes              | - M1_OOB_1_IPMI_4_5_Boot_Device                                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| IPMI        | M1    | IPMI_6     | Yes              | - M1_OOB_1_IPMI_6_IB_Get_Manager_Info                          |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| IPMI        | M1    | IPMI_7     | Yes              | - M1_OOB_1_IPMI_7_IB_Add_User_Account                          |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| IPMI        | M1    | IPMI_8     | Yes              | - M21_IPMI_1_IPMI_8_Redfish_Host_Certificate_Fingerprint       |
|             |       |            |                  | - M21_IPMI_1_IPMI_8_Redfish_Host_Get_Account_Credential        |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| RAS         | M1    | M1_RAS_1   | Yes              | - M1_RAS_1_2_Send_Platform_Error_Record_Command                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| RAS         | M1    | M1_RAS_2   | Yes              | - M1_RAS_1_2_Send_Platform_Error_Record_Command                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| In-Band     | M2    | M2_IB_1    | Yes              | - M2_IB_1_Redfish_HI_Functionality                             |
|             |       |            |                  | - M2_IB_1_Redfish_HI_Type                                      |
|             |       |            |                  | - M2_IB_1_Redfish_HI_Service_Root                              |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| In-Band     | M2    | M2_IB_2    | Yes              | - M2_IB_2_IPMI_SSIF_Functionality                              |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| JTAG        | M2    | M2_JTAG_1  | No               | - M2_JTAG_1_2_Interface_Declaration*                           |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| JTAG        | M2    | M2_JTAG_2  | No               | - M2_JTAG_1_2_Interface_Declaration*                           |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| BMC-IO      | M2    | M2_IO_1    | No               | - M2_IO_1_NCSI_Interface_Declaration*                          |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| OOB         | M2    | M2_OOB_1   | Yes              | - M2_OOB_1_Redfish_Host_PowerOn                                |
|             |       |            |                  | - M2_OOB_1_Redfish_Host_PowerOff                               |
|             |       |            |                  | - M2_OOB_1_Redfish_Host_ForceRestart                           |
|             |       |            |                  | - M2_OOB_1_Redfish_Boot_Source_As_Once                         |
|             |       |            |                  | - M2_OOB_1_Redfish_Boot_Source_As_Continuous                   |
|             |       |            |                  | - M2_OOB_1_Redfish_Boot_Source_As_Disabled                     |
|             |       |            |                  | - M2_OOB_1_Redfish_Protocol_Validator                          |
|             |       |            |                  | - M2_OOB_1_Redfish_JsonSchema_ResponseValidator                |
|             |       |            |                  | - M2_OOB_1_Redfish_Reference_Checker                           |
|             |       |            |                  | - M2_OOB_1_Redfish_Service_Validator                           |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| OOB         | M2    | M2_OOB_2   | Yes              | - M2_OOB_2_IPMI_1_2_3_Power_Control                            |
|             |       |            |                  | - M2_OOB_2_IPMI_4_5_Boot_Device                                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| OOB         | M2    | M2_OOB_3   | Yes              | - M2_OOB_3_Redfish_Interop_Validator_On_OCP_Baseline           |
|             |       |            |                  | - M2_OOB_3_Redfish_Interop_Validator_On_OCP_Server             |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| RAS         | M2    | M2_RAS_1   | No               | - M2_RAS_1_2_Function_Declaration*                             |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| RAS         | M2    | M2_RAS_2   | No               | - M2_RAS_1_2_Function_Declaration*                             |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| In-Band     | M21   | M21_IB_1   | Yes              | - M21_IB_1_IPMI_SSIF_Capability                                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| In-Band     | M21   | M21_IB_2   | Yes              | - M21_IB_2_IPMI_SSIF_Interrupt                                 |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| PCIe        | M21   | M21_PCI_1  | Yes              | - M21_PCI_1_Interface_Availability                             |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| USB         | M21   | M21_USB_1  | Yes              | - M21_USB_1_Redfish_Virtual_Media_Action_Uri                   |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| IPMI        | M21   | M21_IPMI_1 | Yes              | - M21_IPMI_1_Power_Control                                     |
|             |       |            |                  | - M21_IPMI_1_Boot_Device                                       |
|             |       |            |                  | - M21_IPMI_1_IB_Get_Manager_Info                               |
|             |       |            |                  | - M21_IPMI_1_IB_Add_User_Account                               |
|             |       |            |                  | - M21_IPMI_1_IPMI_8_Redfish_Host_Certificate_Fingerprint       |
|             |       |            |                  | - M21_IPMI_1_IPMI_8_Redfish_Host_Get_Account_Credential        |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| IPMI        | M21   | M21_IPMI_2 | Yes              | - M21_IPMI_2_Send_Platform_Error_Record_Command                |
|             |       |            |                  | - M21_IPMI_2_Send_Boot_Progress_Code_Command                   |
|             |       |            |                  | - M21_IPMI_2_Get_Boot_Progress_Code                            |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| Side-Band   | M3    | M3_SB_1    | No               |                                                                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| Side-Band   | M3    | M3_SB_2    | No               |                                                                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| Side-Band   | M3    | M3_SB_3    | No               |                                                                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| Side-Band   | M3    | M3_SB_4    | No               |                                                                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| Side-Band   | M3    | M3_SB_5    | No               |                                                                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| Side-Band   | M3    | M3_SB_6    | No               |                                                                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| Side-Band   | M3    | M3_SB_7    | No               |                                                                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| Side-Band   | M3    | M3_SB_8    | No               |                                                                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| Side-Band   | M3    | M3_SB_9    | No               |                                                                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| JTAG        | M3    | M3_JTAG_1  | No               |                                                                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| JTAG        | M3    | M3_JTAG_2  | No               |                                                                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| BMC-IO      | M3    | M3_IO_1    | No               |                                                                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| BMC-IO      | M3    | M3_IO_2    | No               |                                                                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| OOB         | M3    | M3_OOB_1   | No               |                                                                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| OOB         | M3    | M3_OOB_2   | No               |                                                                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| SPDM        | M3    | M3_SPDM_1  | No               |                                                                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| SPDM        | M3    | M3_SPDM_2  | No               |                                                                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| RAS         | M3    | M3_RAS_1   | No               |                                                                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| In-Band     | M4    | M4_IB_1    | No               |                                                                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| Side-Band   | M4    | M4_SB_1    | No               |                                                                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| BMC-IO      | M4    | M4_IO_1    | No               |                                                                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| BMC-IO      | M4    | M4_IO_2    | No               |                                                                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| BMC-IO      | M4    | M4_IO_3    | No               |                                                                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| In-Band     | M5a   | M5_IB_1    | No               |                                                                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| In-Band     | M5a   | M5_IB_2    | No               |                                                                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| Side-Band   | M5a   | M5_SB_1    | No               |                                                                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| BMC-IO      | M5a   | M5_IO_1    | No               |                                                                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| OOB         | M5a   | M5_OOB_1   | No               |                                                                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| Host-SatMC  | M5a   | M5_HS_1    | No               |                                                                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+
| Host-SatMC  | M5a   | M5_HS_2    | No               |                                                                |
+-------------+-------+------------+------------------+----------------------------------------------------------------+

Note: Some tests cannot assess functionality due to feasibility or interface limitations, requiring users to manually declare system compliance, tags of such tests are
marked with \*

*Copyright (c) 2024, Arm Limited and Contributors. All rights reserved.*