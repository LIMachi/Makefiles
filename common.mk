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
$(info no SRCS set, including .srcs)
include .srcs
endif

OBJS := $(patsubst %.c, $(OBJ_DIR)/%.o, $(SRCS))

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

$(OBJ_DIR)/.:
	@echo Preparing $(OBJ_DIR) to hold object files
	@mkdir -p $@

$(OBJ_DIR)%/.:
	@echo Preparing subdir $(patsubst %/., %, $@) to hold object files
	@mkdir -p $@

re: | fclean all

FORCE:

%.h:

%: FORCE
	@#echo $@