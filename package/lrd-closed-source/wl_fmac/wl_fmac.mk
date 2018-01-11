#############################################################
#
# wl_fmac tools
#
#############################################################

WL_FMAC_VERSION = local
WL_FMAC_SITE    = package/lrd-closed-source/externals/wl_fmac
WL_FMAC_SITE_METHOD = local
WL_FMAC_DEPENDENCIES = libnl host-pkgconf

WL_FMAC_MAKE_ENV += CC="$(TARGET_CC)" \
                  ARCH="$(KERNEL_ARCH)" \
                  TARGETARCH="$(ARCH)" \
                  PKG_CONFIG="$(HOST_DIR)/usr/bin/pkg-config" \
                  CFLAGS="-I$(@D)/include/uapi/"
                  NL80211=1 \
                  APPLY_PREFIX=false

define WL_FMAC_BUILD_CMDS
	$(WL_FMAC_MAKE_ENV) $(MAKE) -C $(@D)/src/wl/exe clean
	$(WL_FMAC_MAKE_ENV) $(MAKE) -C $(@D)/src/wl/exe
endef

define WL_FMAC_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/src/wl/exe/wlarm $(TARGET_DIR)/usr/bin/wl
endef

define WL_FMAC_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/bin/wl
endef

$(eval $(generic-package))
