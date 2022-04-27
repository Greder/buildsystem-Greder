#
STM_RELOCATE     = /opt/STM/STLinux-2.4

# updates / downloads
STL_FTP          = http://archive.stlinux.com/stlinux/2.4
STL_FTP_UPD_SRC  = $(STL_FTP)/updates/SRPMS
STL_FTP_UPD_SH4  = $(STL_FTP)/updates/RPMS/sh4
STL_FTP_UPD_HOST = $(STL_FTP)/updates/RPMS/host

## ordering is important here. The /host/ rule must stay before the less
## specific %.sh4/%.i386/%.noarch rule. No idea if this is portable or
## even reliable :-(
$(ARCHIVE)/stlinux24-host-%.i386.rpm \
$(ARCHIVE)/stlinux24-host-%noarch.rpm:
	$(WGET) $(STL_FTP_UPD_HOST)/$(subst $(ARCHIVE)/,"",$@)

$(ARCHIVE)/stlinux24-host-%.src.rpm:
	$(WGET) $(STL_FTP_UPD_SRC)/$(subst $(ARCHIVE)/,"",$@)

$(ARCHIVE)/stlinux24-sh4-%.sh4.rpm \
$(ARCHIVE)/stlinux24-cross-%.i386.rpm \
$(ARCHIVE)/stlinux24-sh4-%.noarch.rpm:
	$(WGET) $(STL_FTP_UPD_SH4)/$(subst $(ARCHIVE)/,"",$@)

#
# install the RPMs
#

# 4.6.3
#BINUTILS_VER = 2.22-64
#GCC_VER      = 4.6.3-111
#LIBGCC_VER   = 4.6.3-111
#GLIBC_VER    = 2.10.2-42

# 4.8.4
BINUTILS_VER = 2.24.51.0.3-76
GCC_VER      = 4.8.4-139
LIBGCC_VER   = 4.8.4-148
GLIBC_VER    = 2.14.1-59

crosstool-rpminstall: \
$(ARCHIVE)/stlinux24-cross-sh4-binutils-$(BINUTILS_VER).i386.rpm \
$(ARCHIVE)/stlinux24-cross-sh4-binutils-dev-$(BINUTILS_VER).i386.rpm \
$(ARCHIVE)/stlinux24-cross-sh4-cpp-$(GCC_VER).i386.rpm \
$(ARCHIVE)/stlinux24-cross-sh4-gcc-$(GCC_VER).i386.rpm \
$(ARCHIVE)/stlinux24-cross-sh4-g++-$(GCC_VER).i386.rpm \
$(ARCHIVE)/stlinux24-sh4-linux-kernel-headers-$(STM_KERNEL_HEADERS_VER).noarch.rpm \
$(ARCHIVE)/stlinux24-sh4-glibc-$(GLIBC_VER).sh4.rpm \
$(ARCHIVE)/stlinux24-sh4-glibc-dev-$(GLIBC_VER).sh4.rpm \
$(ARCHIVE)/stlinux24-sh4-libgcc-$(LIBGCC_VER).sh4.rpm \
$(ARCHIVE)/stlinux24-sh4-libstdc++-$(LIBGCC_VER).sh4.rpm \
$(ARCHIVE)/stlinux24-sh4-libstdc++-dev-$(LIBGCC_VER).sh4.rpm
	$(SCRIPTS_DIR)/unpack-rpm.sh $(BUILD_TMP) $(STM_RELOCATE)/devkit/sh4 $(CROSS_DIR) \
		$^
	touch $(D)/$(notdir $@)

CROSSTOOL = crosstool
crosstool: $(D)/directories driver-symlink crosstool-rpminstall
	@touch $(D)/$(notdir $@)

$(TARGET_DIR)/lib/libc.so.6:
	set -e; cd $(CROSS_DIR); rm -f sh4-linux/sys-root; ln -s ../target sh4-linux/sys-root; \
	if [ -e $(CROSS_DIR)/target/usr/lib/libstdc++.la ]; then \
		sed -i "s,^libdir=.*,libdir='$(CROSS_DIR)/target/usr/lib'," $(CROSS_DIR)/target/usr/lib/lib{std,sup}c++.la; \
	fi
	if test -e $(CROSS_DIR)/target/usr/lib/libstdc++.so; then \
		cp -a $(CROSS_DIR)/target/usr/lib/libstdc++.s*[!y] $(TARGET_DIR)/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/libdl.so $(TARGET_DIR)/usr/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/libm.so $(TARGET_DIR)/usr/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/librt.so $(TARGET_DIR)/usr/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/libutil.so $(TARGET_DIR)/usr/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/libpthread.so $(TARGET_DIR)/usr/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/libresolv.so $(TARGET_DIR)/usr/lib; \
		ln -sf $(CROSS_DIR)/target/usr/lib/libc.so $(TARGET_DIR)/usr/lib/libc.so; \
		ln -sf $(CROSS_DIR)/target/usr/lib/libc_nonshared.a $(TARGET_DIR)/usr/lib/libc_nonshared.a; \
	fi
	if test -e $(CROSS_DIR)/target/lib; then \
		cp -a $(CROSS_DIR)/target/lib/*so* $(TARGET_DIR)/lib; \
	fi
	if test -e $(CROSS_DIR)/target/sbin/ldconfig; then \
		cp -a $(CROSS_DIR)/target/sbin/ldconfig $(TARGET_DIR)/sbin; \
		cp -a $(CROSS_DIR)/target/etc/ld.so.conf $(TARGET_DIR)/etc; \
		cp -a $(CROSS_DIR)/target/etc/host.conf $(TARGET_DIR)/etc; \
	fi

#
# host_u_boot_tools
#
HOST_U_BOOT_TOOLS_VER = 1.3.1_stm24-9

host_u_boot_tools: \
$(ARCHIVE)/stlinux24-host-u-boot-tools-$(HOST_U_BOOT_TOOLS_VER).i386.rpm
	$(START_BUILD)
	$(SCRIPTS_DIR)/unpack-rpm.sh $(BUILD_TMP) $(STM_RELOCATE)/host/bin $(HOST_DIR)/bin \
		$^
	@touch $(D)/$(notdir $@)
	@echo -e "Build of $(TERM_GREEN_BOLD)$@$(PKG_VER) $(TERM_NORMAL)completed."; echo


