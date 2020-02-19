$(BUILD_DIR)/srcs: | $(BUILD_DIR)/.
ifneq ($(VERBOSE), )
	@$(ECHO) preparing $(BUILD_DIR)/srcs
	printf "SRCS = " > $(BUILD_DIR)/srcs
ifeq ($(WHITE_LIST_SRCS),)
	find . -type f | grep "\.c$$" $(foreach V, $(BLACK_LIST_SRCS), | grep -v "$(V)") $(foreach V, $(TEST_SRCS), | grep -v "^$(V)$$") | cut -f2- -d/ | grep -v " " | sed "s/^/       /" | sed "s/$$/ \\\\/" | sed "1s/^       //" | sed "$$ s/..$$//" >> $(BUILD_DIR)/srcs
else
	$(foreach W, $(WHITE_LIST_SRCS), find $W -type f | grep "\.c$$" $(foreach V, $(BLACK_LIST_SRCS), | grep -v "$(V)") $(foreach V, $(TEST_SRCS), | grep -v "^$(V)$$") | cut -f2- -d/ | grep -v " " | sed "s/^/       $W\//" | sed "s/$$/ \\\\/" | sed "1s/^       //" | sed "$$ s/..$$//" >> $(BUILD_DIR)/srcs;)
endif
else
	@printf "SRCS = " > $(BUILD_DIR)/srcs
ifeq ($(WHITE_LIST_SRCS),)
	@find . -type f | grep "\.c$$" $(foreach V, $(BLACK_LIST_SRCS), | grep -v "$(V)") $(foreach V, $(TEST_SRCS), | grep -v "^$(V)$$") | cut -f2- -d/ | grep -v " " | sed "s/^/       /" | sed "s/$$/ \\\\/" | sed "1s/^       //" | sed "$$ s/..$$//" >> $(BUILD_DIR)/srcs
else
	@$(foreach W, $(WHITE_LIST_SRCS), find $W -type f | grep "\.c$$" $(foreach V, $(BLACK_LIST_SRCS), | grep -v "$(V)") $(foreach V, $(TEST_SRCS), | grep -v "^$(V)$$") | cut -f2- -d/ | grep -v " " | sed "s/^/       $W\//" | sed "s/$$/ \\\\/" | sed "1s/^       //" | sed "$$ s/..$$//" >> $(BUILD_DIR)/srcs;)
endif
endif

CMAKE_INCLUDE_DIRECTORIES := $(shell echo | clang -Wp,-v -xc - 2>&1 | grep " /" | cut -c2- | grep -v " ")

.PHONY: CMake $(dir $(abspath $(SNAME)))CMakeLists.txt

resource: | $(BUILD_DIR)/.
	rm -rf $(dir $(abspath $(SNAME)))CMakeLists.txt $(BUILD_DIR)/srcs
	@make --no-print-directory -f $(LOCAL_MAKEFILE) CMake

CMake: $(dir $(abspath $(SNAME)))CMakeLists.txt

$(dir $(abspath $(SNAME)))CMakeLists.txt:
ifneq ($(VERBOSE), )
	echo "cmake_minimum_required(VERSION 3.12)\nproject($(SNAME))\nset(CMAKE_CXX_STANDARD 14)\ninclude_directories($(foreach V,$(INC_DIR) $(CMAKE_INCLUDE_DIRECTORIES),$(if $(patsubst /%,,$V),$(abspath $(PWD)$V),$V)))" > $@
	$(foreach V, $(CLIB), echo "add_subdirectory($(dir $(V)) $(BUILD_DIR))" >> $@;)
	$(foreach V, $(CMAKE_MODULES), echo "add_subdirectory($(V))" >> $@;)
	echo "add_library($(notdir $(SNAME)) $(foreach V,$(TEST_SRCS) $(SRCS), $(if $(patsubst /%,,$V),$(abspath $(PWD)$V),$V)))" >> $@
else
	@$(ECHO) preparing $@
	@echo "cmake_minimum_required(VERSION 3.12)\nproject($(SNAME))\nset(CMAKE_CXX_STANDARD 14)\ninclude_directories($(foreach V,$(INC_DIR) $(CMAKE_INCLUDE_DIRECTORIES),$(if $(patsubst /%,,$V),$(abspath $(PWD)$V),$V)))" > $@
	@$(foreach V, $(CLIB), echo "add_subdirectory($(dir $(V)) $(BUILD_DIR))" >> $@;)
	@$(foreach V, $(CMAKE_MODULES), echo "add_subdirectory($(V))" >> $@;)
	@echo "add_library($(notdir $(SNAME)) $(foreach V,$(TEST_SRCS) $(SRCS), $(if $(patsubst /%,,$V),$(abspath $(PWD)$V),$V)))" >> $@
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
