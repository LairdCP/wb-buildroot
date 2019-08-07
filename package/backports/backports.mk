# Coccinelle requires:
# sudo apt install coccinelle

# Backports addtionally requires:
# sudo apt-get install libncurses-dev
#    Note that libncurses-dev is required by the WB build, so you probably already have it

BACKPORTS_VERSION = 7.0.0.109
BACKPORTS_LICENSE = GPL-2.0
BACKPORTS_LICENSE_FILES = COPYING
BACKPORTS_SITE = $(TOPDIR)/package/lrd/externals/backports
BACKPORTS_SITE_METHOD = local

BP_OUT := $(BINARIES_DIR)
PATH := $(PATH):$(HOST_DIR)/bin
SPATCH_PATH := /usr/local/bin/spatch
BP_TREE :=  $(BP_OUT)/laird-backport-tree-$(BACKPORTS_VERSION)
BP_TREE_WORKING :=  $(BP_OUT)/laird-backport-tree-working
BP_LINUX_DIR :=  $(TOPDIR)/package/lrd/externals/kernel
BP_LRDMWL_DIR := $(BP_LINUX_DIR)/drivers/net/wireless/laird/lrdmwl
BP_LRDMWL_GIT_DIR := $(BP_LRDMWL_DIR)/.git

define HOST_BACKPORTS_BUILD_CMDS
	rm -rf $(BP_LRDMWL_GIT_DIR)/shallow
	$(@D)/gentree.py --clean --copy-list $(@D)/copy-list \
			       $(BP_LINUX_DIR) \
			       $(BP_TREE_WORKING)
	rm -rf $(BP_TREE_WORKING)/drivers/net/wireless/laird/lrdmwl/.git
	mv $(BP_TREE_WORKING) $(BP_TREE) # necessary to catch failure of prev step
endef

define HOST_BACKPORTS_INSTALL_CMDS
	tar -cj -C $(BP_TREE) --transform "s,.,laird-backport-$(BACKPORTS_VERSION)," -f $(BP_OUT)/backports-laird-$(BACKPORTS_VERSION).tar.bz2 .
endef

$(eval $(host-generic-package))
