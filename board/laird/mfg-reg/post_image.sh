# enable tracing and exit on errors
set -x -e

BR2_LRD_PRODUCT="$(sed -n 's,^BR2_DEFCONFIG=".*/\(.*\)_defconfig"$,\1,p' ${BR2_CONFIG})"

echo "${BR2_LRD_PRODUCT^^} POST Image script: starting..."

mkdir -p "${BINARIES_DIR}"

RELEASE_FILE=${BR2_LRD_PRODUCT}
if [ -n "${VERSION}" ]; then
	RELEASE_FILE+="-${VERSION}"

	mv -f "${TARGET_DIR}/${BR2_LRD_PRODUCT}.manifest" \
		"${TARGET_DIR}/${RELEASE_FILE}.manifest"
fi

sed -i "2i#${VERSION}" "${TARGET_DIR}/reg_tools.sh"

TARFILE="${BINARIES_DIR}/${RELEASE_FILE}.tar.bz2"

tar -C "${TARGET_DIR}" -cjf "${TARFILE}" --transform 's,.*/,,' \
	--owner=0 --group=0 --numeric-owner \
	${RELEASE_FILE}.manifest \
	$(sed 's,^/,,' "${TARGET_DIR}/${RELEASE_FILE}.manifest")

# generate SHA to validate package
sha256sum "${TARFILE}" > "${BINARIES_DIR}/${RELEASE_FILE}.sha"

# generate self-extracting script and repackage tar.bz2 to contain script and binary file
cat "${TARGET_DIR}/reg_tools.sh" "${TARFILE}" > "${BINARIES_DIR}/${RELEASE_FILE}.sh"
chmod +x "${BINARIES_DIR}/${RELEASE_FILE}.sh"

# create new tar.bz2 containing self-extracting script and SHA file
tar -cjf "${TARFILE}" -C "${BINARIES_DIR}" "${RELEASE_FILE}.sh" "${RELEASE_FILE}.sha"

echo "${BR2_LRD_PRODUCT^^} POST Image script: done."
