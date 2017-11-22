#!/usr/bin/env sh
# set -x -e

help_text() {
echo
echo "$0 is a self-extracting tarball script meant for"
echo "  manufacturing and regulatory testing."
echo
echo "Options:"
echo "  sha  ..validate the encapsulated tarball vs the sha signature file supplied as an argument"
echo "  install  ..install the files from the tarball in their proper places, -f to force install"
echo "  tar  ..dump the encapsulated tarball to the filesystem as a normal .tar.bz2"
echo "  version  ..output the version number of this build"
echo
echo "Examples:"
echo "  $0 sha [file]"
echo "  $0 install"
echo "  $0 tar"
echo "  $0 version"
echo
}

# searches for the line number where finish the script and start the tar.bz2
SKIP=`awk '/^__TARFILE_FOLLOWS__/ { print NR + 1; exit 0; }' $0`
# remember our file name
THIS=`pwd`/$0

# get base name
ROOTNAME=`echo $0 | sed 's/^\(.\/\)\1*//;s/...$//'`

case $1 in
	"sha")
		if [ -z "$2" ]
		then
			echo "Please supply file as parameter to validate against."
			help_text
			exit 1
		fi
		TAR_SHA=`tail -n +$SKIP $THIS | sha256sum | sed -e 's/\s.*$//'`
		FILE_SHA=`cat $2 | sed -e 's/\s.*$//'`
		if [ "$TAR_SHA" == "$FILE_SHA" ]
		then
			echo "Computed checksums match"
		else
			echo "Computed checksums did NOT match"
		fi
		break
		;;
	"install")
		# make directory to store files
		mkdir -p $ROOTNAME
		# decompress tar.bz2
		tail -n +$SKIP $THIS | tar -xzj -C $ROOTNAME
		# read manifest
		while read line; do
			BIN=`echo $line | sed 's/.*\///'`
			if [[ ${line:0:1} != '#' ]]
			then
				# check for forced
				if [ "$2" == "-f" ]
				then
					mkdir -p `echo $line | sed "s/$BIN//g"`
					echo "Forced install of $BIN to $line"
					cp "$ROOTNAME/$BIN" "$line"
				else
					# check if file exists
					if [[ -e "$line" ]]
					then
						echo "File $line already exists, skipping..."
					else
						mkdir -p `echo $line | sed "s/$BIN//g"`
						echo "Installing $BIN to $line"
						cp "$ROOTNAME/$BIN" "$line"
					fi
				fi
			fi
		done < `find $ROOTNAME/. -name '*.manifest'`
		rm -rf $ROOTNAME
		break
		;;
	"tar")
		tail -n +$SKIP $THIS > "$ROOTNAME.tar.bz2"
		break
		;;
	"version")
		sed -n 2,2p $0 | sed 's/.*#//'
		break
		;;
	*)
		help_text
		;;
esac

exit 0
__TARFILE_FOLLOWS__
