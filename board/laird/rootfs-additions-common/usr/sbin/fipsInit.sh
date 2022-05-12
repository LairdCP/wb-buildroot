#!/bin/sh

INIT=/usr/sbin/init

fail() {
	echo -e "\nFIPS Integrity check Failed: $1\n"
	/usr/sbin/reboot -f
}

mount -t proc proc /proc 2> /dev/null
PROC_MOUNT=$?

read -r cmdline < /proc/cmdline
set -- ${cmdline}
for x in "$@"; do
	case "${x}" in
		ubi.mtd=*)
			KERNEL=/dev/mtd$((${x#*=} - 2))
			;;

		initlrd=*)
			INIT=${x#initlrd=}
			;;
	esac
done

[ -f /proc/sys/crypto/fips_enabled ] && \
	read -r FIPS_ENABLED < /proc/sys/crypto/fips_enabled

if [ "${FIPS_ENABLED}" = "1" ] && [ -n "${KERNEL}" ]; then
	# trigger kernel crypto ccm self-test
	modprobe tcrypt mode=37
	modprobe -r tcrypt

	mount -o mode=1777,nosuid,nodev -t tmpfs tmpfs /tmp 2> /dev/null
	TMP_MOUNT=$?

	[ -f /lib/fipscheck/Image.lzma.hmac ] && IMGTYP=lzma || IMGTYP=gz

	/usr/sbin/dumpimage -T flat_dt -p 0 -o /tmp/Image.${IMGTYP} ${KERNEL} > /dev/null ||\
		fail "Cannot extract kernel image error: $?"

	FIPSCHECK_DEBUG=stderr /usr/bin/fipscheck /tmp/Image.${IMGTYP} /usr/lib/libcrypto.so.1.0.0 ||\
		fail "fipscheck error: $?"

	shred -zu -n 1 /tmp/Image.${IMGTYP}

	[ ${TMP_MOUNT} -eq 0 ] && umount /tmp

	echo -e "\nFIPS Integrity check Success\n"
fi

[ ${PROC_MOUNT} -eq 0 ] && umount /proc

echo -e "Launching: ${INIT}\n"

if [ "${INIT#*.}" = "sh" ]; then
	. ${INIT}
else
	exec ${INIT}
fi
