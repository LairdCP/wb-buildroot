#!/bin/sh

# Copyright (c) 2015, Laird Connectivity
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.
#
# contact: support@lairdconnect.com

# tcmd.sh
# Provides athtestcmd support.
# Usage:
# Enable/disable testmode:
#   tcmd.sh [off]
#
# Show firmware related files and version info:
#   tcmd.sh check
#
# Set firmware link:  (use 'fw' for latest or specify filename)
#   tcmd.sh [fw|<fw_v#.#.#.#.bin>]
#

if grep -Fq "Workgroup Bridge 50N" /proc/device-tree/model
then
        FW_PATH=/lib/firmware/ath6k/AR6004/hw3.0
        CHIPSET=ar6004
        ATH6K_SDIO_PARAMS="reset_pwd_gpio=131"
else
        echo "Unsupported platform"
        return 0
fi

# check if NM build or not
test -x /usr/lib/libnm.so && NM=1

do_() {
  echo -e "+ $@"; $@; return $?
}

case ${1#--} in
  -h|help|usage)
    sed -n "/# tcmd/,/^$/{/# tcmd/d;/^$/q;p}" $0
    ;;

  '') ## setup for athtestcmd
    test -x /usr/bin/lru \
      || { echo "error - lru not available"; exit 1; }

    # remove any configuration
    if [ -z "$NM" ]; then
      do_ ifrc -v -n wlan0 stop
    else
      do_ systemctl stop NetworkManager.service
      do_ kill -9 `pidof sdcsupp`
      do_ modprobe -r ath6kl_sdio
      do_ sleep 3
    fi
    echo
    (
      if [ -z "$NM" ]; then
        do_ modprobe ath6kl_core testmode=1 heart_beat_poll=0
        do_ modprobe ath6kl_sdio $ATH6K_SDIO_PARAMS
      else
        do_ modprobe ath6kl_core testmode=1 heart_beat_poll=0
        do_ modprobe ath6kl_sdio
      fi
    )
    sleep 3
    ip link set wlan0 up
    # allow driver init time and check interface
    grep -sH ..:. /sys/class/net/wlan0/address \
      || { echo "  ...error - interface n/a"; $0 off; exit 1; }

    # report driver/firmware loaded and dump settings
    dmesg |sed -n '/ath6kl: '${CHIPSET}' .* fw/h;$g;${s/\\[^ ]\+//;p}'
    ;;

  off|done) ## reload drivers
    if [ -z "$NM" ]; then
      do_ ifrc -v -n wlan0 restart
    else
      do_ modprobe -r ath6kl_sdio
      do_ modprobe  ath6kl_sdio
      do_ systemctl start NetworkManager.service
    fi
    ;;

  show|check) ## list firmware files
    echo "Driver status:"
    grep ath6kl /proc/modules \
      && dmesg |sed -n '/ath6kl: '${CHIPSET}' .* fw/h;$g;$s/^.*ath6kl: /  /p' \
      || echo "  ...not present"
    ;;
esac

