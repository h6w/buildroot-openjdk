################################################################################
#
# openjdk
#
################################################################################

#Version is the same as OpenJDK HG tag

OPENJDK_VERSION = 12.0.1+12
OPENJDK_RELEASE = jdk12u
OPENJDK_PROJECT = jdk-updates
OPENJDK_VARIANT = server
OPENJDK_SOURCE = jdk-$(OPENJDK_VERSION).tar.gz
OPENJDK_SITE = https://hg.openjdk.java.net/$(OPENJDK_PROJECT)/$(OPENJDK_RELEASE)/archive
OPENJDK_LICENSE = GPLv2+ with exception
OPENJDK_LICENSE_FILES = COPYING

export DISABLE_HOTSPOT_OS_VERSION_CHECK=ok
OPENJDK_CONF_OPTS = \
        --openjdk-target=$(GNU_TARGET_NAME) \
        --with-boot-jdk=$(HOST_DIR) \
        --with-debug-level=release \
	--with-devkit=$(HOST_DIR) \
	--with-extra-cflags='-Os -Wno-maybe-uninitialized' \
	--with-sysroot=$(STAGING_DIR) \
        --with-x \
	$(OPENJDK_GENERAL_OPTS)

# If building for AArch64, use the provided CPU port.
ifeq ($(BR2_aarch64),y)
OPENJDK_CONF_OPTS += --with-abi-profile=aarch64
endif

ifeq ($(BR2_CCACHE),y)
OPENJDK_CONF_OPTS += \
	--enable-ccache \
	--with-ccache-dir=$(BR2_CCACHE_DIR)
endif
	
OPENJDK_MAKE_OPTS = \
	$(OPENJDK_GENERAL_OPTS) \
        images

OPENJDK_DEPENDENCIES = \
	alsa-lib \
	host-openjdk-bin \
	host-pkgconf \
	libffi \
	cups \
	freetype \
	xlib_libXrender \
	xlib_libXt \
	xlib_libXext \
	xlib_libXtst \
	libusb \
	giflib \
	jpeg

define OPENJDK_CONFIGURE_CMDS
	chmod +x $(@D)/configure
	cd $(@D); ./configure autogen $(OPENJDK_CONF_OPTS)
endef

define OPENJDK_BUILD_CMDS
	# LD is using CC because busybox -ld do not support -Xlinker -z hence linking using -gcc instead
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D) $(OPENJDK_MAKE_OPTS)
endef

define OPENJDK_INSTALL_TARGET_CMDS
	cp -dpfr $(@D)/build/linux-*-release/images/jdk/bin/* $(TARGET_DIR)/usr/bin
	cp -dpfr $(@D)/build/linux-*-release/images/jdk/lib/* $(TARGET_DIR)/usr/lib/
endef

#openjdk configure is not based on automake
$(eval $(generic-package))
