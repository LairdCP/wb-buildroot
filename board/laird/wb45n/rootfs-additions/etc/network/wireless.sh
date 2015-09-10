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

# /etc/network/wireless.sh - driver-&-firmware configuration for the wb45n
# 20120520

WIFI_PREFIX=wlan                              ## iface to be enumerated
WIFI_DRIVER=ath6kl_sdio                       ## device driver "name"
WIFI_MODULE=ath/ath6kl/ath6kl_sdio.ko         ## kernel module path
WIFI_KMPATH=/lib/modules/`uname -r`/kernel/drivers/net/wireless
#WIFI_FWPATH=/lib/firmware/ath6k/AR6003/hw2.1.1
#WIFI_NVRAM=/lib/nvram/nv

WIFI_PROFILES=/etc/summit/profiles.conf       ## sdc_cli profiles.conf
WIFI_MACADDR=/etc/summit/wifi_interface       ## persistent mac-address file

## monitor, supplicant and cli - comment out to disable . . .
EVENT_MON=/usr/bin/event_mon
SDC_SUPP=/usr/bin/sdcsupp
SDC_CLI=/usr/bin/sdc_cli

## supplicant options
WIFI_80211=-Dnl80211                          ## supplicant driver nl80211 
#WIFI_DEBUG=-tdddd                             ## supplicant debugging '-td..'

## fips-mode support - also can invoke directly via the cmdline as 'fips'
#WIFI_FIPS=-F                                  ## FIPS mode support '-F'


wifi_config() {
  # ensure that the profiles.conf file exists and is not zero-length
  # avoids issues while loading drivers and starting the supplicant
  [ ! -s "$WIFI_PROFILES" -a -x "$SDC_CLI" ] \
  && { msg re-generating $WIFI_PROFILES; rm -f $WIFI_PROFILES; $SDC_CLI quit; }

  # check global profile setting: fips-mode <disabled|enabled>
  # cmdline or script setting may override, otherwise not-enabled
  fm=$( ${SDC_CLI:-:} global show fips 2>/dev/null )
  [ "${fm/*Enabled*/yes}" == yes ] && WIFI_FIPS=-F

  return 0
}

wifi_set_dev() {
  ip link set dev $WIFI_DEV $1 2>&1 #/dev/null
}

msg() {
  echo "$@"
}

wifi_status() {
  module=${module/.ko/}
  echo -e "Modules loaded and size:"
  grep -s -e "${module%%_*}" -e "sdcu" -e "sdc2u" /proc/modules \
  && echo "  `dmesg |sed -n '/ath6kl: ar6003 .* fw/h;$g;$s/^.*ath6kl: //p'`" \
  || echo "  ..."

  echo -e \
  "\nProcesses related for ${WIFI_DRIVER}${WIFI_FIPS:+, w/fips}:\n  ...\r\c"
  top -bn1 \
  |sed -e '/sed/d;s/\(^....[^ ]\)\ \+[^ ]\+\ \+[^ ]\+\ \+\(.*\)/\1 \2/' \
       -e '4h;/hostapd/H;/.[dp].supp/H;/event_m/H;/sdcu/H' \
       -e "/${module%%_*}"'/{H;x;p;}' -n

  if wifi_queryinterface
  then
    sed 's/^Inter-/\n\/proc\/net\/wireless:\n&/;$a' \
      /proc/net/wireless 2>/dev/null || echo

    iw dev $WIFI_DEV link \
      |sed 's/onnec/ssocia/;s/cs/as/;s/Cs/As/;s/(.*)//;/[RT]X:/d;/^$/,$d'
  else
    echo
  fi
  echo
}

