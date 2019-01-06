ifeq ($(MAKEFILES_DIR), )
MAKEFILES_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
endif

include $(MAKEFILES_DIR)/common.mk

.srcs:
	printf "SRCS = " > .srcs
	find . -type f | grep "\.c$$" | cut -f2- -d/ | grep -v " " | sed "s/^/       /" | sed "s/$$/ \\\\/" $(foreach V, $(BLACK_LIST_SRCS), | grep -v "$(V)") | sed "1s/^       //" | sed "$$ s/..$$//" >> .srcs

$(NAME): $(OBJS) | $(CLIB) $(LDLIBS)
	@echo Compiling binary $@
	@$(LD) $^ $| $(LDFLAGS) -o $@

clean: FORCE
	@echo Removing $(OBJ_DIR)
	@$(RM) -rf $(OBJ_DIR)
ifneq ($(RECURSIVE), )
ifneq ($(CLIB), )
	@echo Recursive:
	@$(foreach V, $(dir $(CLIB)), $(MAKE) -C $(V) --no-print-directory -j clean;)
endif
endif

fclean: FORCE
	@echo Removing $(NAME) and $(OBJ_DIR)
	@$(RM) -rf $(OBJ_DIR)
	@$(RM) -rf $(NAME)
ifneq ($(RECURSIVE), )
ifneq ($(CLIB), )
	@echo Recursive:
	@$(foreach V, $(dir $(CLIB)), $(MAKE) -C $(V) --no-print-directory -j fclean;)
endif
endif

include $(MAKEFILES_DIR)/common_second_pass.mk
