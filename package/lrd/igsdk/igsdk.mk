#####################################################################
# Laird Industrial Gateway SDK
#####################################################################

IGSDK_VERSION = local
IGSDK_SITE = package/lrd/externals/igsdk
IGSDK_SITE_METHOD = local

ifeq ($(BR2_REPRODUCIBLE),y)
define IGSDK_PYTHON3_FIX_TIME
	find $(TARGET_DIR)/usr/lib -name '*.py' -print0 | \
		xargs -0 --no-run-if-empty touch -d @$(SOURCE_DATE_EPOCH)
endef
endif

define IGSDK_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/python/igsdk/bt_module.py $(TARGET_DIR)/usr/lib/igsdk/bt_module.py

	$(IGSDK_PYTHON3_FIX_TIME)
	PYTHONPATH="$(PYTHON3_PATH)" \
	cd $(TARGET_DIR) && $(HOST_DIR)/bin/python$(PYTHON3_VERSION_MAJOR) \
		$(TOPDIR)/support/scripts/pycompile.py \
		$(if $(BR2_REPRODUCIBLE),--force) \
		usr/lib/igsdk && rm -f $(TARGET_DIR)/usr/lib/igsdk/*.py
endef

$(eval $(generic-package))
