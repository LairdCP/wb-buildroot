IMAGESDIR="${1}"
BR2_LRD_PRODUCT="${2}"

echo "${BR2_LRD_PRODUCT^^} POST Image script: starting..."

mkdir -p "${IMAGESDIR}"

# enable tracing and exit on errors
set -x -e

TARFILE="${IMAGESDIR}/${BR2_LRD_PRODUCT}.tar.bz2"

tar -C "${TARGET_DIR}" -cjf "${TARFILE}" --transform 's,.*/,,' \
	$(sed 's,^/,,' ${TARGET_DIR}/${BR2_LRD_PRODUCT}.manifest)

# generate SHA to validate package
sha256sum "${TARFILE}" > "${IMAGESDIR}/${BR2_LRD_PRODUCT}.sha"

# generate self-extracting script and repackage tar.bz2 to contain script and binary file
cat "${TARGET_DIR}/reg_tools.sh" "${TARFILE}" > "${IMAGESDIR}/${BR2_LRD_PRODUCT}.sh"
chmod +x "${IMAGESDIR}/${BR2_LRD_PRODUCT}.sh"

# create new tar.bz2 containing self-extracting script and SHA file
tar -cjf "${TARFILE}" -C "${IMAGESDIR}" "${BR2_LRD_PRODUCT}.sh" "${BR2_LRD_PRODUCT}.sha"

echo "${BR2_LRD_PRODUCT^^} POST Image script: done."
