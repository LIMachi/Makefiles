ifeq ($(MAKEFILES_DIR), )
MAKEFILES_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
endif

TEST_SRCS :=

include $(MAKEFILES_DIR)/common.mk

$(NAME): $(CLIB) $(OBJS) | $(LDLIBS)
ifneq ($(VERBOSE), )
	@echo $(LOCAL_MAKEFILE): Compiling binary $@
	$(LD) $(OBJS) $(CLIB) $| $(LDFLAGS) -o $@
else
	@$(LD) $(OBJS) $(CLIB) $| $(LDFLAGS) -o $@
endif

test: $(NAME) FORCE
	$(PRE_TEST) ./$(NAME) $(TEST_ARG)

include $(MAKEFILES_DIR)/common_second_pass.mk
