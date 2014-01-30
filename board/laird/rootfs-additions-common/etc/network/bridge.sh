#!/usr/bin/env ash
# /etc/network/bridge.sh
# Typically, to be called by the network init-script.
# Settings may be applied via cli or the /e/n/i file.
#
# jon.hefling@lairdtech.com

bridge_device="br0"
bridge_method="manual"
bridge_ports="eth0 wlan0"
bridge_setfd="0"
bridge_stp="off"
  ## defaults in lieu of bridge_* settings from cli or from /e/n/i file


show_bridge_mode() {
  bridge_info() {
    [ 3 -eq $# ] \
    && echo -e "Bridge mode interface '$1' active using '$2' and '$3'."
  }
  if ps ax |grep -q 'S[0-9][0-9]bridge.*start'
  then
    echo "Bridge mode setting up..."
  elif grep -q 'br[0-9]' /proc/net/dev
  then
    bmi=$( brctl show |sed -n '2{p;n;p;}' |grep -o '[a-z][a-z][a-z]*[0-9]' )
    bridge_info $bmi
  else
    exit 1;
  fi
}

waitfor_interface() {
  # timeout is 3s
  let n=30
  addr=/sys/class/net/$1/address
  until ! let n-- || mac=$( grep -so ..:.. $addr ); do usleep 100000; done
  [ -n "$mac" ] && return 0 || return 1
}

start() {
  echo Starting bridged network support: $bridge_ports

  for dev in $bridge_ports
  do
    if ! waitfor_interface $dev
    then
      #echo \ \ ifrc $dev up
      #
      ifrc $dev up \
      && waitfor_interface $dev \
      || { echo \ \ ...port n/a: $dev; exit 1; }
    fi
  done

  brctl addbr $bridge_device
  brctl stp $bridge_device $bridge_stp
  brctl setfd $bridge_device $bridge_setfd
  brctl addif $bridge_device $bridge_ports

  echo \ \ enablng $bridge_device
  ifconfig $bridge_device up || { echo \ \ ...failed; exit 1; }
  usleep 500000
  
  modprobe nf_conntrack_ipv4
  echo 1 > /proc/sys/net/ipv4/conf/all/proxy_arp
  echo 1 > /proc/sys/net/ipv4/ip_forward
    
  # disable ARP packets from interfering w/DHCP by dropping dev's mac address 
  : ebtables -A FORWARD --in-interface $dev --protocol ARP --arp-mac-src $mac -j DROP
         
  ebtables -t nat -A PREROUTING --in-interface $dev -j arpnat --arpnat-target ACCEPT
  ebtables -t nat -A POSTROUTING --out-interface $dev -j arpnat --arpnat-target ACCEPT
  ebtables -t broute -A BROUTING --in-interface $dev --protocol 0x888e -j DROP
}

stop() {
  echo Stopping bridged network support.

  ebtables -t broute -F
  ebtables -t nat -F
  ebtables -F
  echo 0 > /proc/sys/net/ipv4/conf/all/proxy_arp
  echo 0 > /proc/sys/net/ipv4/ip_forward

  if [ -d /sys/class/net/$bridge_device ]
  then
    echo \ \ disabling $bridge_device
    ifconfig $bridge_device down 2>/dev/null
    usleep 500000

    # delete bridge name if it exists
    brctl show |grep -q $bridge_device \
    && { echo -en \ \ ; brctl delbr $bridge_device && echo \ \ done; }
  fi
}

# invocation:
# bridge [{stop|start|restart}] [iface] [bridge_settings...]
#
eni=/etc/network/interfaces
self=\ \<\>\ ${0##*/}

#echo $self $@
cmd=$1 && shift

[ -x /usr/sbin/brctl ] || { echo $self: brctl n/a; exit 1; }
[ -x /sbin/ebtables ] || { echo $self: ebtables n/a; exit 1; }
[ -x /sbin/ifrc ] || { echo $self: ifrc n/a; exit 1; }

# take subsequent parameters as bridge device and settings
# the bridge_device may also be included in the settings
if [ -n "$1" ]
then
  bridge_device=$1 && shift
fi

# use passed-in bridge_* settings or read bridge stanza settings from /e/n/i
if [ "${1%%_*}" == "bridge" ]
then
  bridge_settings="$@"
else
  eval `sed -n "s/^iface \(br[i0-9][dge]*\) inet \([a-z]*\)/\
     bridge_device=\1 bridge_method=\2/p" $eni 2>/dev/null`

  [ -n "$bridge_device" ] \
  && bridge_settings=$( sed -n "/^iface $bridge_device inet/,/^$/\
     s/^[ \t][ ]*\(bridge_[a-z]*\)[ ]\(.*\)/\1=\"\2\"/p" $eni 2>/dev/null )
fi
if [ -n "$bridge_settings" ]
then
  #echo $self settings: $bridge_settings
  eval $bridge_settings
fi

case $cmd in
  stop)
    stop
    ;;

  start)
    start
    ;;

  restart)
    stop
    start
    ;;

  '')
    show_bridge_mode
    ;;

  *)
    echo "Usage: $0 {stop|start|restart} [<iface>] [<bridge_param=value> ...]"
    exit 1
    ;;
esac
exit 0

