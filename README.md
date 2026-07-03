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

## Execution modes
SBMR-ACS can be executed in the below modes

| Modes  | Test type   | Description                                                                                                                                                                                                            | Remarks                                                                                                                                                                             |
| ------ |:-----------:|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Mode 1 | Out-of-Band | OOB tests: SBMR-ACS may be downloaded and run on any external host machine (x86, AArch64) with Linux<br>Note: Pre-requisites mentioned in the README must be installed.                                     | Note: For Ubuntu, automated scripts to install the pre-requisites is supported in the package.<br>For other Distros, this must be done manually.                                    |
| Mode 2 | In-Band     | In-Band tests: Download and run SBMR ACS on any Linux distro (based on AArch64) installed on the system-under-test.<br>Note: Pre-requisites must be installed.                                                 | Please Note: For Ubuntu, automated scripts to install the pre-requisites is supported in the package.<br>For other Distros, this must be done manually.                             |
| Mode 3 | In-Band     | In-Band tests: Run the SBMR ACS in-built into the SystemReady-band ACS image through a simple automation on the ACS Linux<br>For more details, please see: https://github.com/ARM-software/arm-systemready/blob/main/SystemReady-band/README.md. | Pre-built SystemReady-band ACS image inbuilt with SBMR ACS can be found at [SystemReady-band Pre-built images](https://github.com/ARM-software/arm-systemready/tree/main/SystemReady-band/prebuilt_images).<br><br> Choose the grub option "Linux boot" to run the in-band tests as part of ACS automation or refer the [SystemReady Band Execution Enviroment and Configuration User Guide](https://github.com/ARM-software/arm-systemready/blob/main/docs/SystemReady_Execution_Enviroment_and_Config_Guide.md) to modify acs_run_config.ini to run SBMR in-band tests specifically.  |

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
### Configure

**Note: For In-band testing, this step may be skipped. Go directly to [Running SBMR-ACS in-band (IB) tests](#running-sbmr-acs-in-bandib-tests).**

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

After following [configure](#configure) and [steps-for-installation-of-pre-requisites](#steps-for-installation-of-pre-requisites) steps on an external host machine.
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


### Some useful commands:

- Execute SBMR test script with Debug Mode (with -d):

  ```
  ./run-sbmr-acs.sh oob -d
  ```

- Execute SBMR test script for an explicit historical level:

  ```
  ./run-sbmr-acs.sh oob --level M1
  ./run-sbmr-acs.sh linux -l M2.1
  ```

- Execute SBMR future requirement test cases:

  ```
  ./run-sbmr-acs.sh oob --level FR
  ```

- Generate SBMR OOB test cases manually:

  ```
  $ ./bin/generate_level_argumentfile.py --suite oob --level M3 --output logs/sbmr-acs-oob-M3.args
  ```

- Execute SBMR OOB test cases with a generated argument file:

  ```
  $ robot --argumentfile config --argumentfile logs/sbmr-acs-oob-M3.args .
  ```

- Execute SBMR IB test cases with a generated argument file:

  ```
  $ robot --argumentfile config --argumentfile logs/sbmr-acs-linux-M3.args ./redfish ./ipmi ./host
  ```

- Execute/skip single or multiple test cases using --include and --exclude:

  ```
  $ robot --argumentfile config --include TEST_TAG1 --exclude TEST_TAG2 .
  ```

  Example:

  ```
  $ robot --argumentfile config \
      --include M2_OOB_1_Redfish_Host_PowerOn \
      --include M2_OOB_1_Redfish_Host_PowerOff \
      --exclude M2_OOB_1_Redfish_Host_ForceRestart .
  ```

  **Note:** Separate argument files can be used for include and exclude tags. The file content should contain the required Robot options, for example --include entries in one file and --exclude entries in another file:

  ```
  $ robot --argumentfile config --argumentfile include.args --argumentfile exclude.args .
  ```

## Guidance on SBMR Compliance for Arm SystemReady Requirements

For Arm SystemReady band compliance on physical servers, Arm SystemReady Requirements SRS v3.1.1 mandates SBMR v2.1 or later, with minimum SBMR level `M2.1`.

SBMR-ACS supports the following execution modes for this requirement:

- Out-of-band testing: run Mode 1 from [Execution modes](#execution-modes) with `--level M2.1`.
- In-band testing: run Mode 2 directly on the system-under-test with `--level M2.1`, or run Mode 3 through the SystemReady-band ACS image.

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
