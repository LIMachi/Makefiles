ifeq ($(MAKEFILES_DIR), )
MAKEFILES_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
endif

include $(MAKEFILES_DIR)/common.mk

.srcs:
	@printf "SRCS = " > .srcs
	@find . -type f | grep "\.c$$" $(foreach V, $(BLACK_LIST_SRCS), | grep -v "$(V)") | cut -f2- -d/ | grep -v " " | sed "s/^/       /" | sed "s/$$/ \\\\/" | sed "1s/^       //" | sed "$$ s/..$$//" >> .srcs

$(NAME): $(CLIB) $(OBJS) | $(LDLIBS)
	@echo $(MAKEFILE_PATH): Compiling binary $@
	@$(LD) $(OBJS) $(CLIB) $| $(LDFLAGS) -o $@

CMake:
	@echo "cmake_minimum_required(VERSION 3.12)\nproject($(NAME))\ninclude_directories($(INC_DIR))" > CMakeLists.txt
	@$(foreach V, $(CLIB), $(if $(findstring ..,$(V)),, echo "add_subdirectory($(dir $(V)))" >> CMakeLists.txt;))
	@echo "add_executable($(NAME) $(SRCS))" >> CMakeLists.txt
	@echo $(MAKEFILE_PATH): built CMakeLists.txt

test: $(NAME) FORCE
	$(PRE_TEST) ./$(NAME) $(TEST_ARG)

clean: FORCE
	@echo $(MAKEFILE_PATH): Removing $(OBJ_DIR)
	@$(RM) -rf $(OBJ_DIR)
ifneq ($(RECURSIVE), )
ifneq ($(CLIB), )
	@echo $(MAKEFILE_PATH): Recursive:
	@$(foreach V, $(dir $(CLIB)), $(MAKE) $(FORWARD) -C $(V) --no-print-directory -j clean;)
endif
endif

fclean: FORCE
	@echo $(MAKEFILE_PATH): Removing $(NAME) and $(OBJ_DIR)
	@$(RM) -rf $(OBJ_DIR) $(NAME)
ifneq ($(RECURSIVE), )
ifneq ($(CLIB), )
	@echo $(MAKEFILE_PATH): Recursive:
	@$(foreach V, $(dir $(CLIB)), $(MAKE) $(FORWARD) -C $(V) --no-print-directory -j fclean;)
endif
endif

include $(MAKEFILES_DIR)/common_second_pass.mk
