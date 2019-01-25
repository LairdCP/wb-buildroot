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
if [ -z "$LOCRELSTR" ] || [ "$LOCRELSTR" == "0.0.0.0" ]; then
	LOCRELSTR="Laird Linux development build $(date +%Y%m%d)"
fi
echo "$LOCRELSTR" > $TARGETDIR/etc/laird-release
echo "$LOCRELSTR" > $TARGETDIR/etc/issue

echo -ne \
"NAME=Laird Linux\n"\
"VERSION=$LOCRELSTR\n"\
"ID=buildroot\n"\
"VERSION_ID=${LOCRELSTR##* }\n"\
"PRETTY_NAME=\"$LOCRELSTR\""\
>  $TARGETDIR/usr/lib/os-release

mkdir -p $TARGETDIR/etc/NetworkManager/system-connections
