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

OPENJDK_CONF_ENV = \
	PATH=$(BR_PATH) \
	CC=$(TARGET_CC) \
	CPP=$(TARGET_CPP) \
	CXX=$(TARGET_CXX) \
	LD=$(TARGET_CC) \
	BUILD_SYSROOT_CFLAGS="$(HOST_CFLAGS)" \
	BUILD_SYSROOT_LDFLAGS="$(HOST_LDFLAGS)"

OPENJDK_CONF_OPTS = \
	--disable-full-docs \
	--disable-hotspot-gtest \
	--disable-manpages \
	--disable-warnings-as-errors \
        --with-debug-level=release \
        --openjdk-target=$(GNU_TARGET_NAME) \
	--with-sysroot=$(STAGING_DIR) \
	--with-boot-jdk=$(HOST_DIR) \
	--with-devkit=$(HOST_DIR) \
	--with-extra-cflags="$(TARGET_CFLAGS) -fno-stack-protector" \
	--with-extra-cxxflags="$(TARGET_CXXFLAGS) -fno-stack-protector" \
        --with-x \
	$(OPENJDK_GENERAL_OPTS)

OPENJDK_MAKE_OPTS = \
	$(OPENJDK_GENERAL_OPTS) \
        images

OPENJDK_DEPENDENCIES = \
	host-openjdk-bin \
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
	cd $(@D); $(OPENJDK_CONF_ENV) ./configure autogen $(OPENJDK_CONF_OPTS)
endef

define OPENJDK_BUILD_CMDS
	# LD is using CC because busybox -ld do not support -Xlinker -z hence linking using -gcc instead
	$(TARGET_MAKE_ENV) $(MAKE1) -C $(@D) legacy-jre-image
endef

define OPENJDK_INSTALL_TARGET_CMDS
	cp -dpfr $(@D)/build/linux-*-release/images/jre/bin/* $(TARGET_DIR)/usr/bin/
	cp -dpfr $(@D)/build/linux-*-release/images/jre/lib/* $(TARGET_DIR)/usr/lib/
endef

#openjdk configure is not based on automake
$(eval $(generic-package))
