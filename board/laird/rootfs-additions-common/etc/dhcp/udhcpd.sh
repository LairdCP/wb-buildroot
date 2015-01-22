#!/usr/bin/env ash

# Copyright (c) 2015, Laird
# Permission to use, copy, modify, and/or distribute this software for any      !
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

# /etc/dhcp/udhcpd.sh
# A wrapper for udhcpd with process-id control.
#
# Usage:
#  ./udhcpd.sh -i<iface> [-fS] <config>
#          ...start server for iface using config file
#
#  ./udhcpd.sh -i<iface> stop
#          ...stops server for iface
#
#  ./udhcpd.sh -i<iface>
#          ...dump leases for iface and show status
#


msg() {
  echo "$@"
  test "${1:0:3}" == "err" \
    && exit 1
}

# invocation
while let $#
do
  case $1 in
    -h) ## show usage
      sed -n '3,/^[^#]/s/^./ /p;/^$/q' $0
      exit 0
      ;;
    -i*) ## interface
      dev=${1:2}
      ;;
    -*) ## flag
      [ "${1/*f*/f}" != "f" ] || b=\&
      flags=${flags:+$flags }${1}
      ;;
    stop)
      act=stop
      ;;
    *) ## conf
      act=start
      conf=$1
      ;;
  esac
  shift
done

test -n "$dev" \
  || msg "error: -i<iface> is required"

test -d /var/lib/dhcp \
  || ln -s /tmp /var/lib/dhcp

case $act in
  stop)
    if { read -rst1 pid < /var/lib/dhcp/udhcpd.$dev.pid; } 2>/dev/null
    then
      if [ -d /proc/$pid ]
      then
        msg -n "stopping udhcpd on $dev ..."
        echo `kill $pid`
      fi
      rm /var/lib/dhcp/udhcpd.$dev.pid
    fi
    ;;

  start) ## run on iface in config file path
    : ${conf:=/etc/dhcp/udhcpd.$dev.conf}
    test "$conf" != "start" \
      || msg "error: try -h"

    # conf required
    test -f "$conf" \
      || msg "error: $conf n/a"

    # get/set/chk pidfile
    pf=$( sed -n '/^pidfile/s/.* //p' $conf )
    test -f "${pf:=/var/lib/dhcp/udhcpd.$dev.pid}" \
      && msg "error"

    # leases file must exist for daemon mode
    lf=$( sed -n '/^lease_file/s/.* //p' $conf )
    : >>${lf:=/var/lib/dhcp/udhcpd.$dev.leases}

    msg "starting udhcpd on $dev"
    eval udhcpd $flags $conf $b

    if [ -n "$b" ]
    then
      echo $! >$pf
    else
      sleep 1
      ps ax -opid,args \
       |sed -n "/[u]dhcpd .*$dev/s/ *\([^ ]\+\).*/\1/p" >$pf
    fi
    ;;

  status|'') ## show if running and dumpleases
    if [ -f /var/lib/dhcp/udhcpd.$dev.leases ]
    then
      set -x
      dumpleases -f /var/lib/dhcp/udhcpd.$dev.leases
    { set +x; echo; } 2>/dev/null
    fi
    msg "+ ps ax -opid,stat,args"
    ps ax -opid,stat,args \
     |grep "$pid.*[u]dhcpd .*conf" \
        || { msg "  ..."; false; }
esac
exit $?

#
#  BusyBox v1.21.1 multi-call binary.
#
#  udhcpd [-fS] [CONFFILE]
#
#    DHCP server
#
#        -f      Run in foreground
#        -S      Log to syslog too
#
#
#  dumpleases [-r|-a] [-f LEASEFILE]
#
#    display DHCP leases granted by udhcpd
#
#        -f,--file=FILE  Lease file
#        -r,--remaining  Show remaining time
#        -a,--absolute   Show expiration time
#

