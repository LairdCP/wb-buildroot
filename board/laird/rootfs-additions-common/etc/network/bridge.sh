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
# contact: support@lairdconnect.com

# /etc/network/bridge.sh v112
# Sets up Ethernet L2 Bridging for USB or WiFi.
# Bridge ports are handled via init.d/S??network.
# Settings applied via cmd-line or the /e/n/i file.
#
# Usage:
#   bridge.sh {stop|start|restart|status} [<name>] [<param=value> ...]
#

bridge_iface="br0"              ## iface device name
bridge_method="manual"          ## config is manual/static/dhcp
bridge_ports="eth0 wlan0"       ## iface ports to be bridged
bridge_fd="0"                   ## set forwarding delay in seconds
bridge_stp="off"                ## spanning tree protocol is off/on
bridge_mcs="off"                ## multicast snooping can be off/on
bridge_setup="auto"             ## setup is auto/manual, and any flags:
  ##                            --verbose or -v
  ##
  ## defaults in lieu of bridge_* settings from cli or from the /e/n/i file


br_start() {
  echo Starting bridge-mode $bridge_iface: $bridge_ports

  # create bridge device if necessary
  test ! -s /sys/class/net/$bridge_iface/address \
    && $brctl addbr $bridge_iface \
    || { echo \ \ ...failed; exit 1; }

  # set bridge device options
  $brctl stp $bridge_iface $bridge_stp
  $brctl setfd $bridge_iface $bridge_fd

  # disable multicast snooping
  [ "$bridge_mcs" == "off" ] && \
  fn 'echo 0 > /sys/devices/virtual/net/$bridge_iface/bridge/multicast_snooping'

  # disable bridge netfilter
  if [ -d /proc/sys/net/bridge ]
  then
    fn 'echo 0 > /proc/sys/net/bridge/bridge-nf-call-arptables'
    fn 'echo 0 > /proc/sys/net/bridge/bridge-nf-call-ip6tables'
    fn 'echo 0 > /proc/sys/net/bridge/bridge-nf-call-iptables'
  fi

  bridge_ports_check
  # activate bridge-mode
  $ip link set dev $bridge_iface up \
   || { echo \ \ ...bridge n/a; exit 1; }

  # display bridge/ports
  brctl show $bridge_iface

  # read mac of the virtual bridge interface
  read braddr < /sys/class/net/$bridge_iface/address

  echo Installing L2 bridging rules.
  # flush bridging rules
  $ebtables -t broute -F
  $ebtables -t nat -F
  $ebtables -F
  if ${phy80211:-false}
  then
    # wait n deciseconds for wireless setup to complete
    n=27; while [ -d /tmp/wifi^ ] && let n--; do usleep 98765; done

    # apply ARP NAT for wireless
    $ebtables -t nat -A POSTROUTING -o wlan0 -j arpnat --arpnat-target ACCEPT
    $ebtables -t nat -A PREROUTING -i wlan0 -j arpnat --arpnat-target ACCEPT
    # route EAPoL for wireless
    $ebtables -t broute -A BROUTING -i wlan0 --protocol 0x888e -j DROP
  fi

  # prevent bridge ARP packets from interfering with DHCP
  $ebtables -A FORWARD -i any --protocol 0x0806 --arp-mac-src $braddr -j DROP
}

br_stop() {
  echo Stopping bridge-mode $bridge_iface: $bridge_ports
  # flush bridging rules
  $ebtables -t broute -F
  $ebtables -t nat -F
  $ebtables -F

  if [ -d /sys/class/net/$bridge_iface ]
  then
    for dev in $bridge_ports
    do
      if [ -d /proc/sys/net/ipv4/conf/$dev ]
      then
        fn "echo 0 > /proc/sys/net/ipv4/conf/$dev/proxy_arp"
      fi
      $ip link set promisc off dev $dev
      $brctl delif $bridge_iface $dev
      $nis $dev stop
    done
    echo Removing $bridge_iface
    $ip link set dev $bridge_iface down
    $brctl delbr $bridge_iface
  fi
}

