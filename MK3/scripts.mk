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
	$(foreach V, $(CMAKE_MODULES), echo "add_subdirectory($(V))" >> CMakeLists.txt;)
	echo "add_library($(NAME) $(TEST_SRCS) $(SRCS))" >> CMakeLists.txt
else
	@echo "cmake_minimum_required(VERSION 3.12)\nproject($(NAME))\nset(CMAKE_CXX_STANDARD 14)\ninclude_directories($(INC_DIR) $(CMAKE_INCLUDE_DIRECTORIES))" > CMakeLists.txt
	@$(foreach V, $(CLIB), echo "add_subdirectory($(dir $(V)) $(MAKEFILE_FILES_DIR))" >> CMakeLists.txt;)
	@$(foreach V, $(CMAKE_MODULES), echo "add_subdirectory($(V))" >> CMakeLists.txt;)
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
