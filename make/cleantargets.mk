depsclean:
	( cd $(D) && find . ! -name "*\.*" -delete )

clean:
	@echo -e "$(TERM_YELLOW)---> cleaning everything except toolchain.$(TERM_NORMAL)"
	@-$(MAKE) kernel-clean
	@-$(MAKE) driver-clean
	@-$(MAKE) tools-clean
	@-rm -rf $(RELEASE_DIR)
	@-rm -rf $(TARGET_DIR)
	@-rm -rf $(SOURCE_DIR)
	@-rm -rf $(BOOT_DIR)
	@-rm -rf $(D)/kernel
	@-rm -rf $(D)/*.do_compile
	@-rm -rf $(D)/*.do_prepare
	@-rm -rf $(D)/*.config.status
	@-rm -rf $(D)/directories
	@-rm -rf $(D)/diverse-tools
	@-rm -rf $(D)/system-tools
	@echo -e "$(TERM_YELLOW)done\n$(TERM_NORMAL)"

distclean: depsclean
	@echo -e "$(TERM_YELLOW)---> cleaning whole build system .. $(TERM_NORMAL)"
	@-rm -rf $(RELEASE_DIR)
	@-rm -rf $(TARGET_DIR)
	@-rm -rf $(HOST_DIR)
	@-rm -rf $(BOOT_DIR)
	@-rm -rf $(CROSS_DIR)
	@-rm -rf $(BUILD_TMP)
	@-rm -rf $(SOURCE_DIR)
	@-rm -rf $(D)
	@echo -e "$(TERM_YELLOW)done\n$(TERM_NORMAL)"

%-clean:
	( cd $(D) && find . -name $(subst -clean,,$@) -delete )
