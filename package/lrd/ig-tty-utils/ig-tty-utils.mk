##########################################################################
# Sentrius IG60 TTY Utils
##########################################################################

define IG_TTY_UTILS_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -t $(TARGET_DIR)/etc/systemd/system/serial-getty@ttyS2.service.d \
		-m 644 $(IG_TTY_UTILS_PKGDIR)/ttyS2-startup.conf
	$(INSTALL) -D -t $(TARGET_DIR)/usr/lib/systemd/system \
		-m 644 $(IG_TTY_UTILS_PKGDIR)/ig-card-detect.service
	$(INSTALL) -d $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
	ln -srf $(TARGET_DIR)/usr/lib/systemd/system/ig-card-detect.service \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/ig-card-detect.service
	ln -srf $(TARGET_DIR)/usr/lib/systemd/system/serial-getty@.service \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/serial-getty@ttyS2.service
	ln -srf $(TARGET_DIR)/usr/lib/systemd/system/serial-getty@.service \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/serial-getty@ttyUSB0.service
endef

$(eval $(generic-package))

