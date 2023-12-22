#!/bin/bash
# script to stop the MK1 video service

gst-client pipeline_stop h265src
gst-client pipeline_stop server
gst-client pipeline_stop snapshot

gst-client pipeline_delete h265src
gst-client pipeline_delete server
gst-client pipeline_delete snapshot

set +e
gstd -f /var/run -l /dev/null -d /dev/null -k
set -e
