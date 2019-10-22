$(if $(NAME),,$(error Missing NAME definition))#make sure name is non null
$(if $(filter file line, $(origin NAME)),,$(error Missing NAME definition))#make sure name was activelly set by the user via a makefile or command line

EXTRA_NAMES := $(wordlist 2, $(words $(NAME)), $(NAME))#put extra names in a secondary variable for later processing
SNAME := $(word 1, $(NAME))

LOCAL_MAKEFILE := $(realpath $(firstword $(MAKEFILE_LIST)))#get the path of the CALLING makefile for recursion

CC := gcc
ARFLAGS := r
TEST_SRCS := ./test.c
LD := gcc
AR := ar
PRE_TEST :=
BLACK_LIST_SRCS += cmake-build-debug/ $(foreach V, $(EXTRA_NAMES), $(V)/ )
INC_DIR += inc
FORWARD :=

ifneq ($(VERBOSE), )
FORWARD += VERBOSE=1
ARFLAGS += v
endif

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
ifeq ($(DEBUG), )
ifeq ($(SANITIZE), )
CFLAGS += -O3
endif
endif

include $(MAKEFILES_DIR)/arch.mk

BUILD_ROOT := $(dir $(LOCAL_MAKEFILE))build
BUILD_DIR := $(BUILD_ROOT)/$(SNAME)/$(OS)
BUILD_NAME := $(BUILD_DIR)/$(SNAME)

OBJ_DIR := $(BUILD_DIR)/obj
DEP_DIR := $(BUILD_DIR)/dep

$(foreach V, $(filter $(SNAME)_%, $(.VARIABLES)), $(eval V2 = $(patsubst $(SNAME)_%, %, $(V)))$(if $(filter override, $(origin $(V))), $(eval $(V2) := $($(V))), $(eval $(V2) += $($(V)))))

ifeq ($(SRCS), )
ifeq ($(filter mclean, $(MAKECMDGOALS)), )
ifeq ($(words $(MAKECMDGOALS)), 1)
ifneq ($(VERBOSE), )
include $(BUILD_DIR)/srcs
else
-include $(BUILD_DIR)/srcs
endif
endif
endif
endif

OBJS := $(patsubst %.c, $(OBJ_DIR)/%.o, $(SRCS))
DEPS := $(patsubst %.c, $(DEP_DIR)/%.d, $(SRCS))

CFLAGS += -Wall -Wextra -Werror $(foreach V, $(INC_DIR), -I$(V))
