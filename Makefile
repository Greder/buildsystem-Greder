#master makefile

SHELL = /bin/bash
UID := $(shell id -u)
ifeq ($(UID), 0)
warn:
	@echo "You are running as root. Do not do this, it is dangerous."
	@echo "Aborting the build. Log in as a regular user and retry."
else
LC_ALL:=C
LANG:=C
export TOPDIR LC_ALL LANG

# Boxtype
init:
	@echo "Welcome!"
	@echo "Target receivers:"
	@echo -e "   \033[01;32m1)  HL101\033[00m"
	@read -p "Press Enter " BOXTYPE; \
	BOXTYPE=$${BOXTYPE}; \
	case "$$BOXTYPE" in \
		1) BOXTYPE="hl101";; \
		*) BOXTYPE="hl101";; \
	esac; \
	echo "BOXTYPE=$$BOXTYPE" > config
# box	
	@echo -e "\nBox:"
	@echo "   1) Gi-s980"
	@echo "   2) Opticum-HD"
	@read -p "Select optimization (1-2)? " BOX; \
	BOX=$${BOX}; \
	case "$$BOX" in \
		1) echo "BOX=Gi-s980" >> config;; \
		2) echo "BOX=Opticum-HD" >> config;; \
		3|*) ;; \
	esac; \
# tuner	
	@echo -e "\nTuner:"
	@echo "   1) RB"
	@echo "   2) ST"
	@read -p "Select optimization (1-2)? " TUNER; \
	TUNER=$${TUNER}; \
	case "$$TUNER" in \
		1) echo "TUNER=RB" >> config;; \
		2) echo "TUNER=ST" >> config;; \
		3|*) ;; \
	esac; \
# kernel debug	
	@echo -e "\nOptimization:"
	@echo -e "   \033[01;32m1) optimization for size\033[00m"
	@echo "   2) optimization normal"
	@read -p "Select optimization (1-2)? " OPTIMIZATIONS; \
	OPTIMIZATIONS=$${OPTIMIZATIONS}; \
	case "$$OPTIMIZATIONS" in \
		1) echo "OPTIMIZATIONS=size" >> config;; \
		2) echo "OPTIMIZATIONS=normal" >> config;; \
		*) echo "OPTIMIZATIONS=size" >> config;; \
	esac; \
# WLAN driver
	@echo -e "\nDo you want to build WLAN drivers and tools"
	@echo "   1) no"
	@echo "   2) yes (includes WLAN drivers and tools)"
	@read -p "Select to build (1-2)? " WLAN; \
	WLAN=$${WLAN}; \
	case "$$WLAN" in \
		1) echo "WLAN=" >> config;; \
		2) echo "WLAN=wlandriver" >> config;; \
		3|*) ;; \
	esac; \
# Media framework
	@echo -e "\nMedia Framework:"
	@echo -e "   \033[01;32m1) libeplayer3\033[00m"
	@echo "   2) gstreamer (not recommended for sh boxes)"
	@read -p "Select media framework (1-2)? " MEDIAFW; \
	MEDIAFW=$${MEDIAFW}; \
	case "$$MEDIAFW" in \
		1) echo "MEDIAFW=buildinplayer" >> config;; \
		2) echo "MEDIAFW=gstreamer" >> config;; \
		*) echo "MEDIAFW=buildinplayer" >> config;; \
	esac; \
# lua
	@echo -e "\nLua support:"
	@echo -e "   \033[01;32m1) yes\033[00m"
	@echo "   2) no"
	@read -p "Select lua support (1-2)? " LUA; \
	LUA=$${LUA}; \
	case "$$LUA" in \
		1) echo "LUA=lua" >> config;; \
		2) echo "LUA=" >> config;; \
		*) echo "LUA=lua" >> config;; \
	esac; \
# python
	@echo -e "\nPython support:"
	@echo "   1) yes"
	@echo -e "   \033[01;32m2) no\033[00m"
	@read -p "Select python support (1-2)? " PYTHON; \
	PYTHON=$${PYTHON}; \
	case "$$PYTHON" in \
		1) echo "PYTHON=python" >> config;; \
		2) echo "PYTHON=" >> config;; \
		*) echo "PYTHON=" >> config;; \
	esac; \
# emu
	@echo -e "\nOscam:"
	@echo "   1) yes"
	@echo "   2) no"
	@read -p "Select emu support? " EMU; \
	EMU=$${EMU}; \
	case "$$EMU" in \
		1) echo "EMU=oscam" >> config;; \
		2) echo "EMU=" >> config;; \
		3|*) ;; \
	esac; \