br_status() {
  br_info() {
    echo -e "Bridge:\t$1:" \
      `sed 's/up/active/' /sys/class/net/$1/operstate 2>/dev/null`

    brctl showstp $1 \
      |sed -n '/port id/{s/.*state[\t ]*\(.*\)/\1_/;H;g;s/^/\t/;s/ (.)/: /p};h' \
      |tr -d '\n' \
      |sed 's/_/\n/g'
  }
  if ps ax |grep -q '[b]ridge.*start'
  then
    echo "Bridge mode setting up..."
  elif grep -q 'br[0-9]' /proc/net/dev
  then
    if [ -z "$cmd" ]
    then
      br_info $( brctl show |sed -n '2{p;n;p;}' |grep -o '[a-z][a-z][a-z]*[0-9]' )
    else
      echo
      ebtables -t broute -L |sed '/table/{N;s/.*/\t-= ebtables broute =-/}'
      echo
      ebtables -t nat -L |sed '/table/{N;s/.*/\t-= ebtables nat =-/}'
      echo
      ebtables -t filter -L |sed '/table/{N;s/.*/\t-= ebtables filter =-/}'
      echo
      echo -e "\t-= bridge status =-"
      brctl showstp $bridge_iface |sed 's/flags//;/^$/d'
      brctl showmacs $bridge_iface
      echo
    fi
  else
    exit 1
  fi
}

bridge_ports_check() {
  # check/start each port
  for dev in $bridge_ports
  do
    test "${bridge_setup/auto*/a}" == "a" \
      && $nis $dev start manual

    # allow 5s for a bridge port to setup
    if waitfor_interface net/$dev 5000 up \
    || { echo \ \ device n/a: $dev; exit 1; }
    then
      # check if port is wireless device
      [ -d /sys/class/net/$dev/phy80211 ] && phy80211=true

      # (re)start supplicant with bridge interface name
      $phy80211 && wireless -b${bridge_iface} restart supp

      if [ ! -d /sys/devices/virtual/net/$bridge_iface/brif/$dev ]
      then
        $brctl addif $bridge_iface $dev \
          && $ip link set promisc on dev $dev \
          && $ip link set $dev up \
          || { echo \ \ ...bridge port n/a: $dev; exit 1; }
      fi
      fn "echo 1 > /proc/sys/net/ipv4/conf/$dev/proxy_arp"
    fi
  done
}

waitfor_interface() {
  # args: <class/iface> [<milliseconds> [{up|down}]]
  let n=0 w=${2:-0}
  while : wait increments of 10ms for address
  do
    { mac=; read -rs mac </sys/class/${1}/address; } 2>/dev/null
    test "${mac/??:??:??:??:??:??/up}" == "up" && break
    test "$3" == "down" && break
    test $n -lt $w && let n+=10 && usleep 9999 || break
  done
  test $n -ge 10 \
    && echo -en "  ...waited ${n}ms for $1\n"
  test -n "$mac"
  return $?
} 2>/dev/null

fn() {
  # verbosely show cmd+args before executing cmd+args
  { $verbose && echo \+ "$*"; } 2>/dev/null; eval "$*"
}


# Invocation:
# bridge [cmd] [iface] [bridge_settings...]
#
eni=/etc/network/interfaces

nis=/etc/init.d/S??network

self=\ \<\>\ ${0##*/}
cmd=$1 && shift

# Take subsequent args as device and bridge_*param=value
# or read settings from bridge stanza in the /e/n/i file.
if [ -n "$1" ]
then
  bridge_iface=$1 && shift
fi
if [ "${1%%_*}" == "bridge" ]
then
  bridge_settings="$@"
else
  eval `sed -n "s/^iface \(br[i0-9][dge]*\) inet \([a-z]*\)/\
     bridge_iface=\1 bridge_method=\2/p" $eni 2>/dev/null`

  test -n "$bridge_iface" \
    && bridge_settings=$( sed -n "/^iface $bridge_iface inet/,/^$/\
       s/^[ \t]\+\(bridge_[a-z]*\)[ ]\(.*\)/\1=\"\2\"/p" $eni 2>/dev/null )
fi
test -n "$bridge_settings" \
  && eval $bridge_settings

# The bridging tool is provided by bridge-utils or busybox.
[ -x /usr/sbin/brctl ] || { echo $self: brctl n/a; exit 1; }
[ -x /sbin/ebtables ] || { echo $self: ebtables n/a; exit 1; }

test "${bridge_setup/*-v*/v}" == "v" \
  && verbose=true || verbose=false

ebtables=fn\ 'ebtables'
brctl=fn\ 'brctl'
ip=fn\ 'ip'

export bridge_=^
case $cmd in
  stop)
    br_stop
    ;;

  start)
    br_start
    ;;

  restart)
    br_stop
    br_start
    ;;

  ''|status)
    br_status
    ;;

  help|*-h*)
    sed -n "/^#.*bridge/,/^$/{s/^#/ /;p;/^$/q}" $0
esac

