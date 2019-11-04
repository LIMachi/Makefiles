#should be the last thing included (and body.mk should be included)

ifeq ($(filter clean fclean mclean CMake, $(MAKECMDGOALS)), )

need_rebuild = $(shell make --no-print-directory -j -q -s VERBOSE= RECURSIVE= -C $(1) || echo 'FORCE')

-include $(DEPS)

$(DEP_DIR)/%.d: ;

.SECONDEXPANSION:

ifneq ($(CLIB), )
$(CLIB): $$(strip $$(call need_rebuild,$$(@D)))
ifneq ($(VERBOSE), )
	$(MAKE) -C $(@D) --no-print-directory -j
else
	@$(ECHO) $(SNAME): Sub-library $@ needs rebuild
	@$(MAKE) -C $(@D) --no-print-directory -j
endif
endif

$(OBJ_DIR)/%.o: %.c | $$(@D)/. $(DEP_DIR)/$$(*D)/. $$(LDLIBS) $$(CLIBS)
$(OBJ_DIR)/%.o: %.c $(DEP_DIR)/%.d | $$(@D)/. $(DEP_DIR)/$$(*D)/. $$(LDLIBS) $$(CLIBS)
ifneq ($(VERBOSE), )
	$(CC) $(CFLAGS) -MT $@ -MMD -MP -MF $(DEP_DIR)/$*.Td -c $< -o $@
	mv -f $(DEP_DIR)/$*.Td $(DEP_DIR)/$*.d
	touch $@
else
	@$(ECHO) $(SNAME): Compiling object for $<
	@$(CC) $(CFLAGS) -MT $@ -MMD -MP -MF $(DEP_DIR)/$*.Td -c $< -o $@
	@mv -f $(DEP_DIR)/$*.Td $(DEP_DIR)/$*.d
	@touch $@
endif
endif
