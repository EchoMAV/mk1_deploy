# Echomav MavnetProxy Deployment


## Dependencies

Requires git-lfs
```
sudo apt update
sudo apt-get -o DPkg::Lock::Timeout=-1 install git-lfs -y
```

Other dependencies will be installed automatically by during a `make install` assuming you have an internet connection  

## Installation

To perform an initial install, establish an internet connection and clone the repository.
You will issue the following commands:
```
sudo apt update
sudo apt-get -o DPkg::Lock::Timeout=-1 install git-lfs -y
cd $HOME
git clone https://github.com/echomav/mk1_deploy.git
make -C $HOME/mk1_deploy install
```

To configure your system, edit the following files in `/usr/local/echopilot/mavnetProxy/`
mavnet.conf - mavnet key, serial number  
mavnetProxy.conf - telemetry IP and interface, FMU interface  
video.conf - video server information  
appsettings.json - app related configuration, sensors onboard, gimbal ip address, gcs_passthru variable, default param values, etc.  

Generally to be used along side https://github.com/echomav/mk1_video.git

## Supported Platforms
These platforms are supported/tested:

 * Jetson Orin
   - [x] [Jetpack 6.X]

