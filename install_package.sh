#!/bin/bash

# Copyright (c) 2023, Arm Limited or its affiliates. All rights reserved.
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

GREEN="\e[32m"
ENDCOLOR="\e[0m"

# Update apt package list
echo -e "${GREEN}==== Update apt list ====${ENDCOLOR}"
sudo apt-get update

# Install ubuntu package
echo -e "${GREEN}==== Install sbmr-acs ubuntu utilities ====${ENDCOLOR}"
echo -e "${GREEN} > Packages to install : python3 python3-pip python-is-python3 git ipmitool expect dmidecode${ENDCOLOR}"
sudo apt-get install python3 python3-pip python-is-python3 git ipmitool dmidecode expect

# Install python package
echo -e "${GREEN}==== Install sbmr-acs python packages ====${ENDCOLOR}"
echo -e "${GREEN} > Python packages in requirements.txt${ENDCOLOR}"
pip install -r requirements.txt

echo -e -n "${GREEN}Install network-manager, redfish-finder and dmidecode for inband testing [y/n] ${ENDCOLOR}"
read response
case "$response" in
  [yY])
    echo -e "${GREEN} > Install network-manager ... ${ENDCOLOR}"
    # Install nmcli utilities
    sudo apt-get install network-manager

    # Install redfish-finder
    echo -e "${GREEN} > Install redfish-finder ... ${ENDCOLOR}"
    git clone https://github.com/nhorman/redfish-finder
    sudo cp redfish-finder/redfish-finder /usr/bin/

    # Install latest dmidecode for support SMBIOS type 42 USB v2
    echo -e "${GREEN} > Build & Install dmidecode ... ${ENDCOLOR}"
    git clone https://git.savannah.gnu.org/git/dmidecode.git/
    pushd dmidecode
    make
    sudo cp dmidecode /usr/sbin/
    popd
    ;;
  *)
    echo -e "${GREEN} > Skip. ${ENDCOLOR}"
    ;;
esac

echo -e "${GREEN}==== Install Completed ====${ENDCOLOR}"
