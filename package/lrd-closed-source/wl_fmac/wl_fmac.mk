#############################################################
#
# wl_fmac tools
#
#############################################################

WL_FMAC_VERSION = local
WL_FMAC_SITE    = package/lrd-closed-source/externals/wl_fmac
WL_FMAC_SITE_METHOD = local
WL_FMAC_DEPENDENCIES = libnl host-pkgconf

ifeq ($(BR2_aarch64),y)
WL_FMAC_TARGETARCH = arm64_le
else ifeq ($(BR2_arm),y)
WL_FMAC_TARGETARCH = arm_le
endif

WL_FMAC_MAKE_ENV += CC="$(TARGET_CC)" \
                  TARGETARCH="$(WL_FMAC_TARGETARCH)" \
                  PKG_CONFIG="$(HOST_DIR)/usr/bin/pkg-config" \
                  NL80211=1 \
                  APPLY_PREFIX=false

define WL_FMAC_BUILD_CMDS
	$(WL_FMAC_MAKE_ENV) $(MAKE) -C $(@D)/src/wl/exe clean
	$(WL_FMAC_MAKE_ENV) $(MAKE) -C $(@D)/src/wl/exe
endef

define WL_FMAC_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/src/wl/exe/wl$(WL_FMAC_TARGETARCH) $(TARGET_DIR)/usr/bin/wl
endef

define WL_FMAC_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/bin/wl
endef

$(eval $(generic-package))
