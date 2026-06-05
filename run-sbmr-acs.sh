#!/bin/bash

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

OUTPUT_DIR=./logs
CONSOLE_LOG=$OUTPUT_DIR/console.log
DEFAULT_LEVEL=M4
DEBUG=""
INTERFACE=""
LEVEL=$DEFAULT_LEVEL

usage() {
  echo "Please specify test suite list: oob | linux"
  echo "Usage: ./run-sbmr-acs.sh <oob|linux> [-d] [--level LEVEL|-l LEVEL]"
  echo -e "Example:\n\t ./run-sbmr-acs.sh oob\n\t ./run-sbmr-acs.sh oob -d\n\t ./run-sbmr-acs.sh oob --level M1\n\t"
}

canonical_level() {
  local requested_level
  requested_level=$(printf '%s' "$1" | tr '[:lower:]' '[:upper:]')
  case "$requested_level" in
    M1|M2|M3|M4|FR)
      printf '%s' "$requested_level"
      ;;
    M2.1)
      printf 'M2.1'
      ;;
    *)
      return 1
      ;;
  esac
}

if [ "$#" -lt 1 ]; then
  usage
  exit 1
fi

# Capture Test Interface
INTERFACE=$1
shift

while [ "$#" -gt 0 ]; do
  case "$1" in
    -d)
      echo "[Debug Mode]"
      DEBUG="--loglevel DEBUG -b debug.log"
      shift
      ;;
    -l|--level)
      if [ "$#" -lt 2 ]; then
        echo "Missing value for $1"
        usage
        exit 1
      fi
      LEVEL=$2
      shift 2
      ;;
    --level=*)
      LEVEL=${1#*=}
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown parameter: $1"
      usage
      exit 1
      ;;
  esac
done

case "$INTERFACE" in
  oob|linux)
    ;;
  *)
    usage
    exit 1
    ;;
esac

if ! SELECTED_LEVEL=$(canonical_level "$LEVEL"); then
  echo "Invalid level: $LEVEL"
  echo "Valid levels: M1, M2, M2.1, M3, M4, FR"
  exit 1
fi

# Save config file in logs
if [ ! -d "$OUTPUT_DIR" ]; then
  mkdir "$OUTPUT_DIR"
fi
cp ./config "$OUTPUT_DIR"

# Delete previous result and capture new console output
if [ -f "$CONSOLE_LOG" ]; then
  rm "$CONSOLE_LOG"
fi

ARGFILE="$OUTPUT_DIR/sbmr-acs-${INTERFACE}-${SELECTED_LEVEL}.args"
./bin/generate_level_argumentfile.py \
  --suite "$INTERFACE" \
  --level "$SELECTED_LEVEL" \
  --output "$ARGFILE" || exit 1

# Execute RobotFramework Testing
echo ""
case "$INTERFACE" in
  'oob')
    echo "===== Running sbmr-acs-oob test suite at level $SELECTED_LEVEL ====="
    robot --argumentfile config --argumentfile "$ARGFILE" $DEBUG \
      --name "SBMR-ACS OOB" . | tee "$CONSOLE_LOG"
    exit "${PIPESTATUS[0]}"
    ;;
  'linux')
    echo "===== Running sbmr-acs-linux test suite at level $SELECTED_LEVEL ====="
    robot --argumentfile config -v AUTO_DISCOVER_REDFISH_IDS:0 \
      --argumentfile "$ARGFILE" $DEBUG \
      --name "SBMR-ACS IB" ./redfish ./ipmi ./host | tee "$CONSOLE_LOG"
    exit "${PIPESTATUS[0]}"
    ;;
esac
