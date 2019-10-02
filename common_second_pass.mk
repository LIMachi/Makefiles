libraries = $(shell make --no-print-directory -j -q -s VERBOSE= RECURSIVE= -C $(1) || echo 'FORCE')

include $(DEPS)
.PRECIOUS: $(DEPS)

$(DEP_DIR)/%.d: ;

.SECONDEXPANSION:

ifneq ($(CLIB), )
$(CLIB): $$(strip $$(call libraries,$$(@D)))
	@echo Sub-library $@ needs rebuild
	@$(MAKE) -C $(@D) --no-print-directory -j
endif

$(OBJ_DIR)/%.o: %.c | $$(@D)/. $(DEP_DIR)/$$(*D)/. $$(LDLIBS) $$(CLIBS)
$(OBJ_DIR)/%.o: %.c $(DEP_DIR)/%.d | $$(@D)/. $(DEP_DIR)/$$(*D)/. $$(LDLIBS) $$(CLIBS)
ifneq ($(VERBOSE), )
	@echo $(LOCAL_MAKEFILE):
	$(CC) $(CFLAGS) -MT $@ -MMD -MP -MF $(DEP_DIR)/$*.Td -c $< -o $@
	mv -f $(DEP_DIR)/$*.Td $(DEP_DIR)/$*.d
	@touch $@
	@echo $(LOCAL_MAKEFILE): Compiled object $@
else
	@$(CC) $(CFLAGS) -MT $@ -MMD -MP -MF $(DEP_DIR)/$*.Td -c $< -o $@
	@mv -f $(DEP_DIR)/$*.Td $(DEP_DIR)/$*.d
	@touch $@
endif
