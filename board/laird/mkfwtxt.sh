#!/bin/sh
set -e

URL="$1"
TGT=fw.txt

echo -n > "$TGT"

for f in bootstrap.bin u-boot.bin kernel.bin rootfs.bin; do
    if [ -e $f ]; then
        if [ $f = "bootstrap.bin" -o $f = "u-boot.bin" ]; then
            echo -n "#" >> "$TGT"
        fi
        echo "$URL/$f `md5sum $f | cut -d ' ' -f 1`" >> "$TGT"
    fi
done
