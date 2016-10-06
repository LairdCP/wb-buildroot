
#!/usr/bin/env ash
# ipv6.ifplugd.script

dev=$2
cmd=$1

#Parse the e/n/i file to determine if we are configured for stateful DHCPv6
dhcp=$(awk -v par="$2" '/^iface/ && $2==par && $3=="inet6" && $4=="dhcp" {f=1} \
    /^iface/ && $2!=par {f=0} f {print "dhcp"; f=0}' /etc/network/interfaces)

#Parse the e/n/i file to determine if we are configured for stateless DHCPv6
auto=$(awk -v par="$2" '/^iface/ && $2==par && $3=="inet6" && $4=="auto" {f=1} \
    /^iface/ && $2!=par {f=0} f && /^\s*dhcp/ {print $2; f=0}' /etc/network/interfaces)

#Set the type flag accordingly
if [ "$dhcp" == "dhcp" ]; then
    echo "Stateful DHCPV6" >> /tmp/dhclient6
    type="-N"
elif [ "$auto" == "1" ]; then
    echo "Stateless DHCPV6" >> /tmp/dhclient6
    type="-S"
fi

# Stop the dhclient
# $dev The interface name. If empty stop all instances of dhclient
dhclient6_stop() {
    for pid in \
    $( ps ax |sed -n "/$dev/s/^[ ]*\([0-9]*\).*[\/ ]\(dhclient\) -.*/\1/p" )
    do
      kill $pid
    done
}

# Release the current ipv6 lease
# $1 The interface name
# We only need to do this if we are using stateful dhcpv6
dhclient6_release() {
    if [ "$type" == "-N" ]; then
      dhclient -6 -r $dev &
    fi
}

# Start the dhclient
# $type -N for stateful dhcpv6, -S stateless dhcpv6
# $1 Interface name
dhclient6_start() {
    if [ ! -z $type  ]; then
        dhclient6_stop $dev
        dhclient -6 $type -nw $dev &
    fi
}

# $1 The command
# $2 The name of the interface
case $cmd in
  start)
    dhclient6_start $dev
  ;;
  stop)
    dhclient6_stop $dev
  ;;
  release)
    dhclient6_release $dev
  ;;
  renew)
    dhclient6_release $dev
    dhclient6_start $dev
  ;;
esac
