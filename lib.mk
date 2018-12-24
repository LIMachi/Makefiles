CFLAGS += -Iinc -Wall -Wextra -Werror

OBJS := $(patsubst %.c, $(OBJ_DIR)/%.o, $(SRCS))

TEST_OBJS := $(patsubst %.c, $(OBJ_DIR)/%.o, $(TEST_SRCS))

ifneq ($(DEBUG), )
PRE_TEST += valgrind
CFLAGS += -g
endif

ifneq ($(SANITIZE), )
CFLAGS += -g -fsanitize=address
LDLIBS += -fsanitize=address
endif

#if neither DEBUG nor SANITIZE is set
ifneq ($(DEBUG), )
ifneq ($(SANITIZE), )
CFLAGS += -O3
endif
endif

.PHONY: all clean fclean re test FORCE
.PRECIOUS: $(OBJ_DIR)/. $(OBJ_DIR)%/.

all: $(NAME)

test: test.bin
	$(PRE_TEST) ./test.bin $(TEST_ARG)

$(NAME): $(OBJS)
	@echo Adding objects to archive $@:
	@$(AR) $(ARFLAGS) $@ $?

test.bin: $(TEST_OBJS) | $(NAME) $(CLIB)
	@echo Preparing temporary executable test.bin
	@$(CC) $(LDFLAGS) $^ $| $(LDLIBS) -o $@

$(OBJ_DIR)/.:
	@echo Preparing $(OBJ_DIR) to hold object files
	@mkdir -p $@

$(OBJ_DIR)%/.:
	@echo Preparing subdir $(patsubst %/., %, $@) to hold object files
	@mkdir -p $@

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

re: | fclean all

dependency = $(shell $(CC) -M -MT $(OBJ_DIR)/$(1).o $(CFLAGS) $(1).c | egrep -oe "[^ ]+\.h")
libraries = $(shell make -q -s -C $(1) || echo 'FORCE')

FORCE:

%.h:

.SECONDEXPANSION:
ifneq ($(CLIB), )
$(CLIB): $$(strip $$(call libraries,$$(@D)))
	@echo Sub-library $@ needs rebuild
	@$(MAKE) -C $(@D) --no-print-directory -j
endif

$(OBJ_DIR)/%.o: %.c $$(strip $$(call dependency,$$*)) | $$(@D)/.
	@$(CC) $(CFLAGS) -c $< -o $@
	@echo Compiled object $@