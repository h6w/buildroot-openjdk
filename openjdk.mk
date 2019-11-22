################################################################################
#
# openjdk
#
################################################################################

#Version is the same as OpenJDK HG tag

OPENJDK_VERSION_MAJOR = 12.0.2
OPENJDK_VERSION_MINOR = 10
OPENJDK_VERSION = $(OPENJDK_VERSION_MAJOR)+$(OPENJDK_VERSION_MINOR)
OPENJDK_RELEASE = jdk12u
OPENJDK_PROJECT = jdk-updates
OPENJDK_SOURCE = jdk-$(OPENJDK_VERSION).tar.gz
OPENJDK_SITE = https://hg.openjdk.java.net/$(OPENJDK_PROJECT)/$(OPENJDK_RELEASE)/archive
OPENJDK_LICENSE = GPL-2.0+ with exception
OPENJDK_LICENSE_FILES = LICENSE

OPENJDK_EXTRA_CFLAGS = $(TARGET_CFLAGS)
OPENJDK_EXTRA_CXXFLAGS = $(TARGET_CXXFLAGS)

# OpenJDK requires Alsa, cups, and X11 even for a headless build.
# host-zip is needed for the zip executable.
OPENJDK_DEPENDENCIES = \
	host-gawk \
	host-openjdk-bin \
	host-pkgconf \
	host-zip \
	host-zlib \
	alsa-lib \
	libffi \
	cups \
	freetype \
	fontconfig \
	giflib \
	jpeg \
	lcms2 \
	libpng \
	libusb \
	xlib_libXrandr \
	xlib_libXrender \
	xlib_libXt \
	xlib_libXext \
	xlib_libXtst \
	zlib

# JVM variants
ifeq ($(BR2_PACKAGE_OPENJDK_JVM_VARIANT_CLIENT),y)
OPENJDK_JVM_VARIANT = client
endif
ifeq ($(BR2_PACKAGE_OPENJDK_JVM_VARIANT_SERVER),y)
OPENJDK_JVM_VARIANT = server
endif

# OpenJDK ignores some variables unless passed via the environment.
# These variables are PATH, LD, CC, CXX, and CPP.
# OpenJDK defaults ld to the ld binary but passes -Xlinker and -z as
# arguments during the linking process, which causes compilation failures.
# To fix this issue, LD is set to point to gcc.
OPENJDK_CONF_ENV = \
	PATH=$(BR_PATH) \
	CC=$(TARGET_CC) \
	CPP=$(TARGET_CPP) \
	CXX=$(TARGET_CXX) \
	LD=$(TARGET_CC) \
	BUILD_SYSROOT_CFLAGS="$(HOST_CFLAGS)" \
	BUILD_SYSROOT_LDFLAGS="$(HOST_LDFLAGS)"


ifeq ($(BR2_TOOLCHAIN_USES_UCLIBC),y)
	export DISABLE_HOTSPOT_OS_VERSION_CHECK=ok
	OPENJDK_EXTRA_CFLAGS += -fno-stack-protector
	OPENJDK_EXTRA_CXXFLAGS += -fno-stack-protector
endif

OPENJDK_CONF_OPTS = \
	--disable-full-docs \
	--disable-hotspot-gtest \
	--disable-manpages \
	--disable-warnings-as-errors \
	--enable-unlimited-crypto \
	--openjdk-target=$(GNU_TARGET_NAME) \
	--with-boot-jdk=$(HOST_DIR) \
	--with-debug-level=release \
	--with-devkit=$(HOST_DIR) \
	--with-extra-cflags="$(OPENJDK_EXTRA_CFLAGS)" \
	--with-extra-cxxflags="$(OPENJDK_EXTRA_CXXFLAGS)" \
	--with-giflib=system \
	--with-jobs=$(PARALLEL_JOBS) \
	--with-jvm-variants=$(OPENJDK_JVM_VARIANT) \
	--with-lcms=system \
	--with-libjpeg=system \
	--with-libpng=system \
	--with-zlib=system \
	--with-native-debug-symbols=none \
	--without-version-pre \
	--with-sysroot=$(STAGING_DIR) \
        --with-x \
	--with-version-build="$(OPENJDK_VERSION_MAJOR)" \
	--with-version-string="$(OPENJDK_VERSION_MAJOR)"

# If building for AArch64, use the provided CPU port.
ifeq ($(BR2_aarch64),y)
OPENJDK_CONF_OPTS += --with-abi-profile=aarch64
endif

ifeq ($(BR2_CCACHE),y)
OPENJDK_CONF_OPTS += \
	--enable-ccache \
	--with-ccache-dir=$(BR2_CCACHE_DIR)
endif

# Autogen and configure are performed in a single step.
define OPENJDK_CONFIGURE_CMDS
	chmod +x $(@D)/configure
	cd $(@D); $(OPENJDK_CONF_ENV) ./configure autogen $(OPENJDK_CONF_OPTS)
endef

# Make -jn is unsupported. Instead, set the "--with-jobs=" configure option,
# and use $(MAKE1).
define OPENJDK_BUILD_CMDS
	# LD is using CC because busybox -ld do not support -Xlinker -z hence linking using -gcc instead
	$(TARGET_MAKE_ENV) $(MAKE1) -C $(@D) legacy-jre-image
endef

# Calling make install always builds and installs the JDK instead of the JRE,
# which makes manual installation necessary.
define OPENJDK_INSTALL_TARGET_CMDS
	cp -dpfr $(@D)/build/linux-*-release/images/jre/bin/* $(TARGET_DIR)/usr/bin/
	cp -dpfr $(@D)/build/linux-*-release/images/jre/lib/* $(TARGET_DIR)/usr/lib/
	echo 'LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/server' >> $(TARGET_DIR)/etc/environment
endef

$(eval $(generic-package))
