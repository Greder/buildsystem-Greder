#
# Makefile to build NEUTRINO
#
$(TARGET_DIR)/.version:
	echo "imagename=neutrinoHD2" > $@
	echo "homepage=https://github.com/mohousch" >> $@
	echo "creator=$(MAINTAINER)" >> $@
	echo "docs=https://github.com/mohousch" >> $@
	echo "forum=https://github.com/mohousch/neutrinohd2" >> $@
	echo "version=0200`date +%Y%m%d%H%M`" >> $@
	echo "git=`git log | grep "^commit" | wc -l`" >> $@

#
# DEPS
#
NEUTRINO_DEPS  = $(D)/bootstrap
NEUTRINO_DEPS += $(D)/ncurses 
NEUTRINO_DEPS += $(D)/libcurl
NEUTRINO_DEPS += $(D)/libpng 
NEUTRINO_DEPS += $(D)/libjpeg 
NEUTRINO_DEPS += $(D)/giflib 
NEUTRINO_DEPS += $(D)/freetype
NEUTRINO_DEPS += $(D)/ffmpeg
NEUTRINO_DEPS += $(D)/libfribidi
NEUTRINO_DEPS += $(D)/libid3tag
NEUTRINO_DEPS += $(D)/libmad
NEUTRINO_DEPS += $(D)/libvorbisidec
NEUTRINO_DEPS += $(D)/flac
NEUTRINO_DEPS += $(D)/e2fsprogs

ifeq ($(PYTHON), python)
NEUTRINO_DEPS += $(D)/python
endif

ifeq ($(LUA), lua)
NEUTRINO_DEPS += $(D)/lua $(D)/luaexpat $(D)/luacurl $(D)/luasocket $(D)/luafeedparser $(D)/luasoap $(D)/luajson
endif

NEUTRINO_DEPS += $(LOCAL_NEUTRINO_DEPS)

#
# CFLAGS / CPPFLAGS
#
N_CFLAGS       = -Wall -W -Wshadow -pipe -Os
N_CFLAGS      += -D__KERNEL_STRICT_NAMES
N_CFLAGS      += -D__STDC_FORMAT_MACROS
N_CFLAGS      += -D__STDC_CONSTANT_MACROS
N_CFLAGS      += -fno-strict-aliasing -funsigned-char -ffunction-sections -fdata-sections
N_CFLAGS      += $(LOCAL_NEUTRINO_CFLAGS)

N_CPPFLAGS     = -I$(TARGET_DIR)/usr/include
N_CPPFLAGS    += -ffunction-sections -fdata-sections

ifeq ($(BOXARCH), arm)
N_CPPFLAGS    += -I$(CROSS_DIR)/$(TARGET)/sys-root/usr/include
endif

ifeq ($(BOXARCH), sh4)
N_CPPFLAGS    += -I$(DRIVER_DIR)/bpamem
N_CPPFLAGS    += -I$(KERNEL_DIR)/include
endif

ifeq ($(BOXTYPE), $(filter $(BOXTYPE), spark spark7162))
N_CPPFLAGS += -I$(DRIVER_DIR)/frontcontroller/aotom_spark
endif

N_CONFIG_OPTS  = $(LOCAL_NEUTRINO_BUILD_OPTIONS)
N_CONFIG_OPTS += --with-boxtype=$(BOXTYPE)

# MEDIAFW
MEDIAFW ?= gstreamer

ifeq ($(MEDIAFW), gstreamer)
NEUTRINO_DEPS  += $(D)/gst_plugins_dvbmediasink
N_CPPFLAGS     += $(shell $(PKG_CONFIG) --cflags --libs gstreamer-1.0)
N_CPPFLAGS     += $(shell $(PKG_CONFIG) --cflags --libs gstreamer-audio-1.0)
N_CPPFLAGS     += $(shell $(PKG_CONFIG) --cflags --libs gstreamer-video-1.0)
N_CPPFLAGS     += $(shell $(PKG_CONFIG) --cflags --libs glib-2.0)
NHD2_OPTS += --enable-gstreamer --with-gstversion=1.0
endif

# python
PYTHON ?=

ifeq ($(PYTHON), python)
NHD2_OPTS += --enable-python PYTHON_CPPFLAGS="-I$(TARGET_DIR)/usr/include/python2.7" PYTHON_LIBS="-L$(TARGET_DIR)/usr/lib -lpython2.7" PYTHON_SITE_PKG="$(TARGET_DIR)/usr/lib/python2.7/site-packages"
endif

# lua
LUA ?= lua

ifeq ($(LUA), lua)
NHD2_OPTS += --enable-lua
endif

# CICAM
CICAM ?= ci-cam

ifeq ($(CICAM), ci-cam)
NHD2_OPTS += --enable-ci
endif

# SCART
SCART ?= scart

ifeq ($(SCART), scart)
NHD2_OPTS += --enable-scart
endif

# LCD 
LCD ?= vfd

