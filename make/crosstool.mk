# 
# crosstool-renew
#
crosstool-renew:
	ccache -cCz
	make distclean
	rm -rf $(CROSS_DIR)
	make crosstool

#
# libc
#
$(TARGET_DIR)/lib/libc.so.6:
	if test -e $(CROSS_DIR)/$(TARGET)/sys-root/lib; then \
		cp -a $(CROSS_DIR)/$(TARGET)/sys-root/lib/*so* $(TARGET_DIR)/lib; \
	else \
		cp -a $(CROSS_DIR)/$(TARGET)/lib/*so* $(TARGET_DIR)/lib; \
	fi

#
# crosstool-ng
#
CROSSTOOL_NG_VER = 872341e3
#CROSSTOOL_NG_VER = 7bd6bb00
#CROSSTOOL_NG_VER = 4e5bc436
CROSSTOOL_NG_SOURCE = crosstool-ng-git-$(CROSSTOOL_NG_VER).tar.bz2
CROSSTOOL_NG_URL = https://github.com/crosstool-ng/crosstool-ng.git
ifeq ($(BOXARCH), arm)
GCC_VER = linaro-6.3-2017.05
#GCC_VER = 6.5.0
#GCC_VER = 9.3.0
endif
ifeq ($(BOXARCH), mips)
GCC_VER = 4.9.4
#GCC_VER = 6.5.0
#GCC_VER = 9.3.0
endif

CUSTOM_KERNEL_VER ?= $(KERNEL_VER)

ifeq ($(CROSSTOOL_NG_VER), 872341e3)
CROSSTOOL_NG_PATCH = ct-ng/crosstool-872341e3-bash.patch
endif

CROSSTOOL_NG_BACKUP = $(ARCHIVE)/crosstool-ng-$(CROSSTOOL_NG_VER)-$(BOXARCH)-gcc-$(GCC_VER)-kernel-$(KERNEL_VER)-backup.tar.gz

$(ARCHIVE)/$(CROSSTOOL_NG_SOURCE):
	$(SCRIPTS_DIR)/get-git-archive.sh $(CROSSTOOL_NG_URL) $(CROSSTOOL_NG_VER) $(notdir $@) $(ARCHIVE)

CROSSTOOL = crosstool
crosstool:
	if test -e $(CROSSTOOL_NG_BACKUP); then \
		make crosstool-restore; \
	else \
		make MAKEFLAGS=--no-print-directory crosstool-ng; \
		if [ ! -e $(CROSSTOOL_NG_BACKUP) ]; then \
			make crosstool-backup; \
		fi; \
	fi
	@touch $(D)/$(notdir $@)

crosstool-ng: $(D)/directories $(ARCHIVE)/$(KERNEL_SRC) $(ARCHIVE)/$(CROSSTOOL_NG_SOURCE) kernel.do_prepare
	make $(BUILD_TMP)
	if [ ! -e $(CROSS_DIR) ]; then \
		mkdir -p $(CROSS_DIR); \
	fi;
	$(REMOVE)/crosstool-ng-git-$(CROSSTOOL_NG_VER)
	$(UNTAR)/$(CROSSTOOL_NG_SOURCE)
	unset CONFIG_SITE LIBRARY_PATH LD_LIBRARY_PATH CPATH C_INCLUDE_PATH PKG_CONFIG_PATH CPLUS_INCLUDE_PATH INCLUDE; \
	$(CHDIR)/crosstool-ng-git-$(CROSSTOOL_NG_VER); \
		cp -a $(PATCHES)/ct-ng/crosstool-ng-$(CROSSTOOL_NG_VER)-gcc-$(GCC_VER)-$(BOXARCH).config .config; \
		NUM_CPUS=$$(expr `getconf _NPROCESSORS_ONLN` \* 2); \
		MEM_512M=$$(awk '/MemTotal/ {M=int($$2/1024/512); print M==0?1:M}' /proc/meminfo); \
		test $$NUM_CPUS -gt $$MEM_512M && NUM_CPUS=$$MEM_512M; \
		test $$NUM_CPUS = 0 && NUM_CPUS=1; \
		sed -i "s@^CT_PARALLEL_JOBS=.*@CT_PARALLEL_JOBS=$$NUM_CPUS@" .config; \
		\
		$(call apply_patches, $(CROSSTOOL_NG_PATCH)); \
		\
		export CT_NG_ARCHIVE=$(ARCHIVE); \
		export CT_NG_BASE_DIR=$(CROSS_DIR); \
		export CT_NG_CUSTOM_KERNEL=$(KERNEL_DIR); \
		export CT_NG_CUSTOM_KERNEL_VER=$(CUSTOM_KERNEL_VER); \
		test -f ./configure || ./bootstrap && \
		./configure --enable-local; \
		MAKELEVEL=0 make; \
		chmod 0755 ct-ng; \
		./ct-ng oldconfig; \
		./ct-ng build
	chmod -R +w $(CROSS_DIR)
	test -e $(CROSS_DIR)/$(TARGET)/lib || ln -sf sys-root/lib $(CROSS_DIR)/$(TARGET)/
	rm -f $(CROSS_DIR)/$(TARGET)/sys-root/lib/libstdc++.so.6.0.20-gdb.py
	$(REMOVE)/crosstool-ng-git-$(CROSSTOOL_NG_VER)

#
# crosstool-backup
#
crosstool-backup:
	cd $(CROSS_DIR); \
	tar czvf $(CROSSTOOL_NG_BACKUP) *

#
# crosstool-restore
#
crosstool-restore: $(CROSSTOOL_NG_BACKUP)
	rm -rf $(CROSS_DIR) ; \
	if [ ! -e $(CROSS_DIR) ]; then \
		mkdir -p $(CROSS_DIR); \
	fi;
	tar xzvf $(CROSSTOOL_NG_BACKUP) -C $(CROSS_DIR)
	@touch $(D)/crosstool

#
# crossmenuconfig
#
crossmenuconfig: $(D)/directories $(ARCHIVE)/$(CROSSTOOL_NG_SOURCE)
	$(REMOVE)/crosstool-ng-git-$(CROSSTOOL_NG_VER)
	$(UNTAR)/$(CROSSTOOL_NG_SOURCE)
	set -e; unset CONFIG_SITE; cd $(BUILD_TMP)/crosstool-ng-git-$(CROSSTOOL_NG_VER); \
		cp -a $(PATCHES)/ct-ng/crosstool-ng-$(CROSSTOOL_NG_VER)-gcc-$(GCC_VER)-$(BOXARCH).config .config; \
		$(call apply_patches, $(CROSSTOOL_NG_PATCH)); \
		test -f ./configure || ./bootstrap && \
		./configure --enable-local; \
		MAKELEVEL=0 make; \
		chmod 0755 ct-ng; \
		./ct-ng menuconfig


