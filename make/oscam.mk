OSCAM_CONFIG = \
		./config.sh \
		--disable all \
		--enable WEBIF \
		CS_ANTICASC \
		CS_CACHEEX \
		CW_CYCLE_CHECK \
		CLOCKFIX \
		HAVE_DVBAPI \
		IRDETO_GUESSING \
		MODULE_MONITOR \
		READ_SDT_CHARSETS \
		TOUCH \
		WEBIF_JQUERY \
		WEBIF_LIVELOG \
		WITH_DEBUG \
		WITH_EMU \
		WITH_LB \
		WITH_NEUTRINO \
		WITH_SSL \
		\
		MODULE_CAMD35 \
		MODULE_CAMD35_TCP \
		MODULE_CCCAM \
		MODULE_CCCSHARE \
		MODULE_CONSTCW \
		MODULE_GBOX \
		MODULE_NEWCAMD \
		\
		READER_CONAX \
		READER_CRYPTOWORKS \
		READER_IRDETO \
		READER_NAGRA \
		READER_NAGRA_MERLIN \
		READER_SECA \
		READER_VIACCESS \
		READER_VIDEOGUARD \
		\
		CARDREADER_INTERNAL \
		CARDREADER_PHOENIX \
		CARDREADER_SMARGO \
		CARDREADER_SC8IN1

$(D)/oscam.do_prepare: $(D)/openssl
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/oscam-svn*
	[ -d "$(ARCHIVE)/oscam-svn" ] && \
	(cd $(ARCHIVE)/oscam-svn; svn up;); \
	[ -d "$(ARCHIVE)/oscam-svn" ] || \
	svn checkout http://www.streamboard.tv/svn/oscam/trunk $(ARCHIVE)/oscam-svn; \
	cp -ra $(ARCHIVE)/oscam-svn $(SOURCE_DIR)/oscam-svn;\
	cp -ra $(SOURCE_DIR)/oscam-svn $(SOURCE_DIR)/oscam-svn.org;\
	cd $(SOURCE_DIR)/oscam-svn; \
		$(OSCAM_CONFIG) \
			$(SILENT_OPT)
	touch $@

$(D)/oscam.do_compile:
	cd $(SOURCE_DIR)/oscam-svn && \
		$(BUILDENV) \
		$(MAKE) CROSS=$(TARGET)- USE_LIBCRYPTO=1 USE_LIBUSB=1 \
		PLUS_TARGET="-rezap" \
		CONF_DIR=/var/keys \
		EXTRA_LDFLAGS="$(TARGET_LDFLAGS)" \
		CC_OPTS=" -Os -pipe "
	touch $@

$(D)/oscam: $(D)/bootstrap $(D)/openssl $(D)/libusb oscam.do_prepare oscam.do_compile
	rm -rf $(TARGET_DIR)/../build_oscam
	mkdir $(TARGET_DIR)/../build_oscam
	cp -pR $(SOURCE_DIR)/oscam-svn/Distribution/* $(TARGET_DIR)/../build_oscam/
	rm -rf $(SOURCE_DIR)/oscam-svn*
	$(TOUCH)

oscam-clean:
	rm -f $(D)/oscam
	cd $(SOURCE_DIR)/oscam-svn && \
		$(MAKE) distclean

oscam-distclean:
	rm -f $(D)/oscam
	rm -f $(D)/oscam.do_compile
	rm -f $(D)/oscam.do_prepare

