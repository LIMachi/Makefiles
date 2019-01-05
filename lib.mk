ifeq ($(MAKEFILES_DIR), )
MAKEFILES_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
endif

include $(MAKEFILES_DIR)/common.mk

.srcs:
	printf "SRCS = " > .srcs
	find . -type f | grep "\.c$$" | cut -f2- -d/ | grep -v " " | sed "s/^/       /" | sed "s/$$/ \\\\/" $(foreach V, $(TEST_SRCS), | grep -v "$(V)") $(foreach V, $(BLACK_LIST_SRCS), | grep -v "$(V)") | sed "1s/^       //" | sed "$$ s/..$$//" >> .srcs

TEST_OBJS := $(patsubst %.c, $(OBJ_DIR)/%.o, $(TEST_SRCS))

test: test.bin
	$(PRE_TEST) ./test.bin $(TEST_ARG)

$(NAME): $(OBJS)
	@echo Adding objects to archive $@:
	@$(AR) $(ARFLAGS) $@ $?

test.bin: $(TEST_OBJS) $(NAME) | $(CLIB) $(LDLIBS)
	@echo Preparing temporary executable test.bin
	@$(LD) $^ $| $(LDFLAGS) -o $@

clean:
	@echo Removing $(OBJ_DIR) and test.bin
	@$(RM) -rf $(OBJ_DIR)
	@$(RM) -f test.bin
ifneq ($(RECURSIVE), )
ifneq ($(CLIB), )
	@echo Recursive:
	@$(foreach V, $(dir $(CLIB)), $(MAKE) -C $(V) --no-print-directory -j clean;)
endif
endif

fclean:
	@echo Removing $(NAME), $(OBJ_DIR) and test.bin
	@$(RM) -rf $(OBJ_DIR)
	@$(RM) -f test.bin
	@$(RM) -rf $(NAME)
ifneq ($(RECURSIVE), )
ifneq ($(CLIB), )
	@echo Recursive:
	@$(foreach V, $(dir $(CLIB)), $(MAKE) -C $(V) --no-print-directory -j fclean;)
endif
endif

include $(MAKEFILES_DIR)/common_second_pass.mk