#!/usr/bin/env ash

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

# /etc/network/wireless.sh - driver-&-firmware configuration for the wb40n
# 20120520

WIFI_PREFIX=wlan                              ## iface prefix to be enumerated
WIFI_DRIVER=bcmsdh_sdmmc                      ## device driver "name"
WIFI_MODULE=extra/drivers/net/wireless/dhd.ko
WIFI_KMPATH=/lib/modules/`uname -r`           ## kernel modules path
WIFI_FWPATH=/etc/summit/firmware              ## location of 'fw' symlink
WIFI_NVRAM=/etc/summit/nvram/nv

WIFI_PROFILES=/etc/summit/profiles.conf       ## sdc_cli profiles.conf
WIFI_MACADDR=/etc/summit/wifi_interface       ## persistent mac-address file

WIFI_USE_DHD_TO_LOAD_FW=no                    ## legacy fw load method
WIFI_ACTIVATE_SETTINGS=no                     ## legacy sdc_cli method

## supplicant and cli - comment out to disable . . .
SDC_SUPP=/usr/bin/sdcsupp
SDC_CLI=/usr/bin/sdc_cli

## supplicant options
WIFI_80211=-Dnl80211                          ## supplicant driver nl80211
#WIFI_DEBUG=-tdddd                             ## supplicant debugging '-td..' 


wifi_config()
{
  # ensure that the profiles.conf file exists and is not zero-length
  # avoids issues while loading drivers and starting the supplicant
  [ ! -s "$WIFI_PROFILES" -a -x "$SDC_CLI" ] \
  && { msg re-generating $WIFI_PROFILES; rm -f $WIFI_PROFILES; $SDC_CLI quit; }

  # determine firmware to use; assume (off) non-ccx
  ccx=$( ${SDC_CLI:-:} global show ccx-features )
  case ${ccx##*: } in
    [Oo]ptimized*|[Ff]ull*|[Oo]n*) WIFI_FW=$WIFI_FWPATH/fw-ccx ;;
    [Oo]ff*|*) WIFI_FW=$WIFI_FWPATH/fw ;;
  esac

  # set method of loading firmware and nvram
  if [ "${WIFI_USE_DHD_TO_LOAD_FW:0:1}" != "y" ]
  then
    driver_load_fw=firmware_path=$WIFI_FW
    driver_load_nv=nvram_path=$WIFI_NVRAM
  fi
  return 0
}

msg()
{
  # display to stdout if not via init/rcS
  [ -n "$rcS_" ] && echo "$@" >>$rcS_log || echo "$@"
}

wifi_awaitinterface()
{
  # arg1 is timeout (10*mSec) to await availability
  let x=0
  while [ $x -lt $1 ]
  do
    grep -q "${WIFI_DEV:-xx}" /proc/net/dev && break
    $usleep 10000 && { let x+=1; msg -en .; }
  done
  [ $x -lt $1 ] && return 0 || return 1
}