#	
	@echo ""
	@make printenv
	@echo "Your next step could be:"
	@echo "  make release-neutrino"
	@echo ""
	@echo ""
	@echo "for more details:"
	@echo "  make help"
	@echo "to check your build enviroment:"
	@echo "  make printenv"
	@echo ""

include make/buildenv.mk

PARALLEL_JOBS := $(shell echo $$((1 + `getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1`)))
override MAKE = make $(if $(findstring j,$(filter-out --%,$(MAKEFLAGS))),,-j$(PARALLEL_JOBS))

#
#  A print out of environment variables
#
# maybe a help about all supported targets would be nice here, too...
#
printenv:
	@echo
	@echo '================================================================================'
	@echo "Build Environment Variables:"
	@echo "PATH             : `type -p fmt>/dev/null&&echo $(PATH)|sed 's/:/ /g' |fmt -65|sed 's/ /:/g; 2,$$s/^/                 : /;'||echo $(PATH)`"
	@echo "ARCHIVE_DIR      : $(ARCHIVE)"
	@echo "BASE_DIR         : $(BASE_DIR)"
	@echo "CUSTOM_DIR       : $(CUSTOM_DIR)"
	@echo "APPS_DIR         : $(APPS_DIR)"
	@echo "DRIVER_DIR       : $(DRIVER_DIR)"
	@echo "FLASH_DIR        : $(FLASH_DIR)"
	@echo "CROSS_DIR        : $(CROSS_DIR)"
	@echo "RELEASE_DIR      : $(RELEASE_DIR)"
	@echo "HOST_DIR         : $(HOST_DIR)"
	@echo "TARGET_DIR       : $(TARGET_DIR)"
	@echo "KERNEL_DIR       : $(KERNEL_DIR)"
	@echo "MAINTAINER       : $(MAINTAINER)"
	@echo "BOXARCH          : $(BOXARCH)"
	@echo "BUILD            : $(BUILD)"
	@echo "TARGET           : $(TARGET)"
	@echo "GCC_VER          : $(GCC_VER)"
	@echo "BOXTYPE          : $(BOXTYPE)"
	@echo "BOX              : $(BOX)"
	@echo "TUNER            : $(TUNER)"
	@echo "KERNEL_VERSION   : $(KERNEL_VER)"
	@echo "OPTIMIZATIONS    : $(OPTIMIZATIONS)"
	@echo "MEDIAFW          : $(MEDIAFW)"
	@echo "WLAN             : $(WLAN)"
	@echo "LUA              : $(LUA)"
	@echo "PYTHON           : $(PYTHON)"
	@echo "EMU              : $(EMU)"
	@echo "CICAM            : $(CICAM)"
	@echo "SCART            : $(SCART)"
	@echo "LCD              : $(LCD)"
	@echo "F-KEYS           : $(FKEYS)"
	@echo "PARALLEL_JOBS    : $(PARALLEL_JOBS)"
	@echo '================================================================================'
	@make --no-print-directory toolcheck
ifeq ($(MAINTAINER),)
	@echo "##########################################################################"
	@echo "# The MAINTAINER variable is not set. It defaults to your name from the  #"
	@echo "# passwd entry, but this seems to have failed. Please set it in 'config'.#"
	@echo "##########################################################################"
	@echo
endif
	@if ! test -e $(BASE_DIR)/config; then \
		echo;echo "If you want to create or modify the configuration, run './make.sh'"; \
		echo; fi

help:
	@echo "a few helpful make targets:"
	@echo ""
	@echo "show board configuration:"
	@echo " make printenv			- show board build configuration"
	@echo ""
	@echo "toolchains:"
	@echo " make crosstool			- build cross toolchain"
	@echo " make bootstrap			- prepares for building"
	@echo ""
	@echo "show all build-targets:"
	@echo " make print-targets		- show all available targets"
	@echo ""
	@echo "later, you might find these useful:"
	@echo " make update			- update the build system, apps, driver and flash"
	@echo ""
	@echo "release or image:"
	@echo " make release-neutrino   - build neutrino with full release dir"
	@echo " make flashimage		- build flashimage"
	@echo ""
	@echo "to update neutrino"
	@echo " make neutrino-distclean	- clean neutrino build"
	@echo " make neutrino			- build neutrino (neutrino plugins)"
	@echo ""
	@echo "cleantargets:"
	@echo " make clean			- clears everything except toolchain."
	@echo " make distclean			- clears the whole construction."
	@echo ""
	@echo "show all supported boards:"
	@echo " make print-boards		- show all supported boards"
	@echo

