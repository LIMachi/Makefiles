MAKEFILES_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))#get the directory containing THIS makefile
include $(MAKEFILES_DIR)/vars.mk

.PHONY: all FORCE re
.DEFAULT_GOAL = all

ifneq ($(words $(MAKECMDGOALS)),1)
.PHONY: $(MAKECMDGOALS)
$(MAKECMDGOALS) all:
	@make $@ --no-print-directory -f $(firstword $(MAKEFILE_LIST))
else

ifneq ($(EXTRA_NAMES), )#this block add a new rule to the currently called rule to make the recursion for other names
ifneq ($(MAKECMDGOALS), )
NEXT_COMMANDS := $(filter-out $(SNAME), $(MAKECMDGOALS))
else
NEXT_COMMANDS := $(.DEFAULT_GOAL)
endif
ifneq ($(NEXT_COMMANDS), )
.PHONY: extra_names_recursion#make it phony to always run the rule
extra_names_recursion: #call the parent makefile with the same target, only one name (the one being processed) is removed from the list
	@make --no-print-directory -f $(LOCAL_MAKEFILE) NAME="$(EXTRA_NAMES)" $(NEXT_COMMANDS)
ifneq ($(filter-out $(NAME), $(MAKECMDGOALS)), )
$(filter-out $(NAME), $(MAKECMDGOALS)): extra_names_recursion#add the new rule to the dependencies of the called rule
endif
$(.DEFAULT_GOAL): extra_names_recursion#and for good mesure, also add it to the default rule
endif
endif

all: $(SNAME)

re:
	@make --no-print-directory -f $(LOCAL_MAKEFILE) fclean
	@make --no-print-directory -f $(LOCAL_MAKEFILE) all

$(SNAME): $(BUILD_NAME)
	@cp -f $< $@

include $(MAKEFILES_DIR)/scripts.mk

.PRECIOUS: $(BUILD_DIR)/. $(BUILD_DIR)%/.

$(BUILD_DIR)/.:
ifneq ($(VERBOSE), )
	mkdir -p $@
else
	@$(ECHO) $(SNAME): Building main directory $@
	@mkdir -p $@
endif

$(BUILD_DIR)%/.:
ifneq ($(VERBOSE), )
	mkdir -p $@
else
	@$(ECHO) $(SNAME): Building sub directory $@
	@mkdir -p $@
endif

TARGET_TYPE := $(word 1, $(filter bin lib, $(TARGET_TYPE)))#the following block make sure [the value of target_type is valid, and otherwise use the extention of name to evaluate its type
ifeq ($(TARGET_TYPE), )
ifneq ($(filter .a, $(suffix $(NAME))), )
TARGET_TYPE := lib
else
TARGET_TYPE := bin
endif
endif

ifeq ($(TARGET_TYPE), bin)
include $(MAKEFILES_DIR)/bin.mk
else
include $(MAKEFILES_DIR)/lib.mk
endif

ifneq ($(filter $(EXTRA_NAMES), $(MAKECMDGOALS)), )
ifeq ($(filter $(SNAME), $(MAKECMDGOALS)), )
$(filter $(EXTRA_NAMES), $(MAKECMDGOALS)): ;
endif
endif

FORCE:

ifneq ($(filter clean fclean mclean, $(MAKECMDGOALS)), )
include $(MAKEFILES_DIR)/clean.mk
endif

endif
