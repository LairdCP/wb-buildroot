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

# tcmd.sh - manage firmware for athtestcmd and setup
#
# For normal wifi operation, we use latest firmware, which requires a symlink.
# An alternate fw_v#.#.#.#.bin may be set by doing:
# tcmd.sh norm fw_v#.#.#.#.bin
#


FW_PATH=/lib/firmware/ath6k/AR6003/hw2.1.1
FW_TCMD=/lib/firmware/ath6k/AR6003/hw2.1.1/fw_v3.2.0.144.bin


do_() {
  echo -e "# $@"; $@; return $?
}


case ${1#--} in
  -h|help)
    echo "Use to set version of firmware for testing vs. normal operation."
    echo "The 'athtestcmd' requires a specific firmware version."
    echo
    echo "Running this script w/o option will attempt setup for athtestcmd."
    echo "However, firmware must be set for using athtestcmd first."
    echo 
    echo "Option:"
    echo "  testing - set fw for athtestcmd usage"
    echo "  normal - set fw for normal wifi operation"
    echo "  check - list fw files and show version details"
    echo 
    echo "Usage:"
    echo "  $0 [option] [fw_v#.#.#.#]"
    echo 
    ;;

  '') ## setup for athtestcmd
    test -x /usr/bin/athtestcmd \
      || { echo "error - athtestcmd not available"; exit 1; }

    test -h ${FW_PATH}/fw-3.bin \
      || { echo "run 'tcmd.sh testmode' firstly"; exit 1; }

    rmmod ath6kl_sdio 2>/dev/null
    rmmod ath6kl_core 2>/dev/null
    echo "  ...setting up for athtestcmd"
    (
      cd /lib/modules/`uname -r`/kernel/drivers/net/wireless/ath/ath6kl
      do_ insmod ath6kl_core.ko testmode=1
      do_ insmod ath6kl_sdio.ko
    )
    echo -n \
    && grep -s . /sys/class/net/wlan0/device/uevent \
    && grep -s . /sys/class/net/wlan0/uevent \
    || { echo "  ...interface n/a, try:  ${0##*/} help"; exit 1; }

    echo 
    do_ athtestcmd -i wlan0 --otpdump

    # examples
    #do_ athtestcmd -i wlan0 --rx promis --rxfreq 2417 --rx antenna auto
    #do_ athtestcmd -i wlan0 --rx report --rxfreq 2417 --rx antenna auto
    ;;
  
  norm*) ## restore normal wifi with latest fw found or specified [fw_v#.#.#.#]
    for FW in $FW_PATH/fw_v*.bin; do :; done
    echo "  ...restoring fw version for normal wifi: ${FW##*/}"
    #
    do_ rm -f ${FW_PATH}/fw-3.bin
    if do_ ln -sf ${FW##*/} ${FW_PATH}/fw-4.bin
    then
      # set /e/n/i option
      do_ ifrc -v -n wlan0 auto
      do_ ifrc -v -n wlan0 stop
    fi
    ;;

  test*) ## setup for testing
    echo "  ...setting fw version for athtestcmd"
    #
    do_ rm -f ${FW_PATH}/fw-4.bin
    if do_ ln -sf ${FW_TCMD##*/} ${FW_PATH}/fw-3.bin
    then
      # unset /e/n/i option
      do_ ifrc -v -n wlan0 noauto
      do_ ifrc -v -n wlan0 stop
      echo
      echo "Now can run 'tcmd.sh' to load modules for 'athtestcmd'."
    fi
    ;;

  check) ## list firmware files
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
      [ "`readlink fw-3.bin 2>/dev/null`" == $x ] && label="fw-3:"
      [ "`readlink fw-4.bin 2>/dev/null`" == $x ] && label="fw-4:"
    
      echo -e "${label:-  -  }" \
      `grep -s -e "^QCA" -e "^$n\.$n\.$n\.$n" $x || echo "(unidentifable)"` \
      "\r\t\t\t\t\b\b\b\b" \
      `md5sum $x 2>/dev/null`
    done
    echo
    echo "Note: The 'athtestcmd' may be used when the driver can load fw-3 symlink."
    echo "      However, the driver will load a fw-4 symlink instead, if available."
    echo
    echo "Driver status:"
    grep ath6kl /proc/modules \
      && dmesg |sed -n '/ath6kl: ar6003 .* fw/h;$g;$s/^.*ath6kl: /  /p' \
      || echo "  ...not present"
    ;;
esac

