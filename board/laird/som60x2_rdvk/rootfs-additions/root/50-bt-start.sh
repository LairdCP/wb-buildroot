#!/bin/sh

/usr/bin/bccmd -t bcsp -d /dev/ttyS1 -b 115200 psload -r /lib/firmware/bluetopia/DWM-W311.psr
/usr/bin/btattach -B /dev/ttyS1 -P h4 -S 115200
