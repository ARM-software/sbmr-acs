## Server Base Manageability Requirements
Server Base Manageability Requirements (SBMR) provides a path to establish a common foundation for server management on SBSA-compliant Arm AArch64 servers where common capabilities are standardized and differentiation truly valuable to the
end-users is built on top. Redfish, PLDM, and MCTP specifications have been chosen to ease the adoption of Arm, by aligning
the AArch64 server ecosystem to where the existing enterprise server market is moving to.

For details, refer to [Arm Server Base Manageability Requirements](https://developer.arm.com/documentation/den0069/latest/)

## SBMR-Architecture Compliance Suite
SBMR Architecture Compliance Suite (ACS) checks for compliance against the [Arm Server Base Manageability Requirements](https://developer.arm.com/documentation/den0069/latest/) specification. The tests uses [Robot automation framework](https://robotframework.org/) and targets IPMI, Redfish, Host Interface and Redfish HI interfaces. The multitude of tests are adapted from [openbmc-test-automation](https://github.com/openbmc/openbmc-test-automation).




## Release details
 - **Code Quality:** ALPHA
 - **Latest tag version:** `v26.06_SBMR_3.0.0`
 - **Specification coverage:** [SBMR 3.0 ALP2](https://developer.arm.com/documentation/den0069/e/?lang=en)
 - The tests are written for version 3.0 ALP2 of the SBMR specification, covering out-of-band, in-band interfaces and guidance for manually testing side-band interfaces.
 - For the detailed testcase checklist, see [SBMR Testcase Checklist](docs/arm_sbmr_testcase_checklist.rst).
 - The compliance suite is not a substitute for design verification.
 - To review the SBMR ACS logs, Arm licensees can contact Arm directly through their partner managers.

## Test coverage and self-declarations

SBMR-ACS provides automated test coverage for in-band and out-of-band requirements, including supported side-band checks executed through the out-of-band suite. The available automated and manual test methods are described in [Execution modes](#execution-modes).

Some SBMR requirements are not currently covered by automated or manual tests. Partners must independently verify compliance with these requirements and set the corresponding self-declaration variables to `1` in the [`config`](config) file. Variables must remain set to `0` for requirements that have not been verified or are not supported.

SBMR-ACS combines automated test results with partner-provided self-declarations to generate a complete compliance report for the applicable SBMR rules.

## Execution modes
SBMR-ACS can be executed in the following modes:

| Mode   | Test type                         | Execution method | Description | Remarks |
| ------ | --------------------------------- | :--------------: | ----------- | ------- |
| Mode 1 | Out-of-Band and Side-Band | Automated | Run SBMR-ACS on an external Linux host. Both x86 and AArch64 hosts are supported. Automated MCTP and PLDM side-band tests are included in the OOB suite through `mctp/test_mctp_interface.robot` and `mctp/test_pldm_interface.robot`. | Ubuntu users can install the prerequisites using the provided script; users of other Linux distributions must install them manually. For side-band automation, configure the BMC SSH connection and `MCTP_SB_INTERFACES`. If side-band automation fails, follow the [Side-band manual testing guide](docs/sideband_manual_testing.md). |
| Mode 2 | In-Band—direct                    | Automated | Download and run the in-band tests directly on an AArch64 Linux distribution installed on the system under test. | Install the prerequisites listed in this README. Ubuntu users can use the provided installation script; users of other Linux distributions must install them manually. |
|        | In-Band—SystemReady image         | Automated | Run the copy of SBMR-ACS built into the [SystemReady-band ACS image](https://github.com/ARM-software/arm-systemready/blob/main/SystemReady-band/README.md) through automation on ACS Linux. | Pre-built images containing SBMR-ACS are available from the [SystemReady-band pre-built images](https://github.com/ARM-software/arm-systemready/tree/main/SystemReady-band/prebuilt_images) directory. Select **SystemReady band ACS (Automation)** from the GRUB menu to run ACS automation. To run only the SBMR in-band tests, follow the [SystemReady-band execution environment and configuration user guide](https://github.com/ARM-software/arm-systemready/blob/main/docs/SystemReady_Execution_Environment_and_Config_Guide.md) and update `acs_run_config.ini`.|


## Steps for Installation of Pre-requisites
- Clone the SBMR-ACS GitHub repository
  ```
  git clone https://github.com/ARM-software/sbmr-acs.git
  cd sbmr-acs
  ```

### Automatic Installation of Pre-requisites

- You can automatically install ubuntu utility & python package by executing below script (ubuntu 20.04) or later.

  ```
  $ ./install_package.sh
  ```

  In-band interface testing needs *sudo* privileges for ipmitool and dmidecode.
  Please switch to root role and install packages as below steps. Also, switching to root role to execute sbmr-acs in-band testing.

  ```
  $ sudo su
  $ ./install_package.sh
  ```

  Note: After `install_package.sh` completes, check whether the *robot* command is available:
  ```
  $ robot --version
  ```

  If the command is not found, create a soft link in /usr/bin:
  ```
  $ sudo ln -s ~/.local/bin/robot /usr/bin/robot
  ```

### Manual Installation of Pre-requisites

**ONLY** follow the manual installation steps if `./install_package.sh` fails to complete and reports an error while installing any component.

- Manually install ubuntu utility & python packages by following below steps.

  - [Robot Framework Install Instructions](https://github.com/robotframework/robotframework/blob/master/INSTALL.rst)

  - Miscellaneous Packages required to be installed for Automation. Install the packages and it's dependencies via `pip`

    If using Python 3.x, use the corresponding `pip3` to install packages. Note: Older Python 2.x is not actively supported.



    REST base packages:

    ```
    $ pip install -U requests
    $ pip install -U robotframework-requests
    $ pip install -U robotframework-httplibrary
    ```

    Python redfish library packages: For more detailed instructions see [python-redfish-library](https://github.com/DMTF/python-redfish-library)

    ```
    $ pip install redfish
    ```

    SSH and SCP base packages: For more detailed installation instructions see [robotframework-sshlibrary](https://pypi.python.org/pypi/robotframework-sshlibrary)

    ```
    $ pip install robotframework-sshlibrary
    $ pip install robotframework-scplibrary
    ```

    Installing requirement dependencies:

    ```
    $ pip install -r requirements.txt
    ```

    Installing expect (Ubuntu example):

    ```
    $ sudo apt-get install expect
    ```

    Installing ipmitool (Ubuntu example):

    ```
    $ sudo apt-get install ipmitool
    ```

  - For in-band interface testing, following additional  installations are required.
    * [redfish-finder](https://github.com/nhorman/redfish-finder) to setup Redfish Host Interface networking configure

      ```
      $ git clone https://github.com/nhorman/redfish-finder
      $ sudo cp redfish-finder/redfish-finder /usr/bin/
      ```

    * Latest [dmidecode](https://git.savannah.gnu.org/git/dmidecode.git/) to support DSP0270 v1.3.0 USB/PCIe v2 device type

      ```
      $ git clone https://git.savannah.gnu.org/git/dmidecode.git/
      $ cd dmidecode
      $ make & make install
      ```

      If you don't need USB/PCIe v2 device type, then install package directly from apt-get (Ubuntu example)

      ```
      $ sudo apt-get install dmidecode
      ```

    * *nmcli* utility to build networkmanager configurations (Ubuntu example).

      ```
      $ sudo apt-get install network-manager
      ```

## Running SBMR-ACS tests

**Note: For in-band testing, the configuration step below is not required. Go directly to [Running SBMR-ACS in-band (IB) tests](#running-sbmr-acs-in-bandib-tests).**

### Configure SBMR-ACS Out-of-Band (OOB) tests:

Download the sbmr-acs repository and install pre-requisites as mentioned in [steps-for-installation-of-pre-requisites](#steps-for-installation-of-pre-requisites) section.
Before running the test suite, set up the configuration values in the [*config*](config) file as discussed below. This is required for OOB testing.

 * `BMC Information`
 * `Host Information`
 * `MCTP Interface Role Mapping`
 * `SOL Information`
 * `Virtual Media Information`
 * `Self-Declaration Information`

For BMC configuration, `BMC_HOST`, `BMC_USERNAME`, and `BMC_PASSWORD` must be set.
For OOB runs started with `run-sbmr-acs.sh`, Redfish instance IDs are auto-discovered by default. If needed, uncomment `BMC_ID`, `SYSTEM_ID`, or `CHASSIS_ID` in [*config*](config) to override auto-discovery. `CHASSIS_ID` should refer to the main chassis that is in charge of power status.

For Host configuration, Host OS `SOL_LOGIN_OUTPUT`, `SOL_LOGIN_USERNAME`, and `SOL_LOGIN_PASSWORD` must be set. `SOL_LOGIN_OUTPUT` is the login prompt that appears when the host boots, and it helps the suite detect that the host has booted before providing credentials. Ensure that the Host OS is set as the first entry in the boot order of the system under test (SUT) for IPMI SOL test to work.

For MCTP and PLDM-over-MCTP testing, configure the Linux MCTP interfaces that connect the BMC to the server SoC and IO devices. Set `MCTP_SB_INTERFACES` for SIDE-BAND connections and `MCTP_IO_INTERFACES` for BMC-IO connections. Use the exact interface names reported by `mctp link`, separate multiple interfaces with commas, and do not assign an interface to both roles. For example:

```
-v MCTP_SB_INTERFACES:mctpi3c6
-v MCTP_IO_INTERFACES:mctpi2c1,mctpi3c1
```

For Serial over LAN (SOL) configuration, SBMR-ACS will verify SOL capability and SOL methods can be IPMI SOL and SSH-based SOL. The default method is IPMI SOL, so no SOL configuration change is required by default. To use SSH-based SOL, set `SOL_TYPE` to `ssh` and set `SOL_SSH_PORT` if a non-default SSH port is required. If extra commands are needed to start SOL over SSH, set `SOL_SSH_CMD`.

For Virtual Media configuration, update `VM_URL` to point to the OS image used for Virtual Media testing. If authentication or transfer settings are required, update the optional Virtual Media variables in [*config*](config).

For self-declaration information, SBMR-ACS has a limitation in verifying some SBMR-defined interfaces. Vendors must declare whether the system supports the corresponding SBMR-compliant interfaces by setting each applicable self-declaration variable to `1`. Leave the variable set to `0` if the interface is not supported.

### Running SBMR-ACS Out-of-Band (OOB) tests:

After following [Configure SBMR-ACS Out-of-Band (OOB) tests](#configure-sbmr-acs-out-of-band-oob-tests) and [steps-for-installation-of-pre-requisites](#steps-for-installation-of-pre-requisites) on an external host machine.
Run run-sbmr-acs.sh with "oob" argument. If no SBMR level is passed, the suite defaults to SBMR 3.0 baseline requirements (M4).

Note: If testing SBMR compliance for Arm SystemReady Requirements, see [Guidance on SBMR Compliance for Arm SystemReady Requirements](#guidance-on-sbmr-compliance-for-arm-systemready-requirements).

  ```
  ./run-sbmr-acs.sh oob
  ```

The logs for the OOB tests will be stored in the 'logs' directory, which is located in the current working directory.

### Running SBMR-ACS in-band(IB) tests:

After following [steps-for-installation-of-pre-requisites](#steps-for-installation-of-pre-requisites) steps on any Linux distro (based on AArch64) installed on the system-under-test. Run run-sbmr-acs.sh with "linux" argument. If no SBMR level is passed, the suite defaults to SBMR 3.0 baseline requirements (M4).

Note: If testing SBMR compliance for Arm SystemReady Requirements, see [Guidance on SBMR Compliance for Arm SystemReady Requirements](#guidance-on-sbmr-compliance-for-arm-systemready-requirements).

  ```
  ./run-sbmr-acs.sh linux
  ```

The logs for the IB tests will be stored in the 'logs' directory, which is located in the current working directory.


### Command-line options

| Option | Description | Example |
| ------ | ----------- | ------- |
| `-d` | Run the test suite in debug mode. | `./run-sbmr-acs.sh oob -d` |
| `-l LEVEL`<br>`--level LEVEL` | Run tests for a specific SBMR requirement level, including historical levels and future requirements. | `./run-sbmr-acs.sh oob --level M1`<br>`./run-sbmr-acs.sh linux -l M2.1`<br>`./run-sbmr-acs.sh oob --level FR` |

### Customizing test execution

| Action | Command |
| ------ | ------- |
| Generate an OOB Robot Framework argument file. | `./bin/generate_level_argumentfile.py --suite oob --level M3 --output logs/sbmr-acs-oob-M3.args` |
| Run tests using a generated argument file. |`robot --argumentfile config --argumentfile logs/sbmr-acs-oob-M3.args .`|
| Run or skip selected test cases using tags. | `robot --argumentfile config --include TEST_TAG1 --exclude TEST_TAG2 .`<br>Example: `robot --argumentfile config --include M2_OOB_1_Redfish_Host_PowerOn --include M2_OOB_1_Redfish_Host_PowerOff --exclude M2_OOB_1_Redfish_Host_ForceRestart .` |
| Use separate argument files for included and excluded tags. | `robot --argumentfile config --argumentfile include.args --argumentfile exclude.args .`<br>**Note:** The include and exclude argument files should contain the required Robot Framework `--include` and `--exclude` options. |

## Guidance on SBMR Compliance for Arm SystemReady Requirements

For Arm SystemReady band compliance on physical servers, Arm SystemReady Requirements SRS v3.1.1 mandates SBMR v2.1 or later, with minimum SBMR level `M2.1`.

SBMR-ACS supports the following execution modes for this requirement:

- Out-of-band testing: run Mode 1 from [Execution modes](#execution-modes) with `--level M2.1`.
- In-band testing: run Mode 2 directly on the system under test with `--level M2.1`, or use the SystemReady-band ACS image.

When running SBMR-ACS standalone for SystemReady band compliance, execute both out-of-band and in-band tests with the explicit SBMR level. For example:

  ```
  ./run-sbmr-acs.sh oob --level M2.1
  ./run-sbmr-acs.sh linux --level M2.1
  ```

For in-band testing through the SystemReady-band ACS image, the required SBMR level information is passed by the automation scripts and no explicit action is required.

## Additional Reading

Refer to the following documents for manual sideband testing guidance and the detailed SBMR testcase checklist:

- [Sideband Manual Testing](docs/sideband_manual_testing.md)
- [SBMR Testcase Checklist](docs/arm_sbmr_testcase_checklist.rst)

## Test Layout
Test Layout in sbmr-acs repository can be classified as follows:

`bin/`: Contains helper scripts for generating argument files, selecting versions, and validating plug-ins.

`data/`: Contains test data, variable definitions, schema lists, boot lists, and lookup tables used by the suite.

`docs/`: Contains testcase checklists and manual testing documentation.

`extended/`: Contains extended boot and keyword execution test cases.

`host/`: Contains host interface and SBMR self-declaration test cases.

`ipmi/`: Contains IPMI in-band and out-of-band test cases.

`lib/`: Contains Robot Framework resources and Python libraries used by the test cases.

`redfish/`: Contains Redfish out-of-band test cases.

`redfish/dmtf_tools/`: Contains test cases that run DMTF Redfish validation tools.

`redfish/host_interface/`: Contains Redfish Host Interface test cases.

`test_lists/`: Contains SBMR rule metadata used to generate level-specific test lists.

`tools/`: Contains Robot Framework linting rules and supporting tool configuration.

`config`: Contains runtime configuration parameters such as BMC credentials, SOL settings, Virtual Media settings, and SBMR self-declaration flags.

## License
SBMR ACS is distributed under Apache v2.0 License.

## Feedback, contributions, and support
 - For feedback, use the GitHub Issue Tracker that is associated with this repository.
 - For support, send an email to "support-systemready-acs@arm.com" with details.
 - Arm licensees may contact Arm directly through their partner managers.
 - Arm welcomes code contributions through GitHub pull requests. See GitHub documentation on how to raise pull requests.

--------------

*Copyright (c) 2023-2026, Arm Limited and Contributors. All rights reserved.*
