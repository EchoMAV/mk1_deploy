	# Automation boilerplate

SHELL := /bin/bash
SN := $(shell hostname)
SUDO := $(shell test $${EUID} -ne 0 && echo "sudo")
.EXPORT_ALL_VARIABLES:

SERIAL ?= $(shell python3 serial_number.py)
LOCAL=/usr/local
LOCAL_SCRIPTS=scripts/start.sh scripts/cockpitScript.sh scripts/temperature.sh scripts/start-video.sh scripts/serial_number.py scripts/snap.sh
CONFIG ?= /var/local
LIBSYSTEMD=/lib/systemd/system
PKGDEPS ?= v4l-utils build-essential nano nload htop modemmanager
SERVICES=mavnetProxy.service temperature.service video.service
SYSCFG=/usr/local/echopilot/mavnetProxy
DRY_RUN=false
PLATFORM ?= $(shell python serial_number.py | cut -c1-4)

.PHONY = clean dependencies cockpit cellular enable install provision see uninstall 

default:
	@echo "Please choose an action:"
	@echo ""
	@echo "  dependencies: ensure all needed software is installed (requires internet)"
	@echo "  install: update programs and system scripts"
	@echo ""
	@echo "The above are issued in the order shown above.  dependencies is only done once."
	@echo ""

clean:
	@if [ -d src ] ; then cd src && make clean ; fi

dependencies:	
	@if [ ! -z "$(PKGDEPS)" ] ; then $(SUDO) apt-get install -y $(PKGDEPS) ; fi

cellular:
# remove --defaults if you want interactive, otherwise it'll use the default ATT Broadband
	@$(SUDO) ./ensure-cellular.sh --defaults

cockpit:
	@$(SUDO) ./ensure-cockpit.sh

	@for s in $(LOCAL_SCRIPTS) ; do $(SUDO) install -Dm755 $${s} $(LOCAL)/echopilot/$${s} ; done

