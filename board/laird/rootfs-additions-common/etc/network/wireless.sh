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

# /etc/network/wireless.sh - driver-&-firmware configuration for wb45n/wb50n
# 20120520/20160604

WIFI_PREFIX=wlan                              ## iface to be enumerated
WIFI_DRIVER=ath6kl_sdio                       ## device driver "name"
WIFI_MODULE=ath/ath6kl/ath6kl_sdio.ko         ## kernel module path
WIFI_KMPATH=/lib/modules/`uname -r`/kernel/drivers/net/wireless
#WIFI_FWPATH=/lib/firmware/ath6k/AR6003/hw2.1.1
#WIFI_NVRAM=/lib/nvram/nv

WIFI_PROFILES=/etc/summit/profiles.conf       ## sdc_cli profiles.conf

## monitor, supplicant and cli - comment out to disable . . .
EVENT_MON=/usr/bin/event_mon
SDC_SUPP=/usr/bin/sdcsupp
SDC_CLI=/usr/bin/sdc_cli

## supplicant options
WIFI_80211=-Dnl80211                          ## supplicant driver nl80211

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
} 2>/dev/null

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
       -e "/${module%%_*}"'/H;${x;p}' -n

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
  # arg1 is timeout (deciseconds) to await availability
  let x=0 timeout=${1:-0} && msg -n '  '
  while [ $x -le $timeout ]
  do
    if [ -z "$WIFI_DEV" ]
    then # determine iface via device path
      for wl_dev in /sys/class/net/*/phy80211
      do
        test -d "${wl_dev//\*}"/device/subsystem/drivers/$WIFI_DRIVER \
          && WIFI_DEV=${wl_dev#*net/} WIFI_DEV=${WIFI_DEV%/*} \
          && break
      done
    fi
    if [ -n "$WIFI_DEV" ] \
    && read -rs wl_mac < /sys/class/net/$WIFI_DEV/address
    then # check if device address is available/ready
      [ "${wl_mac/??:??:??:??:??:??/addr}" == addr ] && break
    else
      let $timeout || break
    fi
    $usleep 87654 && { let x+=1; msg -n .; }
  done 2>/dev/null
  let $x && msg ${x}00mSec
  test -n "$WIFI_DEV"
}

wifi_fips_mode() {
  if [ -f "$WIFI_KMPATH/laird_fips/ath6kl_laird.ko" ] \
  && [ -f "$WIFI_KMPATH/laird_fips/sdc2u.ko" ] \
  && : #[ -x "/usr/bin/sdcu" ]
  then
    msg "configuring for FIPS mode"
    # note - only 'WPA2 EAP-TLS' is supported
    ath6kl_params=$ath6kl_params\ fips_mode=y
    modprobe ath6kl_core $ath6kl_params || return 1
    insmod $WIFI_KMPATH/laird_fips/sdc2u.ko || return 1
    insmod $WIFI_KMPATH/laird_fips/ath6kl_laird.ko || return 1

    # create device node for user space daemon
    major=$( sed -n '/sdc2u/s/^[ ]*\([0-9]*\).*/\1/p' /proc/devices )
    minor=0
    rm -f /dev/sdc2u0
    mknod /dev/sdc2u0 c $major $minor || return 1
    # launch daemon to perform crypto operations
    sdcu >/var/log/sdcu.log 2>&1 &
    cat /var/log/sdcu.log | logger
  else
    msg "configuring non-FIPS mode"
    WIFI_FIPS=
  fi
  return 0
}

wifi_reset_gpio(){
  msg "  ...mmc failed to register, retrying: ${WIFI_DEV:-?}";
  reset_gpio_path=/sys/module/ath6kl_sdio/parameters/reset_pwd_gpio
  if [ -f "$reset_gpio_path" ]
  then
    { read -r reset_pwd_gpio < "$reset_gpio_path"; } 2>/dev/null
    case $reset_pwd_gpio in
    #WB50
      "131")
      echo 0 > /sys/class/gpio/pioE3/value
      $usleep 2500
      echo 1 > /sys/class/gpio/pioE3/value
      $usleep 2500
      break
      ;;
    #WB45
    "28")
      echo 0 > /sys/class/gpio/pioA28/value
      $usleep 2500
      echo 1 > /sys/class/gpio/pioA28/value
      $usleep 2500
      break
      ;;
    *)
      msg "  ...reset GPIO not found: ${WIFI_DEV:-?}";
      ;;
    esac
  fi
}