wifi_queryinterface() {
  # on driver init, must check and wait for device
  # arg1 is timeout (10*mSec) to await availability
  let x=0
  while [ $x -le ${1:-0} ]
  do
    if [ -n "$WIFI_DEV" ]
    then # check if available/ready
      grep -q "$WIFI_DEV" /proc/net/dev && break
    else
      # determine iface via path with matching device/uevent
      WIFI_DEV=$( grep -s "$WIFI_DRIVER" /sys/class/net/*/device/uevent \
                   |sed -n 's,/sys/class/net/\([a-z0-9]\+\)/device.*,\1,p' )
      # recheck
      [ -n "$WIFI_DEV" ] && continue
    fi
    $usleep 10000 && { let x+=1; msg -n .; }
  done
  let $x && msg ${x}0mSec
  test $x -le ${1:-0}
}

wifi_fips_mode() {
  if [ -f "$WIFI_KMPATH/laird_fips/ath6kl_laird.ko" ] \
  && [ -f "$WIFI_KMPATH/laird_fips/sdc2u.ko" ] \
  && : #[ -x "/usr/bin/sdcu" ]
  then
    msg "configuring for FIPS mode"
    # note - only 'WPA2 EAP-TLS' is supported
    ath6kl_params=$ath6kl_params\ fips_mode=y
    insmod $WIFI_KMPATH/ath/ath6kl/ath6kl_core.ko $ath6kl_params || return 1
    insmod $WIFI_KMPATH/laird_fips/sdc2u.ko || return 1
    insmod $WIFI_KMPATH/laird_fips/ath6kl_laird.ko || return 1

    # create device node for user space daemon 
    major=$( sed -n '/sdc2u/s/^[ ]*\([0-9]*\).*/\1/p' /proc/devices )
    minor=0
    rm -f /dev/sdc2u0
    mknod /dev/sdc2u0 c $major $minor || return 1
    # launch daemon to perform crypto operations
    sdcu >/var/log/sdcu.log 2>&1 &
  else
    msg "configuring non-FIPS mode"
    WIFI_FIPS=
  fi
  return 0
}

wifi_start() {
  mkdir -p /tmp/wifi^
  if grep -q "${module/.ko/}" /proc/modules
  then
    msg "checking interface/mode"
    ## see if this 'start' has a fips-mode conflict
    [ -c /dev/sdc2u* ] && fm=-F || fm=
    if ! { wifi_queryinterface || { msg "  ...n/a"; false; }; } \
    || { [ "$WIFI_FIPS" != "$fm" ] && msg "  ...mode"; }
    then
      msg ${PS1}${0##*/} $WIFI_DEBUG ${WIFI_FIPS:+fips} restart
      exec $0 $WIFI_DEBUG ${WIFI_FIPS:+fips} restart
    fi
  else
    ## check for 'slot_b=' setting in kernel args
    grep -o 'slot_b=.' /proc/cmdline \
    && msg "warning: \"slot_b\" setting in bootargs"

    modprobe cfg80211

    ## set atheros driver core options
    ath6kl_params="recovery_enable=1 heart_beat_poll=200"

    ## check fips-mode support
    if [ -n "$WIFI_FIPS" ]
    then
      wifi_fips_mode || { msg " ...fips-mode error"; return 1; }
    else
      insmod $WIFI_KMPATH/ath/ath6kl/ath6kl_core.ko $ath6kl_params
    fi

    modprobe $WIFI_DRIVER \
    || { msg "  ...driver failed to load"; return 1; }

    ## await enumerated interface
    wifi_queryinterface 67 \
    || { msg "  ...driver init failure, iface n/a: ${WIFI_DEV:-?}"; return 1; }
  fi

  # enable interface  
  [ -n "$WIFI_DEV" ] \
  && { msg -n "activate: $WIFI_DEV  ..."; wifi_set_dev up && msg ok; } \
  || { msg "iface $WIFI_DEV n/a, FW issue?  -try: wireless restart"; return 1; }

  # save MAC address for WIFI if necessary
  read -r wl_mac < /sys/class/net/$WIFI_DEV/address
  grep -sq ..:..:..:..:..:.. $WIFI_MACADDR \
    || echo $wl_mac >$WIFI_MACADDR

  # dynamic wait for socket args: <socket> <interval>
  await() { n=27; until [ -e $1 ] || ! let n--; do msg -n .; $usleep $2; done; }

  # the /e/n/i wl* stanza
  stanza='^iface wl.* inet'

  # see if enabled in /e/n/i stanza for wl* -or- requested via cmdline
  hostapd=$( sed -n "/$stanza/"',/^[ \t]\+.*hostapd/h;$x;$s/[ \t]*//p' $eni )
  if [ -n "$hostapd" -a "${hostapd/*#*/X}" != "X" ] \
  && [ "${1/*apd*/X}" != "X" ] \
  && [ ! -f "$supp_sd/pid" ]
  then
    if ! pidof hostapd >/dev/null \
    && ! pidof sdcsupp >/dev/null
    then
      test -s "${cf:=${hostapd##* }}" \
        || { msg "hostapd config file error"; return 1; }

      if grep -q "^ssid=wb..n_id-not-set" $cf
      then
        wl_vei=${wl_mac#??:??:??}
        msg "setting the hostapd ssid in $cf"
        sed "/^ssid=wb..n/s/_.*/_${wl_vei//:}/" -i $cf && fsync $cf
      fi

      # construct the hostapd invocation and execute (flags can be in /e/n/i)
      #debug=-d                                   ## allow debug/err capture
      #pf=-P$apd_sd/pid                            ## pid only if daemonized
      hostapd=${hostapd/apd/apd $debug $pf}          ## insert extra options
      hostapd=${hostapd/-B}                        ## do not allow daemonize
      msg -n executing: $hostapd'  '
      $hostapd 2>&1 &
      #
      await $apd_sd/$WIFI_DEV 200000; msg .ok
      # check and store the process id
      pidof hostapd >$apd_sd/pid \
        && hostapd=started \
        || return 2
    fi
  fi

  # see if enabled in /e/n/i stanza for wl* -or- requested via cmdline
  sdcsupp=$( sed -n "/$stanza/"',/^[ \t]\+.*.[dp].supp/h;$x;$s/[ \t]*//p' $eni )
  if [ -n "$sdcsupp" -o "${hostapd:-not}" != "started" ] \
  && [ "${1/*host*/X}" != "X" ] \
  && [ ! -f $apd_sd/pid ]
  then
    # launch supplicant if exists and not already running
    if test -e "$SDC_SUPP" && ! ps |grep -q "[ ]$SDC_SUPP" && let n=17
    then
      [ -f $supp_sd/pid ] \
      && { msg "$supp_sd/pid exists"; return 1; }

      supp_opt=$WIFI_80211\ $WIFI_DEBUG\ $WIFI_FIPS
      msg -n executing: $SDC_SUPP -i$WIFI_DEV $supp_opt -s'  '
      #
      $SDC_SUPP -i$WIFI_DEV $supp_opt -s >/dev/null 2>&1 &
      #
      await $supp_sd/$WIFI_DEV 500000
      # check and store the process id
      pidof sdcsupp 2>/dev/null >$supp_sd/pid \
      || { msg ..error; return 2; }
      msg .ok
    fi
  fi

  if [ -e "$EVENT_MON" ] \
  && ! pidof event_mon >/dev/null
  then
    $EVENT_MON -ologging -b0x0000003FA3008000 -m &
    msg "  started: event_mon[$!]"
  fi
  return 0
}

wifi_stop() {
  mkdir -p /tmp/wifi^
  if [ -f /sys/class/net/$WIFI_DEV/address ]
  then
    { read -r ifs < /sys/class/net/$WIFI_DEV/operstate; } 2>/dev/null

    ## de-configure the interface
    # This step allows for a cleaner shutdown by flushing settings,
    # so packets don't use it.  Otherwise stale settings can remain.
    ip addr flush dev $WIFI_DEV && msg "  ...de-configured"

    ## terminate the supplicant by looking up its process id
    if { read -r pid < $supp_sd/pid; } 2>/dev/null && let pid+0
    then
      rm -f $supp_sd/pid
      wifi_kill_pid_of_service $pid sdcsupp
      let rv+=$?
    fi

    ## terminate the hostap daemon by looking up its process id
    if { read -r pid < $apd_sd/pid; } 2>/dev/null && let pid+0
    then
      rm -f $apd_sd/pid
      wifi_kill_pid_of_service $pid hostapd
      let rv+=$?
    fi

    ## terminate event_mon
    killall event_mon 2>/dev/null \
         && msg "event_mon stopped"

    ## return if only stopping sdcsupp or hostapd
    test "${1/*supp*/X}" == "X" -o "${1/*host*/X}" == "X" \
      && { wifi_set_dev ${ifs/dormant/up}; return $rv; }

    ## disable the interface
    # This step avoids occasional problems when the driver is unloaded
    # while the iface is still being used.  The supp may do this also.
    wifi_set_dev down && msg "  ...iface disabled"
  fi

  ## unload fips related modules
  let pid=$( pidof sdcu )+0 && wifi_kill_pid_of_service $pid sdcu
  if mls=$( grep -os -e "^sdc2u" -e "^ath6kl_laird" /proc/modules )
  then
    msg unloading: $mls
    rmmod $mls && rm -f /dev/sdc2u0
  fi

  ## unload ath6kl modules
  if mls=$( grep -os -e "^ath6kl_sdio" -e "^ath6kl_core" /proc/modules )
  then
    msg unloading: $mls
    rmmod $mls
  fi

  [ $? -eq 0 ] && { msg "  ...ok"; return 0; } || return 1
}

wifi_kill_pid_of_service() {
  if kill $1 && n=27
  then
    msg -n $2 terminating.
    while [ -d /proc/$1 ] && let n--; do $usleep 50000; msg -n .; done; msg
  fi
} 2>/dev/null


# ensure this script is available as system command
[ -x /sbin/wireless ] || ln -sf /etc/network/wireless.sh /sbin/wireless

# setting debug-mode from cmdline, overrides conf
case $1 in
  -[td]*)
    WIFI_DEBUG=${1} && shift
    ;;
esac

eni=/etc/network/interfaces

# socket directories
supp_sd=/tmp/wpa_supplicant
apd_sd=/tmp/hostapd

module=${WIFI_MODULE##*/}
usleep='busybox usleep'

# optionally, set fips-mode via cmdline
[ "$1" == fips ] && { shift; WIFI_FIPS=-F; }

# timed-wait (n deciseconds) for prior wifi task
let n=27 && while [ -d /tmp/wifi^ ] && let n--; do usleep 98765; done

# command
case $1 in
  
  stop|down)
    wifi_queryinterface
    echo Stopping wireless $WIFI_DEV $2
    wifi_stop $2 || false
    ;;

  start|up)
    echo Starting wireless
    wifi_config && wifi_start $2 || false
    ;;

  restart)
    $0 stop $2 && exec $0 $WIFI_DEBUG ${WIFI_FIPS:+fips} start $2 || false
    ;;

  status|'')
    wifi_status
    ;;
    
  -h|--help)
    echo "$0"
    echo "  ...stop/start/restart the '$WIFI_PREFIX#' interface"
    echo "Manages the '$WIFI_DRIVER' wireless device driver: $WIFI_MODULE"
    echo
    echo "AP association is governed by the 'sdc_cli' and an active profile."
    echo
    [ "settings" == "$2" ] && grep "^WIFI_[A-Z]*=" $0 && echo
    echo "Flags:  (passed to supplicant)"
    echo "  -t  timestamp debug messages"
    echo "  -d  debug verbosity (-dd even more)"
    echo
    echo "Usage:"
    echo "# ${0##*/} [-tdddd] [fips] {stop|start|restart|status} [supp|host]"
    ;;

  *)
    echo "$0 ? [settings]"
    false
    ;;
esac
E=$?
rm -fr /tmp/wifi^
exit $E
