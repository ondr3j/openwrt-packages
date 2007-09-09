#
# Copyright (C) 2007 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# $Id$

ifeq ($(DUMP),)

  PYTHON:=$(STAGING_DIR)/usr/bin/hostpython

  PYTHON_VERSION=2.5

  PYTHON_INC_DIR:=$(STAGING_DIR)/usr/include/python$(PYTHON_VERSION)
  PYTHON_LIB_DIR:=$(STAGING_DIR)/usr/lib/python$(PYTHON_VERSION)

  PYTHON_PKG_DIR:=/usr/lib/python$(PYTHON_VERSION)/site-packages

endif

define PyPackage
  NAME:=$(1)
  $(eval $(call PyPackage/$(1)))

  define Package/$(1)
    TITLE:=$(TITLE)
    SECTION:=lang
    CATEGORY:=Languages
    DEPENDS:=+python
    $(call PyPackage/$(1))
  endef

  ifdef PyPackage/$(1)/description
    define Package/$(1)/description
$(call PyPackage/$(1)/description)
    endef
  endif

  $(call shexport,PyPackage/$(1)/filespec)

  define Package/$(1)/install
	@getvar $$(call shvar,PyPackage/$(1)/filespec) | ( \
		IFS='|'; \
		while read fop fspec fperm; do \
		  if [ "$$$$$$$$fop" = "+" ]; then \
		    dpath=`dirname "$$$$$$$$fspec"`; \
		    if [ -n "$$$$$$$$fperm" ]; then \
		      dperm="-m$$$$$$$$fperm"; \
		    else \
		      dperm=`stat -c "%a" $(PKG_INSTALL_DIR)$$$$$$$$dpath`; \
		    fi; \
		    mkdir -p $$$$$$$$$dperm $$(1)$$$$$$$$dpath; \
		    echo "copying: '$$$$$$$$fspec'"; \
		    cp -fpR $(PKG_INSTALL_DIR)$$$$$$$$fspec $$(1)$$$$$$$$dpath/; \
		    if [ -n "$$$$$$$$fperm" ]; then \
		      chmod -R $$$$$$$$fperm $$(1)$$$$$$$$fspec; \
		    fi; \
		  elif [ "$$$$$$$$fop" = "-" ]; then \
		    echo "removing: '$$$$$$$$fspec'"; \
		    rm -fR $$(1)$$$$$$$$fspec; \
		  elif [ "$$$$$$$$fop" = "=" ]; then \
		    echo "setting permissions: '$$$$$$$$fperm' on '$$$$$$$$fspec'"; \
		    chmod -R $$$$$$$$fperm $$(1)$$$$$$$$fspec; \
		  fi; \
		done; \
	)
	$(call PyPackage/$(1)/install,$$(1))
  endef

  $$(eval $$(call BuildPackage,$(1)))
endef

define Build/Compile/PyMod
	( cd $(PKG_BUILD_DIR)/$(1); \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="$(TARGET_CPPFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		$(3) \
		$(PYTHON) ./setup.py $(2) \
	);
endef