ifeq ($(LCD), lcd)
NHD2_OPTS += --enable-lcd
endif

ifeq ($(LCD), 4-digits)
NHD2_OPTS += --enable-4digits
endif

# FKEYS
FKEY ?=

ifeq ($(FKEYS), fkeys)
NHD2_OPTS += --enable-functionkeys
endif

NEUTRINO_HD2_PATCHES =

$(D)/neutrinohd2.do_prepare: $(NEUTRINO_DEPS)
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/neutrinohd2
	[ -d "$(ARCHIVE)/neutrinohd2.git" ] && \
	(cd $(ARCHIVE)/neutrinohd2.git; git pull;); \
	[ -d "$(ARCHIVE)/neutrinohd2.git" ] || \
	git clone https://github.com/mohousch/neutrinohd2.git $(ARCHIVE)/neutrinohd2.git; \
	cp -ra $(ARCHIVE)/neutrinohd2.git $(SOURCE_DIR)/neutrinohd2; \
	set -e; cd $(SOURCE_DIR)/neutrinohd2/nhd2-exp; \
		$(call apply_patches,$(NEUTRINO_HD2_PATCHES))
	@touch $@

$(D)/neutrinohd2.config.status:
	cd $(SOURCE_DIR)/neutrinohd2/nhd2-exp; \
		./autogen.sh; \
		$(BUILDENV) \
		./configure \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--enable-silent-rules \
			--enable-maintainer-mode \
			--with-boxtype=$(BOXTYPE) \
			$(NHD2_OPTS) \
			$(N_CONFIG_OPTS) \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CPPFLAGS="$(N_CPPFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)"
	@touch $@

$(D)/neutrinohd2.do_compile: $(D)/neutrinohd2.config.status
	cd $(SOURCE_DIR)/neutrinohd2/nhd2-exp; \
		$(MAKE) all
	@touch $@

$(D)/neutrino: $(D)/neutrinohd2.do_prepare $(D)/neutrinohd2.do_compile
	$(MAKE) -C $(SOURCE_DIR)/neutrinohd2/nhd2-exp install DESTDIR=$(TARGET_DIR)
	make $(TARGET_DIR)/.version
	touch $(D)/$(notdir $@)
	$(TUXBOX_CUSTOMIZE)

neutrino-clean:
	rm -f $(D)/neutrino
	$(MAKE) -C $(SOURCE_DIR)/neutrinohd2/nhd2-exp clean

neutrino-distclean:
	$(MAKE) -C $(SOURCE_DIR)/neutrinohd2/nhd2-exp distclean
	rm -rf $(SOURCE_DIR)/neutrinohd2/nhd2-exp/config.status
	rm -f $(D)/neutrino*
	
#
# neutrinohd2 plugins
#
NEUTRINO_HD2_PLUGINS_PATCHES =

$(D)/neutrinohd2-plugins.do_prepare: $(D)/neutrinohd2.do_prepare
	$(START_BUILD)
	set -e; cd $(SOURCE_DIR)/neutrinohd2/plugins; \
		$(call apply_patches, $(NEUTRINO_HD2_PLUGINS_PATCHES))
	@touch $@

$(D)/neutrinohd2-plugins.config.status: $(D)/bootstrap neutrino
	cd $(SOURCE_DIR)/neutrinohd2/plugins; \
		./autogen.sh; \
		$(BUILDENV) \
		./configure $(SILENT_OPT) \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--with-boxtype=$(BOXTYPE) \
			--enable-silent-rules \
			$(NHD2_OPTS) \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CPPFLAGS="$(CPPFLAGS) -I$(driverdir) -I$(KERNEL_DIR)/include -I$(TARGET_DIR)/include" \
			LDFLAGS="$(TARGET_LDFLAGS)"
	@touch $@

$(D)/neutrinohd2-plugins.do_compile: $(D)/neutrinohd2-plugins.config.status
	cd $(SOURCE_DIR)/neutrinohd2/plugins; \
	$(MAKE) top_srcdir=$(SOURCE_DIR)/neutrinohd2/nhd2-exp
	@touch $@

$(D)/neutrino-plugins: $(D)/neutrinohd2-plugins.do_compile
	$(MAKE) -C $(SOURCE_DIR)/neutrinohd2/plugins install DESTDIR=$(TARGET_DIR)

	touch $(D)/$(notdir $@)
	$(TUXBOX_CUSTOMIZE)

neutrino-plugins-clean:
	rm -f $(D)/neutrino-plugins
	$(MAKE) -C $(SOURCE_DIR)/neutrinohd2/plugins clean

neutrino-plugins-distclean:
	$(MAKE) -C $(SOURCE_DIR)/neutrinohd2/plugins distclean
	rm -f $(SOURCE_DIR)/neutrinohd2/plugins/config.status
	rm -f $(D)/neutrinohd2-plugins*

#
#
#
PHONY += $(TARGET_DIR)/.version



