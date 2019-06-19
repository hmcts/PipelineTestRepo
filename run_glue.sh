#!/bin/sh

# Abort script on error
set -e

GLUE_FILE=$1
REPORT_FILE=$2


jq -f jq_pattern $REPORT_FILE > output.json

ruby bin/glue -t Dynamic -T report.json --mapping-file zaproxy
