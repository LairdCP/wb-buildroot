#!/bin/sh
# tcmd.sh - setup for using athtestcmd
# jon.hefling@lairdtech.com


# For normal wifi operation, we use latest firmware, which requires a symlink.
# An alternate fw_v#.#.#.#.bin may be set by doing:
# tcmd.sh norm fw_v#.#.#.#.bin
#
FW_LINK=/lib/firmware/ath6k/AR6003/hw2.1.1/fw-4.bin

do_() {
  echo -e "# $@"; $@; return $?
}


case $1 in
  \?|-h|*help)
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
    [ -x /usr/bin/athtestcmd ] || { echo error; exit 1; }
    #
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
    #do_ athtestcmd -i wlan0 --rx promis --rxfreq 2417 --rx antenna auto
    #do_ athtestcmd -i wlan0 --rx report --rxfreq 2417 --rx antenna auto
    ;;
  
  norm*) ## restore normal wifi ...use default or [fw_v#.#.#.#]
    fw=$( ls -r ${FW_LINK%/*}/${2:-fw_v*.bin} |grep -m1 . ) && [ -f "$fw" ] || exit 1 
    echo "  ...restoring fw version for normal wifi: ${fw##*/}"
    # restore firmware symlink for normal operation
    do_ ln -sf ${fw##*/} ${FW_LINK} || exit 1
    # set /e/n/i option
    do_ ifrc -v -n wlan0 auto
    do_ ifrc -v -n wlan0 stop
    ;;

  test*) ## setup for testing
    echo "  ...setting fw version for athtestcmd"
    # remove normal firmware symlink for testmode
    do_ rm -f ${FW_LINK}
    # unset /e/n/i option
    do_ ifrc -v -n wlan0 noauto
    do_ ifrc -v -n wlan0 stop
    echo
    echo "Now can run 'tcmd.sh' to load modules for 'athtestcmd'."
    ;;

  check) ## list firmware files
    echo  "  ...contents of ${FW_LINK%/*}:"
    ls -ln --color=always ${FW_LINK%/*} |sed '/^.otal/d;s/0\ \ \ \ \ \ \ \ //g'
    echo "  The 'athtestcmd' may be used when the driver can load fw-3."
    echo "  However, the driver will load a fw-4 instead, if available."

    n='[0-9]'
    echo -e "    fw-3: " \
    `grep -s -e "^QCA" -e "^$n\.$n\.$n\.$n" ${FW_LINK%/*}/fw-3.bin || echo n/a` \
    \\\t`md5sum ${FW_LINK%/*}/fw-3.bin |cut -d' ' -f1`

    echo -e "    fw-4: " \
    `grep -s -e "^QCA" -e "^$n\.$n\.$n\.$n" ${FW_LINK%/*}/fw-4.bin || echo n/a` \
    \\\t`md5sum ${FW_LINK%/*}/fw-4.bin |cut -d' ' -f1`
    
    echo
    ;;
esac

