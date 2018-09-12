TARGETDIR=$1

echo "COMMON POST BUILD script: starting..."

# enable tracing and exit on errors
set -x -e

# remove the resolv.conf.  Network Manager will create the appropriate file and
# link on startup.
rm -f $TARGETDIR/etc/resolv.conf

# Create default firmware description file.
# This may be overwritten by a proper release file.
LOCRELSTR="$LAIRD_RELEASE_STRING"
[ -z "$LOCRELSTR" ] && LOCRELSTR="Laird Linux development build $(date +%Y%m%d)"
echo "$LOCRELSTR" > $TARGETDIR/etc/laird-release
echo "$LOCRELSTR" > $TARGETDIR/etc/issue

LOCVER="$LAIRD_RELEASE_STRING"
[ -z "$LOCVER" ] && LOCVER="$(date +%Y%m%d)"

( \
    echo "NAME=Laird Linux"; \
    echo "VERSION=$LOCRELSTR"; \
    echo "ID=buildroot"; \
    echo "VERSION_ID=$LOCVER"; \
    echo "PRETTY_NAME=\"$LOCRELSTR\"" \
) >  $TARGETDIR/usr/lib/os-release

mkdir -p $TARGETDIR/etc/NetworkManager/system-connections
rm -f $TARGETDIR/etc/systemd/system/multi-user.target.wants/dhcpcd.service