# define package versions first...
include make/contrib-libs.mk
include make/contrib-apps.mk
include make/ffmpeg.mk
include make/crosstool-sh4.mk
include make/linux-kernel.mk
include make/driver.mk
include make/gstreamer.mk
include make/root-etc.mk
include make/python.mk
include make/lua.mk
include make/tools.mk
ifeq ($(EMU), oscam)
include make/oscam.mk
endif
include make/release.mk
include make/cleantargets.mk
include make/patches.mk
include make/bootstrap.mk
include make/system-tools.mk
include make/neutrino.mk
include make/release-neutrino.mk
include make/titan.mk

update:
	@if test -d $(BASE_DIR); then \
		cd $(BASE_DIR)/; \
		echo '===================================================================='; \
		echo '      updating $(GIT_NAME)-buildsystem git repository'; \
		echo '===================================================================='; \
		echo; \
		if [ "$(GIT_STASH_PULL)" = "stashpull" ]; then \
			git stash && git stash show -p > ./pull-stash-cdk.patch || true && git pull && git stash pop || true; \
		else \
			git pull; \
		fi; \
	fi
	@echo;
	@if test -d $(DRIVER_DIR); then \
		cd $(DRIVER_DIR)/; \
		echo '==================================================================='; \
		echo '      updating $(GIT_NAME_DRIVER)-driver git repository'; \
		echo '==================================================================='; \
		echo; \
		if [ "$(GIT_STASH_PULL)" = "stashpull" ]; then \
			git stash && git stash show -p > ./pull-stash-driver.patch || true && git pull && git stash pop || true; \
		else \
			git pull; \
		fi; \
	fi
	@echo;
	@if test -d $(APPS_DIR); then \
		cd $(APPS_DIR)/; \
		echo '==================================================================='; \
		echo '      updating $(GIT_NAME_APPS)-apps git repository'; \
		echo '==================================================================='; \
		echo; \
		if [ "$(GIT_STASH_PULL)" = "stashpull" ]; then \
			git stash && git stash show -p > ./pull-stash-apps.patch || true && git pull && git stash pop || true; \
		else \
			git pull; \
		fi; \
	fi
	@echo;
	@if test -d $(FLASH_DIR); then \
		cd $(FLASH_DIR)/; \
		echo '==================================================================='; \
		echo '      updating $(GIT_NAME_FLASH)-flash git repository'; \
		echo '==================================================================='; \
		echo; \
		if [ "$(GIT_STASH_PULL)" = "stashpull" ]; then \
			git stash && git stash show -p > ./pull-stash-flash.patch || true && git pull && git stash pop || true; \
		else \
			git pull; \
		fi; \
	fi
	@echo;
	@if test -d $(HOSTAPPS_DIR); then \
		cd $(HOSTAPPS_DIR)/; \
		echo '==================================================================='; \
		echo '      updating $(GIT_NAME_HOSTAPPS)-hostapps git repository'; \
		echo '==================================================================='; \
		echo; \
		if [ "$(GIT_STASH_PULL)" = "stashpull" ]; then \
			git stash && git stash show -p > ./pull-stash-hostapps.patch || true && git pull && git stash pop || true; \
		else \
			git pull; \
		fi; \
	fi
	@echo;

all:
	@echo "'make all' is not a valid target. Please read the documentation."

# print all present targets...
print-targets:
	@sed -n 's/^\$$.D.\/\(.*\):.*/\1/p' \
		`ls -1 make/*.mk|grep -v make/buildenv.mk|grep -v make/release.mk` | \
		sort -u | fold -s -w 65
		
# print all supported boards ...
print-boards:
	@ls machine | sed 's/.mk//g' 

# for local extensions, e.g. special plugins or similar...
# put them into $(BASE_DIR)/local since that is ignored in .gitignore
-include ./Makefile.local

# debug target, if you need that, you know it. If you don't know if you need
# that, you don't need it.
.print-phony:
	@echo $(PHONY)

PHONY += everything print-targets
PHONY += all printenv .print-phony
PHONY += update
.PHONY: $(PHONY)

# this makes sure we do not build top-level dependencies in parallel
# (which would not be too helpful anyway, running many configure and
# downloads in parallel...), but the sub-targets are still built in
# parallel, which is useful on multi-processor / multi-core machines
.NOTPARALLEL:

endif

