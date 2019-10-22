$(if $(NAME),,$(error Missing NAME definition))#make sure name is non null
$(if $(filter file line, $(origin NAME)),,$(error Missing NAME definition))#make sure name was activelly set by the user via a makefile or command line

EXTRA_NAMES := $(wordlist 2, $(words $(NAME)), $(NAME))#put extra names in a secondary variable for later processing
SNAME := $(word 1, $(NAME))

LOCAL_MAKEFILE := $(realpath $(firstword $(MAKEFILE_LIST)))#get the path of the CALLING makefile for recursion
MAKEFILES_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))#get the directory containing THIS makefile

include $(MAKEFILES_DIR)/arch.mk

BUILD_ROOT := $(dir $(LOCAL_MAKEFILE))build

BUILD_DIR := $(BUILD_ROOT)/$(SNAME)/$(OS)

BUILD_NAME := $(BUILD_DIR)/$(SNAME)

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

$(foreach V, $(filter $(SNAME)_%, $(.VARIABLES)), $(eval V2 = $(patsubst $(SNAME)_%, %, $(V)))$(if $(filter override, $(origin $(V))), $(eval $(V2) := $($(V))), $(eval $(V2) += $($(V)))))

LD := clang
CFLAGS += $(foreach V, $(INC_DIR), -I$(V)) -Wall -Wextra -Werror

all: $(SNAME)

re:
	@make --no-print-directory -f $(LOCAL_MAKEFILE) fclean
	@make --no-print-directory -f $(LOCAL_MAKEFILE) all

$(SNAME): $(BUILD_NAME)
	@cp -f $< $@

include $(MAKEFILES_DIR)/scripts.mk

ifeq ($(SRCS), )
ifneq ($(VERBOSE), )
$(info $(LOCAL_MAKEFILE): no SRCS set, including/generating $(BUILD_DIR)/srcs)
include $(BUILD_DIR)/srcs
else
-include $(BUILD_DIR)/srcs #might silently fail
endif
endif

#ifeq ($(SRCS), )
#$(error SRCS is not defined)
#endif

OBJ_DIR := $(BUILD_DIR)/obj
DEP_DIR := $(BUILD_DIR)/dep
OBJS := $(patsubst %.c, $(OBJ_DIR)/%.o, $(SRCS))
DEPS := $(patsubst %.c, $(DEP_DIR)/%.d, $(SRCS))

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
