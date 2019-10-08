.DEFAULT_GOAL := all

ifeq ($(MAIN_MAKEFILE_DIR), )
MAIN_MAKEFILE_DIR := $(realpath $(dir $(firstword $(MAKEFILE_LIST))))
endif

LOCAL_MAKEFILE := $(realpath $(firstword $(MAKEFILE_LIST)))

FORWARD := MAIN_MAKEFILE_DIR=$(MAIN_MAKEFILE_DIR)

ifneq ($(VERBOSE), )
FORWARD += VERBOSE=1
ARFLAGS := $(ARFLAGS)v
endif

MAKEFILE_FILES_DIR := .makefile_files

CFLAGS += -Wall -Wextra -Werror $($(UNAME)_CFLAGS) $(foreach V, $(INC_DIR), -I$(V))

LDFLAGS += $($(UNAME)_LDFLAGS)
LDLIBS += $($(UNAME)_LDLIBS)
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
ifneq ($(VERBOSE), )
$(info $(LOCAL_MAKEFILE): no SRCS set, including/generating $(MAKEFILE_FILES_DIR)/srcs)
include $(MAKEFILE_FILES_DIR)/srcs
else
-include $(MAKEFILE_FILES_DIR)/srcs
endif
endif

OBJ_DIR := $(MAKEFILE_FILES_DIR)/obj
DEP_DIR := $(MAKEFILE_FILES_DIR)/dep
CLIB_DIR := $(MAKEFILE_FILES_DIR)/clib

OBJS := $(patsubst %.c, $(OBJ_DIR)/%.o, $(SRCS))
DEPS := $(patsubst %.c, $(DEP_DIR)/%.d, $(SRCS))

ifneq ($(DEBUG), )
FORWARD += DEBUG=1
PRE_TEST += #valgrind
CFLAGS += -g
endif

ifneq ($(SANITIZE), )
FORWARD += SANITIZE=1
CFLAGS += -g -fsanitize=address
LDFLAGS += -fsanitize=address
endif

ifneq ($(RECURSIVE), )
FORWARD += RECURSIVE=1
endif

#if neither DEBUG nor SANITIZE is set
ifneq ($(DEBUG), )
ifneq ($(SANITIZE), )
CFLAGS += -O3
endif
endif

.PRECIOUS: $(MAKEFILE_FILES_DIR)/. $(MAKEFILE_FILES_DIR)%/.

all: $(NAME) FORCE

$(MAKEFILE_FILES_DIR)/.:
ifneq ($(VERBOSE), )
	@echo $(LOCAL_MAKEFILE): Building main directory
endif
	@mkdir -p $@

$(MAKEFILE_FILES_DIR)%/.:
ifneq ($(VERBOSE), )
	@echo $(LOCAL_MAKEFILE): Building sub directory
endif
	@mkdir -p $@

re: FORCE
	$(MAKE) $(FORWARD) fclean
	$(MAKE) $(FORWARD) all

#%.h:

.PHONY: FORCE all re clean fclean

FORCE:

$(MAKEFILE_FILES_DIR)/srcs: | $(MAKEFILE_FILES_DIR)/.
ifneq ($(VERBOSE), )
	@echo $(LOCAL_MAKEFILE): preparing $(MAKEFILE_FILES_DIR)/srcs
	printf "SRCS = " > $(MAKEFILE_FILES_DIR)/srcs
	find . -type f | grep "\.c$$" $(foreach V, $(BLACK_LIST_SRCS), | grep -v "$(V)") $(foreach V, $(TEST_SRCS), | grep -v "^$(V)$$") | cut -f2- -d/ | grep -v " " | sed "s/^/       /" | sed "s/$$/ \\\\/" | sed "1s/^       //" | sed "$$ s/..$$//" >> $(MAKEFILE_FILES_DIR)/srcs
else
	@printf "SRCS = " > $(MAKEFILE_FILES_DIR)/srcs
	@find . -type f | grep "\.c$$" $(foreach V, $(BLACK_LIST_SRCS), | grep -v "$(V)") $(foreach V, $(TEST_SRCS), | grep -v "^$(V)$$") | cut -f2- -d/ | grep -v " " | sed "s/^/       /" | sed "s/$$/ \\\\/" | sed "1s/^       //" | sed "$$ s/..$$//" >> $(MAKEFILE_FILES_DIR)/srcs
