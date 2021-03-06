TEST_SRCS :=

$(BUILD_NAME): $(CLIB) $(OBJS) | $(LDLIBS)
ifneq ($(VERBOSE), )
	$(LD) $(OBJS) $(CLIB) $| $(LDFLAGS) -o $@
else
	@$(ECHO) $(SNAME): Compiling binary $@
	@$(LD) $(OBJS) $(CLIB) $| $(LDFLAGS) -o $@
endif

test: $(SNAME)
	$(PRE_TEST) ./$(SNAME) $(TEST_ARG)
