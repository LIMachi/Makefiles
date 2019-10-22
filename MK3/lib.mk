TEST_OBJS := $(patsubst %.c, $(OBJ_DIR)/%.o, $(TEST_SRCS))

.PHONY: test
test: test.bin
	$(PRE_TEST) ./test.bin $(TEST_ARG)

$(BUILD_NAME): $(OBJS) | $(CLIB)
ifneq ($(VERBOSE), )
	$(AR) $(ARFLAGS) $@ $? 2>&1
	touch $@
else
	@$(ECHO) $(LOCAL_MAKEFILE): Adding objects to archive $@
	@$(AR) $(ARFLAGS) $@ $? 2>&1
endif

test.bin: $(TEST_OBJS) $(SNAME) | $(CLIB) $(LDLIBS)
ifneq ($(VERBOSE), )
	$(LD) $^ $| $(LDFLAGS) -o $@
else
	@$(ECHO) $(LOCAL_MAKEFILE): Preparing temporary executable test.bin
	@$(LD) $^ $| $(LDFLAGS) -o $@
endif
