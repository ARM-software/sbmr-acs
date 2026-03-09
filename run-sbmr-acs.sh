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

OUTPUT_DIR=./logs
CONSOLE_LOG=$OUTPUT_DIR/console.log
DEBUG=""
INTERFACE=""

# Auto-discover Redfish IDs if BMC creds are in config
function discover_redfish_ids() {
    function get_config_value() {
        local key="${1}"

        awk -F: -v k="${key}" '$0 ~ "^-v "k":" {print $2; exit}' config
    }

    function get_redfish_id() {
        curl -sk --max-time 10 --retry 2 --retry-delay 1 -u "$2:$3" \
            "https://$1/redfish/v1/$4" \
            | grep -o "/redfish/v1/$4/[^\"]*" | head -n1 | awk -F/ '{print $NF}'
    }

    local bmc_host bmc_user bmc_pass discover_failed=0 item coll key value
    bmc_host=$(get_config_value "BMC_HOST")
    bmc_user=$(get_config_value "BMC_USERNAME")
    bmc_pass=$(get_config_value "BMC_PASSWORD")
    if [ -n "${bmc_host}" ] && [ -n "${bmc_user}" ] && [ -n "${bmc_pass}" ] ; then
        for item in "Managers:BMC_ID" "Systems:SYSTEM_ID" "Chassis:CHASSIS_ID" ; do
            coll="${item%%:*}"
            key="${item##*:}"
            value=$(get_redfish_id "${bmc_host}" "${bmc_user}" "${bmc_pass}" "${coll}")
            if [ -n "${value}" ] && grep -q "^-v ${key}:" config ; then
                sed -i "s/^-v ${key}:.*/-v ${key}:${value}/" config
            else
                [ -z "${value}" ] && discover_failed=1
            fi
        done
    else
        discover_failed=1
    fi
    if [ "${discover_failed}" -eq 1 ] ; then
        echo -e "Warning: Add correct BMC information in config file to run SBMR-ACS out-of-band test.\n"
    fi
}

# Save config file in logs
if [ ! -d "$OUTPUT_DIR" ]; then
  mkdir logs
fi
cp ./config logs

# Delete previous result and capture new console output
if [ -f "$CONSOLE_LOG" ]; then
  rm $CONSOLE_LOG
fi

# Capture Test Interface
INTERFACE=$1
shift

# Capture debug mode
while getopts ":d" opt; do
  case $opt in
     d)
       echo "[Debug Mode]"
       DEBUG="--loglevel DEBUG -b debug.log"
  esac
done

# Execute RobotFramework Testing
echo ""
case "$INTERFACE" in
  'oob')
    discover_redfish_ids
    echo "===== Running sbmr-acs-oob test suite ====="
    robot --argumentfile config --argumentfile test_lists/sbmr-acs-oob $DEBUG \
      --name "SBMR-ACS OOB" . | tee $CONSOLE_LOG
    ;;
  'linux')
    echo "===== Running sbmr-acs-linux test suite ====="
    robot --argumentfile config --argumentfile test_lists/sbmr-acs-linux $DEBUG \
      --name "SBMR-ACS IB" ./redfish ./ipmi ./host | tee $CONSOLE_LOG
    ;;
  *)
    echo "Please specific test suite list : oob | linux and parameter '-d' for debug mode"
    echo -e "Example:\n\t ./run-sbmr-acs oob\n\t ./run-sbmr-acs oob -d\n\t"
    ;;
esac