wifi_start() {
  wifi_lock_wait
  if grep -q "${module/.ko/}" /proc/modules
  then
    msg "checking interface/mode"
    ## see if this 'start' has a fips-mode conflict
    [ -c /dev/sdc2u* ] && fm=-F || fm=
    if ! { wifi_queryinterface || { msg "  ...n/a"; false; }; } \
    || { [ "$WIFI_FIPS" != "$fm" ] && msg "  ...mode"; }
    then
      msg ${PS1}${0##*/} $flags ${WIFI_FIPS:+fips} restart
      exec $0 $flags ${WIFI_FIPS:+fips} restart
    fi
  else
    ## check for 'slot_b=' setting in kernel args
    grep -o 'slot_b=.' /proc/cmdline \
    && msg "warning: \"slot_b\" setting in bootargs"

    modprobe cfg80211

    ## atheros driver options are in modprobe.d/ath6kl.conf
    ath6kl_params=""

    ## check fips-mode support
    if [ -n "$WIFI_FIPS" ]
    then
      wifi_fips_mode || { msg " ...fips-mode error"; return 1; }
    else
      modprobe ath6kl_core $ath6kl_params
    fi

    modprobe $WIFI_DRIVER \
    || { msg "  ...driver failed to load"; return 1; }

    ## await enumerated interface
    wifi_queryinterface 27
    if [ ! -n "$WIFI_DEV"  ]
    then
      wifi_reset_gpio
      wifi_queryinterface 27 \
        || { msg "  ...driver init failure, iface n/a: ${WIFI_DEV:-?}"; }
    fi

  fi

  # enable interface
  [ -n "$WIFI_DEV" ] \
  && { msg -n "activate: $WIFI_DEV  ..."; wifi_set_dev up && msg ok; } \
  || { msg "iface $WIFI_DEV n/a, FW issue?  -try: wireless restart"; return 1; }

  # dynamic wait for socket args: <socket> <interval>
  await() { n=27; until [ -e $1 ] || ! let n--; do msg -n .; $usleep $2; done; }

  # disable wifi for systems that are configured for dcas' ssh_disable
  CONF_FILE=/etc/dcas.conf
  [ -s $CONF_FILE ] && [ `grep ^ssh_disable $CONF_FILE` ] && $SDC_CLI disable

  # choose to run either hostapd or the supplicant (default)
  # check the /e/n/i wifi_dev stanza(s)
  stanza="/^iface ${WIFI_DEV} inet/,/^$/"

  # hostapd - enabled in /e/n/i -or- via cmdline
  if [ ! -f "$supp_sd/pid" -a "${1/*supp*/X}" != "X" -a "$1" != "manual" ] \
  && hostapd=$( sed -n "${stanza}{/hostapd/{s/[ \t]*//;/^[^#]/{p;q}}}" $eni ) \
  && [ -n "$hostapd" ]
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

      $SDC_CLI radio_init_4_hostapd
      # construct the hostapd invocation and execute (flags can be in /e/n/i)
      #debug=-d                                   ## allow debug/err capture
      #pf=-P$apd_sd/pid                            ## pid only if daemonized
      hostapd=${hostapd/apd/apd $debug $pf}          ## insert extra options
      hostapd=${hostapd/-B}                        ## do not allow daemonize
      msg -n executing: $hostapd'  '
      $hostapd 2>&1 &
      #
      await $apd_sd/$WIFI_DEV 200000
      # check and store the process id
      pidof hostapd 2>/dev/null >$apd_sd/pid \
      || { msg ..error; return 2; }
      msg .ok
      hostapd=started
    fi
  fi

  # supplicant - enabled in /e/n/i -or- via cmdline
  if [ ! -f "$apd_sd/pid" -a "${1/*host*/X}" != "X" -a "$1" != "manual" ] \
  && sdcsupp=$( sed -n "${stanza}{/[dp].supp/s/[ \t]*//;/^[^#]/{p;q}}}" $eni ) \
  && [ -n "$sdcsupp" -o "${hostapd:-not}" != "started" ]
  then
    # launch supplicant if exists and not already running
    if test -e "$SDC_SUPP" && ! ps |grep -q "[ ]$SDC_SUPP" && let n=17
    then
      [ -f $supp_sd/pid ] \
      && { msg "$supp_sd/pid exists"; return 1; }

      supp_opt=$WIFI_80211\ $flags\ $WIFI_FIPS
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
    $EVENT_MON -ologging -b0x000000FFA3008000 -m &
    msg "  started: event_mon[$!]"
  fi
  return 0
}

wifi_stop() {
  wifi_lock_wait
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
  if mls=$( grep -os -e "^${WIFI_DRIVER%[_-]*}[^ ]*" /proc/modules )
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

wifi_lock_wait() {
  w4it=27
  # allow upto (n) deciseconds for a prior stop/start to finish
  while [ -d /tmp/wifi^ ] && let --w4it; do $usleep 98765; done
  mkdir -p /tmp/wifi^
} 2>/dev/null

# ensure this script is available as system command
[ -x /sbin/wireless ] || ln -sf /etc/network/wireless.sh /sbin/wireless

# parse cmdline flags
while [ ${#1} -gt 1 ]
do
  case $1 in
    -h*) ## show usage
      break
      ;;
    -*) ## supplicant flags
      flags=${flags:+$flags }$1
      ;;
    -F|fips) ## mode
      WIFI_FIPS=-F
      ;;
    *)
      break
  esac
  shift
done

eni=/etc/network/interfaces

# socket directories
supp_sd=/var/run/wpa_supplicant
apd_sd=/var/run/hostapd

module=${WIFI_MODULE##*/}
usleep='busybox usleep'

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
    $0 stop $2 && exec $0 $flags ${WIFI_FIPS:+fips} start $2 || false
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
    echo "  -d  debug verbosity is multilevel"
    echo "  -b  specify bridge interface name (-bbr0)"
    echo
    echo "Option:  (link service to invoke)"
    echo "  supp  ..target the supplicant"
    echo "  host  ..target hostapd"
    echo "  manual  ..no service"
    echo
    echo "Usage:"
    echo "# ${0##*/} [flags [fips]] {stop|start|restart|status} [option]"
    ;;

  *)
    false
    ;;
esac
E=$?
rm -fr /tmp/wifi^
exit $E
