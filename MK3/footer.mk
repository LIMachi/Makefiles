#should be the last thing included (and body.mk should be included)

ifndef ECHO
T := $(shell $(MAKE) $(MAKECMDGOALS) --no-print-directory \
	-nrRf $(firstword $(MAKEFILE_LIST)) \
	ECHO="COUNTTHIS" | grep -c "COUNTTHIS")
N := x
C = $(words $N)$(eval N := x $N)
ECHO = sleep 0.02; python3 $(MAKEFILES_DIR)/echo_progress.py --stepno=$C --nsteps=$T
endif

ifeq ($(filter clean fclean mclean, $(MAKECMDGOALS)), )

need_rebuild = $(shell make --no-print-directory -j -q -s VERBOSE= RECURSIVE= -C $(1) || echo 'FORCE')

-include $(DEPS)

$(DEP_DIR)/%.d: ;

.SECONDEXPANSION:

ifneq ($(CLIB), )
$(CLIB): $$(strip $$(call need_rebuild,$$(@D)))
ifneq ($(VERBOSE), )
	$(MAKE) -C $(@D) --no-print-directory -j
else
	@$(ECHO) $(LOCAL_MAKEFILE): Sub-library $@ needs rebuild
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
	@$(ECHO) $(LOCAL_MAKEFILE): Compiling object $@
	@$(CC) $(CFLAGS) -MT $@ -MMD -MP -MF $(DEP_DIR)/$*.Td -c $< -o $@
	@mv -f $(DEP_DIR)/$*.Td $(DEP_DIR)/$*.d
	@touch $@
endif
endif
