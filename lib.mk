ifeq ($(MAKEFILES_DIR), )
MAKEFILES_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
endif

include $(MAKEFILES_DIR)/common.mk

TEST_OBJS := $(patsubst %.c, $(OBJ_DIR)/%.o, $(TEST_SRCS))

.PHONY: test
test: test.bin FORCE
	$(PRE_TEST) ./test.bin $(TEST_ARG)

$(NAME): $(OBJS) | $(CLIB)
ifneq ($(VERBOSE), )
	@echo $(LOCAL_MAKEFILE): Adding objects to archive $@:
	$(AR) $(ARFLAGS) $@ $? 2>&1
	@touch $@
else
	@$(AR) $(ARFLAGS) $@ $? 2>&1
endif

test.bin: $(TEST_OBJS) $(NAME) | $(CLIB) $(LDLIBS)
ifneq ($(VERBOSE), )
	@echo $(LOCAL_MAKEFILE): Preparing temporary executable test.bin
endif
	@$(LD) $^ $| $(LDFLAGS) -o $@

include $(MAKEFILES_DIR)/common_second_pass.mk
