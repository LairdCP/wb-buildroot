#!/usr/bin/env ash
# /etc/network/bridge.sh
# This script sets up wireless bridging.
# And works with the S??network init-script.
# Settings may be applied via cli or the /e/n/i file.
# jon.hefling@lairdtech.com
#
# Usage:
#   bridge.sh {stop|start|restart|status} [<name>] [<param=value> ...]
#

bridge_iface="br0"              ## iface device name
bridge_method="manual"          ## config method is manual/static/dhcp/...
bridge_ports="eth0 wlan0"       ## iface ports to be bridged
bridge_fd="0"                   ## set forwarding delay in seconds
bridge_stp="off"                ## spanning tree protocol is off/on
bridge_setup="auto"             ## setup is auto/manual, and any flags [-v]
  ##
  ## defaults in lieu of bridge_* settings from cli or from the /e/n/i file


br_start() {
  echo Starting bridge-mode $bridge_iface: $bridge_ports

  # create bridge device
  brctl addbr $bridge_iface \
    || { echo \ \ ...failed; exit 1; }

  # set bridge device options
  brctl stp $bridge_iface $bridge_stp
  brctl setfd $bridge_iface $bridge_fd

  # support arp/forwarding
  modprobe nf_conntrack_ipv4
  echo 1 > /proc/sys/net/ipv4/ip_forward
  echo 1 > /proc/sys/net/ipv4/conf/all/proxy_arp

  # check/start each port
  for dev in $bridge_ports
  do
    test "${bridge_setup/auto*/a}" == "a" \
      && $nis $dev restart manual

    # allow 5s for bridge port to setup
    waitfor_interface net/$dev 5000 up \
      && brctl addif $bridge_iface $dev \
      && $ifconfig $dev up \
      || { echo \ \ ...bridge port n/a: $dev; exit 1; }
  done

  # activate bridge-mode
  $ifconfig $bridge_iface up \
    || { echo \ \ ...bridge n/a; exit 1; }

  # display bridge/ports
  brctl show $bridge_iface

  # read mac of the virtual bridge interface
  read braddr < /sys/class/net/$bridge_iface/address

  echo Installing L2 bridging rules.
  # prevent bridge ARP packets from interfering w/DHCP
  ebtables -A FORWARD -i wlan0 --protocol 0x0806 --arp-mac-src $braddr -j DROP
  # apply arp nat for wireless
  ebtables -t nat -A POSTROUTING -o wlan0 -j arpnat --arpnat-target ACCEPT
  ebtables -t nat -A PREROUTING -i wlan0 -j arpnat --arpnat-target ACCEPT
  # route EAPoL for wireless
  ebtables -t broute -A BROUTING -i wlan0 --protocol 0x888e -j DROP
}

br_stop() {
  echo Stopping bridge-mode $bridge_iface: $bridge_ports

  ebtables -t broute -F
  ebtables -t nat -F
  ebtables -F

  echo 0 > /proc/sys/net/ipv4/conf/all/proxy_arp
  echo 0 > /proc/sys/net/ipv4/ip_forward

  if [ -d /sys/class/net/$bridge_iface ]
  then
    for dev in $bridge_ports
    do
      brctl delif $bridge_iface $dev
      $nis $dev stop
    done

    echo Removing $bridge_iface
    $ifconfig $bridge_iface down
    brctl delbr $bridge_iface
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

[ -x /usr/sbin/brctl ] || { echo $self: brctl n/a; exit 1; }
[ -x /sbin/ebtables ] || { echo $self: ebtables n/a; exit 1; }

test "${bridge_setup/*-v*/v}" == "v" \
  && verbose=true || verbose=false

ifconfig='ip link set dev'

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
    sed '2,/^[^#]/s/.*/&/;/^$/q' $0
esac

