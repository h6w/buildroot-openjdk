################################################################################
#
# openjdk
#
# Please be aware that, when cross-compiling, the OpenJDK configure script will
# generally use 'target' where autoconf traditionally uses 'host'
#
################################################################################

#Version is the same as OpenJDK HG tag

OPENJDK_VERSION = jdk-9.0.4+11
OPENJDK_RELEASE = jdk9u
OPENJDK_PROJECT = jdk-updates
OPENJDK_VARIANT = client
OPENJDK_SOURCE = openjdk-$(OPENJDK_VERSION).tar.xz
OPENJDK_SITE = http://cdn.tudorholton.net

#export LIBFFI_CFLAGS=-I$(HOST_DIR)/usr/$(TARGET_ARCH)-buildroot-linux-gnu/include
#export LIBFFI_LIBS=-L$(HOST_DIR)/usr/$(TARGET_ARCH)-linux-gnu/sysroot/usr/lib/ -lffi

# TODO make conditional
# --with-import-hotspot=$(STAGING_DIR)/hotspot \

export DISABLE_HOTSPOT_OS_VERSION_CHECK=ok
OPENJDK_CONF_OPTS = \
	--with-jvm-interpreter=cpp \
	--with-jvm-variants=$(OPENJDK_VARIANT) \
	--with-freetype-include=$(STAGING_DIR)/usr/include/freetype2 \
	--with-freetype-lib=$(STAGING_DIR)/usr/lib \
        --with-freetype=$(STAGING_DIR)/usr/ \
        --with-debug-level=release \
        --openjdk-target=$(GNU_TARGET_NAME) \
	--with-sys-root=$(STAGING_DIR) \
	--with-tools-dir=$(HOST_DIR) \
	--disable-freetype-bundling \
        --enable-unlimited-crypto \
	--with-extra-cflags='-Wno-maybe-uninitialized' \
        --with-x
	
OPENJDK_MAKE_OPTS = all CONF=linux-$(TARGET_ARCH)-normal-zero-release
OPENJDK_DEPENDENCIES = alsa-lib host-pkgconf libffi cups freetype xlib_libXrender xlib_libXt xlib_libXext xlib_libXtst libusb

OPENJDK_LICENSE = GPLv2+ with exception
OPENJDK_LICENSE_FILES = COPYING

define OPENJDK_CONFIGURE_CMDS
	mkdir -p $(STAGING_DIR)/hotspot/lib
	touch $(STAGING_DIR)/hotspot/lib/sa-jdi.jar
	mkdir -p $(STAGING_DIR)/hotspot/jre/lib/$(OPENJDK_HOTSPOT_ARCH)/server
	#cp $(TARGET_DIR)/usr/lib/libjvm.so $(STAGING_DIR)/hotspot/jre/lib/$(OPENJDK_HOTSPOT_ARCH)/server
	mkdir -p $(STAGING_DIR)/usr/lib/jvm/lib/$(OPENJDK_HOTSPOT_ARCH)/server
	#cp $(TARGET_DIR)/usr/lib/libjvm.so $(STAGING_DIR)/usr/lib/jvm/lib/$(OPENJDK_HOTSPOT_ARCH)/server
	ln -sf server $(STAGING_DIR)/hotspot/jre/lib/$(OPENJDK_HOTSPOT_ARCH)/client
	touch $(STAGING_DIR)/hotspot/jre/lib/$(OPENJDK_HOTSPOT_ARCH)/server/Xusage.txt
	ln -sf libjvm.so $(STAGING_DIR)/hotspot/jre/lib/$(OPENJDK_HOTSPOT_ARCH)/client/libjsig.so
	chmod +x $(@D)/configure
	cd $(@D); ./configure $(OPENJDK_CONF_OPTS) OBJCOPY=$(TARGET_OBJCOPY) STRIP=$(TARGET_STRIP) CPP_FLAGS=-lstdc++ CXX_FLAGS=-lstdc++ CPP=$(TARGET_CPP) CXX=$(TARGET_CXX) CC=$(TARGET_CC) LD=$(TARGET_LD)
endef

define OPENJDK_BUILD_CMDS
	# LD is using CC because busybox -ld do not support -Xlinker -z hence linking using -gcc instead
	OBJCOPY=$(TARGET_OBJCOPY) STRIP=$(TARGET_STRIP) BUILD_CC=gcc BUILD_LD=ld CPP=$(TARGET_CPP) CXX=$(TARGET_CXX) CC=$(TARGET_CC) LD=$(TARGET_LD) make -C $(@D) jdk
endef

define HOST_OPENJDK_BUILD_CMDS
	# LD is using CC because busybox -ld do not support -Xlinker -z hence linking using -gcc instead
	OBJCOPY=$(HOST_OBJCOPY) STRIP=$(HOST_STRIP) BUILD_CC=gcc BUILD_LD=ld CPP=$(HOST_CPP) CXX=$(HOST_CXX) CC=$(HOST_CC) LD=$(HOST_LD) make -C $(@D) hotspot
endef

define HOST_OPENJDK_INSTALL_CMDS
	mkdir -p $(HOST_DIR)/usr/lib/jvm/
endef

define OPENJDK_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/lib/jvm/
	cp -aLrf $(@D)/build/*/jdk/* $(TARGET_DIR)/usr/lib/jvm/
	cp -arf $(@D)/build/*/jdk/lib/$(OPENJDK_VARIANT)/libjsig.so $(TARGET_DIR)/usr/lib/jvm/lib/
	cp -arf $(@D)/build/*/jdk/lib/$(OPENJDK_VARIANT)/libjvm.so $(TARGET_DIR)/usr/lib/jvm/lib/
endef

#openjdk configure is not based on automake
$(eval $(generic-package))
$(eval $(host-generic-package))
