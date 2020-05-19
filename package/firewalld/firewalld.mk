###############################################################################
#
# firewalld .mk file
#
################################################################################

FIREWALLD_VERSION = v0.8.1
FIREWALLD_SOURCE = $(FIREWALLD_VERSION).tar.gz
FIREWALLD_SITE = https://github.com/firewalld/firewalld/archive
FIREWALLD_DEPENDENCIES = libglib2 nftables host-intltool gettext systemd python-decorator dbus-python python-slip-dbus
FIREWALLD_INSTALL_STAGING = YES
FIREWALLD_LIBTOOL_PATCH = YES
FIREWALLD_AUTORECONF= YES
FIREWALLD_DEFAULT_ZONE = $(call qstrip,$(BR2_PACKAGE_FIREWALLD_DEFAULT_ZONE_VALUE))

FIREWALLD_CONF_OPTS = \
	--with-iptables=no \
	--with-iptables-restore=no \
	--with-ip6tables=no \
	--with-ip6tables-restore=no \
	--with-ebtables=no \
	--with-ebtables-restore=no \
	--with-ipset=no

FIREWALLD_DEPENDENCIES  += python-gobject

define FIREWALLD_RUN_INTLTOOLIZE
	echo $(PATH)
	cd $(@D) && $(HOST_DIR)/usr/bin/intltoolize --force --automake
endef

FIREWALLD_POST_EXTRACT_HOOKS = FIREWALLD_RUN_INTLTOOLIZE

define FIREWALLD_FIX_SHEBANG
	cd $(BUILD_DIR)/firewalld-$(FIREWALLD_VERSION)/src && $(SED) "1s/.*/\#\\!\\/\bin\/\python/" firewalld \
	&& $(SED) "1s/.*/\#\\!\\/\bin\/\python/" firewall-cmd \
	&& $(SED) "1s/.*/\#\\!\\/\bin\/\python/" firewall-applet \
	&& $(SED) "1s/.*/\#\\!\\/\bin\/\python/" firewall-config \
	&& $(SED) "1s/.*/\#\\!\\/\bin\/\python/" firewall-offline-cmd
endef

FIREWALLD_PRE_INSTALL_TARGET_HOOKS = FIREWALLD_FIX_SHEBANG

define FIREWALLD_FIX_CONFIG
	$(SED) "s/ &&.*//g" $(TARGET_DIR)/etc/modprobe.d/firewalld-sysctls.conf
	$(SED) "s/IPv6_rpfilter=yes/IPv6_rpfilter=no/g" $(TARGET_DIR)/etc/firewalld/firewalld.conf
	$(SED) "s/^DefaultZone=.*/DefaultZone=$(FIREWALLD_DEFAULT_ZONE)/g" $(TARGET_DIR)/etc/firewalld/firewalld.conf
endef

FIREWALLD_POST_INSTALL_TARGET_HOOKS = FIREWALLD_FIX_CONFIG

ifeq ($(BR2_PACKAGE_LRD_FACTORY_RESET_TOOLKIT),y)
define FIREWALLD_UPDATE_SERVICE
	$(INSTALL) -d $(TARGET_DIR)/etc/systemd/system/firewalld.service.d
	printf "%s\n" "[Service]" "KeyringMode=inherit" "ExecStart=" "ExecStart=/usr/sbin/firewalld --nofork --nopid --system-config /data/secret/firewalld" > $(TARGET_DIR)/etc/systemd/system/firewalld.service.d/10-reset-conf-dir.conf
endef
endif

define FIREWALLD_INSTALL_INIT_SYSTEMD
        $(INSTALL) -d $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
        ln -rsf $(TARGET_DIR)/usr/lib/systemd/system/firewalld.service \
                $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
		$(FIREWALLD_UPDATE_SERVICE)
endef

$(eval $(autotools-package))