# set up cockpit files
	@echo "Copying cockpit files..."
	@$(SUDO) rm -rf /usr/share/cockpit/mavnet/ /usr/share/cockpit/mavnet-server/ /usr/share/cockpit/video/ /usr/share/cockpit/cellular
	@$(SUDO) mkdir /usr/share/cockpit/mavnet/
	@$(SUDO) cp -rf ui/telemetry/* /usr/share/cockpit/telemetry/
	@$(SUDO) mkdir /usr/share/cockpit/mavnet-server/
	@$(SUDO) cp -rf ui/mavnet-server/* /usr/share/cockpit/mavnet-server/
	@$(SUDO) mkdir /usr/share/cockpit/video/
	@$(SUDO) cp -rf ui/video/* /usr/share/cockpit/video/
	@$(SUDO) mkdir /usr/share/cockpit/cellular
	@$(SUDO) cp -rf ui/cellular/* /usr/share/cockpit/cellular/		
	@$(SUDO) cp -rf ui/branding-ubuntu/* /usr/share/cockpit/branding/ubuntu/
	@$(SUDO) cp -rf ui/static/* /usr/share/cockpit/static/	
	@$(SUDO) cp -rf ui/base1/* /usr/share/cockpit/base1/
	@$(SUDO) install -Dm755 version.txt $(LOCAL)/echopilot/.	

disable:
	@( for c in stop disable ; do $(SUDO) systemctl $${c} $(SERVICES) ; done ; true )
	@$(SUDO) nmcli con down attcell ; $(SUDO) nmcli con delete "attcell"

enable:
	@echo "Installing service files..."
	@( for c in stop disable ; do $(SUDO) systemctl $${c} $(SERVICES) ; done ; true )	
	@( for s in $(SERVICES) ; do $(SUDO) install -Dm644 $${s%.*}.service $(LIBSYSTEMD)/$${s%.*}.service ; done ; true )
	@if [ ! -z "$(SERVICES)" ] ; then $(SUDO) systemctl daemon-reload ; fi
	@echo "Enabling services files..."
	@( for s in $(SERVICES) ; do $(SUDO) systemctl enable $${s%.*} ; done ; true )
	@echo ""
	@echo "mavnetProxy Service is installed. To run now use sudo systemctl start mavnetProxy or reboot"
	@echo "Inspect output with sudo journalctl -fu mavnetProxy"
	@echo ""
	@echo "Video Service is installed. To run now use sudo systemctl start video or reboot"
	@echo "Inspect output with sudo journalctl -fu video"

install: dependencies	

# install video prequisites
	$(SUDO) apt update
	@PLATFORM=$(PLATFORM) ./ensure-gst.sh $(DRY_RUN)
	@PLATFORM=$(PLATFORM) ./ensure-gstd.sh $(DRY_RUN)	

# install cockpit
	@$(MAKE) --no-print-directory cockpit

# set up folders used by mavnetProxy
	@echo "Setting up mavnetProxy folders..."
	@[ -d /mnt/data/mission ] || $(SUDO) mkdir -p /mnt/data/mission
	@[ -d /mnt/container ] || $(SUDO) mkdir -p /mnt/container
	@[ -d /mnt/data/tmp_images ] || $(SUDO) mkdir -p /mnt/data/tmp_images
	@[ -d /mnt/container/image ] || $(SUDO) mkdir -p /container/image
	@[ -d /mnt/data/mission/processed_images ] || $(SUDO) mkdir -p /mnt/data/mission/processed_images
	@[ -d $(LOCAL)/echopilot ] || $(SUDO) mkdir -p $(LOCAL)/echopilot

# install any UDEV RULES
	@echo "Installing UDEV rules..."
	@for s in $(RULES) ; do $(SUDO) install -Dm644 $${s%.*}.rules $(UDEVRULES)/$${s%.*}.rules ; done
	@if [ ! -z "$(RULES)" ] ; then $(SUDO) udevadm control --reload-rules && udevadm trigger ; fi

# install LOCAL_SCRIPTS
	@echo "Installing local scripts..."
	@for s in $(LOCAL_SCRIPTS) ; do $(SUDO) install -Dm755 $${s} $(LOCAL)/echopilot/$${s} ; done

# stop and disable services
	@echo "Disabling running services..."
	@for c in stop disable ; do $(SUDO) systemctl $${c} $(SERVICES) ; done ; true

# install mavnetProxy files
	@echo "Installing mavnetProxy files..."
	@[ -d $(LOCAL)/echopilot/mavnetProxy ] || $(SUDO) mkdir $(LOCAL)/echopilot/mavnetProxy
	@$(SUDO) cp -a bin/. $(LOCAL)/echopilot/mavnetProxy/  
# The baseline configuration files are including in this folder including video.conf
	@$(SUDO) chmod +x $(LOCAL)/echopilot/mavnetProxy/mavnetProxy

# install services and enable them
	@$(MAKE) --no-print-directory enable

# install cellular
	@echo "Setting up cellular connection..."
	@$(MAKE) --no-print-directory cellular

# cleanup and final settings
	@echo "Final cleanup..."
	@$(SUDO) chown -R echopilot /usr/local/echopilot
	@$(SUDO) systemctl stop nvgetty
	@$(SUDO) systemctl disable nvgetty
	@$(SUDO) usermod -aG dialout echopilot
	@$(SUDO) usermod -aG tty echopilot
	@echo "Please access the web UI to change settings..."
	@echo "Please reboot to complete the installation..."

see:
	$(SUDO) cat $(SYSCFG)/mavnetProxy.conf
#   mavnet conf not applicable yet
#	$(SUDO) cat $(SYSCFG)/mavnet.conf
	$(SUDO) cat $(SYSCFG)/video.conf
	@echo -n "Cellular APN is: "
	@$(SUDO) nmcli con show attcell | grep gsm.apn | cut -d ":" -f2 | xargs


uninstall:
	@$(MAKE) --no-print-directory disable
	@( for s in $(SERVICES) ; do $(SUDO) rm $(LIBSYSTEMD)/$${s%.*}.service ; done ; true )
	@if [ ! -z "$(SERVICES)" ] ; then $(SUDO) systemctl daemon-reload ; fi
	$(SUDO) rm -f $(SYSCFG)


