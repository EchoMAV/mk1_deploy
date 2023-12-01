# Echomav MavnetProxy Deployment

## Depracated - now moved to the echomav github repo mk1_deploy

## Dependencies

will be installed automatically by during a `make install` assuming you have an internet connection  


## Installation

To perform an initial install, establish an internet connection and clone the repository.
You will issue the following commands:
```
cd $HOME
git clone https://github.com/horiz31/echomav_deploy.git
```

provide your credentials, then continue:
```
make -C $HOME/echomav_deploy install
```

To configure your system, edit the following files in `/usr/local/echopilot/mavnetProxy/`
mavnet.conf - mavnet key, serial number  
mavnetProxy.conf - telemetry IP and interface, FMU interface  
video.conf - not currently used  
appsettings.json - app related configuration, sensors onboard, gimbal ip address, gcs_passthru variable, default param values, etc.  


## Supported Platforms
These platforms are supported/tested:


 * Raspberry PI
   - [ ] [Raspbian GNU/Linux 10 (buster)](https://www.raspberrypi.org/downloads/raspbian/)
 * Jetson Nano
   - [x] [Jetpack 4.6.x]

