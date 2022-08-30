################################################################################
#
# firewalld
#
################################################################################

FIREWALLD_VERSION = v0.9.3
FIREWALLD_SITE = $(call github,firewalld,firewalld,$(FIREWALLD_VERSION))
FIREWALLD_LICENSE = GPL-2.0
FIREWALLD_LICENSE_FILES = COPYING
FIREWALLD_AUTORECONF = YES
FIREWALLD_DEPENDENCIES = \
	host-intltool \
	host-libglib2 \
	host-libxml2 \
	host-libxslt \
	dbus-python \
	gettext \
	gobject-introspection \
	iptables \
	jansson \
	nftables \
	python3 \
	python-decorator \
	python3-gobject \
	python-six \
	python-slip-dbus

FIREWALLD_DEFAULT_ZONE = $(call qstrip,$(BR2_PACKAGE_FIREWALLD_DEFAULT_ZONE_VALUE))
FIREWALLD_DEFAULT_BACKEND = $(call qstrip,$(BR2_PACKAGE_FIREWALLD_DEFAULT_BACKEND_VALUE))

define FIREWALLD_RUN_AUTOGEN
	cd $(@D) && $(HOST_DIR)/bin/intltoolize --force
endef
FIREWALLD_PRE_CONFIGURE_HOOKS += FIREWALLD_RUN_AUTOGEN

# iptables, ip6tables, ebtables, and ipset *should* be unnecessary
# when the nftables backend is available, because nftables supersedes all of
# them. However we still need to build and install iptables and ip6tables
# because application relying on direct passthrough rules (IE docker) will
# break.
# /etc/sysconfig/firewalld is a Red Hat-ism, only referenced by
# the Red Hat-specific init script which isn't used.
FIREWALLD_CONF_OPTS += \
	--disable-rpmmacros \
	--disable-sysconfig \
	--with-ip6tables=/usr/sbin/ip6tables \
	--with-iptables=/usr/sbin/iptables \
	--without-iptables-restore \
	--without-ip6tables-restore \
	--without-ebtables \
	--without-ebtables-restore \
	--without-ipset \
	--without-xml-catalog

# Firewalld hard codes the python shebangs to the full path of the
# python-interpreter. IE: #!/home/buildroot/output/host/bin/python.
# Force the proper python path.
FIREWALLD_CONF_ENV += PYTHON="/usr/bin/env python3"

ifeq ($(BR2_PACKAGE_SYSTEMD),y)
FIREWALLD_CONF_OPTS += --with-systemd-unitdir=/usr/lib/systemd/system
else
FIREWALLD_CONF_OPTS += --disable-systemd
endif



define FIREWALLD_FIX_CONFIG
	$(SED) "s/ &&.*//g" $(TARGET_DIR)/etc/modprobe.d/firewalld-sysctls.conf
	$(SED) "s/IPv6_rpfilter=yes/IPv6_rpfilter=no/g" $(TARGET_DIR)/etc/firewalld/firewalld.conf
	$(SED) "s/^DefaultZone=.*/DefaultZone=$(FIREWALLD_DEFAULT_ZONE)/g" $(TARGET_DIR)/etc/firewalld/firewalld.conf
	$(SED) "s/^FirewallBackend=.*/FirewallBackend=$(FIREWALLD_DEFAULT_BACKEND)/g" $(TARGET_DIR)/etc/firewalld/firewalld.conf
endef
FIREWALLD_POST_INSTALL_TARGET_HOOKS = FIREWALLD_FIX_CONFIG

ifeq ($(BR2_PACKAGE_LRD_ENCRYPTED_STORAGE_TOOLKI),y)
define FIREWALLD_UPDATE_SERVICE
	$(INSTALL) -d $(TARGET_DIR)/etc/systemd/system/firewalld.service.d
	printf "%s\n" "[Service]" "KeyringMode=inherit" "ExecStart=" "ExecStart=/usr/sbin/firewalld --nofork --nopid" > $(TARGET_DIR)/etc/systemd/system/firewalld.service.d/10-reset-conf-dir.conf
endef
endif

define FIREWALLD_INSTALL_INIT_SYSTEMD
	$(INSTALL) -d $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
	ln -rsf $(TARGET_DIR)/usr/lib/systemd/system/firewalld.service \
			$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
			$(FIREWALLD_UPDATE_SERVICE)

endef

define FIREWALLD_INSTALL_INIT_SYSV
	$(INSTALL) -m 0755 -D $(FIREWALLD_PKGDIR)/firewalld.init \
		$(TARGET_DIR)/etc/init.d/S41firewalld
endef

$(eval $(autotools-package))
