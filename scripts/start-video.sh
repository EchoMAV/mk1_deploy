#!/bin/bash
# script to start the MK1 video streaming service
# 
# This starts two different streams: LOS and RTMP to the video server. The RTMP stream to the server must be manually started using gst-client pipeline_play server
# A snapshot pipeline is also created, which can then be activating using the snap.sh script in this repo

SUDO=$(test ${EUID} -ne 0 && which sudo)
LOCAL=/usr/local

echo "Start MK1 Video Script for $PLATFORM"

# if host is multicast, then append extra
if [[ "$LOS_HOST" =~ ^[2][2-3][4-9].* ]]; then
    extra_los="multicast-iface=${LOS_IFACE} auto-multicast=true ttl=10"
fi

#Scale the bitrate from kbps to bps
SCALED_VIDEOSERVER_BITRATE=$(($VIDEOSERVER_BITRATE * 1000)) 

# ensure previous pipelines are cancelled and cleared
set +e
gstd -f /var/run -l /dev/null -d /dev/null -k
set -e
gstd -e -f /var/run -l /var/run/video-stream/gstd.log -d /var/run/video-stream/gst.log

# video pipelines

gst-client pipeline_create h265src udpsrc port=${GIMBAL_PORT} name=serverReceivePort ! "application/x-rtp, media=(string)video, clock-rate=(int)90000, encoding-name=(string)H265, payload=(int)96" ! rtph265depay ! interpipesink name=h265src
# gst-client pipeline_create los interpipesrc listen-to=h265src block=true is-live=true allow-renegotiation=true stream-sync=compensate-ts ! rtph265pay config-interval=1 pt=96 ! udpsink sync=false host=${LOS_HOST} port=${LOS_PORT} ${extra_los}

# rtmp server over Cellular variation with nvidia hw
gst-client pipeline_create server interpipesrc listen-to=h265src block=false is-live=true allow-renegotiation=true stream-sync=compensate-ts ! queue ! h265parse ! nvv4l2decoder enable-max-performance=true disable-dpb=true ! queue ! nvv4l2h264enc maxperf-enable=1 idrinterval=30 control-rate=1 bitrate=${SCALED_VIDEOSERVER_BITRATE} preset-level=1 name=serverEncoder ! h264parse ! flvmux streamable=true ! rtmpsink location="rtmp://${VIDEOSERVER_HOST}/LiveApp?streamid=LiveApp/${VIDEOSERVER_STREAMNAME}" name=serverLocation

# rtmp server over Cellular variation without nvidia hw encoder
# gst-client pipeline_create server interpipesrc listen-to=h265src block=false is-live=true allow-renegotiation=true stream-sync=compensate-ts ! queue ! h265parse ! nvv4l2decoder enable-max-performance=true disable-dpb=true ! nvvidconv ! x264enc tune=zerolatency speed-preset=1 bitrate=${VIDEOSERVER_BITRATE} name=serverEncoder ! video/x-h264, profile=baseline ! h264parse ! flvmux streamable=true ! rtmpsink location="rtmp://${VIDEOSERVER_HOST}/LiveApp?streamid=LiveApp/${VIDEOSERVER_STREAMNAME}" name=serverLocation

# srt variation over Cellular, which can accept the h265 stream direct from camera
# gst-client pipeline_create server interpipesrc listen-to=h265src block=false is-live=true allow-renegotiation=true stream-sync=compensate-ts ! "application/x-rtp, media=(string)video, clock-rate=(int)90000, encoding-name=(string)H265, payload=(int)96" ! rtph265depay ! queue ! mpegtsmux ! srtsink uri="srt://${VIDEOSERVER_HOST}:4200?streamid=LiveApp/${VIDEOSERVER_STREAMNAME}" name =serverLocation

# srt variation over Cellular, it seems that srt to antmedia requires gstreamer 1.20+, which is a PITA to install on L4T based on Ubuntu 20.04 LTS. Recommend RTMP until L4T 36.x becomes more stable and we can get gstreamer 1.20+
# gst-client pipeline_create server interpipesrc listen-to=h265src block=false is-live=true allow-renegotiation=true stream-sync=compensate-ts ! queue ! h265parse ! nvv4l2decoder enable-max-performance=true disable-dpb=true ! queue ! queue ! nvv4l2h264enc control-rate=0 bitrate=${VIDEOSERVER_BITRATE} profile=0 preset-level=1 maxperf-enable=1 idrinterval=30 EnableTwopassCBR=true name=serverEncoder ! mpegtsmux ! srtsink uri=srt://${VIDEOSERVER_HOST}:8000 pbkeylen=16 passphrase=echomav8echomav4 name=serverLocation

# nb: the server pipeline should be started by a supervisory program (like mavnetproxy) when we know we have connectivity. it is started with gst-client pipeline_play server

# snapshot pipeline
gst-client pipeline_create snapshot interpipesrc listen-to=h265src is-live=true allow-renegotiation=true stream-sync=compensate-ts ! queue max-size-buffers=3 leaky=downstream ! h265parse ! nvv4l2decoder ! nvvidconv ! video/x-raw,format=I420 ! jpegenc ! multifilesink name=filename location=capture.jpg max-files=1 async=false sync=false

# start source pipeline streaming
gst-client pipeline_play h265src

# start los pipeline streaming
# Per nevtvision v1.11.10, use the dual stream fuctionality to send to the LOS endpoint
# gst-client pipeline_play los

