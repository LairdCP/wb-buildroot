#!/bin/bash
# buildroot/board/laird/mkfwusi.sh
# Creates the fw_update/select installer with utilities attached.
# This script may be run by buildroot post_image, or manually.
# The output file 'fw_usi' self-extracts when run on a WB.


tar() {
  echo "creating installer"
  command \
  tar -b 8 -cvf $1 \#\ ${1##*/} \
    -C $TARGETDIR \
    usr/sbin/fw_update \
    usr/sbin/fw_select

  rm -f \#\ ${1##*/}
}

# set output path/file
: ${FWUSI:=`pwd`/fw_usi}

# set target sources path or additions
: ${TARGETDIR:=rootfs-additions-common}

# cd to working dir
cd ${0%/*}/ || exit

# create installer script
cat >\#\ ${FWUSI##*/} << \
-----------fwusi-----------

#!/bin/ash
# fw_usi - fw_update/select installer
# Created by buildroot/board/laird/mkfwusi.sh
# This file contains ustar headers and is to be run directly: 'sh fw_usi'
# Installs fw_* utilities to rootfs-a/b and reports versions.
# Optionally, use to invoke a fw_update or fw_select command.
# Example: 'sh fw_usi update -c -f http://server/path/fw.txt'

sh() { set -x; \$@; { let rv+=\$?; echo; set +x; } 2>/dev/null; }

set -o pipefail 2>/dev/null
tls=/tmp/\${0##*/}.ls
rv=0
echo "extracting:"
tar --exclude=\#\ \* -C / -xvf \$0 |sed 's,^,  /,' |tee \$tls

test \$? -eq 0 \
&& { echo; } \
|| { echo \ \ Aborted!; exit 2; }

sh fw_update --version

sh fw_select --version

sh fw_select --show

test \$rv -eq 0 \
&& case \${1#fw_} in
    '') ## assume default operation to install utilities
      sh fw_select --transfer export -- \$( cat \$tls; rm \$tls )
      ;;

    update|select) ## invoke specified update/select command
      cat \$tls >>/tmp/alt_rootfs.transfer-list
      sh fw_\${@#fw_}
      ;;

    *) let ++rv && echo "v---- usage/syntax: \$@"
  esac

test \$rv\$? -eq 0 \
&& echo "OK" \
|| echo "Error"
exit \$rv

-----------fwusi-----------

tar $FWUSI
echo
echo " -> ${FWUSI##*buildroot/}"
echo
md5sum $FWUSI \
  |sed "s,\(^[^ ]\+\) .*[/]\(.*\),  \1  \2  $( wc -c < $FWUSI ),"
echo
test -s $FWUSI
