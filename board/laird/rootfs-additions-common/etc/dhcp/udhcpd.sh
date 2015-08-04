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

# /etc/dhcp/udhcpd.sh
# An extended support wrapper for udhcpd with process-id control.
#
# Usage:
# ./udhcpd.sh -i<iface> [-fS] [<conf>] [stop|start|{status}]
#
# Flags:
#      -f  run in foreground
#      -S  log to syslog too; debug
#
# Examples:
# ./udhcpd.sh -i<iface> [-fS] <conf>
#          ...start server for iface using config file
#
# ./udhcpd.sh -i<iface> stop
#          ...stops server for iface
#
# ./udhcpd.sh -i<iface>
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
      exec sed -n "/^# .*${0##*/}/,/^[^#]/{s/^#/ /p}" $0
      ;;
    -i*) ## interface
      dev=${1:2}
      ;;
    -*) ## flags; check fg or set bg
      [ "${1/*f*/f}" != "f" ] || b=\&
      flags=${flags:+$flags }${1}
      ;;
    stop)
      act=stop
      ;;
    start)
      act=start
      ;;
    status)
      act=status
      ;;
    *.conf) conf=$1
      act=start
      ;;
    *?)
      msg "error: try -h"
  esac
  shift
done
test -n "$dev" \
  || msg "error: -i<iface> is required"

# dir exists for dhcp
test -d /var/lib/dhcp \
  || ln -s /tmp /var/lib/dhcp

: ${conf:=/etc/dhcp/udhcpd.$dev.conf}
# main
case ${act:-status} in
  stop)
    if { read -rst1 pid < /var/lib/dhcp/udhcpd.$dev.pid; } 2>/dev/null
    then
      if [ -d /proc/$pid ]
      then
        msg -n "stopping udhcpd on $dev ..."
        echo `kill $pid`
      fi
    fi
    rm -f /var/lib/dhcp/udhcpd.$dev.pid
    ;;

  start) ## run on iface in config file path
    # conf required
    test -f "$conf" \
      || msg "error: $conf n/a"

    # iface must exist
    test -s /sys/class/net/$dev/address \
      || msg "error: $dev n/a"

    # get/set/chk pidfile
    pf=$( sed -n '/^pidfile/s/.* //p' $conf )
    test -s "${pf:=/var/lib/dhcp/udhcpd.$dev.pid}" \
      && msg "error: udhcpd.$dev.pid exists"

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
    test -s $pf
    ;;

  status) ## dump leases and show if running
  : ${lf:=$( sed -n '/^lease_file/s/.* //p' $conf 2>/dev/null )}
  : ${lf:=/var/lib/dhcp/udhcpd.$dev.leases}

    echo \+ dumpleases -f $lf
    test -s $lf \
      && dumpleases -f $lf && echo || echo \ \ ...

    echo \+ ps ax -opid,stat,args
    ps ax -opid,stat,args |grep '[0-9]\+ [DR-Z]. *udhcpd .*conf' \
                             || { echo \ \ ...; false; }
esac