wifi_queryinterface()
{
  # determine iface via path with matching device/uevent (do not quote token)
  WIFI_DEV=$( grep -s "$WIFI_DRIVER" /sys/class/net/*/device/uevent \
               |sed -n 's,/sys/class/net/\([a-z0-9]\+\)/device.*,\1,p' )

  if [ -z "$WIFI_DEV" ]
  then
    return 1
  elif let $1+0
  then
    wifi_awaitinterface $1 || return 1
  fi
  return 0
}

wifi_start()
{
  mkdir -p /tmp/wifi^
  if grep -q "${module/.ko/}" /proc/modules
  then
    wifi_queryinterface || exit 1
  else
    ## check for 'slot_b=' setting in kernel args
    grep -o 'slot_b=.' /proc/cmdline \
    && msg "warning: \"slot_b\" setting in bootargs"

    ## perform a "wifi-reset" and load required modules
    msg "  ...resetting wifi"
    modprobe -r at91_mci  # remove existing host-side SDIO state
    if [ ! -d /sys/class/gpio/gpio77 ]
    then
      #msg "creating SYS_RST_L (PB13)"
      echo 77 > /sys/class/gpio/export
      echo out > /sys/class/gpio/gpio77/direction 
    fi
    #msg "de/re-assert'ing SYS_RST_L (PB13)"
    echo 0 > /sys/class/gpio/gpio77/value && $usleep 20000
    echo 1 > /sys/class/gpio/gpio77/value && $usleep 20000
    echo 77 > /sys/class/gpio/unexport
    modprobe at91_mci  # init SDIO bus and find hardware, loads mmc_core

    ## load driver using interface prefix
    msg "firmware: ${WIFI_FW##*/} -> `ls -l $WIFI_FW |grep -o '[^ /]*$' 2>/dev/null`"
    msg -en "loading: `ls -l $WIFI_KMPATH/$WIFI_MODULE |grep -o '[^ /]*$' 2>/dev/null`"
    [ -n "$driver_load_fw" ] && echo -en " +fw"
    [ -n "$driver_load_nv" ] && echo -en " +nv"
    #
    eval \
    insmod $WIFI_KMPATH/$WIFI_MODULE \
     iface_name=$WIFI_PREFIX $driver_load_fw $driver_load_nv \
    && msg "" || { msg "  ...driver load failure"; return 1; }

    ## await enumerated interface
    wifi_queryinterface 67 \
    || { msg "  ...driver init failure, iface not available: ${WIFI_DEV:-?}"; return 1; }
    #&& { msg "  ...success"; } \

    ## employ dhd utility to load firmware and nvram, if not via driver
    if [ "${WIFI_USE_DHD_TO_LOAD_FW:0:1}" == "y" ]
    then
      msg "loading fw: `ls -l $WIFI_FW |grep -o '[^ /]*$'`"
      dhd -i $WIFI_DEV download $WIFI_FW $WIFI_NVRAM || return 1
    fi
  fi  

  # enable interface  
  [ -n "$WIFI_DEV" ] \
  && { msg "activate: $WIFI_DEV  ...`ifconfig $WIFI_DEV up 2>&1 && echo okay`"; } \
  || { msg iface $WIFI_DEV n/a, maybe fw issue, try: wireless restart; return 1; }

  # legacy activation method
  [ "${WIFI_ACTIVATE_SETTINGS:0:1}" == "y" ] \
  && printf activate_global_settings\\\nactivate_current\\\n |${SDC_CLI:-:}

  # save MAC address for WIFI if necessary
  grep -sq ..:..:..:..:..:.. $WIFI_MACADDR \
  || cat /sys/class/net/$WIFI_DEV/address >$WIFI_MACADDR

  # launch supplicant if exists and not already running
  if test -e "$SDC_SUPP" && ! ps |grep -q "[ ]$SDC_SUPP" && let n=17
  then
    [ -f $supp_sd/*.pid ] \
    && { msg "$supp_sd/*.pid exists"; return 1; }

    supp_opt=$WIFI_80211\ $WIFI_DEBUG
    msg -en executing: $SDC_SUPP -i$WIFI_DEV $supp_opt -s'  '
    #
    $SDC_SUPP -i$WIFI_DEV $supp_opt -s >/dev/null 2>&1 &
    #
    # the 'daemonize' option may have issues, so using dynamic wait instead
    until test -e $supp_sd || ! let n=$n-1; do msg -en .; $usleep 500000; done
    # check that supplicant is running and store its process id
    pidof ${SDC_SUPP##*/} 2>/dev/null >$supp_sd/${SDC_SUPP##*/}.pid \
    || { msg ..error; return 1; }
    msg ..okay
  fi
  return 0
}

wifi_stop()
{
  ## Stopping means packets can't use wifi and interface will be removed.
  ##
  mkdir -p /tmp/wifi^
  if [ -n "$WIFI_DEV" ] \
  && grep -q "$WIFI_DEV" /proc/net/dev
  then
    ## de-configure the interface
    # This step allows for a cleaner shutdown by flushing settings,
    # so packets don't use it.  Otherwise stale settings can remain.
    ifconfig $WIFI_DEV 0.0.0.0 && msg "  ...de-configured"

    ## terminate the supplicant by looking up its process id
    let pid=$( grep -s ^ $supp_sd/*.pid )+0 && rm -f $supp_sd/*.pid && let n=27
    if let $pid && kill $pid
    then
      msg -en "supplicant terminating"
      while [ -d /proc/$pid ] && let n--; do $usleep 50000; msg -en .; done; msg
    fi
    [ -n "${1}" -a -z "${1/*supp*/}" ] && return $?

    ## down the interface
    # This step avoids occasional problems when the driver is unloaded
    # while the iface is still being used.
    msg -en "disabling interface  "
    ifconfig $WIFI_DEV down && { $usleep 500000; msg ...down; } || msg
  fi

  ## unload bcmsdh module
  if mls=$( grep -os -e "^${module/.ko/}" /proc/modules )
  then
    msg unloading: $mls
    rmmod $mls
  fi

  [ $? -eq 0 ] && { msg "  ...okay"; return 0; } || return 1
}

# ensure this script is available as system command
[ -x /sbin/wireless ] || ln -sf /etc/network/wireless.sh /sbin/wireless

# setting debug-mode from cmdline, overrides conf
case $1 in
  -[td]*)
    WIFI_DEBUG=${1} && shift
    ;;
