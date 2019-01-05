dependency = $(shell $(CC) -M -MT $(OBJ_DIR)/$(1).o $(CFLAGS) $(1).c | egrep -oe "[^ ]+\.h")

libraries = $(shell make -q -s -C $(1) || echo 'FORCE')

.SECONDEXPANSION:

ifneq ($(CLIB), )
$(CLIB): $$(strip $$(call libraries,$$(@D)))
	@echo Sub-library $@ needs rebuild
	@$(MAKE) -C $(@D) --no-print-directory -j
endif

$(OBJ_DIR)/%.o: %.c $$(strip $$(call dependency,$$*)) | $$(@D)/.
	@$(CC) $(CFLAGS) -c $< -o $@
	@echo Compiled object $@
