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

# /etc/dhcp/udhcpc.sh
# An extended support wrapper for udhcpc with process-id control.
#
# Usage:
# ./udhcpc.sh -i<iface> [-qv] [stop|start|renew|release|check|{status}]
#
# The DHCP event handler is: /etc/dhcp/udhcpc.script
# All options may be set in: /etc/dhcp/udhcpc.conf
# Apply specific options in: /etc/dhcp/udhcpc.<iface>.conf
# Option bootfile is set by: /tmp/bootfile_
# A few settings passed via environment.
#
# Note, as of BusyBox v1.21.x:
# 1. Interface must exist and operstate should be 'up'.
# 2. There is a silent fail condition if/upon iface disappearance.
#

msg() {
  echo "$@"
  echo "$@" >>${log:-/dev/null} || :
} && vm=.

# invocation
while let $#
do
  case $1 in
    -h) ## show usage
      exec sed -n "/^# .*${0##*/}/,/^[^#]/{s/^#/ /p}" $0
      ;;
    -q) ## quiet, no stdout
      vm=
      ;;
    -v) ## add verbosity, multi-level
      vm=$vm.
      ;;
    -i*) ## interface
      [ -n "${1:2}" ] && dev=${1:2} || { dev=${2}; shift; }
      ;;
    -*) ## ignored
      ;;
    *) ## last arg
      act=$1
      break
  esac
  shift
done

# set some message levels according to verbose-mode
[ 0${#vm} -ge 1 ] && alias msg1=msg || alias msg1=:
[ 0${#vm} -ge 2 ] && alias msg2=msg || alias msg2=:


udhcpc_conf() {
  ## apply global conf options
  if [ -f /etc/dhcp/udhcpc.conf ]
  then
    { set ${vm/..*/-x} --; }
    . /etc/dhcp/udhcpc.conf
    { set +x; } 2>/dev/null
  fi
  ## apply select iface conf options
  if [ -f /etc/dhcp/udhcpc.$dev.conf ]
  then
    { set ${vm/..*/-x} --; }
    . /etc/dhcp/udhcpc.$dev.conf
    { set +x; } 2>/dev/null
  fi
  ## flag-file bootfile req
  if [ -f /tmp/bootfile_ ]
  then
    OPT_REQ=$OPT_REQ\ bootfile
  fi
} >>${log:-/dev/null} 2>&1

udhcpc_start() {
  # set no-verbose or use a verbose mode level
  [ -n "$vm" ] && nv='|grep -E "obtained|udhcpc"'
  [ -z "$vm" ] && nv='>/dev/null'
  [ "${vm:1:1}" == "." ] && q=
  [ "${vm:2:1}" == "." ] && vb='-v'

  # request ip-address (env)
  rip=${rip:+--request $rip}

  # specific options to request in lieu of defaults
  ropt=; for t in ${OPT_REQ}; do ropt=$ropt\ -O$t; done
  ropt=${ropt:+-o $ropt}

  # vendor-class-id support (as last line of file or a string)
  vci=$( sed '$!d;s/.*=["]\(.*\)["]/\1/' ${OPT_VCI:-/} 2>/dev/null \
      || echo "$OPT_VCI" )
  vci=${vci:+--vendorclass $vci}
  ropt=${ropt}${vci:+ -O43}

  # specific opt:val pairs to send - must be hex
  xopt=; for t in ${OPT_SND}; do xopt=$xopt\ -x$t; done

  # run-script: /usr/share/udhcpc/default.script
  rs='-s/etc/dhcp/udhcpc.script'
  pf='-p/var/run/dhclient.$dev.pid'

  # merge settings
  eval ${DHCP_PARAMS}
  export \
    DHCP_PARAMS="vb=$vb log=$log mpr=$mpr metric=$metric weight=$weight"

  # A run-script handles client event state actions and writes to a leases file.
  # Client normally continues running in background, and upon obtaining a lease.
  # And it may be signalled or re-spawned again, depending on events/conditions.
  # Flags are:
  # iface, verbose, request-ip, exit-no-lease/quit-option, exit-release
  # Retry mechanism:
  # send 4-discovers, paused at 2sec, repeat after 5sec
  eval \
    udhcpc -i$dev $vb $rip -R -t4 -T2 -A5 -b $ropt $vci $xopt $rbf $pf $rs $nv
} >>${log:-/dev/null}

udhcpc_signal() {
  case $1 in
    RELEASE) action=sigusr2; signal=-12;;
    RENEW) action=sigusr1; signal=-10;;
    TERM) action=sigterm; signal=-15;;
    CHECK) action=sigzero; signal=-00;;
  esac
  rv=1
  if read -r pid < /var/run/dhclient.$dev.pid \
  && read client < /proc/$pid/comm
  then
    kill $signal $pid
    rv=$?
    msg1 "  ${pid}_$client <- $action $rv"
    if [ "$1" == "TERM" ]
    then
      x=16
      while [ -d /proc/$pid ] && usleep 320987
      do
        let --x \
        || { msg "  ${pid}_$x <- $action error"; rv=1; break; }
      done
    fi
  fi
  return $rv
} 2>/dev/null

udhcpc_renewal() {
  # attempt upto 4 requests for renew while checking for success/failure
  for x in 1 2 3 4
  do
    { read -r txp_b </sys/class/net/$dev/statistics/tx_packets; } 2>/dev/null
    udhcpc_signal RENEW || break
    usleep 987654
    { read -r txp_a </sys/class/net/$dev/statistics/tx_packets; } 2>/dev/null
    msg2 "    tx_packets: $txp_b -> $txp_a"
    if [ 0${txp_a} -gt 0${txp_b} ] \
    && udhcpc_signal CHECK
    then
      msg1 "    renew success on $x"
      return 0
    fi
  done
  msg1 "    renew failure on $x"
  return 1
}

# specified interface must exist
test -f /sys/class/net/$dev/uevent \
  || { msg "required: -i<iface>"; exit 1; }

# dir exists for dhcp
test -d /var/lib/dhcp \
  || ln -s /tmp /var/lib/dhcp

# main
case ${act:-status} in
  stop) ## terminate
    udhcpc_signal TERM
    ;;

  start) ## (re)spawn
    udhcpc_signal TERM
    udhcpc_conf
    udhcpc_start || exit $?
    if [ -x "$CLIENT_WD" ]
    then
      client=udhcpc $CLIENT_WD $vb -i$dev
    fi
    ;;

  release) ## deconfigure
    udhcpc_signal RELEASE
    ;;

  renew) ## request
    udhcpc_renewal
    ;;

  check) ## is running
    udhcpc_signal CHECK
    ;;

  status) ## event-state-action and process-id
    echo \: ${leases:=/var/lib/dhcp/dhclient.$dev.leases}
    grep -s '^# esa:' $leases || msg \ \ ...
    echo \+ ps ax -opid,stat,args
    ps ax -opid,stat,args |grep "[0-9]\+ [DR-Z]. *udhcpc .*$dev" \
                             || { msg \ \ ...; false; }
esac

