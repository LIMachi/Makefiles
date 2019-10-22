need_rebuild = $(shell make --no-print-directory -j -q -s VERBOSE= RECURSIVE= -C $(1) || echo 'FORCE')

-include $(DEPS)

$(DEP_DIR)/%.d: ;

.SECONDEXPANSION:

ifneq ($(CLIB), )
$(CLIB): $$(strip $$(call need_rebuild,$$(@D)))
ifneq ($(VERBOSE), )
	@$(ECHO) $(LOCAL_MAKEFILE): Sub-library $@ needs rebuild
endif
	@$(MAKE) -C $(@D) --no-print-directory -j
endif

$(OBJ_DIR)/%.o: %.c | $$(@D)/. $(DEP_DIR)/$$(*D)/. $$(LDLIBS) $$(CLIBS)
$(OBJ_DIR)/%.o: %.c $(DEP_DIR)/%.d | $$(@D)/. $(DEP_DIR)/$$(*D)/. $$(LDLIBS) $$(CLIBS)
ifneq ($(VERBOSE), )
	@$(ECHO) $(LOCAL_MAKEFILE): Compiling object $@
	$(CC) $(CFLAGS) -MT $@ -MMD -MP -MF $(DEP_DIR)/$*.Td -c $< -o $@
	mv -f $(DEP_DIR)/$*.Td $(DEP_DIR)/$*.d
	touch $@
else
	@$(CC) $(CFLAGS) -MT $@ -MMD -MP -MF $(DEP_DIR)/$*.Td -c $< -o $@
	@mv -f $(DEP_DIR)/$*.Td $(DEP_DIR)/$*.d
	@touch $@
endif
