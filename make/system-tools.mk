#
# system-tools
#
SYSTEM_TOOLS  = $(D)/busybox
SYSTEM_TOOLS += $(D)/zlib
SYSTEM_TOOLS += $(D)/sysvinit
SYSTEM_TOOLS += $(D)/util_linux
SYSTEM_TOOLS += $(D)/e2fsprogs
SYSTEM_TOOLS += $(D)/hdidle
SYSTEM_TOOLS += $(D)/portmap
ifneq ($(BOXTYPE), $(filter $(BOXTYPE), ufs910 ufs922))
SYSTEM_TOOLS += $(D)/jfsutils
SYSTEM_TOOLS += $(D)/nfs_utils
endif
SYSTEM_TOOLS += $(D)/vsftpd
SYSTEM_TOOLS += $(D)/autofs
SYSTEM_TOOLS += $(D)/udpxy
SYSTEM_TOOLS += $(D)/dvbsnoop
SYSTEM_TOOLS += $(D)/fbshot
ifeq ($(BOXARCH), $(filter $(BOXARCH), arm mips))
#SYSTEM_TOOLS += $(D)/ofgwrite
endif
SYSTEM_TOOLS += $(D)/diverse-tools

$(D)/system-tools: $(SYSTEM_TOOLS) $(TOOLS)
	@touch $@
