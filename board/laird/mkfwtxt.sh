#!/bin/sh
# create update-list for fw_update
# This script is to be run within the directory containing image files.

# update-list file
fwul=fw.txt

# optional url
url=${1%/}

# list of image files: [#]name
# names may be 6-10 character length
# prepend with '#' to disable in update-list
#
image1=#at91bs.bin
image2=#u-boot.bin
image3=kernel.bin
image4=rootfs.bin


# write target-build description
if [ -n "$LAIRD_RELEASE_STRING" ]
then
  echo "# $LAIRD_RELEASE_STRING" > $fwul
else
  echo "# $(hostname)-${BR2_TARGET_UBOOT_BOARDNAME:-?}" > $fwul
fi

# write update-list
for n in 1 2 3 4
do
  # construct image var
  eval name=\$image$n \
    && image=${name#\#}

  # skip non-existant files
  [ -f $image ] || continue

  # set line prefix as hash or space
  [ $image != $name ] && x='#' || x=' '

  # write image line: [w/prefix] <md5>  <name>  <bytes>
  md5sum $image |sed "s/^.*/$x &  $( wc -c < $image )/" >>$fwul
done
echo >>$fwul

# apply optional flags or shell lines
echo "  flags -c" >>$fwul
echo >>$fwul

# add transfer-list section
cat >>$fwul<<TRANSFER-LIST
# transfer-list
  /etc/summit/profiles.conf
  /etc/network/interfaces
  /etc/ssl
  /root/.ssh
  /etc/dcas.conf
  /etc/NetworkManager/system-connections

TRANSFER-LIST

# display file
echo $fwul:
cat $fwul


#####################################
# duplicate update-list in old-format
# for backwards compatibility
echo >>$fwul
echo >>$fwul
echo "# old format..." >>$fwul
for n in 1 2 3 4
do
  # construct image var
  eval name=\$image$n \
    && image=${name#\#}

  # skip non-existant files
  [ -f $image ] || continue

  # set line prefix as hash or space
  [ $image != $name ] && x='#' || x=' '

  # write image line: <{url/}name>  <md5>
  md5sum $image |sed "s,^\(.*[^ ]\)[ ]\+\(.*\),$x ${url:+$url/}\2  \1," >>$fwul
done
echo >>$fwul

