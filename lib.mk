ifeq ($(MAKEFILES_DIR), )
MAKEFILES_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
endif

include $(MAKEFILES_DIR)/common.mk

.srcs:
	@printf "SRCS = " > .srcs
	@find . -type f | grep "\.c$$" $(foreach V, $(BLACK_LIST_SRCS), | grep -v "$(V)") $(foreach V, $(TEST_SRCS), | grep -v "^$(V)$$") | cut -f2- -d/ | grep -v " " | sed "s/^/       /" | sed "s/$$/ \\\\/" | sed "1s/^       //" | sed "$$ s/..$$//" >> .srcs

TEST_OBJS := $(patsubst %.c, $(OBJ_DIR)/%.o, $(TEST_SRCS))

.PHONY: test
test: test.bin FORCE
	$(PRE_TEST) ./test.bin $(TEST_ARG)

CMake:
	@echo "cmake_minimum_required(VERSION 3.12)\nproject($(NAME))\ninclude_directories($(INC_DIR))" > CMakeLists.txt
	@$(foreach V, $(CLIB), $(if $(findstring ..,$(V)),, echo "add_subdirectory($(dir $(V)))" >> CMakeLists.txt;))
	@echo "add_library($(NAME) $(TEST_SRCS) $(SRCS))" >> CMakeLists.txt
	@echo $(MAKEFILE_PATH): built CMakeLists.txt

$(NAME): $(OBJS)
	@echo $(MAKEFILE_PATH): Adding objects to archive $@:
	@$(AR) $(ARFLAGS) $@ $?
	@touch $@

test.bin: $(TEST_OBJS) $(NAME) | $(CLIB) $(LDLIBS)
	@echo $(MAKEFILE_PATH): Preparing temporary executable test.bin
	@$(LD) $^ $| $(LDFLAGS) -o $@

clean: FORCE
	@echo $(MAKEFILE_PATH): Removing $(OBJ_DIR) and test.bin
	@$(RM) -rf $(OBJ_DIR)
	@$(RM) -f test.bin
ifneq ($(RECURSIVE), )
ifneq ($(CLIB), )
	@echo $(MAKEFILE_PATH): Recursive:
	@$(foreach V, $(dir $(CLIB)), $(MAKE) $(FORWARD) -C $(V) --no-print-directory -j clean;)
endif
endif

fclean: FORCE
	@echo $(MAKEFILE_PATH): Removing $(NAME), $(OBJ_DIR) and test.bin
	@$(RM) -rf $(OBJ_DIR) $(NAME) test.bin
ifneq ($(RECURSIVE), )
ifneq ($(CLIB), )
	@echo $(MAKEFILE_PATH): Recursive:
	@$(foreach V, $(dir $(CLIB)), $(MAKE) $(FORWARD) -C $(V) --no-print-directory -j fclean;)
endif
endif

include $(MAKEFILES_DIR)/common_second_pass.mk
