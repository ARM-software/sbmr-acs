## Server Base Manageability Requirements
Server Base Manageability Requirements (SBMR) provides a path to establish a common foundation for server management on SBSA-compliant Arm AArch64 servers where common capabilities are standardized and differentiation truly valuable to the
end-users is built on top. Redfish, PLDM, and MCTP specifications have been chosen to ease the adoption of Arm, by aligning
the AArch64 server ecosystem to where the existing enterprise server market is moving to.

For details, refer to [Arm Server Base Manageability Requirements](https://developer.arm.com/documentation/den0069/latest/)

## SBMR-Architecture Compliance Suite
SBMR Architecture Compliance Suite (ACS) checks for compliance against the [Arm Server Base Manageability Requirements](https://developer.arm.com/documentation/den0069/latest/) specification. The tests uses [Robot automation framework](https://robotframework.org/) and targets IPMI, Redfish, Host Interface and Redfish HI interfaces. The multitude of tests are adapted from [openbmc-test-automation](https://github.com/openbmc/openbmc-test-automation).




## Release details
 - Code Quality: v0.5 Alpha
 - The tests are written for version 2.0 of the SBMR specification.
 - The compliance suite is not a substitute for design verification.
 - To review the SBMR ACS logs, Arm licensees can contact Arm directly through their partner managers.

## Execution modes
SBMR-ACS can be executed in the below modes

| Modes  | Test type   | Description                                                                                                                                                                                                            | Remarks                                                                                                                                                                             |
| ------ |:-----------:|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Mode 1 | Out-of-Band | OOB tests: SBMR-ACS may be downloaded and run on any external host machine (x86, AArch64) with Linux<br>Note: Pre-requisites mentioned in the README must be installed.                                     | Note: For Ubuntu, automated scripts to install the pre-requisites is supported in the package.<br>For other Distros, this must be done manually.                                    |
| Mode 2 | In-Band     | In-Band tests: Download and run SBMR ACS on any Linux distro (based on AArch64) installed on the system-under-test.<br>Note: Pre-requisites must be installed.                                                 | Please Note: For Ubuntu, automated scripts to install the pre-requisites is supported in the package.<br>For other Distros, this must be done manually.                             |
| Mode 3 | In-Band     | In-Band tests: Run the SBMR ACS in-built into the SystemReady SR ACS image through a simple automation on the ACS Linux<br>For more details, please see: https://github.com/ARM-software/arm-systemready/tree/main/SR. | Pre-built SR ACS image inbuilt with SBMR ACS is provided.<br>Choose the grub option "Server Base Manageability Requirements (SBMR) ACS In-band Tests (optional)" to run the tests.  |

## Steps for Installation of Pre-requisites
- Clone the SBMR-ACS GitHub repository
  ```
  git clone https://github.com/ARM-software/sbmr-acs.git
  cd sbmr-acs
  ```

- You can automatically install ubuntu utility & python package by executing below script (ubuntu 20.04).

  ```
  $ ./install_package.sh
  ```

  In-band interface testing needs *sudo* privileges for ipmitool and dmidecode.
  Please switch to root role and install packages as below steps. Also, switching to root role to execute sbmr-acs in-band testing.

  ```
  $ sudo su
  $ ./install_package.sh
  ```

  Note : if *robot* command not found after pip install robotframework. Please create a soft link in /usr/bin
  ```
  $ sudo ln -s ~/.local/bin/robot /usr/bin/robot
  ```

- Or you can manually install ubuntu utility & python packages by following below steps.

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

Download the sbmr-acs repository and install pre-requisites as mentioned in [steps-for-installation-of-pre-requisites](#steps-for-installation-of-pre-requisites) section.
Before running the test suite, setup for configurations in the [*config*](config) file as discussed below, which is required for OOB testing. <br>Note: For In-band testing, this step may be skipped.

 * `BMC Information`
 * `Host Information`
 * `SOL Information`
 * `Self-Declaration Information`

For BMC configuration, `BMC ip address`, `BMC username`, and `BMC password` needs to be set.
Also, `Redfish instance` name needs to be set as per your system. `*CHASSIS_ID*` is main chassis that in charge of power status.

For Host configuration, Host OS `login prompt`, Host OS `username` and Host OS `password` needs to be set.

For Serial over LAN (SOL) configuration, SBMR-ACS will verify SOL capability and SOL methods can be IPMI SOL and SSH-based SOL. Default method is via IPMI SOL (Don't need to change SOL configuration). You may also change to SSH-based SOL by setting `SOL_TYPE` to ssh and `SOL_SSH_PORT` (default port 22). Besides, if extra commands are needed to start SOL in SSH, `SOL_SSH_CMD` may be set.

For self-declaration information, sbmr-acs has a limitation to verify some SBMR-defined interfaces. Vendor needs to declare if system support the SBMR compliant interfaces by changing corresponding variable.

**Robot Command Line**

After following [configure](#configure) and [steps-for-installation-of-pre-requisites](#steps-for-installation-of-pre-requisites) steps on an external host machine.
Run run-sbmr-acs.sh with "oob" argument.

  ```
  ./run-sbmr-acs.sh oob
  ```

The logs for the OOB tests will be stored in the 'logs' directory, which is located in the current working directory.

### Running SBMR-ACS in-band(IB) tests:

After following [configure](#configure) and [steps-for-installation-of-pre-requisites](#steps-for-installation-of-pre-requisites) steps on any Linux distro (based on AArch64) installed on the system-under-test. Run run-sbmr-acs.sh with "linux" argument.

  ```
  ./run-sbmr-acs.sh linux
  ```

The logs for the IB tests will be stored in the 'logs' directory, which is located in the current working directory.


### Some useful commands:

- Execute SBMR test script with Debug Mode (with -d):

  ```
  ./run-sbmr-acs.sh oob -d
  ```

- Execute SBMR OOB test cases:

  ```
  $ robot --argumentfile config --argumentfile test_lists/sbmr-acs-oob .
  ```

- Execute SBMR IB test cases:

  ```
  $ robot --argumentfile config --argumentfile test_lists/sbmr-acs-linux ./redfish ./ipmi ./host
  ```

- Execute single/multiple test case:

  ```
  $ robot --argumentfile config --include TEST_TAG1 --include TEST_TAG2 .
  ```

- Skip single/multiple test case:

  ```
  $ robot --argumentfile config --exclude TEST_TAG1 --exclude TEST_TAG2 .
  ```

## Test Layout
Test Layout in sbmr-acs repository can be classified as follows:

`extended/`: Contains test cases for boot testing, etc.

`bin/`: Contains application for library, test tool and test cases.

`data/`: Contains data information for library, test tool, and test cases.

`lib/`: Contains python library for dealing with complex test case.

`test_list/`: Contains the argument files used for grouping test cases (e.g sbmr-acs-oob, sbmr-acs-linux.)

`ipmi/`: Contains test cases for ipmi in-band & out-of-band interface.

`redfish/dmtf_tools/`: Contains test cases for DMTF Redfish Validation Tool.

`redfish/host_interface/`: Contains test cases for Redfish host interface.

`host/`: Contains test cases for host interface.

`config`: Parameters for BMC Management, such as BMC IP address, BMC username and etc.

## License
SBMR ACS is distributed under Apache v2.0 License.

## Feedback, contributions, and support
 - For feedback, use the GitHub Issue Tracker that is associated with this repository.
 - For support, send an email to "support-systemready-acs@arm.com" with details.
 - Arm licensees may contact Arm directly through their partner managers.
 - Arm welcomes code contributions through GitHub pull requests. See GitHub documentation on how to raise pull requests.

--------------

*Copyright (c) 2023, Arm Limited and Contributors. All rights reserved.*
