FROM resin/rpi-raspbian:stretch

# Enable building ARM container on x86 machinery on the web (comment out next line if built on Raspberry)
RUN [ "cross-build-start" ]

RUN apt-get update && apt-get install -y wget && echo "deb http://pipplware.pplware.pt/pipplware/dists/unstable/main/binary /" > /etc/apt/sources.list.d/pipplware_unstable.list && \
    wget -O - http://pipplware.pplware.pt/pipplware/key.asc | sudo apt-key add -
RUN apt-get clean && apt-get update && apt-get dist-upgrade -y && apt-get install -y --no-install-recommends xserver-xorg xinit \
     fbset libraspberrypi0 alsa-base alsa-utils alsa-tools kodi=2:18.0~git20181123.0454-rc1-1~stretch kodi-bin=2:18.0~git20181123.0454-rc1-1~stretch xserver-xorg-legacy dbus-x11 \
     && apt-get clean && rm -rf /var/lib/apt/lists/*

# Uncomment if you want to install recommanded PVR addons
#RUN apt-get update && apt-get install -y kodi-pvr-mythtv kodi-pvr-vuplus kodi-pvr-vdr-vnsi kodi-pvr-njoy \
# kodi-pvr-nextpvr kodi-pvr-mediaportal-tvserver kodi-pvr-tvheadend-hts \
# kodi-pvr-dvbviewer kodi-pvr-argustv kodi-pvr-iptvsimple libnss3 \
# && apt-get clean && rm -rf /var/lib/apt/lists/*
 
# Configure Kodi group
RUN usermod -a -G audio root && \
usermod -a -G video root && \
usermod -a -G input root && \
usermod -a -G dialout root && \
usermod -a -G plugdev root && \
usermod -a -G tty root

# Needed configurations files
COPY "./files-to-copy-to-image/Xwrapper.config" "/etc/X11"
COPY "./files-to-copy-to-image/10-permissions.rules" "/etc/udev/rules.d"
COPY "./files-to-copy-to-image/99-input.rules" "/etc/udev/rules.d"
# Uncomment if you want to enable webserver and remote control settings by default
COPY "./files-to-copy-to-image/settings.xml" "/usr/share/kodi/system/settings"

# Kodi directories
RUN  mkdir -p /config/kodi/userdata >/dev/null 2>&1 || true && rm -rf /root/.kodi && ln -s /config/kodi /root/.kodi \
    && mkdir -p /data >/dev/null 2>&1

RUN apt-get update && apt-get install -y gdb
# ports and volumes
VOLUME /config/kodi
VOLUME /data
EXPOSE 8089 8080 9777/udp

CMD ["bash", "/usr/bin/kodi-standalone"]

# stop processing ARM emulation (comment out next line if built on Raspberry)
RUN [ "cross-build-end" ]
