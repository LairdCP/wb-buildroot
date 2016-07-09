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

# /etc/dhcp/odhcp6c.sh
# An extended support wrapper for odhcp6c - the OpenWRT DHCPv6 and RA client.
#
# Usage:
# ./odhcp6c.sh -i<iface> [-v] [stop|start|renew|update|release|check|{status}]
#
# common options to apply: /etc/dhcp/odhcp6c.conf
# specific options set in: /etc/dhcp/odhcp6c.<iface>.conf
# client state run-script: /etc/dhcp/odhcp6c.script


# invocation
while let $#
do
  case $1 in
    -h) ## show usage
      exec sed -n "/^# .*${0##*/}/,/^[^#]/{s/^#/ /p;/^$/{p;q}}" $0
      ;;
    -v) ## add verbosity, multi-level
      vm=$vm.
      ;;
    -i*) ## interface
      [ -n "${1:2}" ] && iface=${1:2} || { iface=${2}; shift; }
      ;;
    -*) ## ignored
      ;;
    *) ## last arg
      act=$1
      break
  esac
  shift
done
test -n "$iface" \
  || { echo "required: -i<iface>"; exit 1; }

# set iface specific pid_file
pf=/var/run/odhcp6c.$iface.pid

odhcp6c_conf() {
  ## apply common conf options
  if [ -f /etc/dhcp/odhcp6c.conf ]
  then
    . /etc/dhcp/odhcp6c.conf
  fi
  ## apply select iface conf options
  if [ -f /etc/dhcp/odhcp6c.$iface.conf ]
  then
    . /etc/dhcp/odhcp6c.$iface.conf
  fi
}

odhcp6c_stop() {
  odhcp6c_signal TERM \
    && rm -f $pf
}

odhcp6c_start() {
  # set verbosity level
  [ ${#vm} -ge 1 ] && v=${vm//./-v }

  # request options added into a comma delimited list
  ropt=; for t in ${OPT_REQ}; do ropt=$ropt,$t; done
  ropt=${ropt:+-r$ropt}

  # vendor class option (as last line of file or a string)
  vci=$( sed '$!d;s/.*=["]\(.*\)["]/\1/' ${OPT_VCI:-/} 2>/dev/null \
      || echo "$OPT_VCI" )
  vci=${vci:+-V$vci}

  # prefix length request
  pl=${OPT_PREFIX}

  # run_script: /usr/sbin/odhcp6c-update
  [ -f /etc/dhcp/odhcp6c.script ] \
    && rs=-r/etc/dhcp/odhcp6c.script

  logm "client start for $iface"
  eval \
    odhcp6c $v -m20 -t120 -S1 -Ntry $pl $vci $ropt -dp$pf $rs $iface
}

odhcp6c_signal() {
  case $1 in
    RELEASE) action=sigusr2; signal=-12;;
    UPDATE) action=sigio; signal=-29;;
    RENEW) action=sigusr1; signal=-10;;
    TERM) action=sigterm; signal=-15;;
    CHECK) action=sigzero; signal=-00;;
  esac
  rv=1
  if read -r pid </var/run/odhcp6c.$iface.pid \
  && read client < /proc/$pid/comm
  then
    logm "$action to [$pid]"
    kill $signal $pid; rv=$?
  fi 2>/dev/null
  return $rv
}

logm() {
  logger -p notice -t "odhcp6c.sh[$$]" "$*"
}


# main
case ${act:-status} in
  stop) ## terminate client
    odhcp6c_stop
    ;;

  start) ## (re)spawn client
    odhcp6c_stop
    odhcp6c_conf
    odhcp6c_start
    ;;

  renew) ## req update
    odhcp6c_signal RENEW
    ;;

  update) ## req ra-update
    odhcp6c_signal UPDATE
    ;;

  release) ## req release
    odhcp6c_signal RELEASE
    ;;

  check) ## is running
    odhcp6c_signal CHECK
    ;;

  status) ## process-id and iface config
    echo \+ ps ax -opid,stat,args
    ps ax -opid,stat,args |grep "[0-9]\+ [DR-Z]. *odhcp6c .*$iface" \
                             && { echo; } \
                             || { echo \ \ ...; false; }
    echo \+ ip -6 addr show dev $iface
    ip -6 addr show dev $iface |grep -v _lft
    ;;

  *) ## error
    false
esac

