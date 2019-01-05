.DEFAULT_GOAL := all

UNAME := $(shell uname)

CFLAGS += -Wall -Wextra -Werror $($(UNAME)_CFLAGS)
LDFLAGS += $($(UNAME)_LDFLAGS)
SRCS += $($(UNAME)_SRCS)
TEST_SRCS += $($(UNAME)_TEST_SRCS)

ifneq ($($(UNAME)_CC), )
CC := $($(UNAME)_CC)
endif

ifneq ($($(UNAME)_LD), )
LD := $($(UNAME)_LD)
endif

ifneq ($($(UNAME)_AR), )
AR := $($(UNAME)_AR)
endif

ifeq ($(SRCS), )
$(warning no SRCS set, including .srcs)
include .srcs
endif

.srcs:
	printf "SRCS = " > .srcs
	find . -type f | grep "\.c$$" | cut -f2- -d/ | grep -v " " | sed "s/^/       /" | sed "s/$$/ \\\\/" $(foreach V, $(TEST_SRCS), | grep -v "$(V)") $(foreach V, $(BLACK_LIST_DIR), | grep -v "$(V)") | sed "1s/^       //" | sed "$$ s/..$$//" >> .srcs

OBJS := $(patsubst %.c, $(OBJ_DIR)/%.o, $(SRCS))
TEST_OBJS := $(patsubst %.c, $(OBJ_DIR)/%.o, $(TEST_SRCS))

ifneq ($(DEBUG), )
PRE_TEST += valgrind
CFLAGS += -g
endif

ifneq ($(SANITIZE), )
CFLAGS += -g -fsanitize=address
LDFLAGS += -fsanitize=address
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

test.bin: $(TEST_OBJS) $(NAME) | $(CLIB) $(LDLIBS)
	@echo Preparing temporary executable test.bin
	@$(LD) $^ $| $(LDFLAGS) -o $@

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

%: FORCE
	@echo $@

.SECONDEXPANSION:

ifneq ($(CLIB), )
$(CLIB): $$(strip $$(call libraries,$$(@D)))
	@echo Sub-library $@ needs rebuild
	@$(MAKE) -C $(@D) --no-print-directory -j
endif

$(OBJ_DIR)/%.o: %.c $$(strip $$(call dependency,$$*)) | $$(@D)/.
	@$(CC) $(CFLAGS) -c $< -o $@
	@echo Compiled object $@
