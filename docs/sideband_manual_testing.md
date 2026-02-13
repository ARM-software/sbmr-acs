# PLDM/MCTP Manual Testing for SBMR Required Interfaces
This document provides manual test guidance for validating SBMR side-band and I/O device interface requirements on server Baseboard Management Controllers (BMCs) running OpenBMC firmware.

The tests described herein use standard OpenBMC utilities (for example, systemctl, busctl, mctp, pldmtool) to verify that the server management stack is configured and layered in
accordance with DMTF PMCI architecture and the rules stated in the Arm SBMR side-band interface section. These checks focus on architectural correctness, protocol selection,
and interface exposure, rather than exhaustive protocol compliance.

This document is intended as guidance for partners and implementers to:
- Perform initial self-assessment of SBMR side-band compliance,
- Support compliance declaration during early enablement phases,
- Validate correct usage of PMCI-defined protocols (PLDM and MCTP) on OpenBMC-based systems.

At this stage, the document does not replace a full conformance test suite. It is expected that, over time, more robust and automated validation infrastructure will be developed,
including testing via PMCI-defined PTTI ([PMCI Test Tools Interface](https://www.dmtf.org/sites/default/files/standards/documents/DSP0280_1.0.0.pdf)) or equivalent mechanisms.

For non-OpenBMC implementations, this document serves as a reference example. Such systems are expected to identify and use functionally equivalent utilities or
interfaces to validate the same architectural properties, protocol layering, and side-band behaviors described here.

# Test Sections
- [Side_Band_Test_Case_001 (M3_SB_1)](#side_band_test_case_001)
- [MCTP_Test_Case_001 (M3_SB_9, M3_IO_2)](#mctp_test_case_001)
- [MCTP_Test_Case_002 (M3_SB_3, M4_IO_1)](#mctp_test_case_002)
- [MCTP_Test_Case_003 (M4_SB_1, M4_IO_3)](#mctp_test_case_003)
- [PLDM_Test_Case_001 (M3_SB_2)](#pldm_test_case_001)
- [PLDM_Test_Case_002 (M3_SB_4)](#pldm_test_case_002)
- [Appendix A: Get MCTP Endpoint ID for PLDM command arguments](#appendix_a_pldm_args)
- [Appendix B: PLDM command reference](#appendix_b_pldm_commands)
- [Appendix C: MCTP example walk-through](#appendix_c_mctp_example)

<a id="side_band_test_case_001"></a>
## Side_Band_Test_Case_001

#### Objective
SBMR standardizes the side-band interface based on the DMTF PMCI workgroup standards which define specifications for primary intercommunication interfaces and data models between BMC and SatMC.

**Verified SBMR Rule ID**
- M3_SB_1

#### Test Cases
<table>
  <tr>
    <td>Steps</td>
    <td>Description</td>
    <td>Expected Result</td>
  </tr>
  <tr>
    <td>1</td>
    <td>Verify all required side-band test cases are compliant: <b>MCTP_Test_Case_001</b>, <b>MCTP_Test_Case_002</b>, <b>MCTP_Test_Case_003</b>, <b>PLDM_Test_Case_001</b>, <b>PLDM_Test_Case_002</b>.</td>
    <td>Compliant if all listed test cases are compliant; otherwise non-compliant.</td>
  </tr>
</table>

<a id="mctp_test_case_001"></a>
## MCTP_Test_Case_001

#### Objective
Verify that MCTP communication supports SMBus/I2C or a higher-bandwidth binding for BMC to SoC side-band and I/O device management when MCTP/PLDM is implemented.

**Verified SBMR Rule ID**
- M3_SB_9
- M3_IO_2

#### Pre-requisites
- M3_SB_3 is compliant
- Check the platform I2C/I3C/PCIe topology used for MCTP on both side-band and I/O device interfaces.
Note: See [Appendix C](#appendix_c_mctp_example) for an example walk-through.

#### Test Cases
<table>
  <tr>
    <td>Steps</td>
    <td>Description</td>
    <td>Expected Result</td>
  </tr>
  <tr>
    <td>1</td>
    <td>Verify the MCTP physical binding.<br><pre><code>mctp link</code></pre></td>
    <td>1. MCTP link shows SMBus/I2C or higher-bandwidth binding (I3C or PCIe VDM where supported)<br>Example output (I2C):<br><pre>dev mctpi2c0 index 6 address none net 1 mtu 68 up</pre>Example output (I3C):<br><pre>dev mctpi3c0 index 7 address none net 1 mtu 68 up</pre></td>
  </tr>
  <tr>
    <td>2</td>
    <td>Repeat Step 1 for the I/O device interface MCTP link (I2C, I3C, or PCIe VDM as implemented).</td>
    <td>1. I/O device interface MCTP link is listed<br>2. Binding reflects the expected bus and platform topology</td>
  </tr>
</table>

<a id="mctp_test_case_002"></a>
## MCTP_Test_Case_002

#### Objective
Verify that MCTP is implemented and used as a transport protocol, providing a bus-independent abstraction for side-band and I/O device communication on the BMC.

**Verified SBMR Rule ID**
- M3_SB_3
- M4_IO_1

#### Pre-requisites
- Access to the BMC console
- `systemctl`, `busctl`, `mctp` utilities installed
- Check the platform I2C/I3C/PCIe topology used for MCTP on both side-band and I/O device interfaces.
- See [Appendix A](#appendix_a_pldm_args) to get the MCTP endpoint ID for PLDM command arguments.
- See [Appendix C](#appendix_c_mctp_example) for an example walk-through.

#### Test Cases
<table>
  <tr>
    <td>Steps</td>
    <td>Description</td>
    <td>Expected Result</td>
  </tr>
  <tr>
    <td>1</td>
    <td>Verify MCTP services are present.<br><pre><code>systemctl list-units --type=service | grep -i mctp</code></pre></td>
    <td>1. One or more MCTP-related services are listed (for example <b>mctpd.service</b>, <b>mctp-*.service</b>)<br>2. Indicates MCTP is implemented as a distinct transport component<br>Example output:<br><pre>mctpd.service</pre></td>
  </tr>
  <tr>
    <td>2</td>
    <td>Verify the MCTP transport stack is active.<br><pre><code>systemctl status mctpd.service</code></pre></td>
    <td>1. mctpd.service exists<br>2. Service state shows: <b>Active: active (running)</b><br>3. Confirms MCTP transport daemon is operational<br>Example output:<br><pre>Active: active (running)</pre></td>
  </tr>
  <tr>
    <td>3</td>
    <td>Discover the MCTP D-Bus service.<br><pre><code>busctl list | grep -i mctp</code></pre></td>
    <td>1. An MCTP D-Bus service is listed (for example <b>au.com.codeconstruct.MCTP1</b>)<br>Example output:<br><pre>au.com.codeconstruct.MCTP1</pre></td>
  </tr>
  <tr>
    <td>4</td>
    <td>Verify the object model for the MCTP D-Bus service.<br><pre><code>busctl tree &lt;mctp-dbus-service&gt;</code></pre></td>
    <td>1. One or more endpoint object paths are present<br>Example output:<br><pre>~# busctl tree au.com.codeconstruct.MCTP1
`- /au
  `- /au/com
    `- /au/com/codeconstruct
      `- /au/com/codeconstruct/mctp1
        |- /au/com/codeconstruct/mctp1/interfaces
        | |- /au/com/codeconstruct/mctp1/interfaces/lo
        | `- /au/com/codeconstruct/mctp1/interfaces/mctpi2c0
        `- /au/com/codeconstruct/mctp1/networks
          `- /au/com/codeconstruct/mctp1/networks/1
            `- /au/com/codeconstruct/mctp1/networks/1/endpoints
              |- /au/com/codeconstruct/mctp1/networks/1/endpoints/18
              `- /au/com/codeconstruct/mctp1/networks/1/endpoints/8</pre></td>
  </tr>
  <tr>
    <td>5</td>
    <td>Use the MCTP <b>SetupEndpoint</b> method to test MCTP control messaging.<br><pre><code>busctl call &lt;mctp-dbus-service&gt; &lt;bus-owner-object-path&gt; au.com.codeconstruct.MCTP.BusOwner1 SetupEndpoint ay &lt;eid&gt; &lt;physical-address&gt;</code></pre></td>
    <td>1. The SetupEndpoint call completes successfully<br>2. Confirms MCTP control messages are accepted by the MCTP bus owner on the target interface<br>Example output (I2C bus: <b>mctpi2c0</b>, physical address: <b>0x40</b>):<br><pre>busctl call au.com.codeconstruct.MCTP1 /au/com/codeconstruct/mctp1/interfaces/mctpi2c0 au.com.codeconstruct.MCTP.BusOwner1 SetupEndpoint ay 1 0x40
 yisb 18 1 "/au/com/codeconstruct/mctp1/networks/1/endpoints/18" false</pre><br>Note: Please check the platform information for the correct I2C bus and physical address.</td>
  </tr>
  <tr>
    <td>6</td>
    <td>Repeat Steps 1–5 for the I/O device interface (including PCIe devices where MCTP/PLDM management is supported).</td>
    <td>1. I/O device interface MCTP transport and control messaging are verified<br>2. Outputs align with expected bus and endpoint configuration</td>
  </tr>
</table>

<a id="mctp_test_case_003"></a>
## MCTP_Test_Case_003

#### Objective
Verify that MCTP communication uses I3C or PCIe VDM binding at SBMR Level M4 (SMBus/I2C only as fallback for legacy devices).

**Verified SBMR Rule ID**
- M4_SB_1
- M4_IO_3

#### Pre-requisites
- Platform claims SBMR Level M4
- Check the platform I2C/I3C/PCIe topology used for MCTP on both side-band and I/O device interfaces.
Note: See [Appendix C](#appendix_c_mctp_example) for an example walk-through.

#### Test Cases
<table>
  <tr>
    <td>Steps</td>
    <td>Description</td>
    <td>Expected Result</td>
  </tr>
  <tr>
    <td>1</td>
    <td>Verify MCTP over I3C binding.<br><pre><code>mctp link</code></pre></td>
    <td>1. MCTP link indicates I3C or PCIe VDM transport (I2C only as fallback for legacy devices)<br>Example output (I3C):<br><pre>dev mctpi3c0 index 1 address none net 1 mtu 68 up</pre></td>
  </tr>
  <tr>
    <td>2</td>
    <td>Repeat Step 1 for the I/O device interface MCTP link.</td>
    <td>1. I/O device interface MCTP link indicates I3C or PCIe VDM transport; I2C only when required for legacy devices</td>
  </tr>
</table>

<a id="pldm_test_case_001"></a>
## PLDM_Test_Case_001

#### Objective
Verify that PLDM is actively used on the BMC to support platform-level data models and platform functions for the side-band interface.

**Verified SBMR Rule ID**
- M3_SB_2

#### Pre-requisites
- Access to the BMC console
- `systemctl`, `busctl` utilities installed


#### Test Cases
<table>
  <tr>
    <td>Steps</td>
    <td>Description</td>
    <td>Expected Result</td>
  </tr>
  <tr>
    <td>1</td>
    <td>Verify the PLDM service is running on the BMC console.<br><pre><code>systemctl status pldmd.service</code></pre></td>
    <td>1. pldmd.service exists<br>2. Service state shows: <b>Active: active (running)</b><br>Example output:<br><pre>Active: active (running)</pre></td>
  </tr>
  <tr>
    <td>2</td>
    <td>Verify the PLDM D-Bus service is registered.<br><pre><code>busctl list | grep -i pldm</code></pre></td>
    <td>1. A PLDM D-Bus service is present, for example: <b>xyz.openbmc_project.PLDM</b><br>Example output:<br><pre>xyz.openbmc_project.PLDM</pre></td>
  </tr>
  <tr>
    <td>3</td>
    <td>Verify PLDM exposes a platform object model.<br><pre><code>busctl tree xyz.openbmc_project.PLDM</code></pre></td>
    <td>1. The object tree is <b>non-empty</b><br>2. One or more PLDM-related object paths are listed<br>3. Object paths represent <b>platform-level entities</b> (termini, devices, or platform objects)<br>Example output:<br><pre>~# busctl tree xyz.openbmc_project.PLDM
`- /xyz
  `- /xyz/openbmc_project
    |- /xyz/openbmc_project/control
    | `- /xyz/openbmc_project/control/system
    |   `- /xyz/openbmc_project/control/system/ProcessorModule_Effecter_1
    |- /xyz/openbmc_project/file
    | `- /xyz/openbmc_project/file/telemetry
    |- /xyz/openbmc_project/inventory
    | `- /xyz/openbmc_project/inventory/system
    |   `- /xyz/openbmc_project/inventory/system/board
    |     `- /xyz/openbmc_project/inventory/system/board/ProcessorModule
    |       |- /xyz/openbmc_project/inventory/system/board/ProcessorModule/ProcessorModule_CoreTemp
    |       `- /xyz/openbmc_project/inventory/system/board/ProcessorModule/ProcessorModule_FileSize
    |- /xyz/openbmc_project/pldm
    |- /xyz/openbmc_project/sensors
    | |- /xyz/openbmc_project/sensors/byte
    | | `- /xyz/openbmc_project/sensors/byte/ProcessorModule_FileSize
    | `- /xyz/openbmc_project/sensors/temperature
    |   `- /xyz/openbmc_project/sensors/temperature/ProcessorModule_CoreTemp</pre></td>
  </tr>
  <tr>
    <td>4</td>
    <td>Verify PLDM objects expose platform-level interfaces.<br><pre><code>busctl introspect xyz.openbmc_project.PLDM &lt;object-path&gt;</code></pre></td>
    <td>1. One or more interfaces related to <b>platform management</b> are present<br>2. Interfaces expose properties or methods corresponding to platform-level data models (for example inventory, platform descriptors, parameters, or events)<br>Example output:<br><pre>~# busctl introspect xyz.openbmc_project.PLDM /xyz/openbmc_project/sensors/temperature/ProcessorModule_CoreTemp
NAME                                                  TYPE      SIGNATURE RESULT/VALUE FLAGS
org.freedesktop.DBus.Introspectable                   interface -         -            -
org.freedesktop.DBus.Peer                             interface -         -            -
org.freedesktop.DBus.Properties                       interface -         -            -</pre></td>
  </tr>
</table>

<a id="pldm_test_case_002"></a>
## PLDM_Test_Case_002

#### Objective
Verify that PLDM messages are carried using the PLDM-over-MCTP binding, ensuring that PLDM is not transported using proprietary or non-standard encapsulation.

**Verified SBMR Rule ID**
- M3_SB_4

#### Pre-requisites
- M3_SB_2 is compliant (PLDM is present and exposes platform-level data models)
- M3_SB_3 is compliant (MCTP transport is implemented and active)

#### Test Cases
<table>
  <tr>
    <td>Steps</td>
    <td>Description</td>
    <td>Expected Result</td>
  </tr>
  <tr>
    <td>1</td>
    <td>Verify PLDM is layered on top of the MCTP transport.<br><pre><code>systemctl show pldmd.service | grep -E "After=|Requires=|Wants="</code></pre></td>
    <td>1. Output shows ordering or dependency on MCTP-related units (for example <b>mctpd.service</b>, <b>mctp.target</b>, or <b>mctp-local.target</b>)<br>2. Confirms PLDM operates over the MCTP transport layer<br>Example output:<br><pre>After=mctpd.service mctp.target</pre></td>
  </tr>
  <tr>
    <td>2</td>
    <td>Verify PLDM base commands are supported.<br><pre><code>pldmtool base GetTID -m 18</code></pre></td>
    <td>1. Command completes successfully<br>2. Output returns a valid TID value<br>Example output:<br><pre>{
    "Response": 1
}</pre></td>
  </tr>
  <tr>
    <td>3</td>
    <td>Set the PLDM terminus ID.<br><pre><code>pldmtool base SetTID -m 18 -t 1</code></pre></td>
    <td>1. Command completes successfully<br>2. Completion code indicates success<br>Example output:<br><pre>{
    "completionCode": 0
}</pre></td>
  </tr>
  <tr>
    <td>4</td>
    <td>Run additional PLDM platform commands in <b><a href="#appendix_b_pldm_commands">Appendix B</a></b> (for example PDR reads) to validate PLDM support.</td>
    <td>1. Commands complete successfully<br>2. Outputs show PLDM platform commands are supported by the target</td>
  </tr>
</table>

<a id="appendix_a_pldm_args"></a>
# Appendix A: Get MCTP Endpoint ID for PLDM command arguments

Note: The example results below are for reference and may vary depending on the system.

#### Determine `-m <eid>` (MCTP Endpoint ID)

**Command**
```sh
mctp route
```

**Example Result**
```
eid min 18 max 18 net 1 dev mctpi2c0
```

**Notes**
- Use the endpoint EID that corresponds to your target device (for example `18` in the route output).

<a id="appendix_b_pldm_commands"></a>
# Appendix B: PLDM command reference
Note: The example results below are for reference and may vary depending on the system.

PLDM tool commands from SBMR Section D.4.

#### Determine sensor/effecter IDs for `-i <id>`

**Command**
```sh
pldmtool platform GetPDR -m <eid> -d 0
```

**Example Result**
```
{
    "recordHandle": 1,
    "PDRType": "Numeric Sensor PDR",
    "sensorID": 2
}
```

**Notes**
- Use `sensorID` for sensor commands and `effecterID` for effecter commands (when present).

#### Determine `-r <rearm>` (rearm behavior for sensor reads)

**Command**
```sh
pldmtool platform GetSensorReading --help
```

**Command**
```sh
pldmtool platform GetStateSensorReadings --help
```

**Notes**
- Use these help outputs to confirm the meaning and valid range for `-r`.
- When you do not need to re-arm event state, use `-r 0` as a safe default.

**Command**
```sh
pldmtool platform GetSensorReading -m 18 -i 2 -r 0
```

**Example Result**
```
{
    "sensorDataSize": "uint32",
    "sensorOperationalState": "Sensor Enabled",
    "presentReading": 28
}
```

**Command**
```sh
pldmtool platform GetStateSensorReadings -m 18 -i 3 -r 0
```

**Example Result**
```
{
    "compositeSensorCount": 1,
    "sensorOpState[0]": "Sensor Enabled",
    "presentState[0]": "Sensor Normal"
}
```

**Command**
```sh
pldmtool platform GetStateEffecterStates -m 18 -i 1
```

**Example Result**
```
{
    "compositeEffecterCount": 1,
    "effecterOpState[0]": "Effecter Enabled No Update Pending",
    "presentState[0]": 0
}
```

**Command**
```sh
pldmtool platform SetStateEffecterStates -m 18 -i 1 -c 1 -d 0 1
```

**Example Result**
```
{
    "Response": "SUCCESS"
}
```

#### Table 16: PLDM FRU Commands

**Command**
```sh
pldmtool fru GetFruRecordTableMetadata -m 18
```

**Example Result**
```
{
    "FRUDATAMajorVersion": 1,
    "FRUTableLength": 54,
    "Total number of records in table": 1
}
```

**Command**
```sh
pldmtool fru GetFruRecordTable -m 18
```

**Example Result**
```
[
    [
        {
            "FRU Record Type": "General(1)"
        }
    ]
]
```

#### Table 18: PLDM PDR Commands

**Command**
```sh
pldmtool platform GetPDR -m 18 -a
```

**Example Result**
```
[
    {
        "nextRecordHandle": 2,
        "responseCount": 105,
        "recordHandle": 1,
        "PDRHeaderVersion": 1,
        "PDRType": "Numeric Sensor PDR",
        "sensorID": 2,
        "entityType": "[Physical] Processor",
        "sensorAuxiliaryNamesPDR": true,
        "sensorDataSize": 4,
        "resolution": 1.0,
        "updateInterval": 1.0,
        "warningHigh": 90,
        "criticalHigh": 100
    },
    ...
]
```

<a id="appendix_c_mctp_example"></a>
# Appendix C: MCTP example walk-through
This example is included only to make the commands easier to follow; expect service names, object paths, and outputs to vary by system configuration.

**Command**
```sh
busctl list | grep -i mctp
```

**Expected Result**
```
au.com.codeconstruct.MCTP1   294 mctpd  root  :1.4  mctpd.service
```

**Command**
```sh
busctl tree au.com.codeconstruct.MCTP1
```

**Expected Result**
```
/au/com/codeconstruct/mctp1
|- /au/com/codeconstruct/mctp1/interfaces
|  |- /au/com/codeconstruct/mctp1/interfaces/lo
|  `- /au/com/codeconstruct/mctp1/interfaces/mctpi2c0
`- /au/com/codeconstruct/mctp1/networks/1/endpoints/8
`- /au/com/codeconstruct/mctp1/networks/1/endpoints/18
```

**Command**
```sh
mctp link
```

**Expected Result**
```
dev mctpi2c0 index 6 address none net 1 mtu 68 up
```

**Command**
```sh
mctp route
```

**Expected Result**
```
eid min 18 max 18 net 1 dev mctpi2c0
```

**Command**
```sh
busctl introspect au.com.codeconstruct.MCTP1 /au/com/codeconstruct/mctp1/networks/1/endpoints/18
```

**Expected Result**
```
au.com.codeconstruct.MCTP.Endpoint1 interface - - -
```

**Command**
```sh
busctl introspect au.com.codeconstruct.MCTP1 /au/com/codeconstruct/mctp1/interfaces/mctpi2c0
```

**Expected Result**
```
au.com.codeconstruct.MCTP.Interface1 interface - - -
```

**Command (optional)**
```sh
busctl call au.com.codeconstruct.MCTP1 /au/com/codeconstruct/mctp1/interfaces/mctpi2c0 \
  au.com.codeconstruct.MCTP.BusOwner1 SetupEndpoint ay 1 0x40
```

**Expected Result**
- Returns endpoint details when setup succeeds; may fail if the endpoint does not respond
```
yisb 18 1 "/au/com/codeconstruct/mctp1/networks/1/endpoints/18" false
```

--------------

*Copyright (c) 2026, Arm Limited and Contributors. All rights reserved.*