endif

CMAKE_INCLUDE_DIRECTORIES := $(shell echo | clang -Wp,-v -xc - 2>&1 | grep " /" | cut -c2- | grep -v " ")

CMake:
ifneq ($(VERBOSE), )
	@echo $(LOCAL_MAKEFILE): preparing CMakeLists.txt
	echo "cmake_minimum_required(VERSION 3.12)\nproject($(NAME))\nset(CMAKE_CXX_STANDARD 14)\ninclude_directories($(INC_DIR) $(CMAKE_INCLUDE_DIRECTORIES))" > CMakeLists.txt
	$(foreach V, $(CLIB), echo "add_subdirectory($(dir $(V)) $(MAKEFILE_FILES_DIR))" >> CMakeLists.txt;)
	echo "add_library($(NAME) $(TEST_SRCS) $(SRCS))" >> CMakeLists.txt
else
	@echo "cmake_minimum_required(VERSION 3.12)\nproject($(NAME))\nset(CMAKE_CXX_STANDARD 14)\ninclude_directories($(INC_DIR) $(CMAKE_INCLUDE_DIRECTORIES))" > CMakeLists.txt
	@$(foreach V, $(CLIB), echo "add_subdirectory($(dir $(V)) $(MAKEFILE_FILES_DIR))" >> CMakeLists.txt;)
	@echo "add_library($(NAME) $(TEST_SRCS) $(SRCS))" >> CMakeLists.txt
endif
ifneq ($(RECURSIVE), )
ifneq ($(CLIB), )
ifneq ($(VERBOSE), )
	@echo Recursive CMake:
endif
	@$(foreach V, $(dir $(CLIB)), $(MAKE) $(FORWARD) -C $(V) --no-print-directory -j CMake;)
endif
endif

clean: FORCE
ifneq ($(VERBOSE), )
	@echo $(LOCAL_MAKEFILE): Removing $(OBJ_DIR) and test.bin
	$(RM) -rf $(OBJ_DIR)
	$(RM) -f test.bin
else
	@$(RM) -rf $(OBJ_DIR) test.bin
endif
ifneq ($(RECURSIVE), )
ifneq ($(CLIB), )
ifneq ($(VERBOSE), )
	@echo Recursive clean:
endif
	@$(foreach V, $(dir $(CLIB)), $(MAKE) $(FORWARD) -C $(V) --no-print-directory -j clean;)
endif
endif

fclean: FORCE
ifneq ($(VERBOSE), )
	@echo $(LOCAL_MAKEFILE): Removing $(NAME), $(OBJ_DIR) and test.bin
	$(RM) -rf $(OBJ_DIR) $(NAME) test.bin
else
	@$(RM) -rf $(OBJ_DIR) $(NAME) test.bin
endif
ifneq ($(RECURSIVE), )
ifneq ($(CLIB), )
ifneq ($(VERBOSE), )
	@echo Recursive fclean:
endif
	@$(foreach V, $(dir $(CLIB)), $(MAKE) $(FORWARD) -C $(V) --no-print-directory -j fclean;)
endif
endif

mclean: FORCE
ifneq ($(VERBOSE), )
	@echo $(LOCAL_MAKEFILE): Removing $(MAKEFILE_FILES_DIR), CMakeLists.txt cmake-build-debug and CMakeFiles
	$(RM) -rf $(MAKEFILE_FILES_DIR) CMakeLists.txt cmake-build-debug CMakeFiles
else
	@$(RM) -rf $(MAKEFILE_FILES_DIR) CMakeLists.txt cmake-build-debug CMakeFiles
endif
ifneq ($(RECURSIVE), )
ifneq ($(CLIB), )
ifneq ($(VERBOSE), )
	@echo Recursive mclean:
endif
	@$(foreach V, $(dir $(CLIB)), $(MAKE) $(FORWARD) -C $(V) --no-print-directory -j mclean;)
endif
endif
