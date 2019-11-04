$(BUILD_DIR)/srcs: | $(BUILD_DIR)/.
ifneq ($(VERBOSE), )
	@$(ECHO) preparing $(BUILD_DIR)/srcs
	printf "SRCS = " > $(BUILD_DIR)/srcs
	find . -type f | grep "\.c$$" $(foreach V, $(BLACK_LIST_SRCS), | grep -v "$(V)") $(foreach V, $(TEST_SRCS), | grep -v "^$(V)$$") | cut -f2- -d/ | grep -v " " | sed "s/^/       /" | sed "s/$$/ \\\\/" | sed "1s/^       //" | sed "$$ s/..$$//" >> $(BUILD_DIR)/srcs
else
	@printf "SRCS = " > $(BUILD_DIR)/srcs
	@find . -type f | grep "\.c$$" $(foreach V, $(BLACK_LIST_SRCS), | grep -v "$(V)") $(foreach V, $(TEST_SRCS), | grep -v "^$(V)$$") | cut -f2- -d/ | grep -v " " | sed "s/^/       /" | sed "s/$$/ \\\\/" | sed "1s/^       //" | sed "$$ s/..$$//" >> $(BUILD_DIR)/srcs
endif

CMAKE_INCLUDE_DIRECTORIES := $(shell echo | clang -Wp,-v -xc - 2>&1 | grep " /" | cut -c2- | grep -v " ")

CMake:
ifneq ($(VERBOSE), )
	echo "cmake_minimum_required(VERSION 3.12)\nproject($(SNAME))\nset(CMAKE_CXX_STANDARD 14)\ninclude_directories($(INC_DIR) $(CMAKE_INCLUDE_DIRECTORIES))" > CMakeLists.txt
	$(foreach V, $(CLIB), echo "add_subdirectory($(dir $(V)) $(BUILD_DIR))" >> CMakeLists.txt;)
	$(foreach V, $(CMAKE_MODULES), echo "add_subdirectory($(V))" >> CMakeLists.txt;)
	echo "add_library($(SNAME) $(TEST_SRCS) $(SRCS))" >> CMakeLists.txt
else
	@$(ECHO) preparing CMakeLists.txt
	@echo "cmake_minimum_required(VERSION 3.12)\nproject($(SNAME))\nset(CMAKE_CXX_STANDARD 14)\ninclude_directories($(INC_DIR) $(CMAKE_INCLUDE_DIRECTORIES))" > CMakeLists.txt
	@$(foreach V, $(CLIB), echo "add_subdirectory($(dir $(V)) $(BUILD_DIR))" >> CMakeLists.txt;)
	@$(foreach V, $(CMAKE_MODULES), echo "add_subdirectory($(V))" >> CMakeLists.txt;)
	@echo "add_library($(SNAME) $(TEST_SRCS) $(SRCS))" >> CMakeLists.txt
endif
ifneq ($(RECURSIVE), )
ifneq ($(CLIB), )
ifneq ($(VERBOSE), )
	$(foreach V, $(dir $(CLIB)), $(MAKE) $(FORWARD) -C $(V) --no-print-directory -j CMake;)
else
	@$(ECHO) Recursive CMake:
	@$(foreach V, $(dir $(CLIB)), $(MAKE) $(FORWARD) -C $(V) --no-print-directory -j CMake;)
endif
endif
endif
