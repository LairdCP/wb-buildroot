# Coccinelle requires:
# sudo apt install coccinelle

# Backports addtionally requires:
# sudo apt-get install libncurses-dev
#    Note that libncurses-dev is required by the WB build, so you probably already have it

BACKPORTS_VERSION = $(call qstrip,$(BR2_PACKAGE_LINUX_BACKPORTS_VERSION))
ifeq ($(BACKPORTS_VERSION),)
BACKPORTS_VERSION = 0.$(BR2_LRD_BRANCH).0.0
endif

BACKPORTS_LICENSE = GPL-2.0
BACKPORTS_LICENSE_FILES = COPYING
BACKPORTS_SITE = $(TOPDIR)/package/lrd/externals/backports
BACKPORTS_SITE_METHOD = local

BP_OUT := $(BINARIES_DIR)
BP_TREE :=  $(BP_OUT)/laird-backport-tree-$(BACKPORTS_VERSION)
BP_TREE_WORKING :=  $(BP_OUT)/laird-backport-tree-working
BP_LINUX_DIR :=  $(TOPDIR)/package/lrd/externals/kernel

define HOST_BACKPORTS_BUILD_CMDS
	$(@D)/gentree.py --clean --copy-list $(@D)/copy-list --base-name "Summit Linux" \
			       $(BP_LINUX_DIR) \
			       $(BP_TREE_WORKING)
	sed -i 's|\(BACKPORTS_VERSION=\).*|\1\"v$(BACKPORTS_VERSION)\"|g' $(BP_TREE_WORKING)/versions
	mv $(BP_TREE_WORKING) $(BP_TREE) # necessary to catch failure of prev step
endef

define HOST_BACKPORTS_INSTALL_CMDS
	tar -cj -C $(BP_TREE) --transform "s,.,laird-backport-$(BACKPORTS_VERSION)," \
		--owner=0 --group=0 --numeric-owner \
		-f $(BP_OUT)/backports-laird-$(BACKPORTS_VERSION).tar.bz2 .
endef

$(eval $(host-generic-package))
