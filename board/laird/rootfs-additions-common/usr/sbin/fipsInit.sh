#!/bin/sh

INIT=/usr/sbin/init

fail() {
	echo -e "\nFIPS Integrity check Failed: $1\n"
	/usr/sbin/reboot -f
}

mount -t proc proc /proc 2> /dev/null
PROC_MOUNT=$?
BOOT_MOUNT=1

set -- $(cat /proc/cmdline)
for x in "$@"; do
	case "$x" in
		ubi.mtd=*)
			KERNEL=/dev/mtd$((${x#*=} - 2))
			;;

		initlrd=*)
			INIT=${x#initlrd=}
			;;
	esac
done

FIPS_ENABLED=$(cat /proc/sys/crypto/fips_enabled 2>/dev/null)

if [ "${FIPS_ENABLED}" == "1" ] && [ -n "${KERNEL}" ]; then
	mount -o mode=1777,nosuid,nodev -t tmpfs tmpfs /tmp 2> /dev/null
	TMP_MOUNT=$?

	if [ ${BOOT_MOUNT} -eq 0 ]; then
		mkdir -p /boot
		mount -t vfat /dev/mmcblk0p1 /boot 2>/dev/null ||
			fail "Cannot mount /boot: $?"
	fi

	[ -f /lib/fipscheck/Image.lzma.hmac ] && IMGTYP=lzma || IMGTYP=gz

	/usr/sbin/dumpimage -i ${KERNEL} -p 0 -T flat_dt /tmp/Image.${IMGTYP} > /dev/null ||\
		fail "Cannot extract kernel image error: $?"

	FIPSCHECK_DEBUG=stderr /usr/bin/fipscheck /tmp/Image.${IMGTYP} /usr/lib/libcrypto.so.1.0.0 ||\
		fail "fipscheck error: $?"

	shred -zu -n 1 /tmp/Image.${IMGTYP}

	[ ${BOOT_MOUNT} -eq 0 ] && umount /boot
	[ ${TMP_MOUNT} -eq 0 ] && umount /tmp

	echo -e "\nFIPS Integrity check Success\n"
fi

[ ${PROC_MOUNT} -eq 0 ] && umount /proc

echo -e "Launching: ${INIT}\n"

if [ "${INIT#*.}" == "sh" ]; then
	. ${INIT}
else
	exec ${INIT}
fi