esac
#[ -z "${WIFI_DEBUG:1}" ] && WIFI_DEBUG= || echo 6 >/proc/sys/kernel/printk

supp_sd=/tmp/wpa_supplicant
module=${WIFI_MODULE##*/}
usleep='busybox usleep'

# timed-wait (n deciseconds) for prior wifi task
let n=27 && while [ -d /tmp/wifi^ ] && let n--; do usleep 98765; done

# command
case $1 in

  stop|down)
    wifi_queryinterface
    echo \ \ Stopping wireless $WIFI_DEV $2
    wifi_stop $2
    ;;

  start|up)
    echo \ \ Starting wireless
    wifi_config && wifi_start $2
    ;;

  restart)
    $0 stop $2 && exec $0 $WIFI_DEBUG start $2
    ;;

  ''|status)
    module=${module/.ko/}
    echo -e "Modules loaded and size:"
    grep -s -e "^${module%%_*}" /proc/modules \
    || echo "  ..." 

    echo -e "\nProcesses related for $WIFI_DRIVER and supplicant:"
    top -bn1 \
    |sed 's/\(^....[^ ]\ \+[^ ]\+\ \)\+[^ ]\+\ \+\(.*\)/\1\2/' \
    |sed -n '/sed/d;4H;/'"${SDC_SUPP##*/}"'/H;/'"${module%%_*}"'/{H;x;p;}' \
    |uniq |grep . || echo "  ..."

    if wifi_queryinterface
    then
      sed 's/^Inter-/\n\/proc\/net\/wireless:\n&/;$a' \
        /proc/net/wireless 2>/dev/null || echo

      iw dev $WIFI_DEV link \
        |sed 's/onnec/ssocia/;s/cs/as/;s/Cs/As/;s/(.*)//;/[RT]X:/d;/^$/,$d'
    fi
    echo
    ;;

  \?|-h|--help)
    echo "$0"
    echo "  ...stop/start/restart the '$WIFI_PREFIX#' interface"
    echo "Manages the '$WIFI_DRIVER' wireless device driver: $module"
    echo
    echo "AP association is governed by the 'sdc_cli' and an active profile."
    echo
    [ "settings" == "$2" ] && grep "^WIFI_[A-Z]*=" $0 && echo
    echo "Flags:  (passed to supplicant)"
    echo "  -t  timestamp debug messages"
    echo "  -d  debug verbosity (-dd even more)"
    echo
    echo "Usage:"
    echo "# ${0##*/} [-tdddd] {stop|start|restart|status} [supp]"
    ;;

  *)
    echo "$0 ? [settings]"
    false
    ;;
esac
E=$?
rm -fr /tmp/wifi^
exit $E
