#############################################################
#
# NCM
#
#############################################################

NCM_VERSION = local
NCM_SITE = package/lrd-closed-source/externals/ncm
NCM_SITE_METHOD = local

NCM_DEPENDENCIES = libnl msd-binaries libedit protobuf openssl
NCM_MAKE_ENV = CC="$(TARGET_CC)" \
                  CXX="$(TARGET_CXX)" \
                  CROSS="" \
                  CFLAGS="$(TARGET_CFLAGS)"

define NCM_BUILD_CMDS
    $(MAKE) -C $(@D) clean
	$(NCM_MAKE_ENV) $(MAKE) -C $(@D)
endef

define NCM_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/ncm $(TARGET_DIR)/usr/bin/ncm
endef

define NCM_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/bin/ncm
endef

$(eval $(generic-package))
