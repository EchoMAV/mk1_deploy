# extract unique serial number from the nvidia jetson
# FIXME: this is not a good solution for determining the hardware type, if it is necessary for other programs this needs to be improved

def serial_number():
    """Extract a unique serial number from the nvidia jetson the function is executed upon."""

    _paths = [
        ('NVID','/proc/device-tree/chosen/nvidia,ether-mac'),    # NVidia TX1/TX2/Xavier
        ('NVID','/proc/device-tree/chosen/nvidia,ethernet-mac'), # NVidia Jetson Nano
        ('NVID','/proc/device-tree/serial-number'),              # Nvidia Jetson Orin
    ]
    for (t,p) in _paths:
        try:
            sn = open(p).readline().strip()
            return t+''.join([x for x in sn.split(':')])
        except IOError:
            continue

    # got here?  punt, and go through the remaining network interfaces
    try:
        import netifaces as ni
        for iface in ni.interfaces():
            addr = ni.ifaddresses(iface)[ni.AF_LINK][0]['addr']
            if addr.startswith('00:00:00'):
                continue
            return 'XMAC'+''.join([ x for x in addr.split(':')])
    except Exception as e:
        sys.stderr.write(str(e)+'\n')
    raise RuntimeError('unable to obtain serial number from various methods')

# ---------------------------------------------------------------------------
# For command-line testing
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    import sys
    
    sn = serial_number()
    sys.stdout.write(sn+'\n')