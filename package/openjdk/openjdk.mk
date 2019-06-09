################################################################################
#
# openjdk
#
################################################################################

#Version is the same as OpenJDK HG tag

OPENJDK_VERSION = jdk-11.0.1+13
OPENJDK_RELEASE = jdk11u
OPENJDK_PROJECT = jdk-updates
OPENJDK_VARIANT = server
OPENJDK_SOURCE = openjdk-$(OPENJDK_VERSION).tar.xz
OPENJDK_SITE = https://hg.openjdk.java.net/$(OPENJDK_PROJECT)/$(OPENJDK_RELEASE)/


export DISABLE_HOTSPOT_OS_VERSION_CHECK=ok
OPENJDK_CONF_OPTS = \
        --with-debug-level=release \
        --openjdk-target=$(GNU_TARGET_NAME) \
	--with-sysroot=$(STAGING_DIR) \
	--with-devkit=$(HOST_DIR) \
	--disable-freetype-bundling \
	--with-extra-cflags='-Os -Wno-maybe-uninitialized' \
        --with-x \
	$(OPENJDK_GENERAL_OPTS)
	
OPENJDK_MAKE_OPTS = \
	$(OPENJDK_GENERAL_OPTS) \
        images

OPENJDK_DEPENDENCIES = alsa-lib host-pkgconf libffi cups freetype xlib_libXrender xlib_libXt xlib_libXext xlib_libXtst libusb giflib jpeg

OPENJDK_LICENSE = GPLv2+ with exception
OPENJDK_LICENSE_FILES = COPYING

define OPENJDK_CONFIGURE_CMDS
	chmod +x $(@D)/configure
	cd $(@D); ./configure $(OPENJDK_CONF_OPTS)
endef

define OPENJDK_BUILD_CMDS
	# LD is using CC because busybox -ld do not support -Xlinker -z hence linking using -gcc instead
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D) $(OPENJDK_MAKE_OPTS)
endef

define OPENJDK_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/lib/jvm/
	cp -aLrf $(@D)/build/*/images/* $(TARGET_DIR)/usr/lib/jvm/
	cp -arf $(@D)/build/*/images/jdk/lib/$(OPENJDK_VARIANT)/libjvm.so $(TARGET_DIR)/usr/lib/jvm/lib/
endef

#openjdk configure is not based on automake
$(eval $(generic-package))
