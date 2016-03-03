#!/bin/sh

# Copyright (c) 2015, Laird
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
# contact: ews-support@lairdtech.com

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
        FW_LINK=fw-5.bin
        CHIPSET=ar6004
        ATH6K_SDIO_PARAMS="reset_pwd_gpio=131"
elif grep -Fq "Workgroup Bridge 45N" /proc/device-tree/model
then
        FW_PATH=/lib/firmware/ath6k/AR6003/hw2.1.1
        FW_LINK=fw-4.bin
        CHIPSET=ar6003
        ATH6K_SDIO_PARAMS="reset_pwd_gpio=28"
else
        echo "Unsupported platform"
        return 0
fi

do_() {
  echo -e "+ $@"; $@; return $?
}

case ${1#--} in
  -h|help|usage)
    sed -n "/# tcmd/,/^$/{/# tcmd/d;/^$/q;p}" $0
    ;;

  '') ## setup for athtestcmd
    test -x /usr/bin/athtestcmd \
      || { echo "error - athtestcmd not available"; exit 1; }

    # remove any configuration
    do_ ifrc -v -n wlan0 stop
    echo
    (
      cd /lib/modules/`uname -r`/kernel/drivers/net/wireless/ath/ath6kl
      do_ insmod ath6kl_core.ko testmode=1
      do_ insmod ath6kl_sdio.ko $ATH6K_SDIO_PARAMS
    )
    sleep 3
    ip link set wlan0 up
    # allow driver init time and check interface
    grep -sH ..:. /sys/class/net/wlan0/address \
      || { echo "  ...error - interface n/a"; $0 off; exit 1; }

    # report driver/firmware loaded and dump settings
    dmesg |sed -n '/ath6kl: ar6003 .* fw/h;$g;${s/\\[^ ]\+//;p}'
    echo
    do_ athtestcmd -i wlan0 --otpdump
    ;;

  off|done) ## unload drivers
      do_ ifrc -v -n wlan0 restart
    ;;

  fw*) ## set firmware link to latest fw found or a specified <fw_v#.#.#.#.bin>
    [ "${#1}" -gt 2 ] && fw_specified=$FW_PATH/$1

    # find/test the latest or a specified version of firmware
    for FW in $FW_PATH/fw_v*.bin $fw_specified; do [ -f $FW ]; done
    test $? -eq 0 \
      || { echo "  ...n/a: $FW"; exit 1; }

    do_ ln -sf ${FW##*/} ${FW_PATH}/${FW_LINK}
    ;;

  show|check) ## list firmware files
    echo "Contents of ${FW_PATH}:"
    ls -ln --color=always ${FW_PATH} \
       |sed '/^.otal/d;s/ \+[0-9]\+ //;s/0        //g'
    echo
    echo "Firmware:"
    cd $FW_PATH
    n='[0-9]'
    for x in fw_v*.bin
    do
      label=
      [ "`readlink ${FW_LINK} 2>/dev/null`" == $x ] && label="${FW_LINK}"

      echo -e "${label:-  -  }" \
      `grep -s -e "^QCA" -e "^$n\.$n\.$n\.$n" $x || echo "(unidentifable)"` \
      "\r\t\t\t\t\b\b\b\b" \
      `md5sum $x 2>/dev/null`
    done
    echo
    echo "Driver status:"
    grep ath6kl /proc/modules \
      && dmesg |sed -n '/ath6kl: '${CHIPSET}' .* fw/h;$g;$s/^.*ath6kl: /  /p' \
      || echo "  ...not present"
    ;;
esac

