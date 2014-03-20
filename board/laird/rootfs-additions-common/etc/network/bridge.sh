#!/usr/bin/env ash
# /etc/network/bridge.sh
# Typically, to be called by the network init-script.
# Settings may be applied via cli or the /e/n/i file.
#
# This init-script will setup wireless bridging.
# And relies on the S??network init-script.
# jon.hefling@lairdtech.com

bridge_iface="br0"
bridge_method="manual"
bridge_ports="eth0 wlan0"
bridge_setfd="0"
bridge_stp="off"
  ## defaults in lieu of bridge_* settings from cli or from /e/n/i file


br_start() {
  echo Starting bridged network: $bridge_ports

  brctl addbr $bridge_iface \
    || { echo \ \ ...failed; exit 1; }

  brctl stp $bridge_iface $bridge_stp
  brctl setfd $bridge_iface $bridge_setfd

  modprobe nf_conntrack_ipv4
  echo 1 > /proc/sys/net/ipv4/ip_forward
  echo 1 > /proc/sys/net/ipv4/conf/all/proxy_arp

  for dev in $bridge_ports
  do
    ts $nis $dev restart manual
    # allow 5s for each port to setup
    waitfor_interface net/$dev 5000 up \
      && brctl addif $bridge_iface $dev \
      || { echo \ \ ...bridge port n/a: $dev; exit 1; }
  done

  echo \ \ enabling $bridge_iface
  $ifconfig $bridge_iface up \
    || { echo \ \ ...failed; exit 1; }

  echo \ \ installing L2 bridge rules
  read braddr < /sys/class/net/$dev/address

  # prevent bridge ARP packets from interfering w/DHCP
  ebtables -A FORWARD -i wlan0 --protocol 0x0806 --arp-mac-src $braddr -j DROP

  # apply arp nat for wireless
  ebtables -t nat -A POSTROUTING -o wlan0 -j arpnat --arpnat-target ACCEPT
  ebtables -t nat -A PREROUTING -i wlan0 -j arpnat --arpnat-target ACCEPT

  # route EAPoL for wireless
  ebtables -t broute -A BROUTING -i wlan0 --protocol 0x888e -j DROP

  echo \ \ ...bridge init completed
}

br_stop() {
  echo Stopping bridged network support.

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

    echo \ \ disabling $bridge_iface
    $ifconfig $bridge_iface down
    brctl delbr $bridge_iface \
      && echo \ \ ...done
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
  if ps ax |grep -q 'S[0-9][0-9]bridge.*start'
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
    exit 1;
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
  test $n -ge 10 && echo -en "  ...waited ${n}ms${mac:+\n}${3:+\n}"
  test -n "$mac" && rv=0 || rv=1
  return $rv
} 2>/dev/null

ts() {
  # timestamp passed-in command+args
  read -rs us is < /proc/uptime
  echo \ br: ${us}s - $@
  $@
}


# Invocation:
# bridge [cmd] [iface] [bridge_settings...]
#
eni=/etc/network/interfaces

nis=/etc/init.d/S??network

ifconfig='ip link set dev'

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

  [ -n "$bridge_iface" ] \
  && bridge_settings=$( sed -n "/^iface $bridge_iface inet/,/^$/\
     s/^[ \t][ ]*\(bridge_[a-z]*\)[ ]\(.*\)/\1=\"\2\"/p" $eni 2>/dev/null )
fi
if [ -n "$bridge_settings" ]
then
: echo $self $bridge_settings
  eval $bridge_settings
fi

[ -x /usr/sbin/brctl ] || { echo $self: brctl n/a; exit 1; }
[ -x /sbin/ebtables ] || { echo $self: ebtables n/a; exit 1; }

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

  *)
    echo "Bridging mode init-script."
    echo " - typically called by the network init-script"
    echo
    echo "Usage:"
    echo "# ${0##*/} {stop|start|restart|status} [<name>] [<param=value> ...]"
    exit 1
esac

