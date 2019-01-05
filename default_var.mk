MAKEFILES_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
ARG_TEST +=
OBJ_DIR := .obj
TEST_SRCS := test.c
CFLAGS += -Iinc
LD := gcc
PRE_TEST :=
BLACK_LIST_SRCS += cmake-build-debug/
